<?php

namespace App\Test\TestCase;

use App\Test\Traits\AppTestTrait;
use Fig\Http\Message\StatusCodeInterface;
use PHPUnit\Framework\TestCase;

/**
 * Test.
 *
 * @coversDefaultClass \App\Action\Home\HomeAction
 */
class HomeActionTest extends TestCase
{
    use AppTestTrait;

    private $apiBaseDir = '/slim-template';
    public function testPing(): void
    {
        $request = $this->createRequest('GET', '/slim-template/ping');
        $response = $this->app->handle($request);

        $this->assertSame(StatusCodeInterface::STATUS_OK, $response->getStatusCode());
        $this->assertResponseContains('Reporting!', $response);
    }

    public function testPageNotFound(): void
    {
        $request = $this->createRequest('GET', '/oi');
        $response = $this->app->handle($request);

        $this->assertSame(StatusCodeInterface::STATUS_NOT_FOUND, $response->getStatusCode());
    }
}
