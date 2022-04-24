# https://hub.docker.com/_/php
echo building $1
podman build -t php-fpm /vagrant/src/install --build-arg PRIMARY_APPLICATION=$1
podman run -d -p 8090:9000 --mount type=bind,src=/vagrant,dst=/opt/application/$1,ro=true php-fpm