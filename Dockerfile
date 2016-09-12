FROM daocloud.io/library/php:5.6.25-fpm

MAINTAINER Minho <longfei6671@163.com>

RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
		libpcre3-dev \
		gcc \
		make \
        bzip2 \
	libbz2-dev \
	libmemcached-dev \
	git \
    && rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-install mbstring \
    && docker-php-ext-install iconv  \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
	&& docker-php-ext-install mcrypt\
    && docker-php-ext-install mysqli \
    && docker-php-ext-install bz2 \
    && docker-php-ext-install ctype \
    && docker-php-ext-install zip \
	&& docker-php-ext-install pdo \
	&& docker-php-ext-install pdo_mysql \
	&& apt-get -y autoremove \ 
	&& apt-get -y autoclean 
	
WORKDIR /usr/src/php/ext/
RUN git clone https://github.com/php-memcached-dev/php-memcached.git \
	&& docker-php-ext-configure php-memcached \
	&& docker-php-ext-install php-memcached \
	&& rm -rf php-memcached \
	&& git clone -b master https://github.com/phpredis/phpredis.git \
	&& docker-php-ext-configure phpredis \
	&& docker-php-ext-install phpredis \
	&& rm -rf phpredis

ENV PHALCON_VERSION=3.0.1

# Compile Phalcon
RUN set -xe && \
        curl -LO https://github.com/phalcon/cphalcon/archive/v${PHALCON_VERSION}.tar.gz && \
        tar xzf v${PHALCON_VERSION}.tar.gz && cd cphalcon-${PHALCON_VERSION}/build && ./install && \
        echo "extension=phalcon.so" > /usr/local/etc/php/conf.d/phalcon.ini && \
        cd ../.. && rm -rf v${PHALCON_VERSION}.tar.gz cphalcon-${PHALCON_VERSION} 
        # Insall Phalcon Devtools, see https://github.com/phalcon/phalcon-devtools/
        #curl -LO https://github.com/phalcon/phalcon-devtools/archive/v${PHALCON_VERSION}.tar.gz && \
        #tar xzf v${PHALCON_VERSION}.tar.gz && \
        #mv phalcon-devtools-${PHALCON_VERSION} /usr/local/phalcon-devtools && \
        #ln -s /usr/local/phalcon-devtools/phalcon.php /usr/local/bin/phalcon

#Composer
RUN curl -sS https://getcomposer.org/installer | php \
	&& mv composer.phar /usr/local/bin/composer

# PHP config
ADD conf/php.ini /usr/local/etc/php/php.ini
ADD conf/www.conf /usr/local/etc/php-fpm.d/www.conf
		
EXPOSE 9000