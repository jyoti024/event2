FROM php:8.2-apache

# SQLite3 support is already built into the official PHP image.

# Keep the database folder from being served over HTTP
RUN printf '<DirectoryMatch "^/var/www/html/data">\n    Require all denied\n</DirectoryMatch>\n' \
    > /etc/apache2/conf-available/deny-private.conf \
    && a2enconf deny-private

# Startup script is created here inside the image, so the build no longer
# depends on a separate docker/start.sh file existing in the repo.
RUN printf '%s\n' \
    '#!/bin/sh' \
    'set -e' \
    'PORT="${PORT:-10000}"' \
    'sed -i "s/Listen 80/Listen ${PORT}/" /etc/apache2/ports.conf' \
    'sed -i "s/<VirtualHost \*:80>/<VirtualHost *:${PORT}>/" /etc/apache2/sites-available/000-default.conf' \
    'mkdir -p /var/www/html/data' \
    'chown -R www-data:www-data /var/www/html/data' \
    'exec apache2-foreground' \
    > /usr/local/bin/start.sh \
    && chmod +x /usr/local/bin/start.sh

WORKDIR /var/www/html
COPY . /var/www/html/
RUN mkdir -p /var/www/html/data \
    && chown -R www-data:www-data /var/www/html

# Render sends traffic to $PORT (default 10000)
ENV PORT=10000
EXPOSE 10000

CMD ["/usr/local/bin/start.sh"]
