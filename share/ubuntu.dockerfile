FROM ubuntu:latest

RUN apt-get update &&  \
    DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y \
        autoconf \
        bison \
        build-essential \
        gdb \
        libbz2-dev \
        libcurl4-openssl-dev \
        libonig-dev \
        libpcre2-dev \
        libsqlite3-dev \
        libssl-dev \
        libxml2-dev \
        libzip-dev \
        pkg-config \
        re2c \
        unzip \
        valgrind \
        vim-tiny \
        wget \
        zlib1g-dev

ARG COMPOSER_TAG_NAME=latest
COPY --from=composer:${COMPOSER_TAG_NAME} /usr/bin/composer /usr/local/bin/composer

COPY scripts/ /usr/local/bin/
COPY share/buildPhp.sh /opt/

ARG INSTALL_ADDITIONAL_PACKAGES

RUN apt-get update &&  \
    DEBIAN_FRONTEND=noninteractive apt-get install -y ${INSTALL_ADDITIONAL_PACKAGES}

ARG PHP_TARBALL_NAME
ARG PHP_GIT_BRANCH
ARG ADDITIONAL_PHP_CONFIG_ARGS
ARG PHP_CFLAGS
ARG CC

ENV CC="${CC:-cc}"

RUN /opt/buildPhp.sh

ARG EXTENSION_CFLAGS
ARG ADDITIONAL_PHP_TEST_ARGS

ENV EXTENSION_CFLAGS="${EXTENSION_CFLAGS}"
ENV NO_INTERACTION=1
ENV TEST_PHP_ARGS="--show-diff${ADDITIONAL_PHP_TEST_ARGS:+ }${ADDITIONAL_PHP_TEST_ARGS}"

CMD /bin/bash
