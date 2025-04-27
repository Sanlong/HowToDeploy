fn main() {
    println!("Hello, Rust!");
    
    // 计算斐波那契数列
    let n = 10;
    println!("斐波那契数列前{}项:", n);
    
    for i in 0..n {
        println!("{}: {}", i, fibonacci(i));
    }
}

fn fibonacci(n: u32) -> u32 {
    match n {
        0 => 0,
        1 => 1,
        _ => fibonacci(n - 1) + fibonacci(n - 2)
    }
}