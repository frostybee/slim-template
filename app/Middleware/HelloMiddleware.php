<?php declare(strict_types=1);

namespace Vanier\Api\Middleware;

use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Server\RequestHandlerInterface as RequestHandler;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Server\MiddlewareInterface;

class HelloMiddleware implements MiddlewareInterface
{
    public function process(Request $request, RequestHandler $handler): ResponseInterface
    {
        //echo "Hello! From test middleware!";exit;

        //! DO NOT remove or change the following statements. 
        $response = $handler->handle($request);
        return $response;
    }    
}
