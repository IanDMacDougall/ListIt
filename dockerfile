# Building
FROM rust:1.88-alpine AS builder

RUN apk add --no-cache musl-dev pkgconfig openssl-dev

WORKDIR /app

COPY Cargo.toml Cargo.lock ./
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release

COPY src ./src
RUN touch src/main.rs
RUN cargo build --release

# Running

FROM alpine:3.19

RUN apk add --no-cache openssl ca-certificates

WORKDIR /app

COPY --from=builder /app/target/release/list_it .
COPY templates ./templates
COPY static ./static

EXPOSE ${PORT}

CMD ["./list_it"]