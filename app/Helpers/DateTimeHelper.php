<?php

namespace Vanier\Api\Helpers;

use DateTime;
use DateTimeZone;

/**
 * A helper class that provides date and time utility functions.  
 * 
 * @author frostybee  
 */
class DateTimeHelper
{
    /**
     * @var string Year/month/day hour:minute:seconds date and time format.
     */
    const Y_M_D_H_M_S = 'Y\-m\-d\ h:i:s';

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
     * 
     * @see: https://www.php.net/manual/en/timezones.america.php 
     * @return string the current date and time for the specified time zone.
     */
    public static function getDateAndTime(string $format, string $time_zone = 'America/Toronto') : string
    {
        $datetime = new DateTime('now', new DateTimeZone($time_zone));
        return $datetime->format($format);
    }
}
