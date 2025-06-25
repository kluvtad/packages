FROM python:3.12.0-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt-get install -y \
    wget iputils-ping procps git-all curl jq bash telnet dnsutils \
    apt-transport-https ca-certificates gnupg lsb-release

# mysql
RUN apt-get install -y default-mysql-client

# psql
# https://www.postgresql.org/download/linux/ubuntu/
RUN apt-get install -y postgresql-common
RUN install -d /usr/share/postgresql-common/pgdg
RUN curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc https://www.postgresql.org/media/keys/ACCC4CF8.asc
RUN sh -c 'echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN apt update && apt-get install -y postgresql-client-16

# redis-cli
# https://redis.io/docs/latest/operate/oss_and_stack/install/install-redis/install-redis-on-linux/
RUN curl -fsSL https://packages.redis.io/gpg | gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/redis.list
RUN apt-get update && apt-get install -y redis-tools

# kubectl
# https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
RUN curl -Lo /usr/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && chmod +x /usr/bin/kubectl

# http-logger
COPY ./requirements.txt /requirements.txt
RUN pip install -r /requirements.txt

COPY . /workspace

WORKDIR /workspace
ENTRYPOINT [ "uvicorn", "app:app", "--host=0.0.0.0", "--port=8000" , "--workers=1"]
CMD [ ]
