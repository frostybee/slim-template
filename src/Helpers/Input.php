<?php

namespace Vanier\Api\Helpers;


/**
 * A helper class that exposes various data validation functions. 
 */
class Input
{


    /**
     * Checks whether a string contains only alphabetic characters. 
     * @param mixed $value the string to be validated
     * @return mixed false if the value is invalid. Otherwise, the sanitized string will be returned. 
     */
    public static function isAlpha($value)
    {
        $value = filter_var(trim($value), FILTER_SANITIZE_ADD_SLASHES);
        if (ctype_alpha($value)) {
            return $value;
        }
        return false;
    }

    /**
     * Checks whether a value is int and is within a range.
     * @param mixed $value
     * @param int $min
     * @param int $max
     * @return bool|array
     */
    public static function isIntInRange($value, int $min, int $max)
    {
        return filter_var($value, FILTER_VALIDATE_INT, static::getRangeOptions($min, $max));
    }


    /**
     * Checks whether a value is a valid int or not.
     * If the min value is provided and it's greater than 0, 
     * it verifies if the value is > min.
     * @param mixed $input
     * @return mixed bool|array
     */
    public static function isInt($input, int $min = -1): mixed
    {
        if ($min >= 0) {
            return filter_var($input, FILTER_VALIDATE_INT, self::getMinRangeOptions($min));
        }

        return filter_var($input, FILTER_VALIDATE_INT);
    }
    public static function getMinRangeOptions(int $min): array
    {
        return array("options" => array("min_range" => $min));
    }
    public static function getRangeOptions(int $min, int $max): array
    {
        return array(
            "options" =>
            array("min_range" => $min, "max_range" => $max)
        );
    }

    /**
     * Determines whether an array is associative or not.     
     * 
     * An array is "associative" if it doesn't have sequential numerical keys beginning with zero.
     * Note that an array in PHP can be either sequential or associative. 
     *
     * @param  array  $array the array to be verified.
     * @return bool
     */
    public static function isAssoc(array $input): bool
    {
        if (empty($input)) {
            return false;
        }
        $keys = array_keys($input);
        return array_keys($keys) !== $keys;
    }
}
