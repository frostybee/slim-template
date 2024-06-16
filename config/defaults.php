<?php

// Application default settings
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
    'path' => realpath(__DIR__ . '/../var/logs'),
    // Default log level
    'level' => Psr\Log\LogLevel::DEBUG,
];

// Database settings
$settings['db'] = [
    'host' => 'localhost',
    'encoding' => 'utf8mb4',
];

return $settings;
