
push: build
	git add .
	git commit -am "publish" || true
	git push
	docker push javanile/openvpn

build:
	chmod +x *.sh
	docker build -t javanile/openvpn .
	docker-compose build openvpn

test: build
	docker-compose down -v
	docker-compose up --force-recreate openvpn

test-set_passphrase: build
	docker-compose run --rm openvpn set_passphrase

test-add_client: build
	docker-compose run --rm openvpn add_client test

test-get_client: build
	docker-compose run --rm openvpn get_client test > test.ovpn

test-remove_client: build
	docker-compose run --rm openvpn remove_client test > test.ovpn
