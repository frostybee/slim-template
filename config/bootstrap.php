<?php

declare(strict_types=1);

use DI\ContainerBuilder;
use Slim\App;

// require realpath(__DIR__ . '/../vendor/autoload.php');
$autoloadPath = __DIR__ . '/../vendor/autoload.php';
if ($autoloadPath !== false && is_file($autoloadPath)) {
    require $autoloadPath;
} else {
    die('<br><strong>Error:</strong> Composer autoload file not found. <br> Fix: Please run the following command in a <strong>VS Code command prompt terminal</strong> to install the missing dependencies: <br><strong>Command (keep the double quotes):</strong> <span style="background-color: yellow;"> "../../composer.bat" update </span><br> For more details, refer to: <br><a href="https://github.com/frostybee/slim-template?tab=readme-ov-file#how-do-i-usedeploy-this-template" target="_blank">Configuration instructions in README.md</a>');
}

// Load the app's global constants.
require_once __DIR__ . '/constants.php';
// Include the global functions that will be used across the app's various components.
require_once __DIR__ . '/functions.php';

// Configure the DI container and load dependencies.
$definitions = require_once __DIR__ . '/container.php';

// Build DI container instance
//@see https://php-di.org/
$container = (new ContainerBuilder())
    ->addDefinitions($definitions)
    ->build();
// Create App instance
return $container->get(App::class);
