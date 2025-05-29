#!/bin/bash
adduser --home /home/${ACCESS_KEY} --disabled-password --shell /bin/bash --gecos GECOS ${ACCESS_KEY}

mtproto-proxy --port 8443 --slaves 1 --user ${ACCESS_KEY} --http-ports 8080 --mtproto-secret ${SECRET_KEY} --aes-pwd /proxy-secret /proxy-multi.conf