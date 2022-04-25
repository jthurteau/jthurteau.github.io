##
# PHP8 FPM Dockerfile - jthurtea
# development container that mounts the repo
# LICENSE & DISCLAIMERS https://github.com/jthurteau/jthurteau.github.io/

FROM php:fpm-alpine3.15 as builder
ARG PRIMARY_APPLICATION
ENV PRIMARY_APPLICATION=${PRIMARY_APPLICATION}
##
# deploy option 2
VOLUME ["/opt/application/${PRIMARY_APPLICATION}"]
VOLUME ["/opt/project"]
RUN mkdir /var/www/application \
  && mkdir -p /opt/application/vendor \
  && echo what $PRIMARY_APPLICATION \
  && ln -s /opt/application/$PRIMARY_APPLICATION /var/www/application/$PRIMARY_APPLICATION \
  && rmdir /var/www/html \
  && ln -s /var/www/application/$PRIMARY_APPLICATION/public /var/www/html \
  && apk add git \
  # https://hub.docker.com/_/php
  # https://github.com/mlocati/docker-php-extension-installer
  && apk add openldap-dev \
    #&& docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ 
    && docker-php-ext-install ldap
# Docker no likey cloning into /opt/application/vendor in the same RUN that created it...
RUN git clone https://github.com/jthurteau/saf.git /opt/application/vendor/saf \
  && mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini" \
  && rm /usr/local/etc/php-fpm.d/docker.conf
COPY php-fpm/debug.conf /usr/local/etc/php-fpm.d/docker-local.conf

WORKDIR /var/www/html
# CMD []
# ENTRYPOINT []

# Flag the PHP-FPM as Exposed :
EXPOSE 9000