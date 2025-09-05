<?php

declare(strict_types=1);

use App\Middleware\HelloMiddleware;
use Slim\App;

return function (App $app) {
    //TODO: Add your middleware here.

    $app->addBodyParsingMiddleware();
    $app->addRoutingMiddleware();

    //!NOTE: the error handling middleware MUST be added last.
    $errorMiddleware = $app->addErrorMiddleware(true, true, true);
    $errorMiddleware->getDefaultErrorHandler()->forceContentType(APP_MEDIA_TYPE_JSON);
    //!NOTE: You can add override the default error handler with your custom error handler.
    //* For more details, refer to Slim framework's documentation.
};
