use std::time::Duration;

use warp::Filter;

#[tokio::main]
async fn main() {
    // Match any request and return hello world!
    let routes = warp::any().map(|| "Hello, World!");

    tokio::spawn(async {
        loop {
            println!(
                "{}",
                std::env::var("THE_SECRET").unwrap_or_else(|err| err.to_string())
            );
            tokio::time::sleep(Duration::from_secs(60)).await;
        }
    });

    warp::serve(routes).run(([0, 0, 0, 0], 3030)).await;
}
