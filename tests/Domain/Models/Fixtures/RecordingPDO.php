<?php

declare(strict_types=1);

namespace Tests\Domain\Models\Fixtures;

use PDO;
use PDOStatement;

/**
 * A PDO connection that remembers every SQL statement it is asked to prepare.
 *
 * Tests use it to check the SQL that BaseModel generates, including SQL that
 * the SQLite test database cannot execute (e.g. DELETE ... LIMIT).
 */
class RecordingPDO extends PDO
{
    /** @var list<string> */
    public array $statements = [];

    public function prepare(string $query, array $options = []): PDOStatement|false
    {
        $this->statements[] = $query;

        return parent::prepare($query, $options);
    }

    public function lastStatement(): string
    {
        return $this->statements[array_key_last($this->statements)] ?? '';
    }
}
