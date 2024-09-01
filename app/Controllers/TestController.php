<?php

namespace App\Controllers;

use App\Core\PDOService;
use App\Models\TestModel;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

class TestController extends BaseController
{

    public function __construct(private TestModel $testModel) {

    }

    public function handleTest(Request $request, Response $response): Response
    {
        $this->testModel->sayHello();

        return $response;
    }
}
