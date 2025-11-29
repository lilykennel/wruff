use tracing::info;

#[dotenvy::load(required = false)]
#[tokio::main]
async fn main() -> std::io::Result<()> {
    // TODO: set up file logging w/ https://crates.io/crates/tracing-appender
    tracing_subscriber::fmt::init();
    info!("Hello, world!");

    Ok(())
}
