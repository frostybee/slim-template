<?php

declare(strict_types=1);

use DI\ContainerBuilder;
use Slim\Factory\AppFactory;
use Slim\App;

require realpath(__DIR__ . '/../vendor/autoload.php');

require realpath(__DIR__ . '/config/functions.php');

// Configure the DI container and load dependencies.
$definitions = require realpath(__DIR__ . '/container.php');

// Build DI container instance
$container = (new ContainerBuilder())
    ->addDefinitions($definitions)
    ->build();

// Create App instance
return $container->get(App::class);
