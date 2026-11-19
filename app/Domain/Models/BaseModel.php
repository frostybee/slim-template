<?php

declare(strict_types=1);

namespace App\Domain\Models;

use App\Exceptions\DatabaseException;
use App\Helpers\Core\PDOService;
use PDO;

/**
 * A wrapper class for interacting with a MySQL DB using the PDO API.
 * This class can be extended for further customization.
 */
abstract class BaseModel
{

    /**
     * holds a handle to a database connection.
     */
    private PDO $db;

    /**
     * The index of the current page.
     */
    private int $current_page = 1;

    /**
     * Holds the number of records to include per page.
     */
    private int $records_per_page = 5;

    /**
     * Counter used to give each nested transaction a unique savepoint name.
     * It is static because all models share the same database connection.
     */
    private static int $savepoint_counter = 0;

    /**
     * Instantiates the PDO wrapper.
     *
     * @param PDOService $pdo A helper object that contains the
     *                        established DB connection.
     */
    public function __construct(PDOService $pdo)
    {
        $this->db = $pdo->getPDO();
    }

    /**
     * Validates a table or column name and wraps it in backticks.
     *
     * Validation prevents SQL injection through identifiers. The backticks
     * allow names that are reserved SQL keywords (e.g. `condition`, `order`).
     *
     * @param string|int $name The table or column name to validate and quote.
     *                         Integer keys from list-style arrays are rejected.
     * @param string $kind Either 'table' or 'column'. Used in error messages.
     * @return string The validated name wrapped in backticks.
     * @throws \InvalidArgumentException If the name is empty or invalid
     */
    private function quoteIdentifier(string|int $name, string $kind = 'column'): string
    {
        $name = (string) $name;
        $label = ucfirst($kind);

        if ($name === '') {
            throw new \InvalidArgumentException(
                "$label name cannot be empty. Please provide a valid $kind name."
            );
        }

        if (!preg_match('/^[a-zA-Z_][a-zA-Z0-9_]*$/', $name)) {
            $examples = $kind === 'table'
                ? "'users', 'user_profiles', 'Product_Categories'"
                : "'email', 'first_name', 'created_at'";

            throw new \InvalidArgumentException(
                "Invalid $kind name: '$name'. " .
                    "$label names can only contain letters, numbers, and underscores, " .
                    "and must start with a letter or underscore. " .
                    "Example: $examples"
            );
        }

        return "`$name`";
    }

    /**
     * Formats a database error message based on the SQLSTATE code.
     *
     * @param string $sqlState The SQLSTATE error code from PDO
     * @param string $originalMessage The original error message
     * @return string A user-friendly error message
     */
    private function formatDatabaseErrorMessage(string $sqlState, string $originalMessage): string
    {
        $errorMessages = [
            '42S02' => "Table not found. The database table referenced in your query does not exist. " .
                "Check the spelling of the table name, and make sure the schema was imported into " .
                "the database that is set in the config/env.php file.",
            '42S22' => "Column not found. The column referenced in your query does not exist in the table. " .
                "Please verify your column names match the database schema.",
            '42S21' => "Duplicate column name. Two columns selected by your query have the same name. " .
                "Give each one a unique alias (e.g. SELECT users.id AS user_id, orders.id AS order_id).",
            '23000' => "Integrity constraint violation. This usually means a duplicate key, foreign key violation, " .
                "or a required field is missing. Check your data for duplicates or missing required values.",
            '42000' => "SQL syntax error. There is an error in your SQL query syntax. " .
                "Please review the query structure and ensure all keywords and operators are correct.",
            'HY093' => "Invalid parameter binding. The number of bound parameters does not match the placeholders in your query.",
            '08006' => "Connection failure. The database connection was lost. Please check that the database server is running.",
            '28000' => "Authentication failed. Invalid database username or password. " .
                "Please verify your credentials in config/env.php.",
        ];

        $baseMessage = $errorMessages[$sqlState] ??
            "Database operation failed. This usually indicates a problem with your SQL query, " .
            "database connection, or data types. Check your query syntax and ensure the database is accessible.";

        return $baseMessage . " Original error: " . $originalMessage;
    }

