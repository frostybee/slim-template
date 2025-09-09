<?php

declare(strict_types=1);

namespace App\Helpers\Core;

/**
 * Application settings utility class.
 *
 * Provides access to application configuration settings stored in an array.
 * @author  frostybee
 */
class AppSettings
{
    /**
     * The settings array containing configuration data.
     *
     * @var array
     */
    private array $settings;

    /**
     * Constructor to initialize the AppSettings with a settings array.
     *
     * @param array $settings The configuration settings array.
     */
    public function __construct(array $settings)
    {
        $this->settings = $settings;
    }

    /**
     * Retrieves a configuration value by key or all settings if no key is provided.
     *
     * @param string $key The configuration key to retrieve. If empty, returns all settings.
     * @return mixed The configuration value for the given key, or all settings if key is empty.
     */
    public function get(string $key = ''): mixed
    {
        return (empty($key)) ? $this->settings : $this->settings[$key];
    }
}
