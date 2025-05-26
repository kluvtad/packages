FROM debian:12.11 AS build

RUN apt update
RUN apt install -y git curl build-essential libssl-dev zlib1g-dev

WORKDIR /src
RUN curl -s https://core.telegram.org/getProxySecret -o /proxy-secret && \
    curl -s https://core.telegram.org/getProxyConfig -o /proxy-multi.conf 
RUN git clone https://github.com/TelegramMessenger/MTProxy

WORKDIR /src/MTProxy
RUN sed -i 's/^\(CFLAGS *=.*\)$/\1 -fcommon/' Makefile && sed -i 's/^\(LDFLAGS *=.*\)$/\1 -fcommon/' Makefile
RUN make

ENV PATH="/src/MTProxy/objs/bin:$PATH"

WORKDIR /

ENTRYPOINT [ "mtproto-proxy" ]
CMD [ "--port", "443", "--slaves", "1", \
    "--user", "${ACCESS_KEY}", \
    "--secret", "${SECRET_KEY}", \
    "--aes-pwd", "/proxy-secret", \
    "/proxy-multi.conf"]
