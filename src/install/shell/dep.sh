apk add bash
apk add coreutils
apk add curl
apk add nano
apk add nginx
# https://wiki.alpinelinux.org/wiki/Nginx
adduser -D -g 'www' www
cp /vagrant/src/install/nginx/conf /etc/nginx/http.d/default.conf
ln -s /vagrant/podvan/$1 /opt/project
mkdir /var/www/error
cp /vagrant/src/install/nginx/404.html /var/www/error/404.html
cp /vagrant/src/install/nginx/50x.html /var/www/error/50x.html
cp /vagrant/src/install/nginx/test.html /var/www/localhost/htdocs/test.html
chown -R :www-data /var/www/error
rc-service nginx start
rc-update add nginx default
apk add podman
# https://wiki.alpinelinux.org/wiki/Podman
rc-update add cgroups
rc-service cgroups start