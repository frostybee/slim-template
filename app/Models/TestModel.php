<?php

namespace App\Models;

use App\Core\PDOService;

class TestModel  extends BaseModel
{
    public function __construct(PDOService $pdo)
    {
        parent::__construct($pdo);
        //dd($pdo);
    }
    public function sayHello() : void {
        $sql = "SELECT * FROM players";
        dd(
            $this->fetchAll($sql)
        );
    }
}
