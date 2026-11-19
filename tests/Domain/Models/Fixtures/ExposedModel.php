<?php

declare(strict_types=1);

namespace Tests\Domain\Models\Fixtures;

use App\Domain\Models\BaseModel;
use PDOStatement;

/**
 * A model that makes the protected BaseModel methods callable from tests.
 */
class ExposedModel extends BaseModel
{
    public function callRun(string $sql, array $args = []): PDOStatement
    {
        return $this->run($sql, $args);
    }

    public function callFetchAll(string $sql, array $args = []): array
    {
        return $this->fetchAll($sql, $args);
    }

    public function callFetchSingle(string $sql, array $args = []): mixed
    {
        return $this->fetchSingle($sql, $args);
    }

    public function callCount(string $sql, array $args = []): int
    {
        return $this->count($sql, $args);
    }

    public function callCountRows(string $sql, array $args = []): int
    {
        return $this->countRows($sql, $args);
    }

    public function callInsert(string $table, array $data): mixed
    {
        return $this->insert($table, $data);
    }

    public function callUpdate(string $table, array $data, array $where): int
    {
        return $this->update($table, $data, $where);
    }

    public function callDelete(string $table, array $where, int ...$limit): int
    {
        return $this->delete($table, $where, ...$limit);
    }

    public function callTransaction(callable $work): mixed
    {
        return $this->transaction($work);
    }
}