    /**
     * Executes a SQL query with the provided arguments.
     *
     * This method prepares and executes a SQL statement, binding parameters appropriately
     * whether they are provided as an associative or indexed array. Integers, booleans,
     * and null values are bound with their own type, everything else as a string.
     *
     * Use it in a model for statements that insert(), update(), and delete()
     * cannot express (e.g. an UPDATE with a LIKE condition). Table and column
     * names in $sql are not validated or quoted: never build $sql from user
     * input, pass values through $args instead.
     *
     * @param string $sql The SQL query to be executed.
     * @param array $args An optional array of parameters to bind to the SQL query.
     *                     Use string keys for named placeholders (:name) and a
     *                     plain list for positional placeholders (?).
     *                     If empty, the query is executed directly without parameter binding.
     * @return \PDOStatement The PDOStatement object representing the executed statement.
     * @throws DatabaseException If the database rejects the query.
     */
    protected function run(string $sql, array $args = []): \PDOStatement
    {
        try {
            if ($args === []) {
                return $this->db->query($sql);
            }

            $stmt = $this->db->prepare($sql);

            //named placeholders use string keys, positional placeholders don't
            $is_named = array_filter(array_keys($args), 'is_string') !== [];
            if (!$is_named) {
                //positional placeholders are numbered from 1
                $args = array_combine(range(1, count($args)), array_values($args));
            }

            foreach ($args as $key => $value) {
                $param = $is_named ? ':' . ltrim((string) $key, ':') : $key;
                if (is_bool($value)) {
                    $value = (int) $value;
                }
                $stmt->bindValue($param, $value, $this->getParamType($value));
            }
            $stmt->execute();

            return $stmt;
        } catch (\PDOException $e) {
            $sql_state = (string) ($e->errorInfo[0] ?? $e->getCode());
            throw new DatabaseException(
                $this->formatDatabaseErrorMessage($sql_state, $e->getMessage()),
                $sql_state,
                $e
            );
        }
    }

    /**
     * Picks the PDO parameter type that matches a PHP value.
     *
     * @param mixed $value The value to be bound to a placeholder.
     * @return int One of the PDO::PARAM_* constants.
     */
    private function getParamType(mixed $value): int
    {
        return match (true) {
            is_int($value) => PDO::PARAM_INT,
            $value === null => PDO::PARAM_NULL,
            default => PDO::PARAM_STR,
        };
    }

    /**
     * Builds the WHERE clause shared by update() and delete().
     *
     * Conditions are joined with AND. A null value is matched with IS NULL,
     * because "column = NULL" is never true in SQL. Any other value is
     * compared with = and bound to a placeholder.
     *
     * @param array $where_conditions An associative array of column-value pairs.
     * @return array A two-item list: the SQL of the conditions, and the values to bind.
     */
    private function buildWhere(array $where_conditions): array
    {
        $where_parts = [];
        $values = [];
        foreach ($where_conditions as $key => $value) {
            $column = $this->quoteIdentifier($key);
            if ($value === null) {
                $where_parts[] = "$column IS NULL";
            } else {
                $where_parts[] = "$column = ?";
                $values[] = $value;
            }
        }

        return [implode(' AND ', $where_parts), $values];
    }

    /**
     * Runs several database operations as one transaction.
     *
     * Every change made inside $work is saved only if $work finishes. If it
     * throws, the changes are rolled back and the exception is thrown again.
     *
     * A call made while a transaction is already open is nested: it uses a
     * savepoint, so a failure rolls back only the changes of the inner call.
     *
     * @param callable $work A function that performs the database operations.
     * @return mixed The value returned by $work.
     * @throws \Throwable Whatever $work throws, after the rollback.
     */
    protected function transaction(callable $work): mixed
    {
        if (!$this->db->inTransaction()) {
            $this->db->beginTransaction();
            try {
                $result = $work();
                $this->db->commit();
                return $result;
            } catch (\Throwable $e) {
                if ($this->db->inTransaction()) {
                    $this->db->rollBack();
                }
                throw $e;
            }
        }

        //already in a transaction: protect the inner work with a savepoint
        $savepoint = 'savepoint_' . (++self::$savepoint_counter);
        $this->db->exec("SAVEPOINT $savepoint");
        try {
            $result = $work();
            $this->db->exec("RELEASE SAVEPOINT $savepoint");
            return $result;
        } catch (\Throwable $e) {
            $this->db->exec("ROLLBACK TO SAVEPOINT $savepoint");
            throw $e;
        }
    }

