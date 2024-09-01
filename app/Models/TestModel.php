<?php

namespace App\Models;

use App\Core\PDOService;

class TestModel  extends BaseModel
{
    public function __construct(PDOService $pdo)
    {
        parent::__construct($pdo);
    }
    public function sayHello() : void {
        echo  "Test";
    }
}
