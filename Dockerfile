FROM kylemanna/openvpn
LABEL mantainer="Francesco Bianco <bianco@javanile.org>"

#RUN apk update && apk --no-cache add ufw ip6tables

COPY ./set_passphrase.sh /usr/bin/set_passphrase

COPY ./add_client.sh /usr/bin/add_client
COPY ./get_client.sh /usr/bin/get_client
COPY ./remove_client.sh /usr/bin/remove_client

COPY ./docker-entrypoint.sh /usr/bin/docker-entrypoint

CMD ["docker-entrypoint"]
