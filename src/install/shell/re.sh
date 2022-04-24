cp /vagrant/src/install/nginx/conf /etc/nginx/http.d/default.conf
cp /vagrant/src/install/nginx/backend /etc/nginx/extra/backend.conf
rc-service nginx restart