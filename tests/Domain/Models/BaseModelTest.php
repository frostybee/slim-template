<?php

declare(strict_types=1);

namespace Tests\Domain\Models;

use App\Exceptions\DatabaseException;
use App\Helpers\Core\PDOService;
use InvalidArgumentException;
use PDO;
use PDOException;
use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;
use ReflectionProperty;
use RuntimeException;
use Tests\Domain\Models\Fixtures\ExposedModel;
use Tests\Domain\Models\Fixtures\RecordingPDO;

/**
 * Tests BaseModel against an in-memory SQLite database, so no database
 * server is needed. The table and column names are reserved SQL keywords
 * on purpose.
 */
final class BaseModelTest extends TestCase
{
    private RecordingPDO $pdo;
    private ExposedModel $model;

    protected function setUp(): void
    {
        $this->pdo = new RecordingPDO('sqlite::memory:', null, null, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        ]);
        $this->pdo->exec(
            'CREATE TABLE `order` (
                id INTEGER PRIMARY KEY,
                `condition` TEXT,
                `group` TEXT,
                code TEXT UNIQUE,
                deleted_at TEXT
            )'
        );

        // Hand the SQLite connection to PDOService, which skips connecting
        // to MySQL when it already holds a connection.
        $service = new PDOService([]);
        (new ReflectionProperty(PDOService::class, 'db'))->setValue($service, $this->pdo);

        $this->model = new ExposedModel($service);
    }

    private function rows(): array
    {
        return $this->pdo->query('SELECT * FROM `order` ORDER BY id')->fetchAll();
    }

    // --- insert(), update(), delete() with reserved keywords ---------------

    public function testInsertQuotesReservedTableAndColumnNames(): void
    {
        $id = $this->model->callInsert('order', ['condition' => 'good', 'group' => 'a']);

        $this->assertSame('1', $id);
        $this->assertSame('good', $this->rows()[0]['condition']);
        $this->assertStringContainsString('INSERT INTO `order` (`condition`,`group`)', $this->pdo->lastStatement());
    }

    public function testUpdateQuotesReservedTableAndColumnNames(): void
    {
        $this->model->callInsert('order', ['condition' => 'good', 'group' => 'a']);

        $affected = $this->model->callUpdate('order', ['condition' => 'poor'], ['group' => 'a']);

        $this->assertSame(1, $affected);
        $this->assertSame('poor', $this->rows()[0]['condition']);
    }

    public function testDeleteQuotesReservedTableAndColumnNames(): void
    {
        $this->model->callInsert('order', ['condition' => 'good', 'group' => 'a']);

        $affected = $this->model->callDelete('order', ['condition' => 'good'], 0);

        $this->assertSame(1, $affected);
        $this->assertSame([], $this->rows());
    }

    // --- identifier validation ---------------------------------------------

    public static function invalidColumnNames(): array
    {
        return [
            'backtick breakout' => ['id`) VALUES (1); DROP TABLE `order`; --'],
            'space' => ['first name'],
            'expression' => ['1=1 OR id'],
            'starts with digit' => ['1st'],
            'qualified name' => ['order.id'],
            'empty' => [''],
        ];
    }

    #[DataProvider('invalidColumnNames')]
    public function testInsertRejectsInvalidColumnNames(string $column): void
    {
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage($column === '' ? 'Column name cannot be empty' : 'Invalid column name');

        $this->model->callInsert('order', [$column => 1]);
    }

    #[DataProvider('invalidColumnNames')]
    public function testUpdateRejectsInvalidDataColumnNames(string $column): void
    {
        $this->expectException(InvalidArgumentException::class);

        $this->model->callUpdate('order', [$column => 1], ['id' => 1]);
    }

    #[DataProvider('invalidColumnNames')]
    public function testUpdateRejectsInvalidWhereColumnNames(string $column): void
    {
        $this->expectException(InvalidArgumentException::class);

        $this->model->callUpdate('order', ['group' => 'b'], [$column => 1]);
    }

    #[DataProvider('invalidColumnNames')]
    public function testDeleteRejectsInvalidWhereColumnNames(string $column): void
    {
        $this->expectException(InvalidArgumentException::class);

        $this->model->callDelete('order', [$column => 1]);
    }

    public function testInsertRejectsListStyleArray(): void
    {
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage("Invalid column name: '0'");

        $this->model->callInsert('order', ['good', 'a']);
    }

    public static function invalidTableNames(): array
    {
        return [
            'starts with digit' => ['123invalid', "Invalid table name: '123invalid'. Table names can only contain"],
            'qualified name' => ['db.order', 'Invalid table name'],
            'backtick' => ['order`; DROP TABLE `order', 'Invalid table name'],
            'empty' => ['', 'Table name cannot be empty'],
        ];
    }

    #[DataProvider('invalidTableNames')]
    public function testInvalidTableNamesAreRejected(string $table, string $message): void
    {
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage($message);

        $this->model->callInsert($table, ['condition' => 'good']);
    }

    public function testRejectedNamesNeverReachTheDatabase(): void
    {
        try {
            $this->model->callInsert('order', ['id`) VALUES (1); DROP TABLE `order`; --' => 1]);
        } catch (InvalidArgumentException) {
        }

        $this->assertSame([], $this->pdo->statements);
        $this->assertSame([], $this->rows());
    }

    // --- empty input guards ------------------------------------------------

    public function testInsertRejectsEmptyData(): void
    {
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('No data provided for insert operation');

        $this->model->callInsert('order', []);
    }

    public function testUpdateRejectsEmptyWhere(): void
    {
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('No WHERE conditions provided for update operation');

        $this->model->callUpdate('order', ['group' => 'b'], []);
    }

    public function testDeleteRejectsEmptyWhere(): void
    {
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('No WHERE conditions provided for delete operation');

        $this->model->callDelete('order', []);
    }

    // --- count() -----------------------------------------------------------

    public function testCountReturnsTheValueOfACountQuery(): void
    {
        $this->model->callInsert('order', ['group' => 'a']);
        $this->model->callInsert('order', ['group' => 'a']);
        $this->model->callInsert('order', ['group' => 'b']);

        $this->assertSame(3, $this->model->callCount('SELECT COUNT(*) FROM `order`'));
        $this->assertSame(2, $this->model->callCount('SELECT COUNT(*) FROM `order` WHERE `group` = ?', ['a']));
        $this->assertSame(0, $this->model->callCount('SELECT COUNT(*) FROM `order` WHERE `group` = ?', ['none']));
    }

    public function testCountReturnsZeroWhenTheQueryHasNoRow(): void
    {
        $this->assertSame(0, $this->model->callCount('SELECT id FROM `order` WHERE id = ?', [99]));
    }

    // --- countRows() -------------------------------------------------------

    public function testCountRowsReturnsTheNumberOfRowsOfASelectQuery(): void
    {
        $this->model->callInsert('order', ['group' => 'a']);
        $this->model->callInsert('order', ['group' => 'a']);
        $this->model->callInsert('order', ['group' => 'b']);

        $this->assertSame(3, $this->model->callCountRows('SELECT * FROM `order`'));
        $this->assertSame(2, $this->model->callCountRows('SELECT * FROM `order` WHERE `group` = ? ORDER BY id', ['a']));
        $this->assertSame(2, $this->model->callCountRows('SELECT * FROM `order` WHERE `group` = :group', ['group' => 'a']));
        $this->assertSame(0, $this->model->callCountRows('SELECT * FROM `order` WHERE `group` = ?', ['none']));
    }

    public function testCountRowsCountsGroupsAndNotTheRowsBehindThem(): void
    {
        $this->model->callInsert('order', ['group' => 'a']);
        $this->model->callInsert('order', ['group' => 'a']);
        $this->model->callInsert('order', ['group' => 'b']);

        $this->assertSame(2, $this->model->callCountRows('SELECT `group`, COUNT(*) AS total FROM `order` GROUP BY `group`'));
    }

    public function testCountRowsAcceptsATrailingSemicolon(): void
    {
        $this->model->callInsert('order', ['group' => 'a']);

        $this->assertSame(1, $this->model->callCountRows("SELECT * FROM `order`;\n"));
    }

    public function testCountRowsDoesNotTransferTheRows(): void
    {
        $this->model->callCountRows('SELECT * FROM `order` WHERE `group` = ?', ['a']);

        $this->assertSame(
            'SELECT COUNT(*) FROM (SELECT * FROM `order` WHERE `group` = ?) AS counted_rows',
            $this->pdo->lastStatement()
        );
    }

    // --- NULL conditions ---------------------------------------------------

    public function testUpdateMatchesNullConditionsWithIsNull(): void
    {
        $this->model->callInsert('order', ['group' => 'a', 'deleted_at' => null]);
        $this->model->callInsert('order', ['group' => 'a', 'deleted_at' => '2026-01-01']);

        $affected = $this->model->callUpdate('order', ['condition' => 'kept'], ['group' => 'a', 'deleted_at' => null]);

        $this->assertSame(1, $affected);
        $this->assertSame(['kept', null], array_column($this->rows(), 'condition'));
        $this->assertStringContainsString('WHERE `group` = ? AND `deleted_at` IS NULL', $this->pdo->lastStatement());
    }

    public function testDeleteMatchesNullConditionsWithIsNull(): void
    {
        $this->model->callInsert('order', ['group' => 'a', 'deleted_at' => null]);
        $this->model->callInsert('order', ['group' => 'b', 'deleted_at' => '2026-01-01']);

        $affected = $this->model->callDelete('order', ['deleted_at' => null], 0);

        $this->assertSame(1, $affected);
        $this->assertSame(['b'], array_column($this->rows(), 'group'));
    }

    public function testUpdateCanSetAColumnToNull(): void
    {
        $this->model->callInsert('order', ['group' => 'a', 'deleted_at' => '2026-01-01']);

        $this->model->callUpdate('order', ['deleted_at' => null], ['group' => 'a']);

        $this->assertNull($this->rows()[0]['deleted_at']);
    }

    // --- delete() limit ----------------------------------------------------

    public function testDeleteAddsLimitOneByDefault(): void
    {
        // DELETE ... LIMIT is MySQL syntax that SQLite may not accept, so
        // this test checks the generated SQL and not its execution.
        try {
            $this->model->callDelete('order', ['group' => 'a']);
        } catch (DatabaseException) {
        }

        $this->assertSame('DELETE FROM `order` WHERE `group` = ? LIMIT 1', $this->pdo->lastStatement());
    }

    public function testDeleteUsesTheGivenLimit(): void
    {
        try {
            $this->model->callDelete('order', ['group' => 'a'], 5);
        } catch (DatabaseException) {
        }

        $this->assertStringEndsWith(' LIMIT 5', $this->pdo->lastStatement());
    }

    public function testDeleteWithLimitZeroDeletesEveryMatch(): void
    {
        $this->model->callInsert('order', ['group' => 'a']);
        $this->model->callInsert('order', ['group' => 'a']);
        $this->model->callInsert('order', ['group' => 'b']);

        $affected = $this->model->callDelete('order', ['group' => 'a'], 0);

        $this->assertSame(2, $affected);
        $this->assertSame('DELETE FROM `order` WHERE `group` = ?', $this->pdo->lastStatement());
    }

    // --- transaction() -----------------------------------------------------

    public function testTransactionCommitsAndReturnsTheResultOfTheWork(): void
    {
        $result = $this->model->callTransaction(function () {
            $this->model->callInsert('order', ['group' => 'a']);
            return $this->model->callInsert('order', ['group' => 'b']);
        });

        $this->assertSame('2', $result);
        $this->assertCount(2, $this->rows());
        $this->assertFalse($this->pdo->inTransaction());
    }

    public function testTransactionRollsBackWhenTheWorkThrows(): void
    {
        try {
            $this->model->callTransaction(function () {
                $this->model->callInsert('order', ['group' => 'a']);
                throw new RuntimeException('stop');
            });
            $this->fail('The exception was not thrown again.');
        } catch (RuntimeException $e) {
            $this->assertSame('stop', $e->getMessage());
        }

        $this->assertSame([], $this->rows());
        $this->assertFalse($this->pdo->inTransaction());
    }

    public function testTransactionRollsBackWhenTheDatabaseRejectsAQuery(): void
    {
        try {
            $this->model->callTransaction(function () {
                $this->model->callInsert('order', ['code' => 'A1']);
                $this->model->callInsert('order', ['code' => 'A1']);
            });
            $this->fail('The duplicate key was not reported.');
        } catch (DatabaseException) {
        }

        $this->assertSame([], $this->rows());
    }

    public function testNestedTransactionRollsBackOnlyItsOwnWork(): void
    {
        $this->model->callTransaction(function () {
            $this->model->callInsert('order', ['group' => 'outer']);

            try {
                $this->model->callTransaction(function () {
                    $this->model->callInsert('order', ['group' => 'inner']);
                    throw new RuntimeException('inner failed');
                });
            } catch (RuntimeException) {
            }

            $this->model->callInsert('order', ['group' => 'outer again']);
        });

        $this->assertSame(['outer', 'outer again'], array_column($this->rows(), 'group'));
    }

    public function testNestedTransactionKeepsItsWorkWhenItSucceeds(): void
    {
        $this->model->callTransaction(function () {
            $this->model->callInsert('order', ['group' => 'outer']);
            $this->model->callTransaction(fn() => $this->model->callInsert('order', ['group' => 'inner']));
        });

        $this->assertSame(['outer', 'inner'], array_column($this->rows(), 'group'));
    }

    public function testOuterRollbackAlsoUndoesAFinishedNestedTransaction(): void
    {
        try {
            $this->model->callTransaction(function () {
                $this->model->callTransaction(fn() => $this->model->callInsert('order', ['group' => 'inner']));
                throw new RuntimeException('outer failed');
            });
        } catch (RuntimeException) {
        }

        $this->assertSame([], $this->rows());
    }

    // --- errors ------------------------------------------------------------

    public function testDatabaseErrorsCarryTheSqlState(): void
    {
        $this->model->callInsert('order', ['code' => 'A1']);

        try {
            $this->model->callInsert('order', ['code' => 'A1']);
            $this->fail('The duplicate key was not reported.');
        } catch (DatabaseException $e) {
            $this->assertSame('23000', $e->getSqlState());
            $this->assertInstanceOf(RuntimeException::class, $e);
            $this->assertInstanceOf(PDOException::class, $e->getPrevious());
            $this->assertStringStartsWith('Integrity constraint violation.', $e->getMessage());
            $this->assertStringContainsString('Original error:', $e->getMessage());
        }
    }

    public function testQueriesWithoutParametersAlsoReportDatabaseErrors(): void
    {
        $this->expectException(DatabaseException::class);

        $this->model->callFetchAll('SELECT * FROM missing_table');
    }

    // --- parameter binding -------------------------------------------------

    public static function boundValues(): array
    {
        return [
            'integer' => [42, 'integer'],
            'string' => ['42', 'text'],
            'null' => [null, 'null'],
            'true' => [true, 'integer'],
            'false' => [false, 'integer'],
            'float' => [1.5, 'text'],
        ];
    }

    #[DataProvider('boundValues')]
    public function testPositionalParametersAreBoundWithTheirType(mixed $value, string $type): void
    {
        $row = $this->model->callFetchSingle('SELECT typeof(?) AS type', [$value]);

        $this->assertSame($type, $row['type']);
    }

    #[DataProvider('boundValues')]
    public function testNamedParametersAreBoundWithTheirType(mixed $value, string $type): void
    {
        $row = $this->model->callFetchSingle('SELECT typeof(:value) AS type', ['value' => $value]);

        $this->assertSame($type, $row['type']);
    }

    public function testFalseIsStoredAsZeroAndNotAsAnEmptyString(): void
    {
        $row = $this->model->callFetchSingle('SELECT ? AS value', [false]);

        $this->assertSame(0, $row['value']);
    }

    public function testNamedParametersAcceptKeysWithALeadingColon(): void
    {
        $row = $this->model->callFetchSingle('SELECT :a AS a, :b AS b', [':a' => 'x', 'b' => 'y']);

        $this->assertSame(['a' => 'x', 'b' => 'y'], $row);
    }

    public function testPositionalParametersKeepTheirOrderWhenKeysHaveGaps(): void
    {
        // array_filter() keeps the original keys, so the list has a gap.
        $args = array_filter(['x', null, 'y'], fn($value) => $value !== null);

        $row = $this->model->callFetchSingle('SELECT ? AS a, ? AS b', $args);

        $this->assertSame(['a' => 'x', 'b' => 'y'], $row);
    }

    public function testRunReturnsAStatementForRawSql(): void
    {
        $this->model->callInsert('order', ['group' => 'abc']);

        $stmt = $this->model->callRun('UPDATE `order` SET `condition` = ? WHERE `group` LIKE ?', ['fair', 'ab%']);

        $this->assertSame(1, $stmt->rowCount());
    }
}