    /**
     * Fetches all results from a SQL query as an array.
     *
     * This method executes a SQL query and returns the results in the specified fetch mode.
     *
     * @param string $sql The SQL query to be executed.
     * @param array $args An optional array of parameters to bind to the SQL query.
     * @param int $fetchMode The PDO fetch mode to use for the results. Defaults to PDO::FETCH_ASSOC.
     * @return array An array of results from the query, formatted according to the specified fetch mode.
     */
    protected function fetchAll(string $sql, array $args = [], $fetchMode = PDO::FETCH_ASSOC): array
    {
        return (array) $this->run($sql, $args)->fetchAll($fetchMode);
    }

    /**
     * Fetches a single result from a SQL query.
     *
     * This method executes a SQL query and returns a single result in the specified fetch mode.
     *
     * @param string $sql The SQL query to be executed.
     * @param array $conditions An optional array of parameters to bind to the SQL query.
     *                          It should contain the filtering options.
     * @param int $fetchMode The PDO fetch mode to use for the result. Defaults to PDO::FETCH_ASSOC.
     * @return mixed The result of the query, formatted according to the specified fetch mode, or false if no result is found.
     */
    protected function fetchSingle(string $sql, array $conditions = [], $fetchMode = PDO::FETCH_ASSOC)
    {
        return $this->run($sql, $conditions)->fetch($fetchMode);
    }


    /**
     * Returns the result of a COUNT query.
     *
     * This method executes a SELECT COUNT(*) query and returns the number it produces
     * (e.g. "SELECT COUNT(*) FROM users WHERE status = ?"). It reads the first column
     * of the first row, so do not pass a "SELECT *" query.
     *
     * @param string $sql The COUNT query to be executed.
     * @param array $args An optional array of parameters to bind to the SQL query.
     * @return int The count produced by the query, or 0 if the query returns no row.
     */
    protected function count(string $sql, array $args = []): int
    {
        return (int) $this->run($sql, $args)->fetchColumn();
    }

    /**
     * Counts the number of rows that a SELECT query produces.
     *
     * Use it when you need the total number of rows of a query, for example to
     * paginate its results. Pass the same query and parameters that you would
     * pass to fetchAll(), without the LIMIT and OFFSET of the page.
     *
     * The rows are counted by the database (the query is wrapped in a
     * SELECT COUNT(*)), so they are not transferred to PHP. Because of that,
     * every column selected by the query must have a unique name: give an
     * alias to columns that share a name in a JOIN (e.g. two "id" columns).
     *
     * @param string $sql The SELECT query whose rows are to be counted.
     * @param array $args An optional array of parameters to bind to the SQL query.
     * @return int The number of rows that the query produces.
     */
    protected function countRows(string $sql, array $args = []): int
    {
        //a trailing semicolon is not allowed inside a subquery
        $sql = rtrim($sql, "; \t\n\r");

        return $this->count("SELECT COUNT(*) FROM ($sql) AS counted_rows", $args);
    }

    /**
     * Retrieves the ID of the last inserted record.
     *
     * This method returns the ID generated by the last INSERT operation
     * performed by the current database connection.
     *
     * @return string The ID of the last inserted record, or an empty string if no record was inserted.
     */
    protected function lastInsertId(): string
    {
        return $this->db->lastInsertId();
    }

