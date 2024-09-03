<?php

declare(strict_types=1);

namespace App\Core;

use RuntimeException;

trait PasswordTrait
{
    private $cost = 12;

    /**
     * Returns a hashed password.
     *
     * @param string $plainPassword the user password that needs to be hashed
     * @return string the hashed password.
     */
    public function cryptPassword(string $plainPassword): string
    {
        $hash = password_hash($plainPassword, PASSWORD_BCRYPT, ['cost' => $this->cost]);
        if ($hash === null) {
            throw new RuntimeException("[AuthService] Hashing algorithm is invalid. Blowfish not supported? ");
        }
        if ($hash === false) {
            throw new RuntimeException("[AuthService] Generate blowfish hash failed");
        }
        return $hash;
    }

    public function isPasswordValid(string $plainPassword, string $hash): bool
    {
        return password_verify($plainPassword, $hash);
    }

    public function setCost(int $cost): void
    {
        //@see: https://www.php.net/manual/en/function.password-hash.php
        if ($cost < 4 || $cost > 13) {
            throw new \InvalidArgumentException('Cost must be in the range of 4-31.');
        }
        $this->cost = $cost;
    }
}
