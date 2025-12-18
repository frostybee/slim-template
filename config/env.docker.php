<?php

declare(strict_types=1);

/**
 * Docker environment configuration.
 *
 * This file is used when running the application in Docker containers.
 * It is automatically mounted as env.php by docker-compose.yml.
 *
 * Database credentials match those defined in docker-compose.yml.
 */

return function (array $settings): array {
    // Database credentials for Docker MySQL container
    $settings['db']['host'] = 'db';  // Docker service name
    $settings['db']['username'] = 'slim_user';
    $settings['db']['database'] = 'slim_app';
    $settings['db']['password'] = 'slim_pass';
    $settings['db']['port'] = '3306';

    return $settings;
};
