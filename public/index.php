<?php

declare(strict_types=1);

// Declare the path of the application's root directory.
define('APP_ROOT_DIR', dirname(__DIR__));
define('APP_ROOT_DIR_NAME', basename(dirname(dirname(__FILE__))));
require_once realpath(__DIR__.'/../config/bootstrap.php');
