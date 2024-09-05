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
    public function sayHello(): array
    {
        $sql = "SELECT * FROM players";
        return   (array)$this->fetchAll($sql);
    }
}
