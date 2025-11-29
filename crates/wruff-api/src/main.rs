use axum::{routing::get, Json, Router};
use tracing::info;

use crate::error::ApiError;

mod error;

#[derive(serde::Serialize, serde::Deserialize, Debug)]
struct ApplicationInfo {
    pub name: String,
    pub version: String,
    pub message: String,
}

#[dotenvy::load(required = false)]
#[tokio::main]
async fn main() -> Result<(), ApiError> {
    // TODO: set up file logging w/ https://crates.io/crates/tracing-appender
    tracing_subscriber::fmt::init();
    info!("awruff!!");

    // wruff::wruff();

    let app = Router::new().route("/", get(root));

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await?;
    axum::serve(listener, app).await?;

    Ok(())
}

async fn root() -> Result<Json<ApplicationInfo>, ApiError> {
    Ok(Json(ApplicationInfo {
        name: "wruff-api".to_string(),
        version: env!("CARGO_PKG_VERSION").to_string(),
        message: "hi :3".to_string(),
    }))
}
