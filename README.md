# OpenVPN

Best free VPN server for Docker

### Start environment

```
$ docker-compose up -d
```

### Configure VPN Passphrase

```
$ docker-compose run --rm openvpn set_passphrase 
```

## Clients

### Add New Client

```
docker-compose exec openvpn add_client CLIENTNAME 
```

### Retrieve Client Configuration

```
docker-compose exec openvpn get_client CLIENTNAME > CLIENTNAME.ovpn
```

### Remove Client Configuration
```
$ docker-compose exec openvpn ovpn_revokeclient $CLIENTNAME remove
```

## Caveat

Ubuntu clients need the following installed

```
# apt-get install openvpn-systemd-resolved
```

And should have a config file generated using the following command

```
$ docker-compose exec openvpn get_client CLIENTNAME --ubuntu > CLIENTNAME.ovpn
```

## Hotfix

```
push "route 0.0.0.0 128.0.0.0 net_gateway"
push "route 128.0.0.0 128.0.0.0 net_gateway"
```
