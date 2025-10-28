FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y software-properties-common iputils-ping telnet curl python3-pip 

# ansible
RUN add-apt-repository -y --update ppa:ansible/ansible && apt install -y ansible=5.10.0-1ppa~focal

RUN ansible-galaxy collection install community.docker community.postgresql

RUN pip3 install psycopg2-binary

ENV ANSIBLE_HOST_KEY_CHECKING=False

WORKDIR /workspace