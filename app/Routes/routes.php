<?php

declare(strict_types=1);

use App\Controllers\AboutController;
use App\Helpers\DateTimeHelper;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

return static function (Slim\App $app): void {

    // Routes without authentication check: /login, /token

    // Routes with authentication
    //* ROUTE: GET /
    $app->get('/', [AboutController::class, 'handleAboutWebService']);

    //* ROUTE: GET /ping
    $app->get('/ping', function (Request $request, Response $response, $args) {

        $now = DateTimeHelper::now(DateTimeHelper::Y_M_D_H_M);
        $response->getBody()->write("Reporting! Hello there! The current time is: {$now}");
        return $response;
    });
};
