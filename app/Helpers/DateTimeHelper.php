<?php

declare(strict_types=1);

namespace App\Helpers;

use DateTime;
use DateTimeZone;

/**
 * A helper class that provides data and time utility functions.
 *
 * @author frostybee
 */
class DateTimeHelper
{
    /**
     * Year/month/day hour:minute:seconds date and time format
     * @var string
     */
    const Y_M_D_H_M_S = 'Y\-m\-d\ h:i:s';
    /**
     * Year/month/day hour:minute date and time format.
     * @var string .
     */
    const Y_M_D_H_M = 'Y\-m\-d\ h:i';

    /**
     * @var string month/day/year hour:minute:seconds date and time format.
     */
    const M_D_Y_H_M_S = 'm\-d\-Y\ h:i:s';

    /**
     * @var string day/month/year date format.
     */
    const D_M_Y = 'd\-m\-Y';

    /**
     * @var string month/day/year date format.
     */
    const M_D_Y = 'm\-d\-Y';

    /**
     * @var string year/month/year date format.
     */
    const Y_M_D = 'Y\-m\-d';

    /**
     * @var string hour:minutes:seconds time format.
     */
    const H_M_S = 'h:i:s';



    /**
     * Gets the current date and time for the specified time zone.
     * @see: https://www.php.net/manual/en/timezones.america.php
     * @param string $format The format of the date and time to be generated.
     * @param string $time_zone The time zone for which a date should be generated
     * @return string The current date and time for the specified time zone.
     */
    public static function now(string $format, string $time_zone = 'America/Toronto'): string
    {
        $datetime = new DateTime('now', new DateTimeZone($time_zone));
        return $datetime->format($format);
    }
    public static function nowForDb(): string
    {
        return self::now(self::Y_M_D_H_M);
    }
}
