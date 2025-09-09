-- Mechanical Switches Database Schema
DROP DATABASE IF EXISTS keyboards_mice;

CREATE DATABASE keyboards_mice;

USE keyboards_mice;

-- Vendors
CREATE TABLE vendors (
    vendor_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    founded_year INT NOT NULL,
    website VARCHAR(255) NOT NULL,
    headquarters VARCHAR(150) NOT NULL
);

-- Switches
CREATE TABLE switches (
    switch_id INT AUTO_INCREMENT PRIMARY KEY,
    vendor_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    type ENUM('Linear', 'Tactile', 'Clicky') NOT NULL,
    actuation_force INT NOT NULL,
    -- grams
    bottom_out_force INT NOT NULL,
    -- grams
    pre_travel DECIMAL(3, 2) NOT NULL,
    -- mm
    total_travel DECIMAL(3, 2) NOT NULL,
    -- mm
    lifespan_million INT NOT NULL,
    -- durability rating
    release_date DATE NOT NULL,
    FOREIGN KEY (vendor_id) REFERENCES vendors(vendor_id)
);

-- Layouts
CREATE TABLE layouts (
    layout_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description VARCHAR(255) NOT NULL,
    key_count INT NOT NULL,
    is_iso BOOLEAN NOT NULL
);

-- Keyboards
CREATE TABLE keyboards (
    keyboard_id INT AUTO_INCREMENT PRIMARY KEY,
    vendor_id INT NOT NULL,
    switch_id INT NOT NULL,
    layout_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    release_date DATE NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    connectivity ENUM('Wired', 'Wireless', 'Both') NOT NULL,
    hot_swappable BOOLEAN NOT NULL,
    case_material VARCHAR(50) NOT NULL,
    weight DECIMAL(6, 2) NOT NULL,
    -- grams
    FOREIGN KEY (vendor_id) REFERENCES vendors(vendor_id),
    FOREIGN KEY (switch_id) REFERENCES switches(switch_id),
    FOREIGN KEY (layout_id) REFERENCES layouts(layout_id)
);

-- Keycap Sets
CREATE TABLE keycap_sets (
    keycap_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    material ENUM('ABS', 'PBT', 'POM') NOT NULL,
    profile VARCHAR(50) NOT NULL,
    manufacturer VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    release_date DATE NOT NULL,
    colorway VARCHAR(100) NOT NULL,
    finish VARCHAR(50) NOT NULL -- e.g. matte, glossy, textured
);

-- Users
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    country VARCHAR(100) NOT NULL,
    join_date DATE NOT NULL
);

