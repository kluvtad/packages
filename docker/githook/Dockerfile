FROM python:3.9.20

RUN apt-get update -y &&  apt-get install -y git wget openssh-client
RUN apt-get install -y git wget openssh-client
RUN wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 && chmod a+x /usr/local/bin/yq

COPY ./requirements.txt /requirements.txt
WORKDIR /workspace
RUN pip3 install -r /requirements.txt
COPY . /workspace

ENTRYPOINT [ "/workspace/entrypoint.sh" ]