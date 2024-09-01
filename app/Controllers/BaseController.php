<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Core\Services\PDOService;
use Psr\Http\Message\ResponseInterface as Response;

abstract class BaseController
{
    protected PDOService $pdo;
    public function __construct(PDOService $pdo)
    {
        $this->pdo = $pdo;
    }
    protected function renderJson(Response $response, array $data, int $status_code = 200): Response
    {
        // var_dump($data);
        $json_data = json_encode($data);
        //-- Write JSON data into the response's body.
        $response->getBody()->write($json_data);
        return $response->withStatus($status_code)->withAddedHeader(HEADERS_CONTENT_TYPE, APP_MEDIA_TYPE_JSON);
    }
}
