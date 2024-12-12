<?php

declare(strict_types=1);

namespace App\Core;

use Exception;

/**
 * Provides an implementation of the Result pattern.
 * This class encapsulates the outcome of an operation, which can be either a success or failure.
 * It includes details such as a success flag, messages, data, and errors.
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
     * Holds the actual result of a successful operation.
     * Can be any type of data depending on the operation.
     *
     * @var mixed
     */
    private $data;

    /**
     * An array or other data structure containing one or more error messages.
     * Only populated if the operation failed.
     *
     * @var mixed
     */
    private $errors;

    /**
     * Constructor to create an instance of Result.
     *
     * @param bool $success Indicates if the operation was successful.
     * @param string $message The message related to the operation outcome.
     * @param mixed|null $data Optional data that is associated with a successful operation.
     * @param mixed|null $errors Optional errors if the operation failed.
     */
    private function __construct(bool $success, string $message, mixed $data = null, mixed $errors = null)
    {
        $this->is_success = $success;
        $this->message = $message;
        $this->data = $data;
        $this->errors = $errors;
    }

    /**
     * Creates a successful Result instance.
     *
     * @param string $message The success message.
     * @param mixed|null $data Optional additional data to include with the result.
     * @return Result A Result instance indicating a successful operation.
     */
    public static function success($message, mixed $data = null): Result
    {
        return new Result(true, $message, $data);
    }

    /**
     * Creates a failed Result instance.
     *
     * @param string $message The failure message.
     * @param mixed|null $errors Optional additional errors to include with the failure.
     * @return Result A Result instance indicating failure.
     */
    public static function failure($message, mixed $errors = null): Result
    {
        return new Result(false, $message, null, $errors);
    }

    /**
     * Checks if the operation was successful.
     *
     * @return bool Returns true if the operation was successful, false otherwise.
     */
    public function isSuccess(): bool
    {
        return $this->is_success;
    }

    /**
     * Checks if the operation failed.
     *
     * @return bool Returns true if the operation failed, false otherwise.
     */
    public function isFailure(): bool
    {
        return !$this->is_success;
    }

    /**
     * Gets the data associated with the result.
     *
     * @return mixed The data if the operation was successful.
     * @throws Exception If the operation failed, an exception is thrown.
     */
    public function getData(): mixed
    {
        if (!$this->is_success) {
            throw new Exception("Cannot get data from a failed result.");
        }
        return $this->data;
    }

    /**
     * Gets the errors associated with the result.
     *
     * @return mixed The errors if the operation failed.
     * @throws Exception If the operation was successful, an exception is thrown.
     */
    public function getErrors(): mixed
    {
        if ($this->is_success) {
            throw new Exception("Cannot get errors from a successful result.");
        }
        return $this->errors;
    }

    /**
     * Gets the message associated with the result.
     * This message describes the outcome of the operation.
     *
     * @return string The message describing the result.
     */
    public function getMessage(): string
    {
        return $this->message;
    }

    /**
     * Converts the result to a string representation.
     * The string representation includes the success status, message, and optional data or errors.
     *
     * * NOTE: This can be used for debugging or logging purposes.
     *
     * @return string A string representation of the result.
     *
     * @example $successResult = Result::success("Operation succeeded", ["id" => 123]);
     * echo $successResult; // Output: Success: Operation succeeded, Data: {"id":123}
     *
     * @example $failureResult = Result::failure("Operation failed", ["error_code" => 404]);
     * echo $failureResult; // Output: Failure: Operation failed, Errors: {"error_code":404}
     *
     */
    public function __toString(): string
    {
        if ($this->is_success) {
            $data = $this->data !== null ? 'Data: ' . json_encode($this->data) : 'No data';
            return "Success: {$this->message}, {$data}";
        } else {
            $errors = $this->errors !== null ? 'Errors: ' . json_encode($this->errors) : 'No errors';
            return "Failure: {$this->message}, {$errors}";
        }
    }
}
