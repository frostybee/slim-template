<?php

declare(strict_types=1);

// Application's default settings

// Error reporting
// Default settings: disable all error reporting for production.
error_reporting(0);
ini_set('display_errors', '0');
ini_set('display_startup_errors', '0');
// Timezone
date_default_timezone_set('America/Toronto');

$settings = [];

// Error handler
$settings['error'] = [
    // Should be set to false for the production environment
    'display_error_details' => false,
];

// Logger settings
$settings['logger'] = [
    // Log file location
    'path' => realpath(__DIR__ . '/../../var/logs'),
    // Default log level
    'level' => Psr\Log\LogLevel::DEBUG,
];

// Database settings
$settings['db'] = [
    'host' => 'localhost',
    'encoding' => 'utf8mb4',
    'options' => [
        // Turn off persistent connections
        PDO::ATTR_PERSISTENT => false,
        // Enable exceptions
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        // Emulate prepared statements
        PDO::ATTR_EMULATE_PREPARES => false,
        // Leave column names as returned by the database driver.
        PDO::ATTR_CASE => PDO::CASE_NATURAL,
        // Set default fetch mode to array
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        // Set character set
        PDO::MYSQL_ATTR_INIT_COMMAND => 'SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci'
    ]
];

return $settings;
