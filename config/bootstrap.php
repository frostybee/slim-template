<?php

declare(strict_types=1);

use Slim\Factory\AppFactory;

require realpath(__DIR__ . '/../vendor/autoload.php');

// Load the app's global constants.
require_once realpath(__DIR__ . '/constants.php');

// Configure the DI container and load dependencies.
$container = require realpath(__DIR__ . '/container.php');

AppFactory::setContainer($container);
$app = AppFactory::create();

// You might also need to change it in .htaccess
//NOTE: If running DOCKER: htdocs
// Set the base path to:
//$app->setBasePath('/htdocs');
//call phpinfo(); then check the value of the DOCUMENT_ROOT property.

$app->setBasePath('/' . APP_ROOT_DIR_NAME);

// Register routes
(require_once realpath(__DIR__ . '/../app/Routes/routes.php'))($app);

// Register middleware
(require_once realpath(__DIR__ . '/middleware.php'))($app);

// Run the app.
$app->run();
