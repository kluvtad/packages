FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y curl iputils-ping telnet \
                apt-transport-https ca-certificates gnupg lsb-release jq

# Taskfile
# TASK_X_ENV_PRECEDENCE=1 - https://taskfile.dev/experiments/env-precedence
ENV TASK_X_ENV_PRECEDENCE=1
RUN curl --location https://taskfile.dev/install.sh | sh /dev/stdin -d v3.45.5 -b /usr/local/bin

# https://cloud.google.com/sdk/docs/install#deb
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg

RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

RUN apt-get update && apt-get install -y google-cloud-cli google-cloud-cli-gke-gcloud-auth-plugin

# minio
RUN curl https://dl.min.io/client/mc/release/linux-amd64/mc -o /usr/bin/mc && chmod +x /usr/bin/mc

# psql
# https://www.postgresql.org/download/linux/ubuntu/
RUN apt-get install -y postgresql-common
RUN install -d /usr/share/postgresql-common/pgdg
RUN curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc https://www.postgresql.org/media/keys/ACCC4CF8.asc
RUN sh -c 'echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN apt update && apt-get install -y postgresql-client-17

# kubectl
# https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
RUN curl -Lo /usr/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && chmod +x /usr/bin/kubectl

COPY . /workspace
WORKDIR /workspace

ENTRYPOINT ["task", "run"]
CMD [ ]