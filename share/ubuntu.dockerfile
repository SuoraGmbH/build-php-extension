FROM ubuntu:latest

RUN apt-get update &&  \
    DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y \
        autoconf \
        build-essential \
        gdb \
        libbz2-dev \
        libcurl4-openssl-dev \
        libonig-dev \
        libsqlite3-dev \
        libssl-dev \
        libxml2-dev \
        libzip-dev \
        pkg-config \
        unzip \
        valgrind \
        wget \
        zlib1g-dev

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

COPY scripts/ /usr/local/bin/

ARG INSTALL_ADDITIONAL_PACKAGES

RUN apt-get update &&  \
    DEBIAN_FRONTEND=noninteractive apt-get install -y ${INSTALL_ADDITIONAL_PACKAGES}

ARG PHP_TARBALL_NAME
ARG ADDITIONAL_PHP_CONFIG_ARGS
ARG CC

ENV CC="${CC:-cc}"

RUN mkdir -p /opt/php-src && \
    wget "https://www.php.net/distributions/${PHP_TARBALL_NAME}" -O - | tar xJC /opt/php-src/ --strip-components 1 && \
    cd /opt/php-src && \
    ./configure \
        --enable-fpm \
        --enable-mbstring \
        --enable-pdo \
        --enable-soap \
        --with-bz2 \
        --with-curl \
        --with-mysqli \
        --with-openssl \
        --with-pdo-mysql \
        --with-pdo-sqlite \
        --with-zip \
        --with-zlib \
        --without-pear \
        ${ADDITIONAL_PHP_CONFIG_ARGS} && \
    make -j$(( $(getconf _NPROCESSORS_ONLN) + 1 )) && \
    make install

ARG EXTENSION_CFLAGS

ENV EXTENSION_CFLAGS="${EXTENSION_CFLAGS}"
ENV NO_INTERACTION=1
ENV TEST_PHP_ARGS="--show-diff"

CMD /bin/bash
