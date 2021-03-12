#
# Dockerfile for mantisbt
#

FROM php:8.0.3-apache
MAINTAINER kev <kenny.yc.chen@fubon.com>
ENV MANTIS_VER 2.24.4
ENV SQLSRV_VER 5.9.0
ENV MANTIS_URL https://sourceforge.net/projects/mantisbt/files/mantis-stable/${MANTIS_VER}/mantisbt-${MANTIS_VER}.tar.gz
ENV MANTIS_FILE mantisbt.tar.gz
RUN apt-get update && apt-get install -y locales unixodbc libgss3 odbcinst vim \
    devscripts debhelper dh-exec dh-autoreconf libreadline-dev libltdl-dev \
    tdsodbc unixodbc-dev wget unzip apt-transport-https \
    libfreetype6-dev libmcrypt-dev libjpeg-dev libpng-dev\
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-install pdo \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
RUN apt-get update \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install --yes --no-install-recommends msodbcsql17 mssql-tools \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*
RUN pecl install WINCACHE-1.3.7.12 pdo_sqlsrv-${SQLSRV_VER} sqlsrv-${SQLSRV_VER} \
    && docker-php-ext-enable pdo_sqlsrv sqlsrv
RUN \
    apt-get update && \
    apt-get install libldap2-dev -y && \
    rm -rf /var/lib/apt/lists/* && \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
    docker-php-ext-install ldap
RUN set -xe \
    && curl -fSL ${MANTIS_URL} -o ${MANTIS_FILE} \
    && tar -xz --strip-components=1 -f ${MANTIS_FILE} \
    && rm ${MANTIS_FILE} \
    && chown -R www-data:www-data .
RUN set -xe \
    && ln -sf /usr/share/zoneinfo/Asia/Taipei /etc/localtime \
    && echo 'date.timezone = "Asia/Taipei"' > /usr/local/etc/php/php.ini
