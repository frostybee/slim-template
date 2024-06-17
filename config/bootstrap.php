<?php

declare(strict_types=1);

use DI\ContainerBuilder;
use Slim\Factory\AppFactory;
use Slim\App;

require realpath(__DIR__ . '/../vendor/autoload.php');

// Configure the DI container and load dependencies.
$definitions = require realpath(__DIR__ . '/container.php');

// Build DI container instance
$container = (new ContainerBuilder())
    ->addDefinitions($definitions)
    ->build();

// Create App instance
return $container->get(App::class);


/* AppFactory::setContainer($container);
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
 */
