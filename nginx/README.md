# Nginx Configuration for Slim Framework Template

This directory contains Nginx configuration files for running the Slim Framework Template on a native Nginx server (not Docker).

## Prerequisites

Before you begin, ensure you have:
- Nginx installed (`nginx -v` to check)
- PHP-FPM installed (e.g., `php8.4-fpm`)
- Required PHP extensions: pdo, pdo_mysql, curl, mbstring

## Quick Start

### 1. Install Required Software

**Ubuntu/Debian:**

```bash
# Install Nginx
sudo apt update
sudo apt install nginx

# Install PHP-FPM and required extensions
sudo apt install php8.4-fpm php8.4-mysql php8.4-curl php8.4-mbstring

# Verify PHP-FPM is running
sudo systemctl status php8.4-fpm
```


### 2. Deploy Your Application

```bash
# Create web directory
sudo mkdir -p /var/www/[your-project-name]

# Copy project files (example using Git)
cd /var/www
sudo git clone https://github.com/frostybee/slim-template.git [your-project-name]

# Remove the template's git history to start fresh
sudo rm -rf /var/www/[your-project-name]/.git

# Set ownership
sudo chown -R www-data:www-data /var/www/[your-project-name]

# Install Composer dependencies
cd /var/www/[your-project-name]
sudo -u www-data composer install --no-dev --optimize-autoloader
```

### 3. Configure Nginx

```bash
# Copy the configuration file
sudo cp nginx/slim-template.conf /etc/nginx/sites-available/[your-project-name]

# Edit the configuration
sudo nano /etc/nginx/sites-available/[your-project-name]

# Update these values:
# - server_name: Your domain or IP
# - root: Path to your project's public/ directory
# - fastcgi_pass: Your PHP-FPM socket path

# Enable the site
sudo ln -s /etc/nginx/sites-available/[your-project-name] /etc/nginx/sites-enabled/

# Remove default site (optional)
sudo rm /etc/nginx/sites-enabled/default

# Test configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

### 4. Configure PHP-FPM

Ensure your PHP-FPM pool is configured correctly:

```bash
# Edit PHP-FPM pool configuration
sudo nano /etc/php/8.4/fpm/pool.d/www.conf
```

Verify these settings:

```ini
user = www-data
group = www-data
listen = /var/run/php/php8.4-fpm.sock
listen.owner = www-data
listen.group = www-data
```

Restart PHP-FPM after changes:

```bash
sudo systemctl restart php8.4-fpm
```

### 5. Set Up Database Configuration

```bash
# Copy the environment config
cd /var/www/[your-project-name]
sudo -u www-data cp config/env.example.php config/env.php

# Edit with your database credentials
sudo nano config/env.php
```

### 6. Set Directory Permissions

```bash
# Ensure proper permissions for logs directory
sudo mkdir -p /var/www/[your-project-name]/var/logs
sudo chown -R www-data:www-data /var/www/[your-project-name]/var
sudo chmod -R 775 /var/www/[your-project-name]/var
```

## PHP-FPM Socket Paths

The PHP-FPM socket path varies by system. Common paths:

| Distribution  | PHP Version | Socket Path                    |
| ------------- | ----------- | ------------------------------ |
| Ubuntu/Debian | PHP 8.4     | `/var/run/php/php8.4-fpm.sock` |
| Generic       | TCP         | `127.0.0.1:9000`               |

Find your socket:

```bash
# Check PHP-FPM configuration
grep -r "listen = " /etc/php/*/fpm/pool.d/
# or
grep -r "listen = " /etc/php-fpm.d/
```

## Troubleshooting

### 502 Bad Gateway

- PHP-FPM is not running: `sudo systemctl start php8.4-fpm`
- Wrong socket path: Check `fastcgi_pass` matches your PHP-FPM socket
- Permission issues: Ensure www-data owns the socket

### 404 Not Found

- Wrong document root: Verify `root` points to the `public/` directory
- Missing index.php: Check the file exists

### 403 Forbidden

- Permission issues: `sudo chown -R www-data:www-data /var/www/[your-project-name]`
- SELinux (CentOS): `sudo setsebool -P httpd_can_network_connect 1`

### Check Logs

```bash
# Nginx error log
sudo tail -f /var/log/nginx/error.log

# PHP-FPM error log
sudo tail -f /var/log/php8.4-fpm.log

# Application logs
sudo tail -f /var/www/[your-project-name]/var/logs/*.log
```

