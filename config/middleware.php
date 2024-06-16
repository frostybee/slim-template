<?php

declare(strict_types=1);

use App\Middleware\ExceptionMiddleware;
use Odan\Session\Middleware\SessionStartMiddleware;
use Slim\App;

return function (App $app) {
    // Add your middleware here.
    $app->addBodyParsingMiddleware();
    $app->addRoutingMiddleware();
    //!NOTE: the error handling middleware MUST be added last.
    $errorMiddleware = $app->addErrorMiddleware(true, true, true);
    $errorMiddleware->getDefaultErrorHandler()->forceContentType(APP_MEDIA_TYPE_JSON);
};
