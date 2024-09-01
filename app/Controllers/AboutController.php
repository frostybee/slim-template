<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Core\AppSettings;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

class AboutController extends BaseController
{
    private const API_NAME = 'YOUR_PROJECT_NAME';

    private const API_VERSION = '1.0.0';

    public function handleAboutWebService(Request $request, Response $response): Response
    {
        $data = array(
            'api' => self::API_NAME,
            'version' => self::API_VERSION,
            'about' => 'Welcome! This i a Web service that provides this and that...',
            'authors' => 'FrostyBee',
            'resources' => '/blah'
        );

        return $this->renderJson($response, $data);
    }
}
