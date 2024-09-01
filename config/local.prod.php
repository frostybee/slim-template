<?php

// Production environment

return function (array $settings): array {
    $settings['db']['database'] = 'worldcup';
    $settings['db']['hostname'] = 'localhost';

    return $settings;
};
