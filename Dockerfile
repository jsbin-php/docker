FROM php:5.6-apache
MAINTAINER MarQuis Knox <marquis.knox@trustedshops.de> et al
ENV TERM=xterm-color

# Set the timezone
RUN echo "Europe/Berlin" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata

# Install dependencies
RUN apt-get update && apt-get install -y zlib1g-dev \
    libicu-dev g++ git-core mysql-client vim \
    libfreetype6-dev libjpeg62-turbo-dev libmcrypt-dev \
    libpng12-dev ssl-cert ntpdate dialog default-jre \
    default-jdk

# configure PHP
RUN docker-php-ext-configure intl
RUN docker-php-ext-install intl zip mysqli mysql mcrypt gd

# NTP Update
RUN ntpdate -s de.pool.ntp.org

# delete any existing files
RUN rm -rfv /var/www/html/*

# Build script
RUN git clone https://github.com/jsbin-php/jsbin-php.git --branch 'v2.9.16' --single-branch /var/www/html
RUN cd /var/www/html && make

# Apache config
RUN a2enmod rewrite
RUN a2enmod headers

# SSL
RUN a2enmod ssl
RUN a2ensite default-ssl
RUN make-ssl-cert generate-default-snakeoil --force-overwrite
RUN service apache2 restart

# expose ports
EXPOSE 80 443

# chown
RUN chown -vR www-data:www-data /var/www/
