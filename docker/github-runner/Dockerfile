FROM debian:12.11-slim

RUN apt update && apt install -y curl git jq && apt clean && rm -rf /var/lib/apt/lists/*

# Install yq
RUN curl -L "https://github.com/mikefarah/yq/releases/download/v4.45.4/yq_linux_amd64" -o /usr/bin/yq && \
    chmod +x /usr/bin/yq

# Install kubectl, helm
RUN curl -L "https://dl.k8s.io/release/v1.33.1/bin/linux/amd64/kubectl" -o /usr/bin/kubectl && \
    chmod +x /usr/bin/kubectl
RUN curl -L "https://get.helm.sh/helm-v3.18.1-linux-amd64.tar.gz" | tar xz -C /usr/bin --strip-components=1 linux-amd64/helm && \
    chmod +x /usr/bin/helm

# Create a user for the GitHub runner
RUN adduser --uid 1234 --home /home/runner --disabled-password --shell /bin/bash --gecos GECOS runner
USER runner

RUN helm plugin install https://github.com/databus23/helm-diff

# Setup the GitHub Actions runner
WORKDIR /src
RUN curl -L https://github.com/actions/runner/releases/download/v2.324.0/actions-runner-linux-x64-2.324.0.tar.gz -o actions-runner-linux-x64-2.324.0.tar.gz && \
    echo "e8e24a3477da17040b4d6fa6d34c6ecb9a2879e800aa532518ec21e49e21d7b4  actions-runner-linux-x64-2.324.0.tar.gz" | sha256sum -c

RUN tar xzf actions-runner-linux-x64-2.324.0.tar.gz && rm actions-runner-linux-x64-2.324.0.tar.gz

USER root
RUN ./bin/installdependencies.sh

USER runner
ADD ./entrypoint.sh /entrypoint.sh

WORKDIR /workspace
ENTRYPOINT [ "/entrypoint.sh" ]