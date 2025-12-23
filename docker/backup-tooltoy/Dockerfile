FROM alpine:3.23.2

RUN apk add --no-cache curl python3 py3-pip bash

# Python venv
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
COPY ./requirements.txt /requirements.txt
RUN pip install --no-cache-dir -r /requirements.txt

# Taskfile
# TASK_X_ENV_PRECEDENCE=1 - https://taskfile.dev/experiments/env-precedence
ENV TASK_X_ENV_PRECEDENCE=1
RUN curl --location https://taskfile.dev/install.sh | sh /dev/stdin -d v3.45.5 -b /usr/local/bin

# Gcloud
# https://docs.cloud.google.com/sdk/docs/install-sdk#linux
RUN curl -o /tmp/google-cloud-cli-linux-x86_64.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz && \
    tar -xf /tmp/google-cloud-cli-linux-x86_64.tar.gz -C /usr/lib/ && \
    /usr/lib/google-cloud-sdk/install.sh --quiet && \
    rm /tmp/google-cloud-cli-linux-x86_64.tar.gz

ENV PATH="/usr/lib/google-cloud-sdk/bin:${PATH}"

RUN gcloud components install gke-gcloud-auth-plugin --quiet

# minio
RUN curl https://dl.min.io/client/mc/release/linux-amd64/mc.RELEASE.2025-08-13T08-35-41Z -o /usr/bin/mc && chmod +x /usr/bin/mc

# psql
RUN apk add --no-cache postgresql17-client

# kubectl
# https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
RUN curl -Lo /usr/bin/kubectl "https://dl.k8s.io/release/v1.35.0/bin/linux/amd64/kubectl" && chmod +x /usr/bin/kubectl

# yq
RUN curl -Lo /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 && chmod a+x /usr/local/bin/yq

COPY . /workspace
WORKDIR /workspace

ENTRYPOINT ["task", "run"]
CMD [ ]