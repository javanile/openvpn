
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
	rm -fr ./openvpn/
	docker-compose up -d --force-recreate openvpn
	docker-compose run --rm openvpn set_passphrase
	docker-compose run --rm openvpn add_client test
	docker-compose run --rm openvpn get_client test > test.ovpn
	docker-compose logs -f openvpn

test-set_passphrase: build
	docker-compose run --rm openvpn set_passphrase

test-add_client: build
	docker-compose run --rm openvpn add_client test

test-get_client: build
	docker-compose run --rm openvpn get_client test > test.ovpn

test-get_client_ubuntu: build
	docker-compose run --rm openvpn get_client test ubuntu > test.ovpn

test-remove_client: build
	docker-compose run --rm openvpn remove_client test > test.ovpn

test-connect:
	sudo openvpn --config test.ovpn

test-bash: build
	docker-compose up -d --force-recreate openvpn
	docker-compose exec openvpn bash
