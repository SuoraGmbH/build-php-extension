FROM alpine:latest

RUN apk add --no-cache \
    autoconf \
    bash \
    build-base \
    bzip2-dev \
    curl-dev \
    gdb \
    libxml2-dev \
    linux-headers \
    oniguruma-dev \
    pkgconf \
    sqlite-dev \
    valgrind

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

ARG PHP_TARBALL_NAME
ARG ADDITIONAL_PHP_CONFIG_ARGS

RUN mkdir -p /opt/php-src && \
    wget "https://www.php.net/distributions/${PHP_TARBALL_NAME}" -O - | tar xJC /opt/php-src/ --strip-components 1 && \
    cd /opt/php-src && \
    ./configure \
        --enable-fpm  \
        --enable-mbstring  \
        --enable-pdo  \
        --enable-soap  \
        --with-bz2 \
        --with-curl  \
        --with-mysqli  \
        --with-openssl  \
        --with-pdo-mysql  \
        --with-pdo-sqlite  \
        --with-zlib \
        --without-pear  \
        ${ADDITIONAL_PHP_CONFIG_ARGS} && \
    make -j$(( $(getconf _NPROCESSORS_ONLN) + 1 )) && \
    make install

COPY scripts/ /usr/local/bin/

ARG EXTENSION_CFLAGS

ENV EXTENSION_CFLAGS="${EXTENSION_CFLAGS}"
ENV NO_INTERACTION=1

CMD /bin/bash
