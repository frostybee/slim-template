<?php

declare(strict_types=1);

// HTTP response status code.
define('HTTP_OK', 200);
define('HTTP_CREATED', 201);
define('HTTP_NO_CONTENT', 204);
define('HTTP_METHOD_NOT_ALLOWED', 405);
define('HTTP_UNSUPPORTED_MEDIA_TYPE', 415);
define('HTTP_NOT_FOUND', 404);
// HTTP response headers.
define('HEADERS_CONTENT_TYPE', "Content-Type");
// Supported Media Types.
define('APP_MEDIA_TYPE_JSON', "application/json");
define('APP_MEDIA_TYPE_XML', "application/xml");
define('APP_MEDIA_TYPE_YAML', "application/yaml");
