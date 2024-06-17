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

    //private $apiBaseDir = APP_ROOT_DIR;
    public function testPing(): void
    {
        $resource_path  = '/'.APP_ROOT_DIR.'/ping';
        $request = $this->createRequest('GET', $resource_path);
        $response = $this->app->handle($request);

        $this->assertSame(StatusCodeInterface::STATUS_OK, $response->getStatusCode());
        $this->assertResponseContains('Reporting!', $response);
    }

    public function testPageNotFound(): void
    {
        $resource_path  = '/'.APP_ROOT_DIR.'/oi';
        $request = $this->createRequest('GET', $resource_path);
        $response = $this->app->handle($request);

        $this->assertSame(StatusCodeInterface::STATUS_NOT_FOUND, $response->getStatusCode());
    }
}
