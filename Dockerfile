FROM php:7.4-fpm

MAINTAINER Stephen <admin@stephen520.cn>

ARG timezone

ENV TIMEZONE=${timezone:-"Asia/Shanghai"} \
    SWOOLE_VERSION=4.5.2 \
    IMAGICK_VERSION=3.7.0

RUN sed -i "s@http://deb.debian.org@http://mirrors.aliyun.com@g" /etc/apt/sources.list && \

    # Libs
    apt-get update && \
    apt-get install -y curl \
                       wget \
                       telnet \
                       vim \
                       git \
                       npm \
                       zlib1g-dev \
                       libzip-dev \
                       libpng-dev \
                       libjpeg62-turbo-dev \
                       libfreetype6-dev \
                       imagemagick \
                       libmagickwand-dev && \

    # PHP Library
    docker-php-ext-install zip \
                           pdo \
                           pdo_mysql \
                           opcache \
                           mysqli \
                           bcmath \
                           sockets \
                           pcntl && \

    # Clean apt cache
    rm -rf /var/lib/apt/lists/*

# composer
RUN php -r "copy('https://install.phpcomposer.com/installer', 'composer-setup.php');" && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    php -r "unlink('composer-setup.php');" && \
    composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/ && \

    # Redis Mongo
    pecl install redis mongodb imagick && \
    rm -rf /tmp/pear && \
    docker-php-ext-enable redis mongodb imagick && \

    # Swoole
    wget https://github.com/swoole/swoole-src/archive/v${SWOOLE_VERSION}.tar.gz -O swoole.tar.gz && \
    mkdir -p swoole && \
    tar -xf swoole.tar.gz -C swoole --strip-components=1 && \
    rm swoole.tar.gz && \
    ( \
    cd swoole && \
    phpize && \
    ./configure --enable-mysqlnd --enable-sockets --enable-openssl --enable-http2 && \
    make -j$(nproc) && \
    make install \
    ) && \
    rm -r swoole && \
    docker-php-ext-enable swoole && \

    # GD Library
    docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ && \
    docker-php-ext-install -j$(nproc) gd && \

    # Timezone
    cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
    echo "${TIMEZONE}" > /etc/timezone && \
    echo "[Date]\ndate.timezone=${TIMEZONE}" > /usr/local/etc/php/conf.d/timezone.ini && \

    # Clean
    apt-get clean && rm -rf /var/cache/apt/*

ADD . /var/www/html

WORKDIR /var/www/html

EXPOSE 9000

CMD ["/usr/local/sbin/php-fpm"]
