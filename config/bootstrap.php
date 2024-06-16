<?php

declare(strict_types=1);

use Slim\Factory\AppFactory;

require __DIR__ . '/../vendor/autoload.php';

// Load the app's global constants.
require_once __DIR__ . '/constants.php';

// Configure the DI container and load dependencies.
$container = require __DIR__ . '/container.php';

AppFactory::setContainer($container);
$app = AppFactory::create();

// You might also need to change it in .htaccess
//$app_base_dir = basename(dirname(dirname(dirname(__FILE__))));
$app->setBasePath('/' . APP_ROOT_DIR_NAME);

// Register routes
(require_once __DIR__ . '/../app/Routes/routes.php')($app);

// Register middleware
(require_once __DIR__ . '/middleware.php')($app);

// Run the app.
$app->run();