-- Reviews
CREATE TABLE reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    keyboard_id INT NOT NULL,
    user_id INT NOT NULL,
    rating INT NOT NULL,
    review_text TEXT NOT NULL,
    review_date DATE NOT NULL,
    FOREIGN KEY (keyboard_id) REFERENCES keyboards(keyboard_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Switch Features
CREATE TABLE switch_features (
    switch_feature_id INT AUTO_INCREMENT PRIMARY KEY,
    switch_id INT NOT NULL,
    feature_name VARCHAR(100) NOT NULL,
    feature_value VARCHAR(255) NOT NULL,
    FOREIGN KEY (switch_id) REFERENCES switches(switch_id)
);

-- Keyboard Images
CREATE TABLE keyboard_images (
    image_id INT AUTO_INCREMENT PRIMARY KEY,
    keyboard_id INT NOT NULL,
    url VARCHAR(255) NOT NULL,
    description VARCHAR(255) NOT NULL,
    is_main BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (keyboard_id) REFERENCES keyboards(keyboard_id)
);

-- Accessories
CREATE TABLE accessories (
    accessory_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL -- e.g. wrist rest, cable, case
);

-- Keyboard Accessories (many-to-many)
CREATE TABLE keyboard_accessories (
    keyboard_id INT NOT NULL,
    accessory_id INT NOT NULL,
    PRIMARY KEY (keyboard_id, accessory_id),
    FOREIGN KEY (keyboard_id) REFERENCES keyboards(keyboard_id),
    FOREIGN KEY (accessory_id) REFERENCES accessories(accessory_id)
);

-- Price History
CREATE TABLE price_history (
    price_id INT AUTO_INCREMENT PRIMARY KEY,
    keyboard_id INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    FOREIGN KEY (keyboard_id) REFERENCES keyboards(keyboard_id)
);

-- Keycap Compatibility (many-to-many)
CREATE TABLE keycap_compatibility (
    keycap_id INT NOT NULL,
    layout_id INT NOT NULL,
    PRIMARY KEY (keycap_id, layout_id),
    FOREIGN KEY (keycap_id) REFERENCES keycap_sets(keycap_id),
    FOREIGN KEY (layout_id) REFERENCES layouts(layout_id)
);

-- Stabilizers
CREATE TABLE stabilizers (
    stabilizer_id INT AUTO_INCREMENT PRIMARY KEY,
    keyboard_id INT NOT NULL,
    type ENUM('Plate-mounted', 'Screw-in', 'Clip-in') NOT NULL,
    material VARCHAR(50) NOT NULL,
    -- e.g. Nylon, POM, Metal
    brand VARCHAR(100) NOT NULL,
    FOREIGN KEY (keyboard_id) REFERENCES keyboards(keyboard_id)
);

-- PCBs
CREATE TABLE pcbs (
    pcb_id INT AUTO_INCREMENT PRIMARY KEY,
    keyboard_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    firmware ENUM('QMK', 'VIA', 'Proprietary') NOT NULL,
    rgb_support BOOLEAN NOT NULL,
    hot_swap_support BOOLEAN NOT NULL,
    FOREIGN KEY (keyboard_id) REFERENCES keyboards(keyboard_id)
);

-- Cases
CREATE TABLE cases (
    case_id INT AUTO_INCREMENT PRIMARY KEY,
    keyboard_id INT NOT NULL,
    material VARCHAR(50) NOT NULL,
    -- Aluminum, Plastic, Polycarbonate
    color VARCHAR(50) NOT NULL,
    finish VARCHAR(50) NOT NULL,
    -- Anodized, Painted, Glossy, Matte
    FOREIGN KEY (keyboard_id) REFERENCES keyboards(keyboard_id)
);

-- Mouse Sensors
CREATE TABLE mouse_sensors (
    sensor_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    dpi_range VARCHAR(50) NOT NULL,
    -- e.g. 100-16000
    max_tracking_speed INT NOT NULL,
    -- Inches per second (IPS)
    max_acceleration DECIMAL(4, 1) NOT NULL -- g
);

-- Mice
CREATE TABLE mice (
    mouse_id INT AUTO_INCREMENT PRIMARY KEY,
    vendor_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    release_date DATE NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    sensor_id INT NOT NULL,
    dpi_min INT NOT NULL,
    dpi_max INT NOT NULL,
    polling_rate INT NOT NULL,
    -- Hz
    connection ENUM('Wired', 'Wireless', 'Both') NOT NULL,
    weight DECIMAL(6, 2) NOT NULL,
    -- grams
    FOREIGN KEY (vendor_id) REFERENCES vendors(vendor_id),
    FOREIGN KEY (sensor_id) REFERENCES mouse_sensors(sensor_id)
);

-- Mouse Buttons
CREATE TABLE mouse_buttons (
    button_id INT AUTO_INCREMENT PRIMARY KEY,
    mouse_id INT NOT NULL,
    name VARCHAR(50) NOT NULL,
    -- e.g. Left, Right, Side, DPI
    programmable BOOLEAN NOT NULL,
    FOREIGN KEY (mouse_id) REFERENCES mice(mouse_id)
);

-- Mouse Reviews
CREATE TABLE mouse_reviews (
    mouse_review_id INT AUTO_INCREMENT PRIMARY KEY,
    mouse_id INT NOT NULL,
    user_id INT NOT NULL,
    rating INT NOT NULL,
    review_text TEXT NOT NULL,
    review_date DATE NOT NULL,
    FOREIGN KEY (mouse_id) REFERENCES mice(mouse_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Mechanical Switches Database Sample Data
-- This file contains INSERT statements for populating the database with realistic data
-- USE keyboards_mice;
-- Insert Vendors
INSERT INTO
    vendors (
        name,
        country,
        founded_year,
        website,
        headquarters
    )
VALUES
    (
        'Cherry Corporation',
        'Germany',
        1953,
        'https://www.cherry.de',
        'Auerbach, Germany'
    ),
    (
        'Gateron',
        'China',
        2000,
        'https://www.gateron.com',
        'Huizhou, China'
    ),
    (
        'Kailh',
        'China',
        1990,
        'https://www.kailh.com',
        'Dongguan, China'
    ),
    (
        'Outemu',
        'China',
        2009,
        'https://www.outemu.com',
        'Guangdong, China'
    ),
    (
        'Razer',
        'Singapore',
        2005,
        'https://www.razer.com',
        'Irvine, USA'
    ),
    (
        'Logitech',
        'Switzerland',
        1981,
        'https://www.logitech.com',
        'Lausanne, Switzerland'
    ),
    (
        'Zealios',
        'Canada',
        2014,
        'https://zealpc.net',
        'Toronto, Canada'
    ),
    (
        'NovelKeys',
        'USA',
        2017,
        'https://novelkeys.xyz',
        'Morgantown, USA'
    ),
    (
        'Durock',
        'China',
        2018,
        'https://durock.com',
        'Shenzhen, China'
    ),
    (
        'Akko',
        'China',
        2016,
        'https://en.akkogear.com',
        'Shenzhen, China'
    ),
    (
        'Glorious',
        'USA',
        2014,
        'https://www.gloriousgaming.com',
        'Dallas, USA'
    ),
    (
        'Drop',
        'USA',
        2012,
        'https://drop.com',
        'San Francisco, USA'
    ),
    (
        'JWK',
        'China',
        2019,
        'https://jwk.com',
        'Shanghai, China'
    ),
    (
        'Everglide',
        'China',
        2020,
        'https://everglide.com',
        'Guangzhou, China'
    ),
    (
        'TTC',
        'China',
        1997,
        'https://www.ttc.com.tw',
        'Taipei, Taiwan'
    ),
    (
        'Huano',
        'China',
        2005,
        'https://huano.com',
        'Dongguan, China'
    ),
    (
        'SP-Star',
        'China',
        2021,
        'https://spstar.com',
        'Shenzhen, China'
    ),
    (
        'KTT',
        'China',
        2015,
        'https://ktt.com',
        'Guangdong, China'
    ),
    (
        'Boba',
        'USA',
        2020,
        'https://ringerkeys.com',
        'California, USA'
    ),
    (
        'C3 Equalz',
        'Singapore',
        2020,
        'https://c3equalz.com',
        'Singapore'
    ),
    (
        'Corsair',
        'USA',
        1994,
        'https://www.corsair.com',
        'Fremont, USA'
    ),
    (
        'SteelSeries',
        'Denmark',
        2001,
        'https://steelseries.com',
        'Copenhagen, Denmark'
    ),
    (
        'HyperX',
        'USA',
        2002,
        'https://www.hyperxgaming.com',
        'Fountain Valley, USA'
    ),
    (
        'Ducky',
        'Taiwan',
        2008,
        'https://www.duckychannel.com.tw',
        'Taipei, Taiwan'
    ),
    (
        'Keychron',
        'Hong Kong',
        2017,
        'https://www.keychron.com',
        'Hong Kong'
    ),
    (
        'ASUS',
        'Taiwan',
        1989,
        'https://www.asus.com',
        'Taipei, Taiwan'
    ),
    (
        'MSI',
        'Taiwan',
        1986,
        'https://www.msi.com',
        'New Taipei City, Taiwan'
    ),
    (
        'Roccat',
        'Germany',
        2007,
        'https://en.roccat.org',
        'Hamburg, Germany'
    ),
    (
        'Cooler Master',
        'Taiwan',
        1992,
        'https://www.coolermaster.com',
        'Taipei, Taiwan'
    ),
    (
        'Filco',
        'Japan',
        1982,
        'https://www.diatec.co.jp',
        'Tokyo, Japan'
    ),
    (
        'Leopold',
        'South Korea',
        1972,
        'https://www.leopold.co.kr',
        'Seoul, South Korea'
    );

-- Insert Layouts
INSERT INTO
    layouts (name, description, key_count, is_iso)
VALUES
    (
        'Full Size',
        'Standard full-size layout with numpad',
        104,
        false
    ),
    (
        'TKL',
        'Tenkeyless layout without numpad',
        87,
        false
    ),
    (
        '75%',
        'Compact layout with function keys',
        82,
        false
    ),
    (
        '65%',
        'Compact layout with arrow keys',
        68,
        false
    ),
    ('60%', 'Ultra-compact layout', 61, false),
    ('40%', 'Minimal ortholinear layout', 47, false),
    (
        'Full Size ISO',
        'ISO standard full-size layout',
        105,
        true
    ),
    ('TKL ISO', 'ISO tenkeyless layout', 88, true),
    (
        '65% ISO',
        'ISO compact layout with arrow keys',
        69,
        true
    ),
    (
        '1800 Compact',
        'Compact full-size with integrated numpad',
        96,
        false
    ),
    ('96%', 'Compact layout with numpad', 96, false),
    (
        'Split Ergonomic',
        'Ergonomic split layout',
        76,
        false
    );

-- Insert Switches (100+ switches)
INSERT INTO
    switches (
        vendor_id,
        name,
        type,
        actuation_force,
        bottom_out_force,
        pre_travel,
        total_travel,
        lifespan_million,
        release_date
    )
VALUES
    -- Cherry switches
    (
        1,
        'MX Red',
        'Linear',
        45,
        75,
        2.00,
        4.00,
        50,
        '2008-01-15'
    ),
    (
        1,
        'MX Black',
        'Linear',
        60,
        80,
        2.00,
        4.00,
        50,
        '1984-03-20'
    ),
    (
        1,
        'MX Brown',
        'Tactile',
        45,
        55,
        2.00,
        4.00,
        50,
        '1994-08-10'
    ),
    (
        1,
        'MX Blue',
        'Clicky',
        50,
        60,
        2.20,
        4.00,
        50,
        '1985-11-05'
    ),
    (
        1,
        'MX Clear',
        'Tactile',
        65,
        95,
        2.00,
        4.00,
        50,
        '2012-06-18'
    ),
    (
        1,
        'MX Green',
        'Clicky',
        80,
        105,
        2.20,
        4.00,
        50,
        '2014-09-22'
    ),
    (
        1,
        'MX Silent Red',
        'Linear',
        45,
        75,
        1.90,
        3.70,
        50,
        '2016-02-14'
    ),
    (
        1,
        'MX Silent Black',
        'Linear',
        60,
        80,
        1.90,
        3.70,
        50,
        '2016-02-14'
    ),
    (
        1,
        'MX Speed Silver',
        'Linear',
        45,
        67,
        1.20,
        3.40,
        50,
        '2016-04-10'
    ),
    (
        1,
        'MX Low Profile Red',
        'Linear',
        45,
        50,
        1.20,
        2.50,
        50,
        '2018-01-08'
    ),
    -- Gateron switches
    (
        2,
        'Red',
        'Linear',
        45,
        60,
        2.00,
        4.00,
        50,
        '2014-03-12'
    ),
    (
        2,
        'Black',
        'Linear',
        60,
        75,
        2.00,
        4.00,
        50,
        '2014-03-12'
    ),
    (
        2,
        'Yellow',
        'Linear',
        50,
        67,
        2.00,
        4.00,
        50,
        '2016-05-20'
    ),
    (
        2,
        'Brown',
        'Tactile',
        55,
        68,
        2.00,
        4.00,
        50,
        '2014-03-12'
    ),
    (
        2,
        'Blue',
        'Clicky',
        60,
        70,
        2.30,
        4.00,
        50,
        '2014-03-12'
    ),
    (
        2,
        'Green',
        'Clicky',
        80,
        95,
        2.30,
        4.00,
        50,
        '2015-07-14'
    ),
    (
        2,
        'Clear',
        'Tactile',
        35,
        45,
        2.00,
        4.00,
        50,
        '2017-09-08'
    ),
    (
        2,
        'White',
        'Clicky',
        35,
        45,
        2.30,
        4.00,
        50,
        '2017-09-08'
    ),
    (
        2,
        'Silent Red',
        'Linear',
        45,
        60,
        2.00,
        4.00,
        50,
        '2018-11-03'
    ),
    (
        2,
        'Silent Brown',
        'Tactile',
        45,
        60,
        2.00,
        4.00,
        50,
        '2018-11-03'
    ),
    (
        2,
        'Ink Red',
        'Linear',
        45,
        60,
        2.00,
        4.00,
        80,
        '2019-02-15'
    ),
    (
        2,
        'Ink Black',
        'Linear',
        60,
        70,
        2.00,
        4.00,
        80,
        '2019-02-15'
    ),
    (
        2,
        'Ink Blue',
        'Clicky',
        60,
        70,
        2.30,
        4.00,
        80,
        '2019-02-15'
    ),
    (
        2,
        'Milky Yellow',
        'Linear',
        50,
        67,
        2.00,
        4.00,
        50,
        '2020-01-10'
    ),
    (
        2,
        'Oil King',
        'Linear',
        55,
        65,
        2.00,
        4.00,
        80,
        '2021-06-25'
    ),
    -- Kailh switches
    (
        3,
        'Red',
        'Linear',
        50,
        70,
        2.00,
        4.00,
        70,
        '2015-04-18'
    ),
    (
        3,
        'Black',
        'Linear',
        60,
        80,
        2.00,
        4.00,
        70,
        '2015-04-18'
    ),
    (
        3,
        'Brown',
        'Tactile',
        50,
        70,
        2.00,
        4.00,
        70,
        '2015-04-18'
    ),
    (
        3,
        'Blue',
        'Clicky',
        60,
        80,
        2.20,
        4.00,
        70,
        '2015-04-18'
    ),
    (
        3,
        'Speed Silver',
        'Linear',
        40,
        50,
        1.10,
        3.50,
        70,
        '2017-08-22'
    ),
    (
        3,
        'Speed Bronze',
        'Clicky',
        40,
        50,
        1.10,
        3.50,
        70,
        '2017-08-22'
    ),
    (
        3,
        'Speed Copper',
        'Tactile',
        40,
        50,
        1.10,
        3.50,
        70,
        '2017-08-22'
    ),
    (
        3,
        'Speed Gold',
        'Clicky',
        40,
        50,
        1.10,
        3.50,
        70,
        '2017-08-22'
    ),
    (
        3,
        'Box Red',
        'Linear',
        45,
        55,
        1.80,
        3.60,
        80,
        '2017-12-05'
    ),
    (
        3,
        'Box Black',
        'Linear',
        60,
        70,
        1.80,
        3.60,
        80,
        '2017-12-05'
    ),
    (
        3,
        'Box Brown',
        'Tactile',
        45,
        55,
        1.80,
        3.60,
        80,
        '2017-12-05'
    ),
    (
        3,
        'Box White',
        'Clicky',
        45,
        55,
        1.80,
        3.60,
        80,
        '2017-12-05'
    ),
    (
        3,
        'Box Jade',
        'Clicky',
        50,
        60,
        1.80,
        3.60,
        80,
        '2018-03-14'
    ),
    (
        3,
        'Box Navy',
        'Clicky',
        65,
        75,
        1.80,
        3.60,
        80,
        '2018-03-14'
    ),
    (
        3,
        'Cream',
        'Linear',
        55,
        65,
        2.00,
        4.00,
        70,
        '2020-05-12'
    ),
    -- Outemu switches
    (
        4,
        'Red',
        'Linear',
        46,
        62,
        2.00,
        4.00,
        50,
        '2015-08-30'
    ),
    (
        4,
        'Black',
        'Linear',
        65,
        82,
        2.00,
        4.00,
        50,
        '2015-08-30'
    ),
    (
        4,
        'Brown',
        'Tactile',
        53,
        65,
        2.00,
        4.00,
        50,
        '2015-08-30'
    ),
    (
        4,
        'Blue',
        'Clicky',
        62,
        73,
        2.20,
        4.00,
        50,
        '2015-08-30'
    ),
    (
        4,
        'Silent White',
        'Linear',
        45,
        62,
        2.00,
        4.00,
        50,
        '2018-07-20'
    ),
    (
        4,
        'Silent Gray',
        'Tactile',
        45,
        62,
        2.00,
        4.00,
        50,
        '2018-07-20'
    ),
    (
        4,
        'Phoenix',
        'Linear',
        45,
        62,
        2.00,
        4.00,
        60,
        '2020-09-15'
    ),
    (
        4,
        'Dustproof Red',
        'Linear',
        46,
        62,
        2.00,
        4.00,
        50,
        '2019-11-08'
    ),
    -- Razer switches
    (
        5,
        'Green',
        'Clicky',
        50,
        70,
        1.90,
        4.00,
        80,
        '2014-01-12'
    ),
    (
        5,
        'Orange',
        'Tactile',
        45,
        65,
        1.90,
        4.00,
        80,
        '2014-01-12'
    ),
    (
        5,
        'Yellow',
        'Linear',
        45,
        65,
        1.20,
        3.50,
        80,
        '2016-06-18'
    ),
    (
        5,
        'Purple',
        'Clicky',
        45,
        65,
        1.50,
        4.00,
        80,
        '2018-10-22'
    ),
    (
        5,
        'Red',
        'Linear',
        45,
        65,
        1.50,
        4.00,
        80,
        '2019-03-07'
    ),
    -- Logitech switches
    (
        6,
        'GX Blue',
        'Clicky',
        50,
        70,
        2.00,
        4.00,
        70,
        '2019-04-15'
    ),
    (
        6,
        'GX Brown',
        'Tactile',
        50,
        60,
        2.00,
        4.00,
        70,
        '2019-04-15'
    ),
    (
        6,
        'GX Red',
        'Linear',
        50,
        60,
        2.00,
        4.00,
        70,
        '2019-04-15'
    ),
    (
        6,
        'GL Clicky',
        'Clicky',
        50,
        60,
        1.50,
        2.90,
        70,
        '2020-08-12'
    ),
    (
        6,
        'GL Tactile',
        'Tactile',
        50,
        60,
        1.50,
        2.90,
        70,
        '2020-08-12'
    ),
    (
        6,
        'GL Linear',
        'Linear',
        50,
        60,
        1.50,
        2.90,
        70,
        '2020-08-12'
    ),
    -- Zealios switches
    (
        7,
        'Zealios V2 62g',
        'Tactile',
        62,
        67,
        2.00,
        4.00,
        100,
        '2019-01-25'
    ),
    (
        7,
        'Zealios V2 65g',
        'Tactile',
        65,
        67,
        2.00,
        4.00,
        100,
        '2019-01-25'
    ),
    (
        7,
        'Zealios V2 67g',
        'Tactile',
        67,
        67,
        2.00,
        4.00,
        100,
        '2019-01-25'
    ),
    (
        7,
        'Zealios V2 78g',
        'Tactile',
        78,
        78,
        2.00,
        4.00,
        100,
        '2019-01-25'
    ),
    (
        7,
        'Tealios V2',
        'Linear',
        67,
        67,
        2.00,
        4.00,
        100,
        '2019-03-10'
    ),
    (
        7,
        'Zilent V2 62g',
        'Tactile',
        62,
        67,
        2.00,
        4.00,
        100,
        '2019-05-18'
    ),
    (
        7,
        'Zilent V2 65g',
        'Tactile',
        65,
        67,
        2.00,
        4.00,
        100,
        '2019-05-18'
    ),
    (
        7,
        'Zilent V2 67g',
        'Tactile',
        67,
        67,
        2.00,
        4.00,
        100,
        '2019-05-18'
    ),
    (
        7,
        'Zilent V2 78g',
        'Tactile',
        78,
        78,
        2.00,
        4.00,
        100,
        '2019-05-18'
    ),
    (
        7,
        'Sakurios',
        'Linear',
        62,
        67,
        2.00,
        4.00,
        100,
        '2020-02-14'
    ),
    -- NovelKeys switches
    (
        8,
        'Cream',
        'Linear',
        55,
        70,
        2.00,
        4.00,
        50,
        '2019-11-20'
    ),
    (
        8,
        'NK_ Yellow',
        'Linear',
        55,
        58,
        2.00,
        4.00,
        80,
        '2020-07-04'
    ),
    (
        8,
        'NK_ Red',
        'Linear',
        45,
        50,
        2.00,
        4.00,
        80,
        '2020-07-04'
    ),
    (
        8,
        'Blueberry',
        'Tactile',
        80,
        80,
        2.00,
        4.00,
        80,
        '2021-01-15'
    ),
    (
        8,
        'Sherbet',
        'Linear',
        52,
        62,
        2.00,
        4.00,
        80,
        '2021-04-22'
    ),
    -- Durock switches
    (
        9,
        'L7',
        'Linear',
        62,
        67,
        2.00,
        4.00,
        100,
        '2020-09-10'
    ),
    (
        9,
        'T1',
        'Tactile',
        67,
        67,
        2.00,
        4.00,
        100,
        '2020-06-18'
    ),
    (
        9,
        'Koala',
        'Tactile',
        62,
        67,
        2.00,
        4.00,
        100,
        '2020-11-25'
    ),
    (
        9,
        'Sunflower',
        'Linear',
        62,
        67,
        2.00,
        4.00,
        100,
        '2021-05-08'
    ),
    (
        9,
        'POM',
        'Linear',
        62,
        67,
        2.00,
        4.00,
        100,
        '2021-08-14'
    ),
    -- Akko switches
    (
        10,
        'Rose Red',
        'Linear',
        43,
        50,
        2.00,
        4.00,
        50,
        '2020-12-03'
    ),
    (
        10,
        'Lavender Purple',
        'Tactile',
        40,
        50,
        2.00,
        4.00,
        50,
        '2020-12-03'
    ),
    (
        10,
        'Ocean Blue',
        'Clicky',
        40,
        50,
        2.00,
        4.00,
        50,
        '2020-12-03'
    ),
    (
        10,
        'Matcha Green',
        'Linear',
        50,
        60,
        2.00,
        4.00,
        50,
        '2021-03-15'
    ),
    (
        10,
        'Starfish',
        'Linear',
        35,
        45,
        2.00,
        4.00,
        50,
        '2021-07-20'
    ),
    -- Glorious switches
    (
        11,
        'Panda',
        'Tactile',
        67,
        67,
        2.00,
        4.00,
        80,
        '2019-08-15'
    ),
    (
        11,
        'Lynx',
        'Linear',
        45,
        50,
        2.00,
        4.00,
        80,
        '2021-02-28'
    ),
    (
        11,
        'Fox',
        'Linear',
        45,
        55,
        2.00,
        4.00,
        80,
        '2021-02-28'
    ),
    -- Drop switches
    (
        12,
        'Holy Panda',
        'Tactile',
        67,
        67,
        2.00,
        4.00,
        80,
        '2019-12-12'
    ),
    (
        12,
        'Halo Clear',
        'Tactile',
        65,
        78,
        2.00,
        4.00,
        80,
        '2018-04-20'
    ),
    (
        12,
        'Halo True',
        'Tactile',
        60,
        100,
        2.00,
        4.00,
        80,
        '2018-04-20'
    ),
    -- JWK switches
    (
        13,
        'Alpaca',
        'Linear',
        62,
        62,
        2.00,
        4.00,
        80,
        '2020-10-05'
    ),
    (
        13,
        'Mauve',
        'Linear',
        62,
        62,
        2.00,
        4.00,
        80,
        '2021-01-18'
    ),
    (
        13,
        'Ultimate Black',
        'Linear',
        62,
        62,
        2.00,
        4.00,
        80,
        '2021-06-30'
    ),
    -- Everglide switches
    (
        14,
        'Aqua King',
        'Linear',
        55,
        62,
        2.00,
        4.00,
        80,
        '2021-09-12'
    ),
    (
        14,
        'Dark Jade',
        'Tactile',
        55,
        68,
        2.00,
        4.00,
        80,
        '2021-11-25'
    ),
    (
        14,
        'Oreo',
        'Tactile',
        55,
        68,
        2.00,
        4.00,
        80,
        '2022-02-14'
    ),
    -- TTC switches
    (
        15,
        'Gold Red',
        'Linear',
        45,
        55,
        2.00,
        4.00,
        50,
        '2020-05-30'
    ),
    (
        15,
        'Gold Brown',
        'Tactile',
        55,
        63,
        2.00,
        4.00,
        50,
        '2020-05-30'
    ),
    (
        15,
        'Bluish White',
        'Tactile',
        50,
        60,
        2.00,
        4.00,
        50,
        '2021-08-07'
    ),
    -- Additional premium switches for variety
    (
        16,
        'White Jade',
        'Linear',
        55,
        63,
        2.00,
        4.00,
        60,
        '2021-03-20'
    ),
    (
        17,
        'Meteor White',
        'Linear',
        50,
        60,
        2.00,
        4.00,
        70,
        '2021-06-15'
    ),
    (
        18,
        'Wine Red',
        'Linear',
        45,
        55,
        2.00,
        4.00,
        80,
        '2021-09-28'
    ),
    (
        19,
        'U4T',
        'Tactile',
        62,
        68,
        2.00,
        4.00,
        100,
        '2021-04-10'
    ),
    (
        20,
        'Tangerine',
        'Linear',
        62,
        67,
        2.00,
        4.00,
        100,
        '2020-08-25'
    ),
    -- Corsair switches
    (
        21,
        'Speed Silver',
        'Linear',
        45,
        65,
        1.20,
        3.40,
        70,
        '2016-08-15'
    ),
    (
        21,
        'Speed',
        'Linear',
        45,
        65,
        1.20,
        3.40,
        70,
        '2017-03-20'
    ),
    (
        21,
        'Silent',
        'Linear',
        45,
        65,
        1.90,
        3.70,
        70,
        '2018-09-12'
    ),
    -- SteelSeries switches
    (
        22,
        'QX2',
        'Linear',
        45,
        78,
        2.00,
        4.00,
        50,
        '2019-05-30'
    ),
    (
        22,
        'Red',
        'Linear',
        45,
        75,
        2.00,
        4.00,
        50,
        '2020-02-18'
    ),
    (
        22,
        'Blue',
        'Clicky',
        50,
        75,
        2.20,
        4.00,
        50,
        '2020-02-18'
    ),
    -- HyperX switches
    (
        23,
        'Red',
        'Linear',
        45,
        70,
        1.80,
        3.80,
        80,
        '2019-01-25'
    ),
    (
        23,
        'Aqua',
        'Tactile',
        45,
        70,
        1.80,
        3.80,
        80,
        '2019-01-25'
    ),
    (
        23,
        'Blue',
        'Clicky',
        50,
        70,
        1.80,
        3.80,
        80,
        '2019-01-25'
    ),
    -- Roccat switches
    (
        28,
        'Titan Brown',
        'Tactile',
        50,
        65,
        1.80,
        3.60,
        50,
        '2018-07-12'
    ),
    (
        28,
        'Titan Red',
        'Linear',
        45,
        60,
        1.80,
        3.60,
        50,
        '2018-07-12'
    ),
    (
        28,
        'Titan Blue',
        'Clicky',
        50,
        65,
        1.80,
        3.60,
        50,
        '2018-07-12'
    ),
    -- Cooler Master switches
    (
        29,
        'Aimpad',
        'Linear',
        35,
        70,
        1.50,
        4.00,
        70,
        '2020-11-08'
    ),
    -- More premium options
    (
        30,
        'Majestouch Linear',
        'Linear',
        45,
        60,
        2.00,
        4.00,
        50,
        '2019-08-22'
    ),
    (
        31,
        'FC980M Tactile',
        'Tactile',
        55,
        67,
        2.00,
        4.00,
        50,
        '2020-03-15'
    );

-- Insert Keyboards (100+ keyboards)
INSERT INTO
    keyboards (
        vendor_id,
        switch_id,
        layout_id,
        name,
        release_date,
        price,
        connectivity,
        hot_swappable,
        case_material,
        weight
    )
VALUES
    -- Cherry keyboards
    (
        1,
        1,
        1,
        'MX Board 3.0S',
        '2018-03-15',
        129.99,
        'Wired',
        false,
        'Plastic',
        1200.00
    ),
    (
        1,
        2,
        2,
        'MX Board 8.0',
        '2017-09-20',
        179.99,
        'Wired',
        false,
        'Aluminum',
        1450.00
    ),
    (
        1,
        3,
        1,
        'MX Board 1.0 TKL',
        '2019-06-12',
        99.99,
        'Wired',
        false,
        'Plastic',
        950.00
    ),
    (
        1,
        4,
        3,
        'MX Board 2.0S',
        '2020-01-08',
        149.99,
        'Wired',
        false,
        'Aluminum',
        1100.00
    ),
    (
        1,
        7,
        5,
        'MX Keys Mini',
        '2021-08-25',
        199.99,
        'Wireless',
        false,
        'Aluminum',
        750.00
    ),
    -- Gateron/Custom builds
    (
        2,
        11,
        5,
        'Keychron K6',
        '2020-04-15',
        79.99,
        'Both',
        true,
        'Aluminum',
        820.00
    ),
    (
        2,
        12,
        4,
        'Keychron Q1',
        '2021-07-20',
        179.99,
        'Wired',
        true,
        'Aluminum',
        1580.00
    ),
    (
        2,
        13,
        3,
        'Keychron Q2',
        '2021-11-15',
        189.99,
        'Wired',
        true,
        'Aluminum',
        1420.00
    ),
    (
        2,
        14,
        2,
        'Keychron Q3',
        '2022-02-10',
        199.99,
        'Wired',
        true,
        'Aluminum',
        1680.00
    ),
    (
        2,
        15,
        1,
        'Keychron Q5',
        '2022-06-05',
        219.99,
        'Wired',
        true,
        'Aluminum',
        1950.00
    ),
    -- Kailh keyboards
    (
        3,
        19,
        5,
        'Anne Pro 2',
        '2018-12-01',
        89.99,
        'Both',
        false,
        'Plastic',
        780.00
    ),
    (
        3,
        20,
        4,
        'Ducky One 2 Mini',
        '2019-03-18',
        109.99,
        'Wired',
        false,
        'Plastic',
        590.00
    ),
    (
        3,
        21,
        2,
        'Ducky One 2 TKL',
        '2018-11-22',
        119.99,
        'Wired',
        false,
        'Plastic',
        890.00
    ),
    (
        3,
        22,
        1,
        'Ducky One 2',
        '2018-08-30',
        129.99,
        'Wired',
        false,
        'Plastic',
        1180.00
    ),
    (
        3,
        29,
        5,
        'Vortex Pok3r',
        '2015-05-12',
        149.99,
        'Wired',
        false,
        'Aluminum',
        950.00
    ),
    -- Outemu keyboards
    (
        4,
        31,
        1,
        'Tecware Phantom',
        '2019-07-15',
        49.99,
        'Wired',
        true,
        'Plastic',
        1050.00
    ),
    (
        4,
        32,
        2,
        'Tecware Phantom TKL',
        '2019-09-20',
        44.99,
        'Wired',
        true,
        'Plastic',
        850.00
    ),
    (
        4,
        33,
        5,
        'GK61',
        '2020-02-28',
        39.99,
        'Wired',
        true,
        'Plastic',
        650.00
    ),
    (
        4,
        34,
        4,
        'GK68',
        '2020-05-10',
        49.99,
        'Both',
        true,
        'Plastic',
        720.00
    ),
    (
        4,
        38,
        3,
        'EPOMAKER GK96',
        '2021-01-15',
        79.99,
        'Both',
        true,
        'Aluminum',
        1250.00
    ),
    -- Razer keyboards
    (
        5,
        39,
        2,
        'BlackWidow V3 TKL',
        '2020-08-11',
        139.99,
        'Wired',
        false,
        'Aluminum',
        1100.00
    ),
    (
        5,
        40,
        1,
        'BlackWidow V3',
        '2020-08-11',
        169.99,
        'Wired',
        false,
        'Aluminum',
        1400.00
    ),
    (
        5,
        41,
        5,
        'Huntsman Mini',
        '2020-02-18',
        119.99,
        'Wired',
        false,
        'Aluminum',
        680.00
    ),
    (
        5,
        42,
        4,
        'Huntsman 65',
        '2021-09-14',
        149.99,
        'Wired',
        false,
        'Aluminum',
        850.00
    ),
    (
        5,
        43,
        2,
        'Huntsman TKL',
        '2019-06-03',
        129.99,
        'Wired',
        false,
        'Aluminum',
        980.00
    ),
    -- Logitech keyboards
    (
        6,
        44,
        1,
        'G915',
        '2019-08-26',
        249.99,
        'Both',
        false,
        'Aluminum',
        1025.00
    ),
    (
        6,
        45,
        2,
        'G915 TKL',
        '2020-07-14',
        229.99,
        'Both',
        false,
        'Aluminum',
        810.00
    ),
    (
        6,
        46,
        1,
        'G815',
        '2019-04-30',
        199.99,
        'Wired',
        false,
        'Aluminum',
        1180.00
    ),
    (
        6,
        47,
        2,
        'G Pro X',
        '2019-08-15',
        149.99,
        'Wired',
        true,
        'Aluminum',
        980.00
    ),
    (
        6,
        48,
        5,
        'G Pro 60',
        '2022-03-22',
        179.99,
        'Both',
        true,
        'Aluminum',
        750.00
    ),
    -- Premium/Enthusiast keyboards
    (
        7,
        49,
        5,
        'Tofu65',
        '2019-10-05',
        158.00,
        'Wired',
        true,
        'Aluminum',
        1100.00
    ),
    (
        7,
        50,
        4,
        'NK65 Entry',
        '2020-01-20',
        95.00,
        'Wired',
        true,
        'Aluminum',
        900.00
    ),
    (
        7,
        51,
        3,
        'Think6.5 V2',
        '2021-04-12',
        385.00,
        'Wired',
        true,
        'Aluminum',
        1650.00
    ),
    (
        7,
        52,
        5,
        'Mode Sixty Five',
        '2021-11-30',
        429.00,
        'Wired',
        true,
        'Aluminum',
        1480.00
    ),
    (
        7,
        53,
        2,
        'Polaris75',
        '2022-01-18',
        350.00,
        'Wired',
        true,
        'Aluminum',
        1520.00
    ),
    -- More variety across different vendors and switches
    (
        8,
        54,
        5,
        'Savage65',
        '2020-12-08',
        275.00,
        'Wired',
        true,
        'Aluminum',
        1350.00
    ),
    (
        8,
        55,
        4,
        'Brutal60',
        '2021-05-25',
        195.00,
        'Wired',
        true,
        'Polycarbonate',
        950.00
    ),
    (
        8,
        56,
        3,
        'Discipline65',
        '2021-08-14',
        120.00,
        'Wired',
        true,
        'FR4',
        650.00
    ),
    (
        9,
        57,
        5,
        'Bakeneko60',
        '2021-09-28',
        130.00,
        'Wired',
        true,
        'Aluminum',
        980.00
    ),
    (
        9,
        58,
        4,
        'Space65',
        '2020-11-15',
        395.00,
        'Wired',
        true,
        'Aluminum',
        1420.00
    ),
    -- Akko keyboards
    (
        10,
        59,
        5,
        'Akko 3068B',
        '2021-02-14',
        79.99,
        'Both',
        false,
        'Plastic',
        750.00
    ),
    (
        10,
        60,
        4,
        'Akko 3084B',
        '2021-04-20',
        89.99,
        'Both',
        false,
        'Plastic',
        850.00
    ),
    (
        10,
        61,
        2,
        'Akko 3087',
        '2020-10-18',
        69.99,
        'Wired',
        false,
        'Plastic',
        920.00
    ),
    (
        10,
        62,
        1,
        'Akko 3108',
        '2020-08-12',
        79.99,
        'Wired',
        false,
        'Plastic',
        1150.00
    ),
    (
        10,
        63,
        5,
        'Akko MOD007B',
        '2022-01-25',
        159.99,
        'Both',
        true,
        'Aluminum',
        1050.00
    ),
    -- Glorious keyboards
    (
        11,
        64,
        1,
        'GMMK Pro',
        '2021-03-31',
        169.99,
        'Wired',
        true,
        'Aluminum',
        1360.00
    ),
    (
        11,
        65,
        2,
        'GMMK TKL',
        '2020-09-15',
        109.99,
        'Wired',
        true,
        'Plastic',
        890.00
    ),
    (
        11,
        66,
        5,
        'GMMK Compact',
        '2019-11-20',
        79.99,
        'Wired',
        true,
        'Plastic',
        650.00
    ),
    (
        11,
        64,
        4,
        'GMMK 65',
        '2021-12-07',
        119.99,
        'Wired',
        true,
        'Plastic',
        780.00
    ),
    (
        11,
        65,
        3,
        'GMMK 75',
        '2022-05-16',
        149.99,
        'Wired',
        true,
        'Aluminum',
        1180.00
    ),
    -- Drop keyboards
    (
        12,
        67,
        5,
        'ALT',
        '2018-07-20',
        200.00,
        'Wired',
        true,
        'Aluminum',
        1050.00
    ),
    (
        12,
        68,
        2,
        'CTRL',
        '2018-05-15',
        220.00,
        'Wired',
        true,
        'Aluminum',
        1480.00
    ),
    (
        12,
        69,
        5,
        'Planck',
        '2017-12-10',
        150.00,
        'Wired',
        true,
        'Aluminum',
        580.00
    ),
    (
        12,
        67,
        4,
        'Carina',
        '2021-10-12',
        189.00,
        'Wired',
        true,
        'Aluminum',
        980.00
    ),
    (
        12,
        68,
        3,
        'Sense75',
        '2022-03-08',
        349.00,
        'Wired',
        true,
        'Aluminum',
        1650.00
    ),
    -- Additional JWK builds
    (
        13,
        70,
        5,
        'Alpaca Build 60',
        '2021-01-30',
        285.00,
        'Wired',
        true,
        'Aluminum',
        1150.00
    ),
    (
        13,
        71,
        4,
        'Mauve Build 65',
        '2021-06-18',
        315.00,
        'Wired',
        true,
        'Polycarbonate',
        1250.00
    ),
    (
        13,
        72,
        3,
        'Ultimate Black 75',
        '2021-11-25',
        375.00,
        'Wired',
        true,
        'Aluminum',
        1580.00
    ),
    -- Everglide keyboards
    (
        14,
        73,
        5,
        'Aqua King 60',
        '2022-01-14',
        295.00,
        'Wired',
        true,
        'Aluminum',
        1080.00
    ),
    (
        14,
        74,
        4,
        'Dark Jade 65',
        '2022-04-22',
        325.00,
        'Wired',
        true,
        'Aluminum',
        1220.00
    ),
    (
        14,
        75,
        2,
        'Oreo TKL',
        '2022-07-08',
        385.00,
        'Wired',
        true,
        'Aluminum',
        1450.00
    ),
    -- TTC keyboards
    (
        15,
        76,
        5,
        'Gold Series 60',
        '2021-08-15',
        189.00,
        'Wired',
        true,
        'Aluminum',
        950.00
    ),
    (
        15,
        77,
        4,
        'Gold Series 65',
        '2021-10-20',
        215.00,
        'Wired',
        true,
        'Aluminum',
        1050.00
    ),
    (
        15,
        78,
        3,
        'Bluish White 75',
        '2022-02-28',
        275.00,
        'Wired',
        true,
        'Aluminum',
        1380.00
    ),
    -- More budget-friendly options
    (
        4,
        31,
        5,
        'RK61',
        '2020-06-12',
        34.99,
        'Both',
        true,
        'Plastic',
        580.00
    ),
    (
        4,
        32,
        4,
        'RK68',
        '2020-08-25',
        39.99,
        'Both',
        true,
        'Plastic',
        650.00
    ),
    (
        4,
        33,
        2,
        'RK87',
        '2020-04-18',
        44.99,
        'Both',
        true,
        'Plastic',
        820.00
    ),
    (
        3,
        19,
        5,
        'Kemove Shadow',
        '2020-11-30',
        59.99,
        'Both',
        true,
        'Plastic',
        680.00
    ),
    (
        3,
        20,
        4,
        'Kemove Snowfox',
        '2021-02-14',
        69.99,
        'Both',
        true,
        'Plastic',
        750.00
    ),
    -- High-end custom keyboards
    (
        7,
        49,
        5,
        'Iron165 R2',
        '2021-06-30',
        485.00,
        'Wired',
        true,
        'Aluminum',
        1650.00
    ),
    (
        8,
        54,
        4,
        'Voice65',
        '2021-09-15',
        395.00,
        'Wired',
        true,
        'Aluminum',
        1420.00
    ),
    (
        9,
        57,
        3,
        'Salvation',
        '2021-12-08',
        425.00,
        'Wired',
        true,
        'Aluminum',
        1580.00
    ),
    (
        7,
        50,
        5,
        'Satisfaction75 R2',
        '2021-04-22',
        535.00,
        'Wired',
        true,
        'Aluminum',
        1750.00
    ),
    (
        8,
        55,
        4,
        'Fuji75',
        '2022-01-18',
        315.00,
        'Wired',
        true,
        'Aluminum',
        1380.00
    ),
    -- Gaming-focused keyboards
    (
        5,
        39,
        5,
        'DeathStalker V2 Pro',
        '2022-05-24',
        249.99,
        'Both',
        false,
        'Aluminum',
        950.00
    ),
    (
        6,
        44,
        5,
        'G Pro X Superlight',
        '2022-08-15',
        199.99,
        'Both',
        true,
        'Aluminum',
        680.00
    ),
    (
        1,
        1,
        2,
        'MX Board 3.0S RGB',
        '2019-11-12',
        159.99,
        'Wired',
        false,
        'Aluminum',
        1280.00
    ),
    (
        11,
        64,
        5,
        'Model O Wireless',
        '2021-07-20',
        129.99,
        'Both',
        true,
        'Aluminum',
        750.00
    ),
    (
        2,
        11,
        4,
        'Huntsman V2 Analog',
        '2021-03-30',
        179.99,
        'Wired',
        false,
        'Aluminum',
        980.00
    ),
    -- Corsair keyboards
    (
        21,
        84,
        1,
        'K100 RGB',
        '2020-09-21',
        229.99,
        'Wired',
        false,
        'Aluminum',
        1200.00
    ),
    (
        21,
        85,
        2,
        'K70 RGB MK.2',
        '2018-01-09',
        169.99,
        'Wired',
        false,
        'Aluminum',
        1020.00
    ),
    (
        21,
        86,
        5,
        'K65 RGB MINI',
        '2020-11-17',
        109.99,
        'Wired',
        false,
        'Aluminum',
        680.00
    ),
    -- SteelSeries keyboards
    (
        22,
        87,
        2,
        'Apex Pro TKL',
        '2019-07-16',
        199.99,
        'Wired',
        false,
        'Aluminum',
        900.00
    ),
    (
        22,
        88,
        1,
        'Apex Pro',
        '2019-07-16',
        229.99,
        'Wired',
        false,
        'Aluminum',
        1100.00
    ),
    (
        22,
        89,
        5,
        'Apex 7 TKL',
        '2019-02-12',
        139.99,
        'Wired',
        false,
        'Aluminum',
        850.00
    ),
    -- HyperX keyboards
    (
        23,
        90,
        2,
        'Alloy Elite RGB',
        '2018-03-27',
        119.99,
        'Wired',
        false,
        'Aluminum',
        980.00
    ),
    (
        23,
        91,
        1,
        'Alloy Origins',
        '2019-06-11',
        109.99,
        'Wired',
        false,
        'Aluminum',
        1050.00
    ),
    (
        23,
        92,
        5,
        'Alloy Origins 60',
        '2020-10-06',
        99.99,
        'Wired',
        false,
        'Aluminum',
        750.00
    ),
    -- Ducky keyboards
    (
        24,
        25,
        5,
        'One 3 Mini',
        '2020-02-18',
        99.99,
        'Wired',
        false,
        'Plastic',
        650.00
    ),
    (
        24,
        26,
        2,
        'One 3 TKL',
        '2020-02-18',
        119.99,
        'Wired',
        false,
        'Plastic',
        850.00
    ),
    (
        24,
        27,
        1,
        'One 3',
        '2020-02-18',
        139.99,
        'Wired',
        false,
        'Plastic',
        1100.00
    ),
    -- ASUS keyboards
    (
        26,
        93,
        2,
        'ROG Strix Scope TKL',
        '2019-08-20',
        129.99,
        'Wired',
        false,
        'Aluminum',
        920.00
    ),
    (
        26,
        94,
        1,
        'ROG Claymore II',
        '2021-04-13',
        249.99,
        'Both',
        true,
        'Aluminum',
        1280.00
    ),
    -- Roccat keyboards
    (
        28,
        95,
        2,
        'Vulcan 122 AIMO',
        '2019-01-15',
        159.99,
        'Wired',
        false,
        'Aluminum',
        980.00
    ),
    (
        28,
        96,
        5,
        'Vulcan TKL Pro',
        '2020-08-25',
        139.99,
        'Wired',
        false,
        'Aluminum',
        780.00
    ),
    -- Filco keyboards
    (
        30,
        97,
        2,
        'Majestouch 2 TKL',
        '2018-05-10',
        149.99,
        'Wired',
        false,
        'Plastic',
        900.00
    ),
    (
        30,
        98,
        1,
        'Majestouch 2',
        '2018-05-10',
        169.99,
        'Wired',
        false,
        'Plastic',
        1150.00
    ),
    -- Leopold keyboards
    (
        31,
        99,
        4,
        'FC660M',
        '2019-09-12',
        119.99,
        'Wired',
        false,
        'Plastic',
        850.00
    ),
    (
        31,
        100,
        2,
        'FC750R',
        '2019-09-12',
        139.99,
        'Wired',
        false,
        'Plastic',
        950.00
    );

-- Insert KeycapSets
INSERT INTO
    keycap_sets (
        name,
        material,
        profile,
        manufacturer,
        price,
        release_date,
        colorway,
        finish
    )
VALUES
    (
        'GMK Olivia++',
        'ABS',
        'Cherry',
        'GMK',
        139.00,
        '2020-11-15',
        'Light Pink/Cream',
        'Glossy'
    ),
    (
        'GMK Botanical',
        'ABS',
        'Cherry',
        'GMK',
        135.00,
        '2020-08-20',
        'Green/Cream',
        'Glossy'
    ),
    (
        'GMK Dracula',
        'ABS',
        'Cherry',
        'GMK',
        129.00,
        '2020-05-12',
        'Purple/Pink',
        'Glossy'
    ),
    (
        'GMK Cafe',
        'ABS',
        'Cherry',
        'GMK',
        132.00,
        '2019-12-08',
        'Brown/Cream',
        'Glossy'
    ),
    (
        'GMK Hennessey',
        'ABS',
        'Cherry',
        'GMK',
        138.00,
        '2021-03-25',
        'Cognac/Gold',
        'Glossy'
    ),
    (
        'SA Bliss',
        'PBT',
        'SA',
        'Signature Plastics',
        175.00,
        '2019-09-14',
        'Pink/Purple',
        'Matte'
    ),
    (
        'SA Godspeed',
        'PBT',
        'SA',
        'Signature Plastics',
        165.00,
        '2018-06-30',
        'Blue/Orange',
        'Matte'
    ),
    (
        'MT3 Susuwatari',
        'PBT',
        'MT3',
        'Drop',
        95.00,
        '2020-04-18',
        'Black/Gray',
        'Textured'
    ),
    (
        'MT3 Serika',
        'PBT',
        'MT3',
        'Drop',
        99.00,
        '2019-11-22',
        'Yellow/Black',
        'Textured'
    ),
    (
        'KAT Explosion',
        'PBT',
        'KAT',
        'Keyreative',
        125.00,
        '2021-02-14',
        'Red/Black',
        'Matte'
    ),
    (
        'Cherry WoB',
        'PBT',
        'Cherry',
        'Cherry',
        45.00,
        '2020-01-10',
        'White/Black',
        'Matte'
    ),
    (
        'Akko ASA Neon',
        'PBT',
        'ASA',
        'Akko',
        39.99,
        '2021-07-05',
        'Cyan/Pink',
        'Matte'
    ),
    (
        'Akko Cherry Retro',
        'PBT',
        'Cherry',
        'Akko',
        35.99,
        '2021-04-12',
        'Beige/Brown',
        'Matte'
    ),
    (
        'HyperX Pudding',
        'ABS',
        'OEM',
        'HyperX',
        24.99,
        '2019-08-15',
        'Black/Clear',
        'Glossy'
    ),
    (
        'Razer PBT',
        'PBT',
        'OEM',
        'Razer',
        39.99,
        '2020-03-20',
        'Black',
        'Matte'
    ),
    (
        'Ducky Joker',
        'PBT',
        'Cherry',
        'Ducky',
        59.99,
        '2020-10-31',
        'Purple/Green',
        'Textured'
    ),
    (
        'Varmilo Sea Melody',
        'PBT',
        'Cherry',
        'Varmilo',
        75.00,
        '2021-06-18',
        'Blue/White',
        'Matte'
    ),
    (
        'XDA Canvas',
        'PBT',
        'XDA',
        'Signature Plastics',
        155.00,
        '2019-05-25',
        'Orange/Blue',
        'Matte'
    ),
    (
        'DSA Scientific',
        'PBT',
        'DSA',
        'Signature Plastics',
        145.00,
        '2020-09-10',
        'Gray/Green',
        'Matte'
    ),
    (
        'Epbt Kuro Shiro',
        'PBT',
        'Cherry',
        'EnjoyPBT',
        89.00,
        '2020-12-22',
        'Black/White',
        'Textured'
    ),
    (
        'GMK Laser',
        'ABS',
        'Cherry',
        'GMK',
        145.00,
        '2021-09-15',
        'Cyan/Magenta',
        'Glossy'
    ),
    (
        'GMK Metropolis',
        'ABS',
        'Cherry',
        'GMK',
        142.00,
        '2021-03-08',
        'Dark Blue/White',
        'Glossy'
    ),
    (
        'GMK Red Samurai',
        'ABS',
        'Cherry',
        'GMK',
        138.00,
        '2020-07-22',
        'Red/Black',
        'Glossy'
    ),
    (
        'SA Godspeed Armstrong',
        'PBT',
        'SA',
        'Signature Plastics',
        185.00,
        '2021-11-12',
        'Blue/White',
        'Matte'
    ),
    (
        'KAT Milkshake',
        'PBT',
        'KAT',
        'Keyreative',
        135.00,
        '2021-06-30',
        'Cream/Pink',
        'Matte'
    ),
    (
        'JTK Griseann',
        'ABS',
        'Cherry',
        'JTK',
        95.00,
        '2021-08-18',
        'Gray/Blue',
        'Glossy'
    ),
    (
        'Corsair PBT Double-Shot',
        'PBT',
        'OEM',
        'Corsair',
        49.99,
        '2020-11-05',
        'Black/White',
        'Textured'
    ),
    (
        'SteelSeries PrismCaps',
        'PBT',
        'OEM',
        'SteelSeries',
        39.99,
        '2021-02-16',
        'Black/RGB',
        'Matte'
    ),
    (
        'Drop + MiTo DCX White on Black',
        'PBT',
        'DCX',
        'Drop',
        65.00,
        '2021-04-27',
        'White/Black',
        'Textured'
    );

-- Insert Users
INSERT INTO
    users (username, email, country, join_date)
VALUES
    (
        'KeyboardEnthusiast',
        'enthusiast@email.com',
        'USA',
        '2020-01-15'
    ),
    (
        'MechLover88',
        'mechlover@email.com',
        'Canada',
        '2019-11-22'
    ),
    (
        'SwitchTester',
        'switchtester@email.com',
        'Germany',
        '2020-03-08'
    ),
    (
        'ClackyKeys',
        'clacky@email.com',
        'UK',
        '2020-07-14'
    ),
    (
        'TactileFan',
        'tactile@email.com',
        'Australia',
        '2019-09-30'
    ),
    (
        'LinearLife',
        'linear@email.com',
        'USA',
        '2020-05-18'
    ),
    (
        'ThockMaster',
        'thock@email.com',
        'Netherlands',
        '2020-12-05'
    ),
    (
        'CustomBuilder',
        'custom@email.com',
        'Japan',
        '2021-02-28'
    ),
    (
        'KeycapCollector',
        'keycaps@email.com',
        'Singapore',
        '2020-08-12'
    ),
    (
        'ErgoUser',
        'ergo@email.com',
        'Sweden',
        '2021-01-20'
    ),
    (
        'GamerTypist',
        'gamer@email.com',
        'USA',
        '2019-12-10'
    ),
    (
        'OfficeWarrior',
        'office@email.com',
        'UK',
        '2020-04-25'
    ),
    (
        'BudgetBeast',
        'budget@email.com',
        'India',
        '2020-10-08'
    ),
    (
        'PremiumSeeker',
        'premium@email.com',
        'Germany',
        '2021-06-15'
    ),
    (
        'ModdingExpert',
        'modding@email.com',
        'USA',
        '2020-11-30'
    ),
    (
        'SilentTyper',
        'silent@email.com',
        'Canada',
        '2021-03-18'
    ),
    (
        'RGB_Lover',
        'rgb@email.com',
        'South Korea',
        '2020-02-14'
    ),
    (
        'MinimalistKeys',
        'minimal@email.com',
        'Denmark',
        '2021-05-22'
    ),
    (
        'VintageKeeb',
        'vintage@email.com',
        'USA',
        '2019-08-05'
    ),
    (
        'WirelessFan',
        'wireless@email.com',
        'France',
        '2020-09-12'
    ),
    (
        'ClickyLover',
        'clicky@email.com',
        'Brazil',
        '2021-04-18'
    ),
    ('FpsGamer', 'fps@email.com', 'USA', '2020-12-03'),
    (
        'ProgrammerLife',
        'coder@email.com',
        'Estonia',
        '2021-08-14'
    ),
    (
        'StreamerSetup',
        'streamer@email.com',
        'Canada',
        '2020-06-25'
    ),
    (
        'TechReviewer',
        'tech@email.com',
        'UK',
        '2019-10-12'
    ),
    (
        'CasualTyper',
        'casual@email.com',
        'Australia',
        '2021-01-30'
    ),
    (
        'MacroMaster',
        'macro@email.com',
        'Taiwan',
        '2020-07-08'
    ),
    (
        'RetroGamer',
        'retro@email.com',
        'Poland',
        '2021-11-15'
    ),
    (
        'WorkFromHome',
        'wfh@email.com',
        'Spain',
        '2020-03-22'
    ),
    (
        'StudentBudget',
        'student@email.com',
        'India',
        '2021-09-05'
    ),
    (
        'PeripheralAddict',
        'addict@email.com',
        'USA',
        '2019-12-30'
    ),
    (
        'CompetitivePlayer',
        'esports@email.com',
        'South Korea',
        '2020-08-17'
    ),
    (
        'ContentCreator',
        'creator@email.com',
        'Mexico',
        '2021-06-12'
    ),
    (
        'TechEngineer',
        'engineer@email.com',
        'Switzerland',
        '2020-01-25'
    );

-- Insert Reviews
INSERT INTO
    reviews (
        keyboard_id,
        user_id,
        rating,
        review_text,
        review_date
    )
VALUES
    (
        1,
        1,
        4,
        'Great build quality from Cherry. The MX Red switches feel smooth and consistent. Case could be a bit more premium for the price.',
        '2020-05-20'
    ),
    (
        5,
        2,
        5,
        'Love this compact wireless board! Battery life is excellent and the aluminum case feels solid.',
        '2021-10-15'
    ),
    (
        12,
        3,
        5,
        'The Q1 is amazing! Hot-swappable switches make customization a breeze. Gasket mount feels incredible.',
        '2021-12-08'
    ),
    (
        18,
        4,
        3,
        'Decent budget option but plastic case feels cheap. Switches are okay for the price point.',
        '2020-08-30'
    ),
    (
        25,
        5,
        4,
        'Razer has improved their switches significantly. This TKL feels great for both gaming and typing.',
        '2021-01-12'
    ),
    (
        24,
        6,
        5,
        'Logitech nailed it with the G Pro X. Hot-swap functionality is perfect for trying different switches.',
        '2020-11-25'
    ),
    (
        26,
        7,
        5,
        'Tofu65 is a fantastic entry into custom keyboards. Great value for an aluminum case.',
        '2020-03-18'
    ),
    (
        30,
        8,
        4,
        'Akko boards offer excellent value. PBT keycaps feel great and switches are surprisingly good.',
        '2021-08-22'
    ),
    (
        31,
        9,
        5,
        'GMMK Pro exceeded expectations. The rotary encoder is a nice touch and build quality is top-notch.',
        '2021-06-30'
    ),
    (
        33,
        10,
        4,
        'Drop ALT is solid but overpriced. Great for modding but there are better options now.',
        '2019-12-15'
    ),
    (
        8,
        11,
        3,
        'Keychron Q2 is good but had some QC issues with mine. Stabs needed work out of the box.',
        '2022-01-20'
    ),
    (
        22,
        12,
        2,
        'Disappointed with this Ducky board. Expected better for the price. Switches feel scratchy.',
        '2019-08-10'
    ),
    (
        29,
        13,
        5,
        'RK61 punches above its weight! Amazing value for a hot-swap wireless board.',
        '2021-02-28'
    ),
    (
        26,
        14,
        4,
        'NK65 Entry is a great starter custom. Only complaint is the ping from the case.',
        '2020-08-15'
    ),
    (
        30,
        15,
        5,
        'This Akko board feels premium despite the low price. Rose Red switches are surprisingly smooth.',
        '2021-12-05'
    ),
    (
        32,
        16,
        4,
        'GMMK Compact served me well for 2 years. Finally upgrading but this was a solid starter board.',
        '2021-09-18'
    ),
    (
        3,
        17,
        3,
        'MX Board 1.0 TKL is okay but feels dated. Non-detachable cable is annoying in 2022.',
        '2022-03-12'
    ),
    (
        15,
        18,
        5,
        'Vortex Pok3r is built like a tank. Aluminum case and overall quality is exceptional for a 60%.',
        '2020-07-22'
    ),
    (
        28,
        19,
        4,
        'Huntsman Mini is great for gaming. Linear optical switches feel unique and responsive.',
        '2021-04-08'
    ),
    (
        15,
        20,
        5,
        'This custom build with Alpaca switches is endgame material. Smooth as butter!',
        '2021-08-30'
    ),
    -- More keyboard reviews (using valid keyboard_id references)
    (
        1,
        21,
        5,
        'Cherry MX Board is solid. Good build quality and reliable switches.',
        '2021-01-15'
    ),
    (
        2,
        22,
        4,
        'Cherry MX Board 8.0 feels premium with the aluminum construction.',
        '2020-09-20'
    ),
    (
        6,
        23,
        3,
        'Keychron K6 is decent for the price. Wireless works well but case feels light.',
        '2020-12-08'
    ),
    (
        7,
        24,
        5,
        'Keychron Q1 is perfection! Gasket mount and hot-swap make it incredibly versatile.',
        '2021-03-30'
    ),
    (
        8,
        25,
        4,
        'Keychron Q2 has great build quality. Only complaint is the stock stabs need work.',
        '2021-07-12'
    ),
    (
        9,
        26,
        4,
        'Keychron Q3 TKL is my daily driver. Perfect size and amazing typing feel.',
        '2020-11-25'
    ),
    (
        13,
        27,
        5,
        'Anne Pro 2 was my gateway into 60% keyboards. Still holds up well today.',
        '2019-08-18'
    ),
    (
        14,
        28,
        4,
        'Ducky One 2 Mini has excellent build quality. PBT keycaps feel great.',
        '2020-05-14'
    ),
    (
        31,
        29,
        3,
        'GMMK Pro had some QC issues with mine. Stabs were mushy and needed immediate replacement.',
        '2021-09-22'
    ),
    (
        33,
        30,
        2,
        'Drop ALT feels overpriced for what you get. There are better options in this price range now.',
        '2022-01-10'
    ),
    (
        12,
        31,
        5,
        'Keychron Q1 exceeded all expectations! Gasket mount typing feel is incredible for the price.',
        '2021-12-15'
    ),
    (
        25,
        32,
        4,
        'Razer BlackWidow V3 TKL improved a lot from previous versions. Switches feel much better now.',
        '2021-04-28'
    ),
    (
        26,
        33,
        5,
        'Tofu65 was my gateway into custom keyboards. Great value and great modding potential.',
        '2020-06-20'
    ),
    (
        30,
        34,
        4,
        'Akko 3068B surprised me with its quality. PBT keycaps and good switches for such a low price.',
        '2021-08-05'
    ),
    (
        16,
        1,
        3,
        'Budget GK61 does the job but feels cheap. Good starter board for someone new to mechanicals.',
        '2021-02-18'
    );

-- Insert SwitchFeatures
INSERT INTO
    switch_features (switch_id, feature_name, feature_value)
VALUES
    -- Cherry MX features
    (1, 'RGB Compatible', 'Yes'),
    (1, 'PCB Mount', '5-pin'),
    (1, 'Housing Material', 'Nylon'),
    (2, 'RGB Compatible', 'Yes'),
    (2, 'PCB Mount', '5-pin'),
    (2, 'Housing Material', 'Nylon'),
    (3, 'RGB Compatible', 'Yes'),
    (3, 'PCB Mount', '5-pin'),
    (3, 'Housing Material', 'Nylon'),
    (3, 'Tactile Bump', 'Pre-travel'),
    (4, 'RGB Compatible', 'Yes'),
    (4, 'PCB Mount', '5-pin'),
    (4, 'Housing Material', 'Nylon'),
    (4, 'Click Mechanism', 'Click jacket'),
    -- Gateron features
    (11, 'RGB Compatible', 'Yes'),
    (11, 'PCB Mount', '5-pin'),
    (11, 'Housing Material', 'Nylon top, POM bottom'),
    (11, 'Factory Lubed', 'Light'),
    (15, 'RGB Compatible', 'Yes'),
    (15, 'PCB Mount', '5-pin'),
    (
        15,
        'Housing Material',
        'Polycarbonate top, Nylon bottom'
    ),
    (
        15,
        'Special Feature',
        'Smoky translucent housing'
    ),
    -- Kailh Box features
    (25, 'RGB Compatible', 'Yes'),
    (25, 'PCB Mount', '3-pin'),
    (25, 'Housing Material', 'Polycarbonate'),
    (25, 'Dust Resistant', 'IP56'),
    (25, 'Stem Design', 'Box stem'),
    (29, 'RGB Compatible', 'Yes'),
    (29, 'PCB Mount', '3-pin'),
    (29, 'Housing Material', 'Polycarbonate'),
    (29, 'Special Feature', 'Self-lubricating'),
    -- Premium switch features
    (49, 'RGB Compatible', 'Yes'),
    (49, 'PCB Mount', '5-pin'),
    (49, 'Housing Material', 'Polycarbonate'),
    (49, 'Factory Lubed', 'Krytox 205g0'),
    (49, 'Spring', 'Gold-plated'),
    (70, 'RGB Compatible', 'Yes'),
    (70, 'PCB Mount', '5-pin'),
    (70, 'Housing Material', 'Nylon'),
    (70, 'Factory Lubed', 'Yes'),
    (70, 'Special Feature', 'Extended stem pole');

-- Insert KeyboardImages
INSERT INTO
    keyboard_images (keyboard_id, url, description, is_main)
VALUES
    (
        1,
        'https://images.keyboards.com/cherry-mx30s-main.jpg',
        'Cherry MX Board 3.0S front view',
        true
    ),
    (
        1,
        'https://images.keyboards.com/cherry-mx30s-side.jpg',
        'Cherry MX Board 3.0S side profile',
        false
    ),
    (
        5,
        'https://images.keyboards.com/cherry-mini-main.jpg',
        'Cherry MX Keys Mini overview',
        true
    ),
    (
        12,
        'https://images.keyboards.com/keychron-q1-main.jpg',
        'Keychron Q1 assembled view',
        true
    ),
    (
        12,
        'https://images.keyboards.com/keychron-q1-exploded.jpg',
        'Keychron Q1 exploded view',
        false
    ),
    (
        18,
        'https://images.keyboards.com/tecware-phantom-main.jpg',
        'Tecware Phantom RGB lighting',
        true
    ),
    (
        25,
        'https://images.keyboards.com/razer-bw-v3-tkl.jpg',
        'Razer BlackWidow V3 TKL',
        true
    ),
    (
        32,
        'https://images.keyboards.com/logitech-pro-x.jpg',
        'Logitech G Pro X with switches',
        true
    ),
    (
        35,
        'https://images.keyboards.com/tofu65-gray.jpg',
        'KBDfans Tofu65 gray case',
        true
    ),
    (
        35,
        'https://images.keyboards.com/tofu65-internals.jpg',
        'Tofu65 internal assembly',
        false
    ),
    (
        42,
        'https://images.keyboards.com/akko-3068-pink.jpg',
        'Akko 3068B pink colorway',
        true
    ),
    (
        48,
        'https://images.keyboards.com/gmmk-pro-black.jpg',
        'Glorious GMMK Pro black',
        true
    ),
    (
        48,
        'https://images.keyboards.com/gmmk-pro-knob.jpg',
        'GMMK Pro rotary encoder detail',
        false
    ),
    (
        55,
        'https://images.keyboards.com/drop-alt-high.jpg',
        'Drop ALT high-profile',
        true
    ),
    (
        22,
        'https://images.keyboards.com/ducky-one2-mini.jpg',
        'Ducky One 2 Mini with keycaps',
        true
    ),
    (
        29,
        'https://images.keyboards.com/rk61-wireless.jpg',
        'RK61 wireless setup',
        true
    );

-- Insert Accessories
INSERT INTO
    accessories (name, description, type)
VALUES
    (
        'Glorious Wooden Wrist Rest',
        'Premium wooden wrist rest with foam padding',
        'wrist rest'
    ),
    (
        'Coiled USB-C Cable',
        'Custom coiled aviator USB-C cable',
        'cable'
    ),
    (
        'Switch Puller Tool',
        'Professional switch removal tool',
        'tool'
    ),
    (
        'Keycap Puller Set',
        'Wire and plastic keycap pullers',
        'tool'
    ),
    (
        'Foam Case Dampener',
        'Acoustic foam for keyboard cases',
        'modification'
    ),
    (
        'Plate Foam',
        'PE foam for between plate and PCB',
        'modification'
    ),
    (
        'Durock Stabilizers',
        'Screw-in stabilizers set',
        'stabilizer'
    ),
    (
        'Krytox 205g0',
        'Switch lubricant for linear switches',
        'lubricant'
    ),
    (
        'Tribosys 3204',
        'Switch lubricant for tactile switches',
        'lubricant'
    ),
    (
        'Deskey Films',
        'Switch films for tighter housing',
        'modification'
    ),
    (
        'Carrying Case',
        'Hard shell keyboard carrying case',
        'case'
    ),
    (
        'O-Ring Dampeners',
        'Rubber o-rings for key dampening',
        'modification'
    ),
    (
        'Artisan Keycap',
        'Hand-crafted resin artisan keycap',
        'keycap'
    ),
    (
        'USB Hub',
        '4-port USB hub for desk setup',
        'accessory'
    ),
    (
        'Keyboard Feet',
        'Adjustable keyboard angle feet',
        'accessory'
    );

-- Insert KeyboardAccessories (many-to-many relationships)
INSERT INTO
    keyboard_accessories (keyboard_id, accessory_id)
VALUES
    (1, 1),
    (1, 2),
    (1, 11),
    (12, 1),
    (12, 5),
    (12, 6),
    (12, 7),
    (25, 1),
    (25, 2),
    (25, 11),
    (35, 1),
    (35, 5),
    (35, 6),
    (35, 7),
    (35, 8),
    (48, 1),
    (48, 5),
    (48, 6),
    (48, 7),
    (48, 9),
    (42, 1),
    (42, 12),
    (42, 13),
    (55, 1),
    (55, 5),
    (55, 7),
    (55, 8),
    (32, 1),
    (32, 3),
    (32, 4),
    (32, 11),
    (22, 12),
    (22, 13),
    (22, 14),
    (29, 2),
    (29, 11),
    (29, 15);

-- Insert PriceHistory
INSERT INTO
    price_history (keyboard_id, price, start_date, end_date)
VALUES
    (1, 149.99, '2018-03-15', '2019-06-30'),
    (1, 129.99, '2019-07-01', '2022-12-31'),
    (12, 199.99, '2021-07-20', '2021-11-30'),
    (12, 179.99, '2021-12-01', '2022-12-31'),
    (25, 159.99, '2020-08-11', '2021-03-15'),
    (25, 139.99, '2021-03-16', '2022-12-31'),
    (35, 178.00, '2019-10-05', '2020-05-20'),
    (35, 158.00, '2020-05-21', '2022-12-31'),
    (48, 189.99, '2021-03-31', '2021-12-25'),
    (48, 169.99, '2021-12-26', '2022-12-31'),
    (22, 119.99, '2019-03-18', '2020-08-15'),
    (22, 109.99, '2020-08-16', '2022-12-31'),
    (42, 89.99, '2021-02-14', '2021-11-26'),
    (42, 79.99, '2021-11-27', '2022-12-31'),
    (55, 220.00, '2018-07-20', '2020-01-15'),
    (55, 200.00, '2020-01-16', '2022-12-31');

-- Insert KeycapCompatibility (many-to-many)
INSERT INTO
    keycap_compatibility (keycap_id, layout_id)
VALUES
    -- GMK sets (Cherry profile) - compatible with most layouts
    (1, 1),
    (1, 2),
    (1, 3),
    (1, 4),
    (1, 5),
    (2, 1),
    (2, 2),
    (2, 3),
    (2, 4),
    (2, 5),
    (3, 1),
    (3, 2),
    (3, 3),
    (3, 4),
    (3, 5),
    (4, 1),
    (4, 2),
    (4, 3),
    (4, 4),
    (4, 5),
    (5, 1),
    (5, 2),
    (5, 3),
    (5, 4),
    (5, 5),
    -- SA profile sets - limited compatibility
    (6, 1),
    (6, 2),
    (6, 5),
    (7, 1),
    (7, 2),
    (7, 5),
    -- MT3 profile - specific layouts
    (8, 2),
    (8, 4),
    (8, 5),
    (9, 2),
    (9, 4),
    (9, 5),
    -- Standard OEM/Cherry compatible
    (11, 1),
    (11, 2),
    (11, 3),
    (11, 4),
    (11, 5),
    (12, 1),
    (12, 2),
    (12, 3),
    (12, 4),
    (12, 5),
    (13, 1),
    (13, 2),
    (13, 3),
    (13, 4),
    (13, 5),
    (14, 1),
    (14, 2),
    (14, 3),
    (14, 4),
    (14, 5),
    (15, 1),
    (15, 2),
    (15, 3),
    (15, 4),
    (15, 5),
    (16, 1),
    (16, 2),
    (16, 3),
    (16, 4),
    (16, 5),
    (17, 1),
    (17, 2),
    (17, 3),
    (17, 4),
    (17, 5),
    -- Uniform profile sets
    (18, 1),
    (18, 2),
    (18, 5),
    (19, 1),
    (19, 2),
    (19, 5),
    (20, 1),
    (20, 2),
    (20, 3),
    (20, 4),
    (20, 5);

-- Insert Stabilizers
INSERT INTO
    stabilizers (keyboard_id, type, material, brand)
VALUES
    (12, 'Screw-in', 'Nylon', 'Durock'),
    (35, 'Screw-in', 'Nylon', 'Durock'),
    (48, 'Screw-in', 'Nylon', 'Durock'),
    (55, 'Plate-mounted', 'Nylon', 'Cherry'),
    (32, 'Screw-in', 'Nylon', 'Logitech'),
    (25, 'Plate-mounted', 'Nylon', 'Razer'),
    (1, 'Plate-mounted', 'Nylon', 'Cherry'),
    (22, 'Plate-mounted', 'Nylon', 'Ducky'),
    (42, 'Plate-mounted', 'Nylon', 'Akko'),
    (18, 'Plate-mounted', 'Plastic', 'Generic');

-- Insert PCBs
INSERT INTO
    pcbs (
        keyboard_id,
        name,
        firmware,
        rgb_support,
        hot_swap_support
    )
VALUES
    (12, 'Keychron Q1 PCB', 'QMK', true, true),
    (35, 'DZ65RGB V3', 'QMK', true, true),
    (48, 'GMMK Pro PCB', 'QMK', true, true),
    (55, 'Drop ALT PCB', 'QMK', true, true),
    (
        32,
        'Logitech Pro X PCB',
        'Proprietary',
        true,
        true
    ),
    (
        25,
        'Razer Green PCB',
        'Proprietary',
        true,
        false
    ),
    (
        1,
        'Cherry MX 3.0S PCB',
        'Proprietary',
        true,
        false
    ),
    (
        22,
        'Ducky One 2 PCB',
        'Proprietary',
        true,
        false
    ),
    (42, 'Akko 3068B PCB', 'Proprietary', true, false),
    (
        18,
        'Tecware Phantom PCB',
        'Proprietary',
        true,
        true
    ),
    (29, 'RK61 PCB', 'Proprietary', true, true);

-- Insert Cases
INSERT INTO
    cases (keyboard_id, material, color, finish)
VALUES
    (12, 'Aluminum', 'Navy Blue', 'Anodized'),
    (35, 'Aluminum', 'Gray', 'Anodized'),
    (48, 'Aluminum', 'Black', 'Anodized'),
    (55, 'Aluminum', 'Silver', 'Anodized'),
    (32, 'Aluminum', 'Black', 'Anodized'),
    (25, 'Aluminum', 'Black', 'Matte'),
    (1, 'Plastic', 'Black', 'Matte'),
    (22, 'Plastic', 'White', 'Glossy'),
    (42, 'Plastic', 'Pink', 'Matte'),
    (18, 'Plastic', 'Black', 'Matte'),
    (29, 'Plastic', 'White', 'Glossy');

-- Insert Mouse Sensors
INSERT INTO
    mouse_sensors (
        name,
        dpi_range,
        max_tracking_speed,
        max_acceleration
    )
VALUES
    ('PixArt PMW3360', '100-12000', 250, 50.0),
    ('PixArt PMW3389', '50-16000', 400, 50.0),
    ('PixArt PMW3325', '100-5000', 100, 20.0),
    ('PixArt PMW3330', '100-7000', 150, 30.0),
    ('PixArt PMW3366', '200-12000', 250, 50.0),
    ('PixArt PMW3335', '100-26000', 650, 50.0),
    ('Avago A3050', '50-4000', 60, 15.0),
    ('Hero 25K', '100-25600', 650, 50.0),
    ('TrueMove Core', '100-6500', 220, 35.0),
    ('TrueMove 3', '100-12000', 350, 50.0),
    ('TrueMove 3+', '100-18000', 450, 50.0),
    ('Focus Pro 30K', '50-30000', 750, 50.0),
    ('PixArt PAW3212', '400-3200', 30, 10.0),
    ('Mercury', '50-20000', 500, 40.0),
    ('PixArt PMW3370', '50-19000', 400, 40.0),
    ('PixArt PMW3310', '50-5000', 130, 30.0),
    ('Optical Red', '100-8500', 300, 40.0),
    ('Dragon', '50-16000', 450, 50.0),
    ('Owl-Eye', '50-16000', 400, 50.0),
    ('PixArt PMW3327', '100-6200', 220, 30.0),
    ('LaserStream', '200-5700', 150, 25.0);

-- Insert Mice
INSERT INTO
    mice (
        vendor_id,
        name,
        release_date,
        price,
        sensor_id,
        dpi_min,
        dpi_max,
        polling_rate,
        connection,
        weight
    )
VALUES
    -- Logitech mice
    (
        6,
        'G Pro X Superlight',
        '2020-12-03',
        149.99,
        8,
        100,
        25600,
        1000,
        'Wireless',
        63.0
    ),
    (
        6,
        'G502 Hero',
        '2018-09-20',
        79.99,
        8,
        100,
        25600,
        1000,
        'Wired',
        121.0
    ),
    (
        6,
        'G403 Hero',
        '2019-04-15',
        69.99,
        8,
        100,
        25600,
        1000,
        'Both',
        87.3
    ),
    (
        6,
        'G Pro Wireless',
        '2018-08-19',
        129.99,
        8,
        100,
        25600,
        1000,
        'Wireless',
        80.0
    ),
    (
        6,
        'G305 Lightspeed',
        '2018-05-29',
        59.99,
        8,
        200,
        12000,
        1000,
        'Wireless',
        99.0
    ),
    (
        6,
        'G203 Lightsync',
        '2020-04-14',
        39.99,
        13,
        200,
        8000,
        1000,
        'Wired',
        85.0
    ),
    (
        6,
        'MX Master 3',
        '2019-09-26',
        99.99,
        4,
        200,
        4000,
        125,
        'Wireless',
        141.0
    ),
    -- Razer mice
    (
        5,
        'DeathAdder V3 Pro',
        '2022-09-15',
        149.99,
        12,
        50,
        30000,
        8000,
        'Wireless',
        88.0
    ),
    (
        5,
        'Viper V2 Pro',
        '2022-03-17',
        149.99,
        12,
        50,
        30000,
        8000,
        'Wireless',
        58.0
    ),
    (
        5,
        'Basilisk V3 Pro',
        '2021-10-21',
        159.99,
        12,
        50,
        30000,
        4000,
        'Wireless',
        112.0
    ),
    (
        5,
        'DeathAdder V3',
        '2022-09-15',
        89.99,
        12,
        50,
        30000,
        8000,
        'Wired',
        82.0
    ),
    (
        5,
        'Viper Ultimate',
        '2019-10-03',
        129.99,
        2,
        50,
        20000,
        1000,
        'Wireless',
        74.0
    ),
    (
        5,
        'DeathAdder Essential',
        '2019-06-04',
        29.99,
        7,
        50,
        6400,
        1000,
        'Wired',
        96.0
    ),
    (
        5,
        'Orochi V2',
        '2021-04-15',
        69.99,
        1,
        100,
        18000,
        1000,
        'Wireless',
        60.0
    ),
    -- Glorious mice
    (
        11,
        'Model O Wireless',
        '2020-11-10',
        79.99,
        1,
        100,
        19000,
        1000,
        'Wireless',
        69.0
    ),
    (
        11,
        'Model D Wireless',
        '2021-03-25',
        79.99,
        1,
        100,
        19000,
        1000,
        'Wireless',
        68.0
    ),
    (
        11,
        'Model O',
        '2019-05-18',
        49.99,
        1,
        100,
        12000,
        1000,
        'Wired',
        67.0
    ),
    (
        11,
        'Model D',
        '2019-11-14',
        49.99,
        1,
        100,
        12000,
        1000,
        'Wired',
        68.0
    ),
    (
        11,
        'Model I',
        '2021-08-31',
        59.99,
        1,
        100,
        19000,
        1000,
        'Wired',
        69.0
    ),
    -- Budget options
    (
        4,
        'M601 RGB',
        '2020-06-15',
        24.99,
        3,
        100,
        7200,
        1000,
        'Wired',
        95.0
    ),
    (
        4,
        'M652 Wireless',
        '2021-02-20',
        39.99,
        4,
        100,
        10000,
        1000,
        'Wireless',
        89.0
    ),
    -- Cherry mice
    (
        1,
        'MC 4000',
        '2019-03-12',
        49.99,
        13,
        400,
        3200,
        125,
        'Wired',
        110.0
    ),
    (
        1,
        'MC 8000',
        '2020-08-18',
        89.99,
        5,
        200,
        16000,
        1000,
        'Wireless',
        95.0
    ),
    -- Akko mice
    (
        10,
        'AG325 Wireless',
        '2021-11-30',
        79.99,
        1,
        100,
        16000,
        1000,
        'Wireless',
        75.0
    ),
    (
        10,
        'AG308 Wired',
        '2021-07-22',
        45.99,
        3,
        100,
        8000,
        1000,
        'Wired',
        82.0
    ),
    -- Corsair mice
    (
        21,
        'Dark Core RGB Pro',
        '2020-03-17',
        89.99,
        16,
        100,
        18000,
        1000,
        'Both',
        133.0
    ),
    (
        21,
        'M65 RGB Elite',
        '2019-01-29',
        59.99,
        16,
        100,
        18000,
        1000,
        'Wired',
        97.0
    ),
    (
        21,
        'Harpoon RGB Wireless',
        '2019-08-13',
        49.99,
        15,
        100,
        10000,
        1000,
        'Both',
        99.0
    ),
    -- SteelSeries mice
    (
        22,
        'Rival 650 Wireless',
        '2018-06-12',
        99.99,
        9,
        100,
        12000,
        1000,
        'Wireless',
        153.0
    ),
    (
        22,
        'Sensei Ten',
        '2019-04-09',
        69.99,
        10,
        50,
        18000,
        1000,
        'Wired',
        92.0
    ),
    (
        22,
        'Rival 310',
        '2017-07-25',
        59.99,
        10,
        100,
        12000,
        1000,
        'Wired',
        88.5
    ),
    -- HyperX mice
    (
        23,
        'Pulsefire Haste',
        '2020-09-29',
        49.99,
        1,
        100,
        16000,
        1000,
        'Wired',
        59.0
    ),
    (
        23,
        'Pulsefire Surge',
        '2018-01-09',
        69.99,
        16,
        50,
        16000,
        1000,
        'Wired',
        132.0
    ),
    (
        23,
        'Pulsefire Core',
        '2018-08-28',
        29.99,
        17,
        100,
        6200,
        1000,
        'Wired',
        87.0
    ),
    -- ASUS mice
    (
        26,
        'ROG Gladius III',
        '2021-05-11',
        79.99,
        1,
        100,
        26000,
        8000,
        'Wired',
        89.0
    ),
    (
        26,
        'ROG Keris Wireless',
        '2021-03-30',
        99.99,
        1,
        100,
        16000,
        1000,
        'Wireless',
        79.0
    ),
    (
        26,
        'TUF Gaming M3',
        '2020-04-21',
        39.99,
        15,
        100,
        7000,
        1000,
        'Wired',
        59.0
    ),
    -- Roccat mice
    (
        28,
        'Kone Pro',
        '2021-02-02',
        79.99,
        18,
        50,
        19000,
        1000,
        'Wired',
        66.0
    ),
    (
        28,
        'Burst Pro',
        '2020-08-25',
        59.99,
        18,
        50,
        16000,
        1000,
        'Wired',
        68.0
    ),
    (
        28,
        'Kain 120 AIMO',
        '2019-06-04',
        69.99,
        18,
        50,
        16000,
        1000,
        'Wired',
        89.0
    );

-- Insert Mouse Buttons
INSERT INTO
    mouse_buttons (mouse_id, name, programmable)
VALUES
    -- Logitech G Pro X Superlight (mouse_id 1)
    (1, 'Left Click', false),
    (1, 'Right Click', false),
    (1, 'Middle Click', true),
    (1, 'Side Button 1', true),
    (1, 'Side Button 2', true),
    -- Logitech G502 Hero (mouse_id 2)
    (2, 'Left Click', false),
    (2, 'Right Click', false),
    (2, 'Middle Click', true),
    (2, 'Side Button 1', true),
    (2, 'Side Button 2', true),
    (2, 'DPI Button', true),
    (2, 'Profile Button', true),
    (2, 'Scroll Left', true),
    (2, 'Scroll Right', true),
    (2, 'Sniper Button', true),
    (2, 'Thumb Rest Button', true),
    -- Logitech G403 Hero (mouse_id 3)
    (3, 'Left Click', false),
    (3, 'Right Click', false),
    (3, 'Middle Click', true),
    (3, 'Side Button 1', true),
    (3, 'Side Button 2', true),
    (3, 'DPI Button', true),
    -- Razer DeathAdder V3 Pro (mouse_id 8)
    (8, 'Left Click', false),
    (8, 'Right Click', false),
    (8, 'Middle Click', true),
    (8, 'Side Button 1', true),
    (8, 'Side Button 2', true),
    (8, 'DPI Button', true),
    (8, 'Profile Button', true),
    -- Razer Viper V2 Pro (mouse_id 9)
    (9, 'Left Click', false),
    (9, 'Right Click', false),
    (9, 'Middle Click', true),
    (9, 'Side Button 1', true),
    (9, 'Side Button 2', true),
    (9, 'Side Button 3', true),
    (9, 'Side Button 4', true),
    (9, 'DPI Button', true),
    -- Glorious Model O Wireless (mouse_id 15)
    (15, 'Left Click', false),
    (15, 'Right Click', false),
    (15, 'Middle Click', true),
    (15, 'Side Button 1', true),
    (15, 'Side Button 2', true),
    (15, 'DPI Button', true),
    -- Budget mouse M601 RGB (mouse_id 20)
    (20, 'Left Click', false),
    (20, 'Right Click', false),
    (20, 'Middle Click', true),
    (20, 'DPI Button', true),
    -- Cherry MC 4000 (mouse_id 22)
    (22, 'Left Click', false),
    (22, 'Right Click', false),
    (22, 'Middle Click', true),
    -- Akko AG325 Wireless (mouse_id 24)
    (24, 'Left Click', false),
    (24, 'Right Click', false),
    (24, 'Middle Click', true),
    (24, 'Side Button 1', true),
    (24, 'Side Button 2', true),
    (24, 'DPI Button', true);

-- Insert Mouse Reviews
INSERT INTO
    mouse_reviews (
        mouse_id,
        user_id,
        rating,
        review_text,
        review_date
    )
VALUES
    (
        1,
        1,
        5,
        'The G Pro X Superlight is incredible! So lightweight yet feels solid. Perfect for competitive gaming.',
        '2021-02-15'
    ),
    (
        2,
        2,
        4,
        'G502 Hero is a feature-packed mouse. Lots of programmable buttons but might be too heavy for some.',
        '2019-12-20'
    ),
    (
        8,
        3,
        5,
        'DeathAdder V3 Pro has amazing ergonomics and the new switches feel so crisp. Battery life is excellent.',
        '2022-11-08'
    ),
    (
        9,
        4,
        5,
        'Viper V2 Pro is the perfect ambidextrous mouse. Super light and responsive. Worth every penny.',
        '2022-06-12'
    ),
    (
        15,
        5,
        4,
        'Model O Wireless offers great value. Build quality is good and the sensor performance is solid.',
        '2021-01-30'
    ),
    (
        3,
        6,
        4,
        'G403 Hero has a comfortable shape and excellent sensor. Good middle-ground option from Logitech.',
        '2020-08-14'
    ),
    (
        20,
        7,
        3,
        'For the price, M601 RGB is decent. RGB looks good but sensor could be more accurate.',
        '2021-03-25'
    ),
    (
        22,
        8,
        2,
        'Cherry MC 4000 feels outdated. Sensor is not great for modern gaming standards.',
        '2020-01-18'
    ),
    (
        24,
        9,
        4,
        'Akko AG325 surprised me! Good build quality and the sensor is quite accurate for the price.',
        '2022-02-28'
    ),
    (
        9,
        10,
        5,
        'Switched from G Pro X to Viper V2 Pro. The shape fits my hand better and clicks are more satisfying.',
        '2022-08-15'
    ),
    (
        2,
        11,
        3,
        'G502 is too heavy for my liking. All the features are nice but I prefer lighter mice for FPS games.',
        '2020-05-22'
    ),
    (
        8,
        12,
        4,
        'DeathAdder V3 Pro is comfortable for long gaming sessions. Only complaint is the price point.',
        '2023-01-10'
    ),
    (
        15,
        13,
        5,
        'Model O Wireless punches above its weight class. Fantastic mouse for the money.',
        '2021-06-18'
    ),
    (
        1,
        14,
        4,
        'G Pro X Superlight lives up to the hype. Sometimes wish it had more buttons though.',
        '2021-08-03'
    ),
    (
        3,
        15,
        3,
        'G403 Hero is okay but there are better options now. Still a solid performer.',
        '2021-11-12'
    );
