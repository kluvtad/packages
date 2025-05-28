# FROM alpine:3.21.3

# RUN apk add --no-cache \
#         curl bash
# RUN apk add --no-cache \
#         dotnet9-sdk aspnetcore9-runtime dotnet9-runtime \
#         gcc libtool

# RUN ln -s /lib/libc.musl-x86_64.so.1 /lib/ld-linux-x86-64.so.2

# RUN adduser -h /home/runner -D runner -s /bin/bash 

FROM debian:12.11-slim

RUN apt update && apt install -y curl && apt clean && rm -rf /var/lib/apt/lists/*

RUN adduser --home /home/runner --disabled-password --shell /bin/bash --gecos GECOS runner

USER runner

WORKDIR /app

RUN curl -L https://github.com/actions/runner/releases/download/v2.324.0/actions-runner-linux-x64-2.324.0.tar.gz -o actions-runner-linux-x64-2.324.0.tar.gz && \
    echo "e8e24a3477da17040b4d6fa6d34c6ecb9a2879e800aa532518ec21e49e21d7b4  actions-runner-linux-x64-2.324.0.tar.gz" | sha256sum -c

RUN tar xzf actions-runner-linux-x64-2.324.0.tar.gz && rm actions-runner-linux-x64-2.324.0.tar.gz

USER root
RUN ./bin/installdependencies.sh

USER runner

ADD ./entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]



