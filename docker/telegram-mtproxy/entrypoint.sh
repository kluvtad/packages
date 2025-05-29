#!/bin/bash
adduser --home /home/${ACCESS_KEY} --disabled-password --shell /bin/bash --gecos GECOS ${ACCESS_KEY}

mtproto-proxy --slaves 1 --user ${ACCESS_KEY} -p 8080 -H 8443 --mtproto-secret ${SECRET_KEY} --aes-pwd /proxy-secret /proxy-multi.conf