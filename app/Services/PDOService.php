<?php

namespace App\Services;

use Exception;
use PDO;

class PDOService
{
    private PDO $db;
    private array $config = [];
    private array $options = [
        // Turn off persistent connections
        PDO::ATTR_PERSISTENT => false,
        // Enable exceptions
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        // Emulate prepared statements
        PDO::ATTR_EMULATE_PREPARES => false,
        // Leave column names as returned by the database driver.
        PDO::ATTR_CASE => PDO::CASE_NATURAL,
        // Set default fetch mode to array
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        // Set character set
        PDO::MYSQL_ATTR_INIT_COMMAND => 'SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci'

    ];
    public function __construct(array $config)
    {
        $this->config = $config;
    }
    private function connect(): void
    {
        if (!isset($this->config['database'])) {
            throw new Exception('&args[\'database\'] is required.');
        }

        if (!isset($this->config['username'])) {
            throw new Exception('&args[\'username\']  is required');
        }
        $host = $this->config['host'] ?? 'localhost';
        $charset = 'utf8mb4';
        $port = $this->config['port'] ?? '3306';
        $password = $this->config['password'] ?? '';
        $database = $this->config['database'];
        $username = $this->config['username'];
        try {
            $dsn = "mysql:host=$host;dbname=$database;port=$port;charset=$charset";
            $this->db = new PDO($dsn, $username, $password, $this->options);
        } catch (\PDOException $e) {
            throw new \PDOException($e->getMessage(), (int)$e->getCode());
        }
    }
    function getPDO(): PDO
    {
        $this->connect();
        return $this->db;
    }
}
