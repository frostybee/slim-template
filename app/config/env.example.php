<?php

declare(strict_types=1);
/**
 * Environment-specific application configuration.
 *
 * You should store all secret information (usernames, passwords, tokens,
 * private keys) here.
 *
 * TODO:
 * -----
 * 1) Within this folder, create a new PHP file called env.php.
 * 2) Copy the contents of this file into env.php.
 * 3) Make sure the env.php file is added to your .gitignore
 *    so it is not checked into version control.
 *
 * NOTE:
 * -----
 * This approach ensures that no sensitive passwords or API keys
 * will ever be included in version control history, reducing the
 * risk of a security breach. It also ensures that production values
 * never have to be shared with all project collaborators.
 */

return function (array $settings): array {
    // Database credentials
    $settings['db']['username'] = 'root';
    $settings['db']['database'] = 'worldcup';
    $settings['db']['password'] = '';

    //TODO: Additional settings/configs can be declared here.
    return $settings;
};
