<?php

namespace App\Core;

class AppSettings
{
    private array $settings;

    public function __construct(array $settings)
    {
        $this->settings = $settings;
    }

    /**
     * @return mixed
     */
    public function get(string $key = '') : mixed
    {
        return (empty($key)) ? $this->settings : $this->settings[$key];
    }
}
