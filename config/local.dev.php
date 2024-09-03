<?php

declare(strict_types=1);
//Settings for  Dev environment

function myCustomErrorHandler(int $errNo, string $errMsg, string $file, int $line)
{
    echo "Error: #[$errNo] occurred in [$file] at line [$line]: [$errMsg] <br>";
}

set_error_handler('myCustomErrorHandler');

return function (array $settings): array {
    // Error reporting
    // Enable all error reporting for dev environment.
    error_reporting(E_ALL);
    ini_set('display_errors', '1');
    ini_set('display_startup_errors', '1');

    $settings['error']['display_error_details'] = true;

    // Database
    $settings['db']['database'] = 'worldcup';
    $settings['db']['hostname'] = 'localhost';
    $settings['db']['port'] = '3306';

    return $settings;
};
