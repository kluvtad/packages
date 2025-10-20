FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y curl iputils-ping telnet python3 python3-pip

RUN ln -s /usr/bin/python3 /usr/bin/python


# Taskfile
# TASK_X_ENV_PRECEDENCE=1 - https://taskfile.dev/experiments/env-precedence
ENV TASK_X_ENV_PRECEDENCE=1
RUN curl --location https://taskfile.dev/install.sh | sh /dev/stdin -d v3.41.0

# kubectl
# https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
RUN curl -Lo /usr/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && chmod +x /usr/bin/kubectl

COPY requirements.txt /requirements.txt
RUN pip install -r /requirements.txt

WORKDIR /workspace

COPY . .

ENTRYPOINT [ "python", "main.py" ]
CMD [ ]