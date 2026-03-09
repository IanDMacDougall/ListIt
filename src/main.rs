use axum::{Router, response::Html, routing::get};
use dotenvy::dotenv;
use sqlx::PgPool;
use std::env;
use tracing::info;
use tracing_subscriber::EnvFilter;
use tower_http::services::ServeDir;

#[tokio::main]
async fn main() {
    // Load .env file
    dotenv().ok();

    // Set up logging
    tracing_subscriber::fmt()
        .with_env_filter(EnvFilter::from_default_env())
        .init();

    // Connect to database
    let database_url = env::var("DATABASE_URL")
        .expect("DATABASE_URL must be set");

    print!("database url is: {}",database_url);
    
    let pool = PgPool::connect(&database_url)
        .await
        .expect("Failed to connect to database");

    info!("Connected to database");

    // Define Routes
    let app: Router<()> = Router::new()
        .route("/health", get(health_check))
        .route("/", get(index))
        .nest_service("/static", ServeDir::new("static"))
        .with_state(pool);


    // set local address and port
    let port = env::var("PORTS")
        .unwrap_or_else(|_| "3000".to_string());

    let addr = format!("0.0.0.0:{port}");


    let listener = tokio::net::TcpListener::bind(&addr)
        .await
        .unwrap();


    // Start the HTTP server

    info!("Listening on http://{}", addr);

    axum::serve(listener, app).await.unwrap();

}


// The routes

async fn health_check() -> &'static str {
    "OK"
}

async fn index() -> Html<String> {
    let html_site = tokio::fs::read_to_string("templates/index.html")
        .await
        .expect("Could not read index.html");
    Html(html_site.to_string())
}