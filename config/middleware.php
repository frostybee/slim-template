<?php

declare(strict_types=1);

use App\Helpers\Core\AppSettings;
use App\Middleware\HelloMiddleware;
use Slim\App;

return function (App $app) {
    //TODO: Add your middleware here.

    $app->addBodyParsingMiddleware();
    $app->addRoutingMiddleware();

    // Error details (messages, file names, SQL errors) are included in the
    // response only when the 'display_error_details' setting is enabled.
    // It is off by default and turned on in config/settings.dev.php.
    $error_settings = $app->getContainer()->get(AppSettings::class)->get('error');
    $display_error_details = (bool) ($error_settings['display_error_details'] ?? false);

    //!NOTE: the error handling middleware MUST be added last.
    $errorMiddleware = $app->addErrorMiddleware($display_error_details, true, true);
    $errorMiddleware->getDefaultErrorHandler()->forceContentType(APP_MEDIA_TYPE_JSON);
    //!NOTE: You can add override the default error handler with your custom error handler.
    //* For more details, refer to Slim framework's documentation.
};
