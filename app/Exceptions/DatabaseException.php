<?php

declare(strict_types=1);

namespace App\Exceptions;

use RuntimeException;
use Throwable;

/**
 * Thrown by BaseModel when the database rejects a query.
 *
 * The message is a readable explanation followed by the original driver
 * error. Use getSqlState() to react to a specific kind of failure, for
 * example '23000' for a duplicate key or a foreign key violation.
 */
final class DatabaseException extends RuntimeException
{
    /**
     * @param string $message A readable description of the failure.
     * @param string|null $sqlState The five-character SQLSTATE code, when known.
     * @param Throwable|null $previous The original PDOException.
     */
    public function __construct(
        string $message,
        private readonly ?string $sqlState = null,
        ?Throwable $previous = null
    ) {
        parent::__construct($message, 0, $previous);
    }

    /**
     * Gets the SQLSTATE code reported by the database.
     *
     * @return string|null The SQLSTATE code (e.g. '23000'), or null when unknown.
     */
    public function getSqlState(): ?string
    {
        return $this->sqlState;
    }
}
