FROM serversideup/php:8.5-frankenphp

WORKDIR /var/www/html

# Switch to root for package installation
USER root

# Install 1Password CLI dependencies first
RUN apt-get update && apt-get install -y curl gpg && \
    mkdir -p /usr/share/keyrings /etc/debsig/policies/AC2D62742012EA22 /usr/share/debsig/keyrings/AC2D62742012EA22

# Add 1Password CLI repository
RUN curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
    gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | \
    tee /etc/apt/sources.list.d/1password.list && \
    curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | \
    tee /etc/debsig/policies/AC2D62742012EA22/1password.pol && \
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
    gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg

# Install 1Password CLI
RUN apt-get update && apt-get install -y 1password-cli && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Node.js, jq for JSON parsing, and other dependencies
RUN apt-get update && apt-get install -y nodejs npm jq && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Switch back to www-data user
USER www-data

# Copy application files
COPY --chown=www-data:www-data . /var/www/html

# Copy entrypoint script
COPY --chown=www-data:www-data docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Install Node dependencies and build frontend assets
RUN npm ci && npm run build

EXPOSE 8000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
