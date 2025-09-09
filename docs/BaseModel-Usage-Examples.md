# BaseModel Usage Examples

This document provides comprehensive examples of how to use the `BaseModel` class in your Slim API application.

## Table of Contents
- [Basic Setup](#basic-setup)
- [Creating a Model](#creating-a-model)
- [Insert Operations](#insert-operations)
- [Select Operations](#select-operations)
- [Update Operations](#update-operations)
- [Delete Operations](#delete-operations)
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
// 2. Non-empty data array

// This will throw InvalidArgumentException.
try {
    $this->insert('123invalid', $userData); // Invalid table name
} catch (InvalidArgumentException $e) {
    echo $e->getMessage();
    // Output: "Invalid table name: '123invalid'. Table names can only contain..."
}

// This will also throw InvalidArgumentException.
try {
    $this->insert('users', []); // Empty data
} catch (InvalidArgumentException $e) {
    echo $e->getMessage();
    // Output: "No data provided for insert operation. Please provide..."
}
```

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

```php
// Update all inactive users from a specific domain.
$updateData = [
    'status' => 'archived',
    'archived_at' => date('Y-m-d H:i:s')
];

$whereConditions = [
    'status' => 'inactive',
    'email' => '%@olddomain.com' // Note: Use LIKE in SQL for wildcards
];

// For LIKE operations, use raw SQL
$sql = "UPDATE users SET status = ?, archived_at = ? WHERE status = ? AND email LIKE ?";
$stmt = $this->run($sql, ['archived', date('Y-m-d H:i:s'), 'inactive', '%@olddomain.com']);
$affectedRows = $stmt->rowCount();
```

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

## Error Handling

### Common Exception Types

```php
try {
    // Your database operation.
    $result = $this->insert('users', $userData);
    
} catch (InvalidArgumentException $e) {
    // Validation errors (empty data, invalid table names, missing conditions)
    return $response->withJson([
        'error' => 'Validation failed',
        'message' => $e->getMessage()
    ], 400);
    
} catch (RuntimeException $e) {
    // Database connection or SQL execution errors.
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
 