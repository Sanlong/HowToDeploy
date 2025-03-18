#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import argparse
import requests
import json
import os
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry
from tqdm import tqdm

# 设置控制台编码
os.environ["PYTHONIOENCODING"] = "utf-8"

def merge_layers_into_tar(image_name, manifest, digest, output_dir):
    import tarfile
    from tempfile import TemporaryDirectory
    import signal
    import sys
    
    def handle_interrupt(signum, frame):
        print('\n中断信号接收，正在清理临时资源...')
        sys.exit(1)
    
    signal.signal(signal.SIGINT, handle_interrupt)
    
    try:
        with TemporaryDirectory() as tmpdir:
            layer_dirs = []
            
            for layer in manifest['layers']:
                layer_hash = layer['digest'].split(':')[1]
                src_file = os.path.join(output_dir, f"{image_name}_{layer_hash}.tar.gz")
                layer_dir = os.path.join(tmpdir, layer_hash)
                os.makedirs(layer_dir, exist_ok=True)
                
                try:
                    with tarfile.open(src_file, 'r:gz') as tar:
                        tar.extractall(path=layer_dir, filter='data')
                except (KeyboardInterrupt, SystemExit):
                    print('\n提取中断，正在清理...')
                    raise
                except Exception as e:
                    print(f'提取错误: {e}')
                    continue
                
                layer_dirs.append({
                    "Config": f"{layer_hash}.json",
                    "Layers": [os.path.join(layer_hash, "layer.tar")]
                })
        
        merged_filename = os.path.join(output_dir, f"{image_name}_merged.tar")
        with tarfile.open(merged_filename, 'w') as tar:
            for root, _, files in os.walk(tmpdir):
                for file in files:
                    full_path = os.path.join(root, file)
                    arcname = os.path.relpath(full_path, tmpdir)
                    tar.add(full_path, arcname=arcname)
    
    return merged_filename


def main():
    parser = argparse.ArgumentParser(description='下载Docker镜像层')
    parser.add_argument('--image', type=str, default='haproxy', help='镜像名称')
    parser.add_argument('--output', type=str, default=os.path.abspath('./layers'), help='输出目录路径')
    parser.add_argument('--digest', type=str, required=True, help='镜像digest')
    args = parser.parse_args()

    session = requests.Session()
    retries = Retry(total=3, backoff_factor=1)
    session.mount('https://', HTTPAdapter(max_retries=retries))

    token_url = f'https://auth.docker.io/token?service=registry.docker.io&scope=repository:library/{args.image}:pull'
    token = session.get(token_url).json()['token']

    headers = {
        'Authorization': f'Bearer {token}',
        'Accept': 'application/vnd.docker.distribution.manifest.v2+json'
    }

    manifest_url = f'https://registry-1.docker.io/v2/library/{args.image}/manifests/{args.digest}'
    response = session.get(manifest_url, headers=headers)
    response.raise_for_status()
    manifest = response.json()

    if manifest.get('mediaType') == 'application/vnd.oci.image.index.v1+json':
        for manifest_entry in manifest.get('manifests', []):
            if manifest_entry.get('platform', {}).get('architecture') == 'amd64':
                new_digest = manifest_entry['digest']
                manifest_url = f'https://registry-1.docker.io/v2/library/{args.image}/manifests/{new_digest}'
                response = session.get(manifest_url, headers=headers)
                response.raise_for_status()
                manifest = response.json()
                break

    os.makedirs(args.output, exist_ok=True)

    for layer in manifest['layers']:
        blob_digest = layer.get('digest', '')
        digest_hash = blob_digest.split(':')[1]
        filename = os.path.join(args.output, f"{args.image}_{digest_hash}.tar.gz")

        blob_url = f'https://registry-1.docker.io/v2/library/{args.image}/blobs/{blob_digest}'
        with session.get(blob_url, headers=headers, stream=True) as r:
            r.raise_for_status()
            with open(filename, 'wb') as f:
                for chunk in r.iter_content(chunk_size=8192):
                    if chunk:
                        f.write(chunk)

    merged_tar = merge_layers_into_tar(
        image_name=args.image,
        manifest=manifest,
        digest=args.digest,
        output_dir=args.output
    )



if __name__ == '__main__':
    main()

