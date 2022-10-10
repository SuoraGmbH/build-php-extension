FROM alpine:latest

RUN apk add --no-cache \
    autoconf \
    bash \
    bison \
    build-base \
    bzip2-dev \
    curl-dev \
    gdb \
    libxml2-dev \
    libzip-dev \
    linux-headers \
    oniguruma-dev \
    pcre2-dev \
    pkgconf \
    re2c \
    sqlite-dev \
    valgrind

ENV PS1="\\w \\$ "

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

COPY scripts/ /usr/local/bin/
COPY share/buildPhp.sh /opt/

ARG INSTALL_ADDITIONAL_PACKAGES

RUN apk add --no-cache ${INSTALL_ADDITIONAL_PACKAGES}

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
