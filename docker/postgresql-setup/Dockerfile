FROM alpine/ansible:2.18.6

RUN ansible-galaxy collection install community.docker community.postgresql

RUN apk add py3-pip

RUN pip install --break-system-packages psycopg2-binary

USER nobody

COPY . /workspace

WORKDIR /workspace

ENTRYPOINT ["/workspace/entrypoint.sh"]
