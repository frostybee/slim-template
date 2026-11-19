# BaseModel Usage Examples

This document provides comprehensive examples of how to use the `BaseModel` class in your Slim API application.

## Table of Contents
- [Basic Setup](#basic-setup)
- [Creating a Model](#creating-a-model)
- [Insert Operations](#insert-operations)
- [Select Operations](#select-operations)
- [Update Operations](#update-operations)
- [Delete Operations](#delete-operations)
- [Transactions](#transactions)
- [Error Handling](#error-handling)


## Basic Setup

The `BaseModel` is an abstract class that provides database operations using PDO. To use it, create a model class that extends `BaseModel`:

```php
<?php

namespace App\Domain\Models;

use App\Helpers\Core\PDOService;

class UserModel extends BaseModel
{
    public function __construct(PDOService $pdo)
    {
        parent::__construct($pdo);
    }
}
```

## Creating a Model

In your controller or service, instantiate your model:

```php
<?php

use App\Helpers\Core\PDOService;
use App\Domain\Models\UserModel;

// Assuming you have PDOService configured.
$pdoService = new PDOService();
$userModel = new UserModel($pdoService);
```

## Insert Operations

### Basic Insert

```php
// Insert a new user.
$userData = [
    'name' => 'John Doe',
    'email' => 'john@example.com',
    'age' => 25,
    'status' => 'active'
];

try {
    $userId = $this->insert('users', $userData);
    echo "User created with ID: " . $userId;
} catch (InvalidArgumentException $e) {
    echo "Validation error: " . $e->getMessage();
} catch (RuntimeException $e) {
    echo "Database error: " . $e->getMessage();
}
```

### Insert with Validation

```php
// The insert method automatically validates:
// 1. Table name format
// 2. Column name format (the keys of the data array)
// 3. Non-empty data array

// This will throw InvalidArgumentException.
try {
    $this->insert('123invalid', $userData); // Invalid table name
} catch (InvalidArgumentException $e) {
    echo $e->getMessage();
    // Output: "Invalid table name: '123invalid'. Table names can only contain..."
}

// This will also throw InvalidArgumentException.
try {
    $this->insert('users', ['first name' => 'John']); // Invalid column name
} catch (InvalidArgumentException $e) {
    echo $e->getMessage();
    // Output: "Invalid column name: 'first name'. Column names can only contain..."
}

// This will also throw InvalidArgumentException.
try {
    $this->insert('users', []); // Empty data
} catch (InvalidArgumentException $e) {
    echo $e->getMessage();
    // Output: "No data provided for insert operation. Please provide..."
}
```

### Table and Column Names

`insert()`, `update()`, and `delete()` apply the same rules to the table name and to every array key used as a column name:

- A name can contain only letters, numbers, and underscores, and must start with a letter or underscore. Any other name throws `InvalidArgumentException`, which prevents SQL injection through array keys.
- Each name is wrapped in backticks in the generated SQL, so names that are reserved SQL keywords work without extra quoting.

The following example inserts into a column named `condition`, which is a reserved keyword in MariaDB:

```php
$artifactId = $this->insert('artifacts', [
    'artifact_name' => 'Bronze lamp',
    'condition' => 'good'
]);
```

SQL passed to `fetchAll()`, `fetchSingle()`, and `count()` is not changed. Wrap reserved keywords in backticks yourself in those queries.

## Select Operations

### Fetch All Records

```php
// Get all active users.
$sql = "SELECT * FROM users WHERE status = ?";
$users = $this->fetchAll($sql, ['active']);

foreach ($users as $user) {
    echo "User: " . $user['name'] . " (" . $user['email'] . ")\n";
}
```

### Fetch All with Named Parameters

```php
// Using associative array for parameters.
$sql = "SELECT * FROM users WHERE age >= :min_age AND status = :status";
$users = $this->fetchAll($sql, [
    'min_age' => 18,
    'status' => 'active'
]);
```

### Fetch Single Record

```php
// Get a specific user.
$sql = "SELECT * FROM users WHERE id = ?";
$user = $this->fetchSingle($sql, [5]);

if ($user) {
    echo "Found user: " . $user['name'];
} else {
    echo "User not found";
}
```

### Count Records

`count()` runs a `SELECT COUNT(*)` query and returns the number it produces as an integer. It reads the first column of the first row, so do not pass it a `SELECT *` query.

```php
// Count total users.
$sql = "SELECT COUNT(*) as total FROM users";
$count = $this->count($sql);
echo "Total users: " . $count;

// Count with conditions.
$sql = "SELECT COUNT(*) as total FROM users WHERE status = ?";
$activeCount = $this->count($sql, ['active']);
echo "Active users: " . $activeCount;
```

### Count the Rows of a Query

`countRows()` returns the number of rows that a `SELECT` query produces. Use it to get the total for pagination: pass the same query and parameters that you pass to `fetchAll()`, without the `LIMIT` and `OFFSET` of the page.

```php
$sql = "SELECT * FROM users WHERE status = ? ORDER BY name";
$args = ['active'];

// Total number of matching users, across all pages.
$totalUsers = $this->countRows($sql, $args);

// The users of the current page only.
$users = $this->fetchAll($sql . " LIMIT ? OFFSET ?", [...$args, $pageSize, $offset]);
```

The database counts the rows, so they are not transferred to PHP. For that reason, every column selected by the query needs a unique name. If a `JOIN` selects two columns with the same name, give each one an alias:

```php
$sql = "SELECT users.id AS user_id, orders.id AS order_id
        FROM users JOIN orders ON orders.user_id = users.id";
$totalRows = $this->countRows($sql);
```

## Update Operations

### Basic Update

```php
// Update user information.
$updateData = [
    'name' => 'Jane Doe',
    'email' => 'jane.doe@example.com',
    'last_login' => date('Y-m-d H:i:s')
];

$whereConditions = [
    'id' => 5
];

try {
    $affectedRows = $this->update('users', $updateData, $whereConditions);
    echo "Updated {$affectedRows} user(s)";
} catch (InvalidArgumentException $e) {
    echo "Validation error: " . $e->getMessage();
}
```

### Update Multiple Conditions

`update()` joins the conditions with `AND` and compares each one with `=`.

```php
// Archive all inactive users that have the "member" role.
$updateData = [
    'status' => 'archived',
    'archived_at' => date('Y-m-d H:i:s')
];

$whereConditions = [
    'status' => 'inactive',
    'role' => 'member'
];

$affectedRows = $this->update('users', $updateData, $whereConditions);
```

### Conditions with NULL Values

In `update()` and `delete()`, a condition whose value is `null` matches the rows where that column `IS NULL`.

```php
// Archive the users that never logged in.
$affectedRows = $this->update('users', ['status' => 'archived'], ['last_login' => null]);
// Generated SQL: UPDATE `users` SET `status` = ? WHERE `last_login` IS NULL
```

### Update with Raw SQL

For a condition that `update()` cannot express, such as `LIKE`, pass your own SQL to `run()`. `run()` returns a `PDOStatement`.

```php
// Archive all inactive users from a specific email domain.
$sql = "UPDATE users SET status = ?, archived_at = ? WHERE status = ? AND email LIKE ?";
$stmt = $this->run($sql, ['archived', date('Y-m-d H:i:s'), 'inactive', '%@olddomain.com']);
$affectedRows = $stmt->rowCount();
```

`run()` does not validate or quote table and column names. Write them in the SQL yourself, and pass every value through the parameter array.

### Update Validation Examples

```php
// These will throw InvalidArgumentException:

// No data provided
try {
    $this->update('users', [], ['id' => 5]);
} catch (InvalidArgumentException $e) {
    echo $e->getMessage();
    // Output: "No data provided for update operation..."
}

// No WHERE conditions (prevents accidental mass updates)
try {
    $this->update('users', ['status' => 'inactive'], []);
} catch (InvalidArgumentException $e) {
    echo $e->getMessage();
    // Output: "No WHERE conditions provided for update operation..."
}
```

## Delete Operations

`delete()` removes at most one matching record by default, even when several records match the conditions. To delete more, pass a limit as the third argument. Pass `0` to delete every matching record.

### Basic Delete

```php
// Delete a specific user (default limit = 1).
$whereConditions = ['id' => 5];

try {
    $deletedRows = $this->delete('users', $whereConditions);
    echo "Deleted {$deletedRows} user(s)";
} catch (InvalidArgumentException $e) {
    echo "Validation error: " . $e->getMessage();
}
```

### Delete Multiple Records

```php
// Delete multiple inactive users.
$whereConditions = ['status' => 'inactive'];
$limit = 10; // Delete up to 10 records

$deletedRows = $this->delete('users', $whereConditions, $limit);
echo "Deleted {$deletedRows} inactive user(s)";
```

### Delete with No Limit

```php
// Delete all records matching criteria (use with caution!).
$whereConditions = ['status' => 'banned'];
$limit = 0; // No limit

$deletedRows = $this->delete('users', $whereConditions, $limit);
echo "Deleted {$deletedRows} banned user(s)";
```

## Transactions

Use `transaction()` when several changes must succeed or fail together. Pass it a function that performs the changes. If the function finishes, the changes are saved. If it throws an exception, every change made inside it is rolled back and the exception is thrown again.

The following example creates an order and its first item. If the second insert fails, the order is not created either.

```php
public function createOrder(array $orderData, array $itemData): string
{
    return $this->transaction(function () use ($orderData, $itemData) {
        $orderId = $this->insert('orders', $orderData);

        $itemData['order_id'] = $orderId;
        $this->insert('order_items', $itemData);

        return $orderId;
    });
}
```

`transaction()` returns the value that your function returns, here the ID of the new order.

You can call `transaction()` inside another `transaction()`. A failure in the inner call rolls back only the changes of the inner call. The outer function can catch the exception and continue. Nothing is saved until the outer call finishes.

## Error Handling

### Common Exception Types

`BaseModel` throws two kinds of exceptions:

- `InvalidArgumentException` when the arguments are not usable: empty data, an invalid table or column name, or missing conditions. No query is sent to the database.
- `App\Exceptions\DatabaseException` when the database rejects a query. It extends `RuntimeException`. Its `getSqlState()` method returns the SQLSTATE code of the error, for example `23000` for a duplicate key or a foreign key violation.

```php
try {
    // Your database operation.
    $result = $this->insert('users', $userData);
    
} catch (InvalidArgumentException $e) {
    // Validation errors (empty data, invalid table or column names, missing conditions)
    return $response->withJson([
        'error' => 'Validation failed',
        'message' => $e->getMessage()
    ], 400);
    
} catch (DatabaseException $e) {
    // The database rejected the query.
    if ($e->getSqlState() === '23000') {
        // Duplicate key or foreign key violation.
        return $response->withJson([
            'error' => 'Conflict',
            'message' => 'This record already exists or refers to a missing record'
        ], 409);
    }
    error_log('Database error: ' . $e->getMessage());
    return $response->withJson([
        'error' => 'Database operation failed',
        'message' => 'Please try again later'
    ], 500);

} catch (RuntimeException $e) {
    // Other runtime errors, such as a failed database connection.
    error_log('Database error: ' . $e->getMessage());
    return $response->withJson([
        'error' => 'Database operation failed',
        'message' => 'Please try again later'
    ], 500);
    
} catch (Exception $e) {
    // Any other unexpected errors.
    error_log('Unexpected error: ' . $e->getMessage());
    return $response->withJson([
        'error' => 'Internal server error'
    ], 500);
}
```

### Uncaught Exceptions

An exception that you do not catch is turned into a JSON error response by Slim. The response includes the error details (the message, the file, and the original SQL error) only when the `display_error_details` setting is enabled. The setting is off by default and enabled in `config/settings.dev.php`, so the details are visible during development and hidden in production.
