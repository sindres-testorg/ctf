FROM rust:1.49.0-buster AS build

RUN apt-get -y update && apt-get -y install pkg-config libssl-dev curl

# Downloading this here because we don't have wget in the final image
RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64
RUN chmod +x /usr/local/bin/dumb-init


WORKDIR /usr/src/app

RUN mkdir -p src && echo "fn main() {}" > src/main.rs

COPY Cargo.lock .
COPY Cargo.toml .

RUN cargo build --release

COPY . .
RUN touch src/main.rs
RUN cargo build --release

FROM debian:buster-slim AS release

RUN apt-get -y update && apt-get -y install pkg-config libssl1.1 ca-certificates libpq5 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=build /usr/src/app/target/release/ctf .
COPY --from=build /usr/local/bin/dumb-init /usr/local/bin/dumb-init

RUN useradd -ms /bin/bash ctf
USER ctf

ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]
CMD ["/app/ctf"]
EXPOSE 3030