    /**
     * Inserts a new record into the specified table with the provided data.
     *
     * @param string $table The name of the table to insert the record into.
     * @param array $data An associative array of column-value pairs to insert
     *              (e.g., ["username"=>"frostybee", "email" =>"frostybee@me.com"]).
     * @return mixed The ID of the last inserted record or other relevant value,
     *               depending on the implementation.
     */
    protected function insert(string $table, array $data): mixed
    {
        $table = $this->quoteIdentifier($table, 'table');

        if (empty($data)) {
            throw new \InvalidArgumentException(
                "No data provided for insert operation. " .
                    "Please provide an associative array of column-value pairs. " .
                    "Example: ['name' => 'John', 'email' => 'john@example.com']"
            );
        }

        //add columns into comma separated string. Each name is validated and
        //surrounded with backticks to avoid errors related to reserved SQL
        //keywords (e.g. `condition`)
        $columns = implode(',', array_map(fn($key) => $this->quoteIdentifier($key), array_keys($data)));

        //get values
        $values = array_values($data);

        $placeholders = str_repeat('?,', count($data));
        $placeholders = rtrim($placeholders, ',');

        $this->run("INSERT INTO $table ($columns) VALUES ($placeholders)", $values);

        return $this->lastInsertId();
    }

    /**
     * Updates record(s) in the specified table based on the provided data and conditions.
     *
     * @param string $table The name of the table to update.
     * @param array $data An associative array of table column-value pairs to update (e.g.,
     *              ["username"=>"frostybee", "email" =>"frostybee@me.com"]).
     * @param array $where_conditions An associative array of conditions for the update
     *              (e.g., ["user_id"=> 3]). Conditions are joined with AND. A null
     *              value matches rows where the column IS NULL.
     * @return int The number of rows affected by the update operation.
     */
    protected function update(string $table, array $data, array $where_conditions): int
    {
        $table = $this->quoteIdentifier($table, 'table');

        if (empty($data)) {
            throw new \InvalidArgumentException(
                "No data provided for update operation. " .
                    "Please provide an associative array of column-value pairs to update. " .
                    "Example: ['name' => 'Jane', 'email' => 'jane@example.com']"
            );
        }

        if (empty($where_conditions)) {
            throw new \InvalidArgumentException(
                "No WHERE conditions provided for update operation. " .
                    "This prevents accidental updates to all records. " .
                    "Please provide conditions like: ['id' => 5] or ['status' => 'active']"
            );
        }

        //setup fields
        $field_parts = [];
        foreach (array_keys($data) as $key) {
            $field_parts[] = $this->quoteIdentifier($key) . ' = ?';
        }
        $field_details = implode(', ', $field_parts);

        //setup where
        [$where_details, $where_values] = $this->buildWhere($where_conditions);

        //the values of the fields come first, then the values of the conditions
        $values = array_merge(array_values($data), $where_values);

        $stmt = $this->run("UPDATE $table SET $field_details WHERE $where_details", $values);

        return $stmt->rowCount();
    }

    /**
     * Deletes record(s) from the specified table based on the given conditions.
     *
     * By default, at most ONE matching record is deleted. Pass a higher $limit to
     * delete more, or 0 to delete every matching record.
     *
     * @param string $table The name of the table from which to delete records.
     * @param array $where_conditions An associative array of conditions for the deletion
     * in the form of ['table_column' => 'value'] (e.g., ['user_id' => 3]). Conditions
     * are joined with AND. A null value matches rows where the column IS NULL.
     * @param int $limit The maximum number of records to delete. Default is 1.
     *                   Use 0 for no limit.
     *
     * @return int The number of rows affected by the delete operation.
     */
    protected function delete(string $table, array $where_conditions, int $limit = 1): int
    {
        $table = $this->quoteIdentifier($table, 'table');

        if (empty($where_conditions)) {
            throw new \InvalidArgumentException(
                "No WHERE conditions provided for delete operation. " .
                    "This prevents accidental deletion of all records. " .
                    "Please provide conditions like: ['id' => 5] or ['status' => 'inactive']"
            );
        }

        //setup where
        [$where_details, $values] = $this->buildWhere($where_conditions);

        //a limit of 0 (or less) means no limit
        $limit_clause = $limit > 0 ? " LIMIT $limit" : "";

        $stmt = $this->run("DELETE FROM $table WHERE $where_details$limit_clause", $values);

        return $stmt->rowCount();
    }

    /**
     * Sets the pagination options for the current instance.
     *
     * @param int $current_page The current page number.
     * @param int $records_per_page The number of records to include per page.
     * @return void
     */
    public function setPaginationOptions(int $current_page, int $records_per_page): void
    {
        $this->current_page = $current_page;
        $this->records_per_page = $records_per_page;
    }
}
