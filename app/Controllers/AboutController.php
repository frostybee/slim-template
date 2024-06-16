<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Models\TestModel;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

class AboutController extends BaseController
{
    public function handleAboutWebService(Request $request, Response $response): Response
    {
        $data = array(
            'about' => 'Welcome! This is a Web service that provides this and that...',
            'authors' => 'FrostyBee',
            'resources' => '/blah'
        );
        return $this->makeResponse($response, $data);
    }
}
