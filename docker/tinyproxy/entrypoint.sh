#!/usr/bin/bash
cp /etc/tinyproxy/tinyproxy.conf /workspace/tinyproxy.conf
if [ -n "$TINYPROXY_PASSWORD" ]; then
    echo "BasicAuth $TINYPROXY_USER $TINYPROXY_PASSWORD" >> /workspace/tinyproxy.conf
fi 
tinyproxy -d -c /workspace/tinyproxy.conf