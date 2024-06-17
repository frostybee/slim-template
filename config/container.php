<?php

declare(strict_types=1);

use App\Core\AppSettings;
use App\Services\PDOService;
use DI\ContainerBuilder;
use Nyholm\Psr7\Factory\Psr17Factory;
use Psr\Container\ContainerInterface;
use Psr\Http\Message\ResponseFactoryInterface;

$definitions = [
    AppSettings::class => function () {
        return new AppSettings(
            require_once __DIR__ . '/settings.php'
        );
    },

    PDOService::class => function (ContainerInterface $container): PDOService {
        $db_config = $container->get(AppSettings::class)->get('db');
        return new PDOService($db_config);
    },
    // HTTP factories
    ResponseFactoryInterface::class => function (ContainerInterface $container) {
        return $container->get(Psr17Factory::class);
    }
];
return (new ContainerBuilder())->addDefinitions($definitions)->build();
