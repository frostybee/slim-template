<?php

declare(strict_types=1);

namespace Vanier\Api\Controllers;

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

class AboutController extends BaseController
{
    public function handleAboutWebService(Request $request, Response $response, array $uri_args): Response
    {
        $data = array(
            'about' => 'Welcome! This is a Web service that provides this and that...',
            'resources' => 'Blah'
        );
        return $this->makeResponse($response, $data);
    }
}
