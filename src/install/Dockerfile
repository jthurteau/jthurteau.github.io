#
# PHP8 FPM Dockerfile
# for ncsulibraries - jthurtea
# development container that mounts the repo

FROM php:fpm-alpine3.15 as builder
ARG PRIMARY_APPLICATION
ENV PRIMARY_APPLICATION=${PRIMARY_APPLICATION}
##
# deploy option 2
VOLUME ["/opt/application/${PRIMARY_APPLICATION}"]
RUN mkdir /var/www/application \
  && mkdir -p /opt/application/vendor \
  && mkdir /opt/application/library \
  && echo what $PRIMARY_APPLICATION \
  && ln -s /opt/application/$PRIMARY_APPLICATION /var/www/application/$PRIMARY_APPLICATION \
  && rmdir /var/www/html \
  && ln -s /var/www/application/$PRIMARY_APPLICATION/public /var/www/html \
  # https://hub.docker.com/_/php
  # https://github.com/mlocati/docker-php-extension-installer
  && apk add git \
  && apk add openldap-dev \
    #&& docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ 
    && docker-php-ext-install ldap
# Docker no likey cloning into /opt/application/vendor in the same RUN that created it...
RUN git clone --branch php5 https://github.com/jthurteau/saf.git /opt/application/vendor/saf \
  && git clone https://github.com/zendframework/zf1.git /opt/application/vendor/zend \
  && ln -s /opt/application/vendor/saf /opt/application/library/Saf \
  && ln -s /opt/application/vendor/zend/library/Zend /opt/application/library/Zend 
  # \
  #&& mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
##

# COPY src/install/php-fpm/debug.conf /usr/local/etc/php-fpm.d/zz-z.conf

WORKDIR /var/www/html

# CMD []
# ENTRYPOINT []

# Flag the PHP-FPM as Exposed :
EXPOSE 9000