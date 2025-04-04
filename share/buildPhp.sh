#!/bin/sh

set -eu

mkdir -p /opt/php-src

if [ -n "${PHP_GIT_BRANCH-}" ]; then
    git clone --depth 1 --branch "${PHP_GIT_BRANCH}" "https://github.com/${PHP_GITHUB_REPOSITORY}.git" /opt/php-src
else
    wget "https://www.php.net/distributions/${PHP_TARBALL_NAME}" -O - | tar xJC /opt/php-src/ --strip-components 1
fi

cd /opt/php-src

if ! [ -x "configure" ]; then
    ./buildconf --force
fi

./configure \
    CFLAGS="${CFLAGS-} ${PHP_CFLAGS-}" \
    CXXFLAGS="${CXXFLAGS-} ${PHP_CFLAGS-}" \
    LDFLAGS="${LDFLAGS-} ${PHP_LDFLAGS-}" \
    PHP_BUILD_PROVIDER='https://github.com/SuoraGmbH/build-php-extension' \
    --enable-bcmath \
    --enable-fpm \
    --enable-mbstring \
    --enable-pdo \
    --enable-sockets \
    --enable-soap \
    --with-bz2 \
    --with-curl \
    --with-external-pcre \
    --with-mysqli \
    --with-openssl \
    --with-pdo-mysql \
    --with-pdo-sqlite=/usr \
    --with-readline=/usr \
    --with-sodium \
    --with-sqlite3=/usr \
    --with-zip \
    --with-zlib \
    --without-pear \
    ${ADDITIONAL_PHP_CONFIG_ARGS-}

make -j$(( $(getconf _NPROCESSORS_ONLN) + 1 ))
make install
