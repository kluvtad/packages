FROM debian:12.11-slim

RUN apt update && apt install -y curl build-essential && apt clean && rm -rf /var/lib/apt/lists/*

RUN curl -L "https://github.com/tinyproxy/tinyproxy/releases/download/1.11.2/tinyproxy-1.11.2.tar.gz" | tar xz -C /tmp && \
    cd /tmp/tinyproxy-1.11.2 && ./configure --sysconfdir=/etc && \
    make && make install && \
    rm -rf /tmp/tinyproxy-1.11.2

# Create a user for the GitHub runner
RUN adduser --home /home/runner --disabled-password --shell /bin/bash --gecos GECOS nonroot
USER nonroot

COPY ./entrypoint.sh /entrypoint.sh

WORKDIR /workspace
ENTRYPOINT [ "/entrypoint.sh" ]