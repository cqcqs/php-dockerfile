FROM php:8.2-fpm-alpine

MAINTAINER Stephen <admin@stephen520.cn>

ARG timezone

ENV TIMEZONE=${timezone:-"Asia/Shanghai"} \
    SWOOLE_VERSION=4.5.2

# Libs
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
    apk update && \
    apk add --no-cache make \
                       libc-dev \
                       gcc \
                       g++ \
                       wget \
                       tzdata \
                       libxml2-dev \
                       openssl-dev \
                       sqlite-dev \
                       curl-dev \
                       oniguruma-dev \
                       autoconf \
                       libzip-dev \
                       freetype-dev \
                       libjpeg-turbo-dev \
                       linux-headers \
                       libpng-dev \
                       imagemagick \
                       imagemagick-dev && \
    
    # PHP Library
    docker-php-ext-install zip \
                           pdo \
                           pdo_mysql \
                           opcache \
                           mysqli \
                           bcmath \
                           sockets \
                           pcntl && \
    # Timezone
    cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
    echo "${TIMEZONE}" > /etc/timezone && \
    echo "[Date]\ndate.timezone=${TIMEZONE}" > /usr/local/etc/php/conf.d/timezone.ini && \
    apk del tzdata

# composer
RUN php -r "copy('https://install.phpcomposer.com/installer', 'composer-setup.php');" && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    php -r "unlink('composer-setup.php');" && \
    composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/ && \

    # Redis Mongo
    pecl install redis mongodb swoole imagick && \
    rm -rf /tmp/pear && \
    docker-php-ext-enable redis mongodb swoole imagick && \

    # GD Library
    docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ && \
    docker-php-ext-install -j$(nproc) gd && \

    # Clean
    apk del && rm -rf /var/cache/apk/*

ADD . /var/www/html

WORKDIR /var/www/html

EXPOSE 9000

CMD ["php-fpm"]