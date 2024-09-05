<?php

declare(strict_types=1);

namespace App\Core;


/**
 * Provides an implementation of the Result pattern.
 * This class encapsulates the result of an operation.
 */
class Result
{
    /**
     * A flag that determines whether the operation was
     * successful or not.
     *
     * @var bool
     */
    private bool $is_success = false;

    /**
     * Holds the list of errors encountered while
     * performing an operation.
     *
     * @var string
     */
    //private ?array $errors;
    private string $message;

    /**
     * Holds the result of the operation.
     *
     * @var mixed
     */
    private $data;

    public function __construct(bool $success, string $message, $data = null)
    {
        $this->is_success = $success;
        $this->message = $message;
        $this->data = $data;
    }
    public static function success($message, $data = null): Result
    {
        return new Result(true, $message, $data);
    }

    public static function fail($message): Result
    {
        return new Result(false, $message);
    }

    public function isSuccess(): bool
    {
        return $this->is_success;
    }

    public function isFailure(): bool
    {
        return !$this->is_success;
    }

    public function getData(): mixed
    {
        return $this->data;
    }

    public function getErrors(): string
    {
        return $this->message;
    }
    //TODO: toString errors? @see: Valitron
}
