<?php

declare(strict_types=1);

use App\Core\AppSettings;
use App\Core\Services\PDOService;
use Nyholm\Psr7\Factory\Psr17Factory;
use Psr\Container\ContainerInterface;
use Psr\Http\Message\ResponseFactoryInterface;
use Psr\Http\Message\ServerRequestFactoryInterface;
use Psr\Http\Message\StreamFactoryInterface;
use Psr\Http\Message\UriFactoryInterface;
use Slim\Factory\AppFactory;
use Slim\App;
use Slim\Interfaces\RouteParserInterface;

// Declare the path of the application's root directory.
define('APP_BASE_PATH', dirname(__DIR__));
define('APP_ROOT_DIR', basename(dirname(__FILE__, 2)));

// Load the app's global constants.
require_once realpath(__DIR__ . '/constants.php');

$definitions = [
    AppSettings::class => function () {
        return new AppSettings(
            require_once __DIR__ . '/settings.php'
        );
    },
    App::class => function (ContainerInterface $container) {

        $app = AppFactory::createFromContainer($container);
        //$app->setBasePath('/slim-template');
        $app->setBasePath('/' . APP_ROOT_DIR);

        // Register routes
        (require_once realpath(__DIR__ . '/../app/Routes/routes.php'))($app);

        // Register middleware
        (require_once realpath(__DIR__ . '/middleware.php'))($app);

        return $app;
    },

    PDOService::class => function (ContainerInterface $container): PDOService {
        $db_config = $container->get(AppSettings::class)->get('db');
        return new PDOService($db_config);
    },
    // HTTP factories
    ResponseFactoryInterface::class => function (ContainerInterface $container) {
        return $container->get(Psr17Factory::class);
    },
    ServerRequestFactoryInterface::class => function (ContainerInterface $container) {
        return $container->get(Psr17Factory::class);
    },
    StreamFactoryInterface::class => function (ContainerInterface $container) {
        return $container->get(Psr17Factory::class);
    },
    UriFactoryInterface::class => function (ContainerInterface $container) {
        return $container->get(Psr17Factory::class);
    },
    // The Slim RouterParser
    RouteParserInterface::class => function (ContainerInterface $container) {
        return $container->get(App::class)->getRouteCollector()->getRouteParser();
    },
];
return $definitions;
