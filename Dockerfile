FROM rust as builder
WORKDIR /src

RUN apt-get update && apt-get install -y libavahi-compat-libdnssd-dev libclang-dev

RUN git clone https://github.com/jkcoxson/netmuxd .
# Working commit
RUN git checkout a3dbd87da4e651cf5e0a74850bb4903a910384dd

RUN sed -i 's/, path = "..\/zeroconf-rs\/zeroconf", optional = true//g' Cargo.toml
RUN sed -i 's/, path = "..\/mdns"//g' Cargo.toml

RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,sharing=private,target=/src/target \
    cat Cargo.toml && \
    RUSTC_BOOTSTRAP=1 cargo -Z sparse-registry build --release && \
    cp target/release/netmuxd /tmp/
# --features zeroconf

FROM ubuntu
#RUN apt-get update && apt-get install -y libavahi-compat-libdnssd
COPY --from=builder /tmp/netmuxd /bin/
CMD ["/bin/netmuxd"]
