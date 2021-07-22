FROM kylemanna/openvpn:2.4
LABEL mantainer="Francesco Bianco <bianco@javanile.org>"

## Default environment variables
ENV OVPN_DNS=0 \
    OVPN_DEFROUTE=0 \
    OVPN_DISABLE_PUSH_BLOCK_DNS=1

RUN apk update && apk --no-cache add socat

COPY ./set_passphrase.sh /usr/bin/set_passphrase

COPY ./add_client.sh /usr/bin/add_client
COPY ./get_client.sh /usr/bin/get_client
COPY ./remove_client.sh /usr/bin/remove_client

COPY ./docker-entrypoint.sh /usr/bin/docker-entrypoint

CMD ["docker-entrypoint"]
