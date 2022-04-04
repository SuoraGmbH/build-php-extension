FROM alpine:latest

ARG INSTALL_ADDITIONAL_PACKAGES

RUN apk add --no-cache \
    autoconf \
    bash \
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
    sqlite-dev \
    valgrind

ENV PS1="\\w \\$ "

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

COPY scripts/ /usr/local/bin/

ARG INSTALL_ADDITIONAL_PACKAGES

RUN apk add --no-cache ${INSTALL_ADDITIONAL_PACKAGES}

ARG PHP_TARBALL_NAME
ARG ADDITIONAL_PHP_CONFIG_ARGS
ARG PHP_CFLAGS
ARG CC

ENV CC="${CC:-cc}"

RUN mkdir -p /opt/php-src && \
    wget "https://www.php.net/distributions/${PHP_TARBALL_NAME}" -O - | tar xJC /opt/php-src/ --strip-components 1 && \
    cd /opt/php-src && \
    ./configure \
        CFLAGS="${CFLAGS} ${PHP_CFLAGS}" \
        CXXFLAGS="${CXXFLAGS} ${PHP_CFLAGS}" \
        --enable-fpm \
        --enable-mbstring \
        --enable-pdo \
        --enable-soap \
        --with-bz2 \
        --with-curl \
        --with-external-pcre \
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
ARG ADDITIONAL_PHP_TEST_ARGS

ENV EXTENSION_CFLAGS="${EXTENSION_CFLAGS}"
ENV NO_INTERACTION=1
ENV TEST_PHP_ARGS="--show-diff${ADDITIONAL_PHP_TEST_ARGS:+ }${ADDITIONAL_PHP_TEST_ARGS}"

CMD /bin/bash
