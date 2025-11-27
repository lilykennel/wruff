use tracing::info;

#[dotenvy::load(required = false)]
#[tokio::main]
async fn main() -> std::io::Result<()> {
    tracing_subscriber::fmt::init();
    info!("Hello, world!");

    Ok(())
}
