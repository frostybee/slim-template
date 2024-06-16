<?php

// Production environment

return function (array $settings): array {
    $settings['db']['database'] = 'nail_booking';
    $settings['db']['hostname'] = 'localhost';

    return $settings;
};
