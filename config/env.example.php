<?php

declare(strict_types=1);
/**
 * Environment specific application configuration.
 *
 * You should store all secret information (username, password, tokens,
 * private keys) here.
 *
 * TODO:
 * -----
 * 1) Within this folder, create a new PHP file called env.php,
 * 2) Copy the content of this file over to env.php,
 * 2) Make sure the env.php file is added to your .gitignore,
 *    so it is not checked-in the code.
 *
 *? NOTE:
 * ----
 * This usage ensures that no sensitive passwords or API keys will
 * ever be in the version control history so there is less risk of
 * a security breach, and production values will never have to be
 * shared with all project collaborators.
 */

return function (array $settings): array {
    // Database credentials
    $settings['db']['username'] = 'root';
    $settings['db']['database'] = 'worldcup';
    $settings['db']['password'] = '';

    //TODO: Additional settings/configs can be declared here.
    return $settings;
};
