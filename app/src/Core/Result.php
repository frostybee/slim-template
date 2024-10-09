<?php

declare(strict_types=1);

namespace App\Core;


/**
 * Provides an implementation of the Result pattern.
 * This class encapsulates the outcome of an operation.
 */
class Result
{
    /**
     * A flag that determines whether the operation succeeded
     * or failed.
     *
     * @var bool
     */
    private bool $is_success = false;

    /**
     * Holds a success or an error message encountered while
     * performing an operation.
     *
     * @var string
     */
    private string $message;

    /**
     * Holds the result of the operation.
     * It may contain produced data or error messages.
     *
     * @var mixed
     */
    private $data;

    private function __construct(bool $success, string $message, mixed $data = null)
    {
        $this->is_success = $success;
        $this->message = $message;
        $this->data = $data;
    }

    /**
     * Creates a successful Result instance.
     *
     * @param string $message The success message.
     * @param mixed|null $data Optional additional data to include with the result.
     * @return Result A Result instance containing information about a successful operation.
     */
    public static function success($message, mixed $data = null): Result
    {
        return new Result(true, $message, $data);
    }

    /**
     * Creates a failed Result instance.
     *
     * @param string $message The failure message.
     * @param mixed|null $data Optional additional data to include with the result.
     * @return Result A Result instance indicating failure.
     */
    public static function fail($message, mixed $data = null): Result
    {
        return new Result(false, $message, $data);
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

    public function getMessage(): string
    {
        return $this->message;
    }
    //TODO: toString errors? @see: Valitron
}
