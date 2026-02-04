-- Camera Database Schema
DROP DATABASE IF EXISTS camera_db;
CREATE DATABASE camera_db;
USE camera_db;

-- Manufacturers (Canon, Sony, Nikon, Fujifilm, etc.)
CREATE TABLE manufacturers (
    manufacturer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    founded_year INT NOT NULL,
    headquarters VARCHAR(150) NOT NULL,
    website VARCHAR(255) NOT NULL,
    specialization ENUM('Cameras', 'Lenses', 'Both', 'Accessories', 'Cinema') DEFAULT 'Both'
);

-- Image Sensors
CREATE TABLE sensors (
    sensor_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type ENUM('CMOS', 'CCD', 'BSI-CMOS', 'Stacked CMOS') NOT NULL,
    format_size ENUM('Full Frame', 'APS-C', 'APS-H', 'Micro Four Thirds', 'Medium Format', '1-inch') NOT NULL,
    megapixels DECIMAL(4, 1) NOT NULL,
    iso_min INT NOT NULL,
    iso_max INT NOT NULL
);

-- Lens Mounts
CREATE TABLE mounts (
    mount_id INT AUTO_INCREMENT PRIMARY KEY,
    manufacturer_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    flange_distance_mm DECIMAL(5, 2) NOT NULL,
    throat_diameter_mm DECIMAL(5, 2) NOT NULL,
    is_electronic BOOLEAN NOT NULL,
    FOREIGN KEY (manufacturer_id) REFERENCES manufacturers(manufacturer_id)
);

-- Image Processors
CREATE TABLE image_processors (
    processor_id INT AUTO_INCREMENT PRIMARY KEY,
    manufacturer_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    generation INT NOT NULL,
    release_year INT NOT NULL,
    max_burst_fps INT NOT NULL,
    max_video_resolution VARCHAR(50) NOT NULL,
    bit_depth INT NOT NULL,
    ai_features VARCHAR(255),
    FOREIGN KEY (manufacturer_id) REFERENCES manufacturers(manufacturer_id)
);

-- Camera Bodies
CREATE TABLE camera_bodies (
    body_id INT AUTO_INCREMENT PRIMARY KEY,
    manufacturer_id INT NOT NULL,
    sensor_id INT NOT NULL,
    mount_id INT NOT NULL,
    processor_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    body_type ENUM('DSLR', 'Mirrorless', 'Medium Format', 'Compact', 'Cinema') NOT NULL,
    release_date DATE NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    weight_g INT NOT NULL,
    body_material VARCHAR(100) NOT NULL,
    FOREIGN KEY (manufacturer_id) REFERENCES manufacturers(manufacturer_id),
    FOREIGN KEY (sensor_id) REFERENCES sensors(sensor_id),
    FOREIGN KEY (mount_id) REFERENCES mounts(mount_id),
    FOREIGN KEY (processor_id) REFERENCES image_processors(processor_id)
);

-- Body Features (connectivity, durability, environmental specs)
CREATE TABLE body_features (
    body_feature_id INT AUTO_INCREMENT PRIMARY KEY,
    body_id INT NOT NULL,
    weather_sealed BOOLEAN NOT NULL,
    operating_temp_min INT NOT NULL, -- Celsius
    operating_temp_max INT NOT NULL, -- Celsius
    shutter_durability INT NOT NULL, -- rated actuations
    has_gps BOOLEAN NOT NULL,
    has_bluetooth BOOLEAN NOT NULL,
    has_wifi BOOLEAN NOT NULL,
    FOREIGN KEY (body_id) REFERENCES camera_bodies(body_id)
);

-- Body Specifications (detailed performance specs per body)
CREATE TABLE body_specs (
    spec_id INT AUTO_INCREMENT PRIMARY KEY,
    body_id INT NOT NULL,
    shutter_speed_min VARCHAR(20) NOT NULL, -- e.g., "30s"
    shutter_speed_max VARCHAR(20) NOT NULL, -- e.g., "1/8000s"
    burst_fps DECIMAL(4, 1) NOT NULL,
    video_resolution VARCHAR(50) NOT NULL, -- e.g., "8K30, 4K120"
    has_ibis BOOLEAN NOT NULL,
    ibis_stops DECIMAL(3, 1), -- stabilization effectiveness
    evf_resolution INT, -- electronic viewfinder resolution
    lcd_size DECIMAL(3, 1) NOT NULL, -- inches
    lcd_articulating BOOLEAN NOT NULL,
    FOREIGN KEY (body_id) REFERENCES camera_bodies(body_id)
);

-- Autofocus Systems
CREATE TABLE autofocus_systems (
    af_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type ENUM('Phase Detection', 'Contrast Detection', 'Hybrid', 'Dual Pixel') NOT NULL,
    focus_points INT NOT NULL,
    cross_type_points INT NOT NULL,
    eye_tracking BOOLEAN NOT NULL,
    tracking_types VARCHAR(255) NOT NULL, -- e.g., "Eye, Face, Animal, Vehicle"
    low_light_ev DECIMAL(4, 1) NOT NULL, -- lowest EV for AF
    af_speed_rating VARCHAR(50) NOT NULL -- e.g., "0.02s"
);

-- Body Autofocus (links bodies to their AF system)
CREATE TABLE body_autofocus (
    body_af_id INT AUTO_INCREMENT PRIMARY KEY,
    body_id INT NOT NULL,
    af_id INT NOT NULL,
    firmware_version_added VARCHAR(50) NOT NULL,
    is_primary BOOLEAN NOT NULL,
    notes VARCHAR(255),
    FOREIGN KEY (body_id) REFERENCES camera_bodies(body_id),
    FOREIGN KEY (af_id) REFERENCES autofocus_systems(af_id)
);

-- Viewfinders
CREATE TABLE viewfinders (
    viewfinder_id INT AUTO_INCREMENT PRIMARY KEY,
    body_id INT NOT NULL,
    type ENUM('OVF', 'EVF', 'Hybrid', 'None') NOT NULL,
    resolution INT, -- dots for EVF
    magnification DECIMAL(4, 2) NOT NULL,
    refresh_rate_hz INT, -- for EVF
    coverage_percent DECIMAL(5, 2) NOT NULL,
    FOREIGN KEY (body_id) REFERENCES camera_bodies(body_id)
);

-- Storage Types
CREATE TABLE storage_types (
    storage_type_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    form_factor VARCHAR(50) NOT NULL,
    bus_interface VARCHAR(50) NOT NULL,
    max_capacity_gb INT NOT NULL,
    max_speed_mbps INT NOT NULL,
    uhs_class VARCHAR(20),
    video_speed_class VARCHAR(20)
);

-- Body Storage Slots (many-to-many for dual card slots)
CREATE TABLE body_storage_slots (
    slot_id INT AUTO_INCREMENT PRIMARY KEY,
    body_id INT NOT NULL,
    storage_type_id INT NOT NULL,
    slot_number INT NOT NULL,
    is_primary BOOLEAN NOT NULL,
    supports_relay BOOLEAN NOT NULL,
    supports_backup BOOLEAN NOT NULL,
    max_write_speed_mbps INT NOT NULL,
    FOREIGN KEY (body_id) REFERENCES camera_bodies(body_id),
    FOREIGN KEY (storage_type_id) REFERENCES storage_types(storage_type_id)
);

-- Batteries
CREATE TABLE batteries (
    battery_id INT AUTO_INCREMENT PRIMARY KEY,
    manufacturer_id INT NOT NULL,
    model VARCHAR(100) NOT NULL,
    capacity_mah INT NOT NULL,
    voltage DECIMAL(4, 2) NOT NULL,
    weight_g INT NOT NULL,
    FOREIGN KEY (manufacturer_id) REFERENCES manufacturers(manufacturer_id)
);

-- Body Batteries (links bodies to compatible batteries)
CREATE TABLE body_batteries (
    body_battery_id INT AUTO_INCREMENT PRIMARY KEY,
    body_id INT NOT NULL,
    battery_id INT NOT NULL,
    shots_per_charge INT NOT NULL,
    video_minutes INT NOT NULL,
    included_in_box BOOLEAN NOT NULL,
    charging_time_hrs DECIMAL(3, 1) NOT NULL,
    FOREIGN KEY (body_id) REFERENCES camera_bodies(body_id),
    FOREIGN KEY (battery_id) REFERENCES batteries(battery_id)
);

-- Lenses
CREATE TABLE lenses (
    lens_id INT AUTO_INCREMENT PRIMARY KEY,
    manufacturer_id INT NOT NULL,
    mount_id INT NOT NULL,
    name VARCHAR(150) NOT NULL,
    lens_type ENUM('Prime', 'Zoom', 'Macro', 'Tilt-Shift', 'Fisheye', 'Telephoto') NOT NULL,
    focal_length_min INT NOT NULL, -- mm
    focal_length_max INT NOT NULL, -- mm (same as min for primes)
    aperture_max DECIMAL(3, 1) NOT NULL, -- widest (e.g., 1.4)
    aperture_min DECIMAL(4, 1) NOT NULL, -- narrowest (e.g., 22)
    weight_g INT NOT NULL,
    filter_size_mm INT,
    release_date DATE NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (manufacturer_id) REFERENCES manufacturers(manufacturer_id),
    FOREIGN KEY (mount_id) REFERENCES mounts(mount_id)
);

-- Lens Optical Specs (detailed optical characteristics)
CREATE TABLE lens_optical_specs (
    lens_spec_id INT AUTO_INCREMENT PRIMARY KEY,
    lens_id INT NOT NULL,
    min_focus_distance_m DECIMAL(4, 2) NOT NULL,
    max_magnification DECIMAL(4, 2) NOT NULL, -- e.g., 0.25 for 1:4
    optical_elements INT NOT NULL,
    optical_groups INT NOT NULL,
    diaphragm_blades INT NOT NULL,
    has_stabilization BOOLEAN NOT NULL,
    weather_sealed BOOLEAN NOT NULL,
    FOREIGN KEY (lens_id) REFERENCES lenses(lens_id)
);

-- Mount Adapters (allows using lenses on different mounts)
CREATE TABLE mount_adapters (
    adapter_id INT AUTO_INCREMENT PRIMARY KEY,
    manufacturer_id INT NOT NULL,
    source_mount_id INT NOT NULL, -- the lens mount
    target_mount_id INT NOT NULL, -- the body mount
    name VARCHAR(150) NOT NULL,
    has_autofocus BOOLEAN NOT NULL,
    has_stabilization BOOLEAN NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (manufacturer_id) REFERENCES manufacturers(manufacturer_id),
    FOREIGN KEY (source_mount_id) REFERENCES mounts(mount_id),
    FOREIGN KEY (target_mount_id) REFERENCES mounts(mount_id)
);

-- Camera Database Sample Data
-- USE camera_db;
-- =============================================
-- MANUFACTURERS (40 records)
-- =============================================
INSERT INTO manufacturers (name, country, founded_year, headquarters, website, specialization) VALUES
('Canon', 'Japan', 1937, 'Tokyo, Japan', 'https://www.canon.com', 'Both'),
('Nikon', 'Japan', 1917, 'Tokyo, Japan', 'https://www.nikon.com', 'Both'),
('Sony', 'Japan', 1946, 'Tokyo, Japan', 'https://www.sony.com', 'Both'),
('Fujifilm', 'Japan', 1934, 'Tokyo, Japan', 'https://www.fujifilm.com', 'Both'),
('Panasonic', 'Japan', 1918, 'Osaka, Japan', 'https://www.panasonic.com', 'Both'),
('Olympus', 'Japan', 1919, 'Tokyo, Japan', 'https://www.olympus.com', 'Cameras'),
('Leica', 'Germany', 1914, 'Wetzlar, Germany', 'https://www.leica-camera.com', 'Both'),
('Hasselblad', 'Sweden', 1941, 'Gothenburg, Sweden', 'https://www.hasselblad.com', 'Both'),
('Pentax', 'Japan', 1919, 'Tokyo, Japan', 'https://www.ricoh-imaging.com', 'Cameras'),
('Sigma', 'Japan', 1961, 'Kawasaki, Japan', 'https://www.sigma-global.com', 'Both'),
('Tamron', 'Japan', 1950, 'Saitama, Japan', 'https://www.tamron.com', 'Lenses'),
('Tokina', 'Japan', 1950, 'Tokyo, Japan', 'https://www.tokina.com', 'Lenses'),
('Zeiss', 'Germany', 1846, 'Oberkochen, Germany', 'https://www.zeiss.com', 'Lenses'),
('Samyang', 'South Korea', 1972, 'Changwon, South Korea', 'https://www.samyanglensglobal.com', 'Lenses'),
('Voigtlander', 'Germany', 1756, 'Furth, Germany', 'https://www.voigtlaender.de', 'Lenses'),
('Phase One', 'Denmark', 1993, 'Copenhagen, Denmark', 'https://www.phaseone.com', 'Cameras'),
('RED Digital Cinema', 'United States', 2005, 'Irvine, California', 'https://www.red.com', 'Cinema'),
('Blackmagic Design', 'Australia', 2001, 'Melbourne, Australia', 'https://www.blackmagicdesign.com', 'Cinema'),
('DJI', 'China', 2006, 'Shenzhen, China', 'https://www.dji.com', 'Cameras'),
('GoPro', 'United States', 2002, 'San Mateo, California', 'https://www.gopro.com', 'Cameras'),
('Ricoh', 'Japan', 1936, 'Tokyo, Japan', 'https://www.ricoh.com', 'Both'),
('Kodak', 'United States', 1888, 'Rochester, New York', 'https://www.kodak.com', 'Both'),
('Polaroid', 'United States', 1937, 'Minnetonka, Minnesota', 'https://www.polaroid.com', 'Cameras'),
('Mamiya', 'Japan', 1940, 'Tokyo, Japan', 'https://www.mamiya.com', 'Cameras'),
('Rollei', 'Germany', 1920, 'Hamburg, Germany', 'https://www.rollei.com', 'Both'),
('Cosina', 'Japan', 1959, 'Nagano, Japan', 'https://www.cosina.co.jp', 'Lenses'),
('Viltrox', 'China', 2007, 'Shenzhen, China', 'https://www.viltrox.com', 'Lenses'),
('Yongnuo', 'China', 2006, 'Shenzhen, China', 'https://www.yongnuo.com', 'Accessories'),
('Meike', 'China', 2006, 'Shenzhen, China', 'https://www.meike.com', 'Accessories'),
('TTArtisan', 'China', 2019, 'Shenzhen, China', 'https://www.ttartisan.com', 'Lenses'),
('7Artisans', 'China', 2015, 'Shenzhen, China', 'https://www.7artisans.com', 'Lenses'),
('Laowa', 'China', 2013, 'Hefei, China', 'https://www.vfresco.com', 'Lenses'),
('Irix', 'Switzerland', 2016, 'Geneva, Switzerland', 'https://www.irixlens.com', 'Lenses'),
('Meyer Optik', 'Germany', 1896, 'Gorlitz, Germany', 'https://www.meyer-optik-goerlitz.com', 'Lenses'),
('Mitakon', 'China', 2012, 'Shenyang, China', 'https://www.zyoptics.net', 'Lenses'),
('SLR Magic', 'Hong Kong', 2010, 'Hong Kong', 'https://www.slrmagic.com', 'Lenses'),
('Lensbaby', 'United States', 2004, 'Portland, Oregon', 'https://www.lensbaby.com', 'Lenses'),
('Lomography', 'Austria', 1992, 'Vienna, Austria', 'https://www.lomography.com', 'Cameras'),
('Fotodiox', 'United States', 2004, 'San Diego, California', 'https://www.fotodiox.com', 'Accessories'),
('Metabones', 'Hong Kong', 2012, 'Hong Kong', 'https://www.metabones.com', 'Accessories');

-- =============================================
-- SENSORS (40 records)
-- =============================================
INSERT INTO sensors (name, type, format_size, megapixels, iso_min, iso_max) VALUES
('Sony IMX410', 'BSI-CMOS', 'Full Frame', 24.2, 100, 51200),
('Sony IMX571', 'BSI-CMOS', 'APS-C', 26.1, 100, 51200),
('Sony IMX455', 'BSI-CMOS', 'Full Frame', 61.0, 100, 102400),
('Sony IMX311', 'CMOS', 'Full Frame', 42.4, 100, 102400),
('Sony IMX021', 'CMOS', 'Full Frame', 12.1, 200, 25600),
('Canon CMOS FF1', 'CMOS', 'Full Frame', 30.4, 100, 32000),
('Canon CMOS FF2', 'CMOS', 'Full Frame', 50.6, 100, 12800),
('Canon CMOS FF3', 'BSI-CMOS', 'Full Frame', 45.0, 100, 51200),
('Canon CMOS APS1', 'CMOS', 'APS-C', 32.5, 100, 25600),
('Canon CMOS APS2', 'CMOS', 'APS-C', 24.2, 100, 25600),
('Nikon CMOS FX1', 'BSI-CMOS', 'Full Frame', 45.7, 64, 25600),
('Nikon CMOS FX2', 'BSI-CMOS', 'Full Frame', 24.5, 100, 51200),
('Nikon CMOS DX1', 'CMOS', 'APS-C', 20.9, 100, 25600),
('Nikon Stacked FX', 'Stacked CMOS', 'Full Frame', 24.5, 100, 51200),
('Fujifilm X-Trans 4', 'CMOS', 'APS-C', 26.1, 160, 12800),
('Fujifilm X-Trans 5', 'BSI-CMOS', 'APS-C', 40.2, 125, 12800),
('Fujifilm GFX 100S', 'BSI-CMOS', 'Medium Format', 102.0, 100, 12800),
('Fujifilm GFX 50S', 'CMOS', 'Medium Format', 51.4, 100, 12800),
('Panasonic MFT 1', 'CMOS', 'Micro Four Thirds', 20.3, 200, 25600),
('Panasonic MFT 2', 'CMOS', 'Micro Four Thirds', 25.2, 100, 25600),
('Panasonic FF1', 'CMOS', 'Full Frame', 24.2, 100, 51200),
('Panasonic FF2', 'CMOS', 'Full Frame', 47.3, 100, 25600),
('Olympus MFT 1', 'CMOS', 'Micro Four Thirds', 20.4, 200, 25600),
('Olympus MFT 2', 'CMOS', 'Micro Four Thirds', 25.0, 100, 25600),
('Leica FF1', 'CMOS', 'Full Frame', 47.3, 100, 50000),
('Leica FF2', 'CMOS', 'Full Frame', 24.0, 100, 50000),
('Leica APS1', 'CMOS', 'APS-C', 24.0, 100, 50000),
('Hasselblad MF1', 'CMOS', 'Medium Format', 100.0, 64, 12800),
('Hasselblad MF2', 'CMOS', 'Medium Format', 50.0, 100, 12800),
('Phase One IQ4', 'BSI-CMOS', 'Medium Format', 151.0, 50, 25600),
('Phase One IQ3', 'CMOS', 'Medium Format', 100.0, 50, 12800),
('Sony IMX586', 'Stacked CMOS', '1-inch', 48.0, 100, 12800),
('Sony IMX689', 'Stacked CMOS', '1-inch', 48.0, 100, 12800),
('Sony A1 Sensor', 'Stacked CMOS', 'Full Frame', 50.1, 100, 102400),
('Canon R3 Sensor', 'Stacked CMOS', 'Full Frame', 24.1, 100, 102400),
('Nikon Z9 Sensor', 'Stacked CMOS', 'Full Frame', 45.7, 64, 102400),
('Sigma Foveon X3', 'CMOS', 'APS-C', 20.7, 100, 6400),
('Sigma Foveon Merrill', 'CMOS', 'APS-C', 46.0, 100, 6400),
('Pentax FF1', 'CMOS', 'Full Frame', 36.4, 100, 204800),
('Pentax APS1', 'CMOS', 'APS-C', 24.2, 100, 819200);

-- =============================================
-- MOUNTS (40 records)
-- =============================================
INSERT INTO mounts (manufacturer_id, name, flange_distance_mm, throat_diameter_mm, is_electronic) VALUES
(1, 'Canon EF', 44.00, 54.00, TRUE),
(1, 'Canon EF-S', 44.00, 54.00, TRUE),
(1, 'Canon RF', 20.00, 54.00, TRUE),
(1, 'Canon EF-M', 18.00, 47.00, TRUE),
(2, 'Nikon F', 46.50, 44.00, TRUE),
(2, 'Nikon Z', 16.00, 55.00, TRUE),
(3, 'Sony A', 44.50, 50.00, TRUE),
(3, 'Sony E', 18.00, 46.10, TRUE),
(4, 'Fujifilm X', 17.70, 43.50, TRUE),
(4, 'Fujifilm G', 26.70, 65.00, TRUE),
(5, 'Micro Four Thirds', 19.25, 38.00, TRUE),
(6, 'Micro Four Thirds', 19.25, 38.00, TRUE),
(7, 'Leica M', 27.80, 44.00, FALSE),
(7, 'Leica L', 20.00, 51.60, TRUE),
(7, 'Leica S', 45.00, 68.00, TRUE),
(7, 'Leica TL', 20.00, 51.60, TRUE),
(8, 'Hasselblad X', 25.00, 66.00, TRUE),
(8, 'Hasselblad H', 61.63, 68.00, TRUE),
(8, 'Hasselblad V', 74.90, 82.10, FALSE),
(9, 'Pentax K', 45.46, 44.00, TRUE),
(9, 'Pentax 645', 70.87, 64.00, TRUE),
(10, 'Sigma SA', 44.00, 44.00, TRUE),
(14, 'Leica L', 20.00, 51.60, TRUE),
(16, 'Phase One XF', 63.25, 67.00, TRUE),
(17, 'RED DSMC2', 19.00, 48.00, TRUE),
(18, 'Blackmagic', 25.33, 46.00, TRUE),
(19, 'DJI DL', 16.84, 53.00, TRUE),
(21, 'Pentax K', 45.46, 44.00, TRUE),
(26, 'Cosina VM', 27.80, 44.00, FALSE),
(13, 'Contax/Yashica', 45.50, 48.00, FALSE),
(13, 'Zeiss ZM', 27.80, 44.00, FALSE),
(13, 'Zeiss ZF', 46.50, 44.00, TRUE),
(13, 'Zeiss ZE', 44.00, 54.00, TRUE),
(15, 'Voigtlander VM', 27.80, 44.00, FALSE),
(26, 'Cosina SL', 20.00, 51.60, TRUE),
(5, 'Leica L', 20.00, 51.60, TRUE),
(24, 'Mamiya 645', 63.30, 62.00, TRUE),
(25, 'Rollei SL66', 102.80, 80.00, FALSE),
(22, 'Kodak V', 58.30, 57.00, FALSE),
(12, 'Tokina ATX', 44.00, 54.00, TRUE);

-- =============================================
-- IMAGE PROCESSORS (40 records)
-- =============================================
INSERT INTO image_processors (manufacturer_id, name, generation, release_year, max_burst_fps, max_video_resolution, bit_depth, ai_features) VALUES
(1, 'DIGIC 4', 4, 2008, 5, '1080p30', 14, NULL),
(1, 'DIGIC 5+', 5, 2012, 10, '1080p60', 14, NULL),
(1, 'DIGIC 6+', 6, 2014, 14, '4K30', 14, NULL),
(1, 'DIGIC 8', 8, 2018, 20, '4K60', 14, 'Eye AF'),
(1, 'DIGIC X', 10, 2020, 30, '8K30', 14, 'Eye AF, Animal AF, Vehicle AF'),
(2, 'EXPEED 4', 4, 2014, 11, '1080p60', 14, NULL),
(2, 'EXPEED 5', 5, 2016, 12, '4K30', 14, 'Face Detection'),
(2, 'EXPEED 6', 6, 2018, 14, '4K60', 14, 'Eye AF'),
(2, 'EXPEED 7', 7, 2021, 30, '8K30', 14, 'Eye AF, Animal AF, Vehicle AF'),
(3, 'BIONZ', 1, 2006, 5, '1080p30', 12, NULL),
(3, 'BIONZ X', 2, 2013, 11, '4K30', 14, 'Eye AF'),
(3, 'BIONZ XR', 3, 2020, 30, '8K30', 16, 'Real-time Eye AF, Bird AF'),
(4, 'X-Processor Pro', 1, 2016, 8, '4K30', 14, 'Face Detection'),
(4, 'X-Processor 4', 4, 2018, 11, '4K60', 14, 'Eye AF'),
(4, 'X-Processor 5', 5, 2022, 40, '8K30', 14, 'Subject Detection AI'),
(5, 'Venus Engine HD', 1, 2009, 5, '1080p60', 12, NULL),
(5, 'Venus Engine 10', 10, 2017, 12, '4K60', 14, 'DFD AF'),
(5, 'Venus Engine 11', 11, 2022, 30, '6K30', 14, 'Phase Detect AF'),
(6, 'TruePic VII', 7, 2014, 10, '4K30', 12, NULL),
(6, 'TruePic VIII', 8, 2016, 15, '4K60', 12, 'Face Detection'),
(6, 'TruePic IX', 9, 2019, 20, '4K60', 12, 'AI Subject Detection'),
(6, 'TruePic X', 10, 2022, 50, '4K120', 12, 'AI Subject Detection'),
(7, 'Maestro', 1, 2012, 3, '1080p30', 14, NULL),
(7, 'Maestro II', 2, 2017, 10, '4K30', 14, 'Face Detection'),
(7, 'Maestro III', 3, 2020, 14, '5K30', 14, 'Eye AF'),
(8, 'Hasselblad Image Processor', 1, 2016, 2, '4K30', 16, NULL),
(8, 'Hasselblad Image Processor 2', 2, 2020, 4, '4K60', 16, 'Face Detection'),
(16, 'Phase One Sensor+', 1, 2019, 3, '4K30', 16, NULL),
(9, 'PRIME', 1, 2013, 6, '1080p60', 14, NULL),
(9, 'PRIME IV', 4, 2016, 7, '4K30', 14, NULL),
(9, 'PRIME V', 5, 2021, 12, '4K60', 14, 'Eye AF'),
(10, 'TRUE III', 3, 2020, 5, '4K30', 14, NULL),
(17, 'RED IPP2', 2, 2017, 24, '8K60', 16, NULL),
(17, 'RED IPP3', 3, 2022, 30, '8K120', 16, NULL),
(18, 'Blackmagic Image Processor', 1, 2018, 12, '6K60', 12, NULL),
(18, 'Blackmagic Gen 5', 5, 2021, 24, '12K60', 16, NULL),
(19, 'DJI CineCore', 1, 2019, 10, '6K30', 12, NULL),
(19, 'DJI CineCore 3.0', 3, 2022, 20, '8K30', 14, 'Subject Tracking'),
(3, 'BIONZ XR Gen2', 4, 2023, 40, '8K60', 16, 'AI Processing Unit'),
(1, 'DIGIC X+', 11, 2023, 40, '8K60', 14, 'Deep Learning AF');

-- =============================================
-- CAMERA BODIES (40 records)
-- =============================================
INSERT INTO camera_bodies (manufacturer_id, sensor_id, mount_id, processor_id, name, body_type, release_date, price, weight_g, body_material) VALUES
(1, 6, 1, 4, 'Canon EOS 5D Mark IV', 'DSLR', '2016-08-25', 2499.00, 890, 'Magnesium Alloy'),
(1, 7, 1, 3, 'Canon EOS 5DS R', 'DSLR', '2015-06-01', 3699.00, 930, 'Magnesium Alloy'),
(1, 8, 3, 5, 'Canon EOS R5', 'Mirrorless', '2020-07-09', 3899.00, 738, 'Magnesium Alloy'),
(1, 35, 3, 5, 'Canon EOS R3', 'Mirrorless', '2021-11-01', 5999.00, 822, 'Magnesium Alloy'),
(1, 9, 2, 4, 'Canon EOS 90D', 'DSLR', '2019-08-28', 1199.00, 701, 'Polycarbonate'),
(1, 10, 4, 4, 'Canon EOS M6 Mark II', 'Mirrorless', '2019-08-28', 849.00, 408, 'Magnesium Alloy'),
(2, 11, 5, 7, 'Nikon D850', 'DSLR', '2017-07-25', 2996.00, 1015, 'Magnesium Alloy'),
(2, 12, 6, 8, 'Nikon Z6 II', 'Mirrorless', '2020-10-14', 1996.00, 705, 'Magnesium Alloy'),
(2, 36, 6, 9, 'Nikon Z9', 'Mirrorless', '2021-12-24', 5496.00, 1340, 'Magnesium Alloy'),
(2, 12, 6, 9, 'Nikon Z8', 'Mirrorless', '2023-05-10', 3996.00, 910, 'Magnesium Alloy'),
(2, 13, 5, 6, 'Nikon D7500', 'DSLR', '2017-04-12', 1249.00, 720, 'Magnesium Alloy'),
(3, 1, 8, 11, 'Sony A7 III', 'Mirrorless', '2018-02-27', 1999.00, 650, 'Magnesium Alloy'),
(3, 3, 8, 12, 'Sony A7R IV', 'Mirrorless', '2019-07-16', 3499.00, 665, 'Magnesium Alloy'),
(3, 34, 8, 12, 'Sony A1', 'Mirrorless', '2021-01-27', 6499.00, 737, 'Magnesium Alloy'),
(3, 4, 8, 12, 'Sony A7R V', 'Mirrorless', '2022-10-26', 3899.00, 723, 'Magnesium Alloy'),
(3, 2, 8, 11, 'Sony A6600', 'Mirrorless', '2019-08-28', 1398.00, 503, 'Magnesium Alloy'),
(4, 15, 9, 14, 'Fujifilm X-T4', 'Mirrorless', '2020-02-26', 1699.00, 607, 'Magnesium Alloy'),
(4, 16, 9, 15, 'Fujifilm X-T5', 'Mirrorless', '2022-11-02', 1699.00, 557, 'Magnesium Alloy'),
(4, 16, 9, 15, 'Fujifilm X-H2', 'Mirrorless', '2022-09-08', 1999.00, 660, 'Magnesium Alloy'),
(4, 17, 10, 15, 'Fujifilm GFX 100S', 'Medium Format', '2021-01-27', 5999.00, 900, 'Magnesium Alloy'),
(4, 18, 10, 14, 'Fujifilm GFX 50S II', 'Medium Format', '2021-09-02', 3999.00, 900, 'Magnesium Alloy'),
(5, 19, 11, 17, 'Panasonic GH5 II', 'Mirrorless', '2021-06-01', 1699.00, 727, 'Magnesium Alloy'),
(5, 20, 11, 18, 'Panasonic GH6', 'Mirrorless', '2022-02-22', 2199.00, 823, 'Magnesium Alloy'),
(5, 21, 36, 17, 'Panasonic S5', 'Mirrorless', '2020-09-02', 1999.00, 714, 'Magnesium Alloy'),
(5, 22, 36, 18, 'Panasonic S5 II', 'Mirrorless', '2023-01-04', 2199.00, 740, 'Magnesium Alloy'),
(6, 23, 12, 20, 'Olympus OM-D E-M1 Mark III', 'Mirrorless', '2020-02-12', 1799.00, 580, 'Magnesium Alloy'),
(6, 24, 12, 22, 'OM System OM-1', 'Mirrorless', '2022-02-15', 2199.00, 599, 'Magnesium Alloy'),
(7, 25, 14, 25, 'Leica SL2', 'Mirrorless', '2019-11-06', 5995.00, 835, 'Aluminum'),
(7, 26, 13, 24, 'Leica M11', 'Mirrorless', '2022-01-13', 8995.00, 530, 'Brass'),
(7, 27, 16, 24, 'Leica TL2', 'Mirrorless', '2017-07-10', 1950.00, 399, 'Aluminum'),
(8, 28, 17, 27, 'Hasselblad X2D 100C', 'Medium Format', '2022-09-07', 8199.00, 895, 'Aluminum'),
(8, 29, 17, 26, 'Hasselblad X1D II 50C', 'Medium Format', '2019-06-19', 5750.00, 766, 'Aluminum'),
(9, 39, 20, 31, 'Pentax K-1 Mark II', 'DSLR', '2018-04-20', 1799.00, 1010, 'Magnesium Alloy'),
(9, 40, 20, 30, 'Pentax K-3 Mark III', 'DSLR', '2021-04-23', 1999.00, 820, 'Magnesium Alloy'),
(10, 37, 22, 32, 'Sigma fp', 'Mirrorless', '2019-10-25', 1899.00, 422, 'Aluminum'),
(10, 37, 22, 32, 'Sigma fp L', 'Mirrorless', '2021-03-12', 2499.00, 427, 'Aluminum'),
(16, 30, 24, 28, 'Phase One XF IQ4 150MP', 'Medium Format', '2018-09-12', 51990.00, 1945, 'Aluminum'),
(17, 34, 25, 34, 'RED V-Raptor', 'Cinema', '2021-06-01', 24500.00, 1850, 'Aluminum'),
(18, 1, 26, 36, 'Blackmagic Pocket Cinema 6K G2', 'Cinema', '2022-06-15', 2495.00, 823, 'Carbon Fiber'),
(19, 32, 27, 38, 'DJI Ronin 4D', 'Cinema', '2021-10-20', 7199.00, 1450, 'Magnesium Alloy');

-- =============================================
-- BODY FEATURES (40 records)
-- =============================================
INSERT INTO body_features (body_id, weather_sealed, operating_temp_min, operating_temp_max, shutter_durability, has_gps, has_bluetooth, has_wifi) VALUES
(1, TRUE, 0, 40, 500000, TRUE, FALSE, TRUE),
(2, TRUE, 0, 40, 500000, TRUE, FALSE, TRUE),
(3, TRUE, 0, 40, 500000, TRUE, TRUE, TRUE),
(4, TRUE, -10, 40, 500000, TRUE, TRUE, TRUE),
(5, TRUE, 0, 40, 200000, FALSE, TRUE, TRUE),
(6, FALSE, 0, 40, 200000, FALSE, TRUE, TRUE),
(7, TRUE, 0, 40, 400000, TRUE, TRUE, TRUE),
(8, TRUE, -10, 40, 400000, FALSE, TRUE, TRUE),
(9, TRUE, -10, 40, 400000, TRUE, TRUE, TRUE),
(10, TRUE, -10, 40, 400000, FALSE, TRUE, TRUE),
(11, TRUE, 0, 40, 200000, FALSE, TRUE, TRUE),
(12, TRUE, 0, 40, 500000, FALSE, TRUE, TRUE),
(13, TRUE, 0, 40, 500000, FALSE, TRUE, TRUE),
(14, TRUE, 0, 40, 500000, FALSE, TRUE, TRUE),
(15, TRUE, 0, 40, 500000, FALSE, TRUE, TRUE),
(16, TRUE, 0, 40, 200000, FALSE, TRUE, TRUE),
(17, TRUE, -10, 40, 300000, FALSE, TRUE, TRUE),
(18, TRUE, -10, 40, 300000, FALSE, TRUE, TRUE),
(19, TRUE, -10, 40, 300000, FALSE, TRUE, TRUE),
(20, TRUE, -10, 40, 500000, FALSE, TRUE, TRUE),
(21, TRUE, -10, 40, 500000, FALSE, TRUE, TRUE),
(22, TRUE, -10, 40, 400000, FALSE, TRUE, TRUE),
(23, TRUE, -10, 40, 400000, FALSE, TRUE, TRUE),
(24, TRUE, -10, 40, 400000, FALSE, TRUE, TRUE),
(25, TRUE, -10, 40, 400000, FALSE, TRUE, TRUE),
(26, TRUE, -10, 40, 400000, FALSE, TRUE, TRUE),
(27, TRUE, -10, 40, 400000, FALSE, TRUE, TRUE),
(28, TRUE, -10, 40, 500000, FALSE, TRUE, TRUE),
(29, TRUE, -10, 40, 500000, FALSE, TRUE, TRUE),
(30, FALSE, 0, 40, 300000, FALSE, TRUE, TRUE),
(31, TRUE, -10, 40, 500000, FALSE, TRUE, TRUE),
(32, TRUE, -10, 40, 500000, FALSE, TRUE, TRUE),
(33, TRUE, -10, 40, 300000, TRUE, TRUE, TRUE),
(34, TRUE, -10, 40, 300000, TRUE, TRUE, TRUE),
(35, TRUE, -10, 40, 400000, FALSE, TRUE, TRUE),
(36, TRUE, -10, 40, 400000, FALSE, TRUE, TRUE),
(37, TRUE, -10, 40, 500000, FALSE, TRUE, TRUE),
(38, TRUE, -10, 45, 200000, FALSE, TRUE, TRUE),
(39, TRUE, -10, 45, 200000, FALSE, TRUE, TRUE),
(40, TRUE, -20, 40, 200000, TRUE, TRUE, TRUE);

-- =============================================
-- BODY SPECS (40 records)
-- =============================================
INSERT INTO body_specs (body_id, shutter_speed_min, shutter_speed_max, burst_fps, video_resolution, has_ibis, ibis_stops, evf_resolution, lcd_size, lcd_articulating) VALUES
(1, '30s', '1/8000s', 7.0, '4K30', FALSE, NULL, NULL, 3.2, FALSE),
(2, '30s', '1/8000s', 5.0, '1080p60', FALSE, NULL, NULL, 3.2, FALSE),
(3, '30s', '1/8000s', 20.0, '8K30', TRUE, 8.0, 5760000, 3.2, TRUE),
(4, '30s', '1/8000s', 30.0, '6K60', TRUE, 8.0, 5760000, 3.2, TRUE),
(5, '30s', '1/8000s', 10.0, '4K30', FALSE, NULL, NULL, 3.0, TRUE),
(6, '30s', '1/4000s', 14.0, '4K30', FALSE, NULL, 2360000, 3.0, TRUE),
(7, '30s', '1/8000s', 9.0, '4K30', FALSE, NULL, NULL, 3.2, TRUE),
(8, '30s', '1/8000s', 14.0, '4K60', TRUE, 5.0, 3690000, 3.2, TRUE),
(9, '30s', '1/32000s', 30.0, '8K30', TRUE, 6.0, 3690000, 3.2, TRUE),
(10, '30s', '1/32000s', 20.0, '8K30', TRUE, 6.0, 3690000, 3.2, TRUE),
(11, '30s', '1/8000s', 8.0, '4K30', FALSE, NULL, NULL, 3.2, TRUE),
(12, '30s', '1/8000s', 10.0, '4K30', TRUE, 5.5, 2360000, 3.0, TRUE),
(13, '30s', '1/8000s', 10.0, '4K30', TRUE, 5.5, 5760000, 3.0, TRUE),
(14, '30s', '1/32000s', 30.0, '8K30', TRUE, 5.5, 9440000, 3.0, TRUE),
(15, '30s', '1/8000s', 10.0, '8K30', TRUE, 8.0, 9440000, 3.2, TRUE),
(16, '30s', '1/4000s', 11.0, '4K30', TRUE, 5.0, 2360000, 3.0, TRUE),
(17, '30s', '1/8000s', 15.0, '4K60', TRUE, 6.5, 3690000, 3.0, TRUE),
(18, '30s', '1/180000s', 15.0, '6K30', TRUE, 7.0, 3690000, 3.0, TRUE),
(19, '30s', '1/180000s', 15.0, '8K30', TRUE, 7.0, 5760000, 3.0, TRUE),
(20, '60s', '1/16000s', 5.0, '4K30', TRUE, 6.0, 5760000, 3.2, TRUE),
(21, '60s', '1/16000s', 3.0, '4K30', TRUE, 6.5, 3690000, 3.2, TRUE),
(22, '60s', '1/8000s', 9.0, '4K60', TRUE, 6.5, 3690000, 3.0, TRUE),
(23, '60s', '1/8000s', 14.0, '5.7K60', TRUE, 7.5, 3690000, 3.0, TRUE),
(24, '60s', '1/8000s', 7.0, '4K60', TRUE, 5.0, 2360000, 3.0, TRUE),
(25, '60s', '1/8000s', 9.0, '6K30', TRUE, 6.5, 3690000, 3.0, TRUE),
(26, '60s', '1/8000s', 18.0, '4K60', TRUE, 7.5, 3690000, 3.0, TRUE),
(27, '60s', '1/32000s', 50.0, '4K120', TRUE, 7.5, 5760000, 3.0, TRUE),
(28, '60s', '1/8000s', 6.0, '5K30', TRUE, 5.5, 5760000, 3.2, TRUE),
(29, '60s', '1/16000s', 4.5, '4K30', FALSE, NULL, 3690000, 3.0, FALSE),
(30, '30s', '1/4000s', 7.0, '4K30', FALSE, NULL, 2360000, 3.7, FALSE),
(31, '60s', '1/16000s', 3.7, '4K60', TRUE, 7.0, 5760000, 3.6, TRUE),
(32, '60s', '1/16000s', 2.7, '4K30', TRUE, 6.5, 3690000, 3.6, TRUE),
(33, '30s', '1/8000s', 4.4, '4K30', TRUE, 5.0, NULL, 3.2, FALSE),
(34, '30s', '1/12000s', 12.0, '4K30', TRUE, 5.5, 1620000, 3.2, FALSE),
(35, '30s', '1/8000s', 18.0, '4K30', FALSE, NULL, 2360000, 3.2, FALSE),
(36, '30s', '1/8000s', 10.0, '4K30', FALSE, NULL, 2360000, 3.2, FALSE),
(37, '60s', '1/4000s', 3.0, '4K30', FALSE, NULL, 3690000, 3.2, TRUE),
(38, '1s', '1/8000s', 120.0, '8K60', FALSE, NULL, NULL, 4.7, TRUE),
(39, '60s', '1/8000s', 60.0, '6K50', FALSE, NULL, NULL, 5.0, TRUE),
(40, '8s', '1/8000s', 60.0, '8K75', TRUE, 6.0, NULL, 5.5, TRUE);

-- =============================================
-- AUTOFOCUS SYSTEMS (40 records)
-- =============================================
INSERT INTO autofocus_systems (name, type, focus_points, cross_type_points, eye_tracking, tracking_types, low_light_ev, af_speed_rating) VALUES
('Canon Dual Pixel CMOS AF', 'Dual Pixel', 5940, 5940, TRUE, 'Eye, Face', -6.0, '0.05s'),
('Canon Dual Pixel CMOS AF II', 'Dual Pixel', 6072, 6072, TRUE, 'Eye, Face, Animal, Vehicle', -7.5, '0.03s'),
('Canon EOS iTR AF X', 'Dual Pixel', 1053, 1053, TRUE, 'Eye, Face, Head, Animal, Vehicle', -7.5, '0.03s'),
('Canon 61-Point AF', 'Phase Detection', 61, 41, FALSE, 'Face', -3.0, '0.15s'),
('Canon 45-Point AF', 'Phase Detection', 45, 45, FALSE, 'Face', -3.0, '0.15s'),
('Nikon Multi-CAM 20K', 'Phase Detection', 153, 99, TRUE, 'Eye, Face', -4.0, '0.10s'),
('Nikon Hybrid AF', 'Hybrid', 493, 493, TRUE, 'Eye, Face, Animal', -4.5, '0.05s'),
('Nikon Deep Learning AF', 'Hybrid', 493, 493, TRUE, 'Eye, Face, Animal, Vehicle, Aircraft', -8.5, '0.02s'),
('Sony Fast Hybrid AF', 'Hybrid', 693, 693, TRUE, 'Eye, Face', -3.0, '0.05s'),
('Sony Real-time Tracking', 'Hybrid', 759, 759, TRUE, 'Eye, Face, Animal', -4.0, '0.03s'),
('Sony AI AF', 'Hybrid', 759, 759, TRUE, 'Eye, Face, Animal, Bird, Insect, Vehicle', -5.0, '0.02s'),
('Fujifilm Intelligent Hybrid AF', 'Hybrid', 425, 425, TRUE, 'Eye, Face', -5.0, '0.06s'),
('Fujifilm Deep Learning AF', 'Hybrid', 425, 425, TRUE, 'Eye, Face, Animal, Bird, Vehicle', -7.0, '0.04s'),
('Panasonic DFD', 'Contrast Detection', 225, 0, TRUE, 'Eye, Face, Animal', -6.0, '0.08s'),
('Panasonic Phase Hybrid AF', 'Hybrid', 779, 779, TRUE, 'Eye, Face, Animal, Vehicle', -6.5, '0.03s'),
('Olympus 121-Point AF', 'Phase Detection', 121, 121, TRUE, 'Eye, Face', -6.0, '0.05s'),
('OM System AI AF', 'Hybrid', 1053, 1053, TRUE, 'Eye, Face, Motorsport, Aircraft, Train', -8.0, '0.02s'),
('Leica Maestro AF', 'Contrast Detection', 225, 0, TRUE, 'Eye, Face', -4.0, '0.10s'),
('Leica Object Detection AF', 'Hybrid', 315, 315, TRUE, 'Eye, Face', -5.0, '0.06s'),
('Hasselblad PDAF', 'Phase Detection', 117, 117, TRUE, 'Eye, Face', -4.0, '0.15s'),
('Hasselblad Predictive AF', 'Phase Detection', 294, 294, TRUE, 'Eye, Face', -3.5, '0.10s'),
('Pentax SAFOX 11', 'Phase Detection', 27, 25, FALSE, 'Face', -3.0, '0.15s'),
('Pentax SAFOX 13', 'Phase Detection', 101, 25, TRUE, 'Eye, Face', -4.0, '0.10s'),
('Sigma Hybrid AF', 'Hybrid', 49, 49, FALSE, 'Face', -5.0, '0.12s'),
('Phase One AF', 'Contrast Detection', 280, 0, TRUE, 'Eye, Face', -2.0, '0.20s'),
('RED Autofocus', 'Contrast Detection', 100, 0, FALSE, 'Face', -2.0, '0.25s'),
('Blackmagic AF', 'Contrast Detection', 100, 0, FALSE, 'Face', -3.0, '0.20s'),
('DJI LiDAR AF', 'Phase Detection', 324, 324, TRUE, 'Face', -8.0, '0.03s'),
('Canon EOS Cross-type AF', 'Phase Detection', 65, 65, FALSE, 'Face', -2.5, '0.12s'),
('Nikon 51-Point AF', 'Phase Detection', 51, 15, FALSE, 'Face', -2.0, '0.15s'),
('Sony 4D FOCUS', 'Hybrid', 399, 399, FALSE, 'Eye, Face', -2.0, '0.06s'),
('Fujifilm X-Processor AF', 'Hybrid', 117, 117, FALSE, 'Face', -3.0, '0.10s'),
('Panasonic 225-Point AF', 'Contrast Detection', 225, 0, FALSE, 'Face', -4.0, '0.12s'),
('Olympus C-AF', 'Phase Detection', 81, 69, TRUE, 'Eye, Face', -5.0, '0.06s'),
('Sony A-mount AF', 'Phase Detection', 79, 15, FALSE, 'Eye, Face', -3.0, '0.10s'),
('Canon Color Tracking AF', 'Dual Pixel', 4500, 4500, TRUE, 'Eye, Face, Animal', -6.5, '0.04s'),
('Nikon 3D Tracking', 'Phase Detection', 153, 99, FALSE, 'Face', -3.5, '0.08s'),
('Sony A9 AF', 'Hybrid', 693, 693, TRUE, 'Eye, Face, Animal', -3.0, '0.02s'),
('Fujifilm Face/Eye AF', 'Hybrid', 325, 325, TRUE, 'Eye, Face', -3.0, '0.08s'),
('Panasonic S1H AF', 'Contrast Detection', 225, 0, TRUE, 'Eye, Face, Animal', -6.0, '0.08s');

-- =============================================
-- BODY AUTOFOCUS (40 records)
-- =============================================
INSERT INTO body_autofocus (body_id, af_id, firmware_version_added, is_primary, notes) VALUES
(1, 4, '1.0.0', TRUE, 'Standard 61-point system'),
(2, 4, '1.0.0', TRUE, 'Same as 5D Mark IV'),
(3, 2, '1.0.0', TRUE, 'Dual Pixel CMOS AF II'),
(4, 3, '1.0.0', TRUE, 'Eye Control AF supported'),
(5, 5, '1.0.0', TRUE, '45-point all cross-type'),
(6, 1, '1.0.0', TRUE, 'Dual Pixel CMOS AF'),
(7, 6, '1.0.0', TRUE, 'Multi-CAM 20K'),
(8, 7, '1.0.0', TRUE, 'Hybrid AF system'),
(9, 8, '1.0.0', TRUE, 'Deep Learning AF'),
(10, 8, '1.0.0', TRUE, 'Same as Z9'),
(11, 30, '1.0.0', TRUE, '51-point AF'),
(12, 9, '1.0.0', TRUE, 'Fast Hybrid AF'),
(13, 10, '1.0.0', TRUE, 'Real-time Tracking'),
(14, 11, '1.0.0', TRUE, 'AI-based AF'),
(15, 11, '2.0.0', TRUE, 'AI AF with 8-stop IBIS'),
(16, 9, '1.0.0', TRUE, 'Fast Hybrid AF'),
(17, 12, '1.0.0', TRUE, 'Intelligent Hybrid AF'),
(18, 13, '1.0.0', TRUE, 'Deep Learning AF'),
(19, 13, '1.0.0', TRUE, 'Deep Learning AF'),
(20, 13, '1.0.0', TRUE, 'Subject Detection AF'),
(21, 12, '1.0.0', TRUE, 'Intelligent Hybrid AF'),
(22, 14, '1.0.0', TRUE, 'DFD technology'),
(23, 15, '1.0.0', TRUE, 'Phase Hybrid AF'),
(24, 14, '1.0.0', TRUE, 'DFD AF'),
(25, 15, '1.0.0', TRUE, 'Phase Hybrid AF'),
(26, 16, '1.0.0', TRUE, '121-point system'),
(27, 17, '1.0.0', TRUE, 'AI Subject Detection'),
(28, 19, '1.0.0', TRUE, 'Object Detection AF'),
(29, 18, '1.0.0', TRUE, 'Maestro AF'),
(30, 18, '1.0.0', TRUE, 'Contrast AF'),
(31, 21, '1.0.0', TRUE, 'Predictive AF'),
(32, 20, '1.0.0', TRUE, 'PDAF system'),
(33, 22, '1.0.0', TRUE, 'SAFOX 11'),
(34, 23, '1.0.0', TRUE, 'SAFOX 13'),
(35, 24, '1.0.0', TRUE, 'Hybrid AF'),
(36, 24, '1.0.0', TRUE, 'Hybrid AF'),
(37, 25, '1.0.0', TRUE, 'Contrast Detection'),
(38, 26, '1.0.0', TRUE, 'RED Autofocus'),
(39, 27, '1.0.0', TRUE, 'Blackmagic AF'),
(40, 28, '1.0.0', TRUE, 'LiDAR assisted AF');

-- =============================================
-- VIEWFINDERS (40 records)
-- =============================================
INSERT INTO viewfinders (body_id, type, resolution, magnification, refresh_rate_hz, coverage_percent) VALUES
(1, 'OVF', NULL, 0.71, NULL, 100.00),
(2, 'OVF', NULL, 0.71, NULL, 100.00),
(3, 'EVF', 5760000, 0.76, 120, 100.00),
(4, 'EVF', 5760000, 0.76, 120, 100.00),
(5, 'OVF', NULL, 0.95, NULL, 100.00),
(6, 'EVF', 2360000, 0.39, 60, 100.00),
(7, 'OVF', NULL, 0.75, NULL, 100.00),
(8, 'EVF', 3690000, 0.80, 60, 100.00),
(9, 'EVF', 3690000, 0.80, 120, 100.00),
(10, 'EVF', 3690000, 0.80, 120, 100.00),
(11, 'OVF', NULL, 0.94, NULL, 100.00),
(12, 'EVF', 2360000, 0.78, 60, 100.00),
(13, 'EVF', 5760000, 0.78, 60, 100.00),
(14, 'EVF', 9440000, 0.90, 240, 100.00),
(15, 'EVF', 9440000, 0.90, 240, 100.00),
(16, 'EVF', 2360000, 0.70, 120, 100.00),
(17, 'EVF', 3690000, 0.75, 100, 100.00),
(18, 'EVF', 3690000, 0.80, 120, 100.00),
(19, 'EVF', 5760000, 0.80, 120, 100.00),
(20, 'EVF', 5760000, 0.77, 60, 100.00),
(21, 'EVF', 3690000, 0.77, 60, 100.00),
(22, 'EVF', 3680000, 0.76, 120, 100.00),
(23, 'EVF', 3680000, 0.76, 120, 100.00),
(24, 'EVF', 2360000, 0.74, 60, 100.00),
(25, 'EVF', 3680000, 0.78, 60, 100.00),
(26, 'EVF', 2360000, 0.74, 120, 100.00),
(27, 'EVF', 5760000, 0.83, 120, 100.00),
(28, 'EVF', 5760000, 0.78, 60, 100.00),
(29, 'EVF', 3690000, 0.73, 60, 100.00),
(30, 'EVF', 2360000, 0.70, 60, 100.00),
(31, 'EVF', 5760000, 1.00, 60, 100.00),
(32, 'EVF', 3690000, 0.87, 60, 100.00),
(33, 'OVF', NULL, 0.70, NULL, 100.00),
(34, 'OVF', NULL, 1.05, NULL, 100.00),
(35, 'EVF', 2360000, 0.70, 60, 100.00),
(36, 'EVF', 2360000, 0.70, 60, 100.00),
(37, 'EVF', 3690000, 0.87, 60, 100.00),
(38, 'None', NULL, 0.00, NULL, 0.00),
(39, 'None', NULL, 0.00, NULL, 0.00),
(40, 'EVF', 1280000, 0.00, 60, 100.00);

-- =============================================
-- STORAGE TYPES (12 records - realistic count)
-- =============================================
INSERT INTO storage_types (name, form_factor, bus_interface, max_capacity_gb, max_speed_mbps, uhs_class, video_speed_class) VALUES
('SD', 'SD Card', 'SD', 2, 25, NULL, NULL),
('SDHC', 'SD Card', 'SD', 32, 104, 'UHS-I', 'V10'),
('SDXC UHS-I', 'SD Card', 'SD', 512, 104, 'UHS-I', 'V30'),
('SDXC UHS-II', 'SD Card', 'SD', 1024, 312, 'UHS-II', 'V90'),
('CFast 2.0', 'CFast', 'SATA III', 512, 525, NULL, NULL),
('CFexpress Type A', 'CFexpress', 'PCIe Gen3', 640, 800, NULL, NULL),
('CFexpress Type B', 'CFexpress', 'PCIe Gen3', 2048, 1700, NULL, NULL),
('XQD', 'XQD', 'PCIe Gen2', 256, 440, NULL, NULL),
('CompactFlash', 'CF', 'PATA', 256, 167, NULL, NULL),
('microSD', 'microSD', 'SD', 1024, 104, 'UHS-I', 'V30'),
('microSDXC UHS-II', 'microSD', 'SD', 1024, 312, 'UHS-II', 'V60'),
('SSD (Internal)', 'M.2', 'NVMe', 4096, 3500, NULL, NULL);

-- =============================================
-- BODY STORAGE SLOTS (60 records - cameras have 1-2 slots)
-- =============================================
INSERT INTO body_storage_slots (body_id, storage_type_id, slot_number, is_primary, supports_relay, supports_backup, max_write_speed_mbps) VALUES
(1, 9, 1, TRUE, TRUE, TRUE, 167),
(1, 4, 2, FALSE, TRUE, TRUE, 250),
(2, 9, 1, TRUE, TRUE, TRUE, 167),
(2, 4, 2, FALSE, TRUE, TRUE, 250),
(3, 7, 1, TRUE, TRUE, TRUE, 1700),
(3, 4, 2, FALSE, TRUE, TRUE, 250),
(4, 7, 1, TRUE, TRUE, TRUE, 1700),
(4, 7, 2, FALSE, TRUE, TRUE, 1700),
(5, 4, 1, TRUE, FALSE, FALSE, 250),
(6, 4, 1, TRUE, FALSE, FALSE, 250),
(7, 8, 1, TRUE, TRUE, TRUE, 400),
(7, 4, 2, FALSE, TRUE, TRUE, 250),
(8, 7, 1, TRUE, TRUE, TRUE, 1700),
(8, 4, 2, FALSE, TRUE, TRUE, 250),
(9, 7, 1, TRUE, TRUE, TRUE, 1700),
(9, 7, 2, FALSE, TRUE, TRUE, 1700),
(10, 7, 1, TRUE, TRUE, TRUE, 1700),
(10, 4, 2, FALSE, TRUE, TRUE, 250),
(11, 4, 1, TRUE, FALSE, FALSE, 250),
(12, 4, 1, TRUE, TRUE, TRUE, 250),
(12, 4, 2, FALSE, TRUE, TRUE, 250),
(13, 4, 1, TRUE, TRUE, TRUE, 300),
(13, 4, 2, FALSE, TRUE, TRUE, 300),
(14, 7, 1, TRUE, TRUE, TRUE, 800),
(14, 6, 2, FALSE, TRUE, TRUE, 700),
(15, 7, 1, TRUE, TRUE, TRUE, 800),
(15, 6, 2, FALSE, TRUE, TRUE, 700),
(16, 4, 1, TRUE, FALSE, FALSE, 250),
(17, 4, 1, TRUE, TRUE, TRUE, 250),
(17, 4, 2, FALSE, TRUE, TRUE, 250),
(18, 4, 1, TRUE, TRUE, TRUE, 300),
(18, 4, 2, FALSE, TRUE, TRUE, 300),
(19, 7, 1, TRUE, TRUE, TRUE, 800),
(19, 4, 2, FALSE, TRUE, TRUE, 300),
(20, 4, 1, TRUE, TRUE, TRUE, 300),
(20, 4, 2, FALSE, TRUE, TRUE, 300),
(21, 4, 1, TRUE, TRUE, TRUE, 300),
(21, 4, 2, FALSE, TRUE, TRUE, 300),
(22, 4, 1, TRUE, TRUE, TRUE, 300),
(22, 4, 2, FALSE, TRUE, TRUE, 300),
(23, 7, 1, TRUE, TRUE, TRUE, 800),
(23, 4, 2, FALSE, TRUE, TRUE, 300),
(24, 4, 1, TRUE, TRUE, TRUE, 300),
(24, 4, 2, FALSE, TRUE, TRUE, 300),
(25, 4, 1, TRUE, TRUE, TRUE, 300),
(25, 7, 2, FALSE, TRUE, TRUE, 800),
(26, 4, 1, TRUE, TRUE, TRUE, 300),
(26, 4, 2, FALSE, TRUE, TRUE, 300),
(27, 7, 1, TRUE, TRUE, TRUE, 800),
(27, 4, 2, FALSE, TRUE, TRUE, 300),
(28, 7, 1, TRUE, TRUE, TRUE, 1700),
(28, 4, 2, FALSE, TRUE, TRUE, 300),
(29, 4, 1, TRUE, FALSE, FALSE, 300),
(30, 4, 1, TRUE, FALSE, FALSE, 250),
(31, 7, 1, TRUE, TRUE, TRUE, 1700),
(31, 4, 2, FALSE, TRUE, TRUE, 300),
(32, 4, 1, TRUE, FALSE, FALSE, 300),
(33, 4, 1, TRUE, TRUE, TRUE, 300),
(33, 4, 2, FALSE, TRUE, TRUE, 300),
(34, 4, 1, TRUE, TRUE, TRUE, 300),
(34, 4, 2, FALSE, TRUE, TRUE, 300),
(35, 4, 1, TRUE, FALSE, FALSE, 300),
(36, 4, 1, TRUE, FALSE, FALSE, 300),
(37, 8, 1, TRUE, TRUE, TRUE, 400),
(37, 8, 2, FALSE, TRUE, TRUE, 400),
(38, 5, 1, TRUE, TRUE, TRUE, 525),
(38, 12, 2, FALSE, TRUE, TRUE, 2000),
(39, 5, 1, TRUE, TRUE, TRUE, 525),
(39, 4, 2, FALSE, TRUE, TRUE, 300),
(40, 7, 1, TRUE, TRUE, TRUE, 1700);

-- =============================================
-- BATTERIES (40 records)
-- =============================================
INSERT INTO batteries (manufacturer_id, model, capacity_mah, voltage, weight_g) VALUES
(1, 'LP-E6NH', 2130, 7.20, 80),
(1, 'LP-E6N', 1865, 7.20, 80),
(1, 'LP-E6', 1800, 7.20, 80),
(1, 'LP-E19', 2750, 10.80, 185),
(1, 'LP-E17', 1040, 7.20, 45),
(1, 'LP-E12', 875, 7.20, 34),
(2, 'EN-EL15c', 2280, 7.00, 80),
(2, 'EN-EL15b', 1900, 7.00, 80),
(2, 'EN-EL15a', 1900, 7.00, 80),
(2, 'EN-EL15', 1900, 7.00, 78),
(2, 'EN-EL18d', 3300, 10.80, 160),
(2, 'EN-EL25', 1120, 7.60, 44),
(3, 'NP-FZ100', 2280, 7.20, 83),
(3, 'NP-FW50', 1020, 7.20, 57),
(3, 'NP-FM500H', 1650, 7.20, 78),
(3, 'NP-BX1', 1240, 3.60, 19),
(4, 'NP-W235', 2200, 7.20, 100),
(4, 'NP-W126S', 1260, 7.20, 47),
(4, 'NP-T125', 1900, 10.80, 152),
(5, 'DMW-BLK22', 2200, 7.20, 87),
(5, 'DMW-BLJ31', 3100, 7.40, 120),
(5, 'DMW-BLF19', 1860, 7.20, 79),
(5, 'DMW-BLC12', 1200, 7.20, 55),
(6, 'BLH-1', 1720, 7.40, 67),
(6, 'BLS-50', 1210, 7.20, 51),
(6, 'BLX-1', 2280, 7.20, 72),
(7, 'BP-SCL4', 1860, 8.40, 87),
(7, 'BP-SCL6', 1800, 7.40, 78),
(7, 'BP-DC12', 1200, 7.20, 46),
(8, 'High Capacity Li-ion', 3400, 7.27, 100),
(8, 'Rechargeable Li-ion', 1850, 7.27, 70),
(9, 'D-LI90', 1860, 7.20, 95),
(9, 'D-LI109', 1050, 7.20, 39),
(10, 'BP-61', 3000, 7.40, 92),
(16, 'Phase One Battery', 3400, 14.40, 310),
(17, 'RED BRICK', 5200, 14.80, 365),
(17, 'RED Mini-Mag', 2200, 14.80, 175),
(18, 'LP-E6 Compatible', 2000, 7.40, 78),
(19, 'DJI TB51', 4280, 14.76, 389),
(19, 'DJI WB37', 4920, 7.60, 168);

-- =============================================
-- BODY BATTERIES (45 records)
-- =============================================
INSERT INTO body_batteries (body_id, battery_id, shots_per_charge, video_minutes, included_in_box, charging_time_hrs) VALUES
(1, 2, 900, 80, TRUE, 2.5),
(2, 2, 700, 60, TRUE, 2.5),
(3, 1, 490, 85, TRUE, 2.5),
(4, 1, 860, 150, TRUE, 2.5),
(5, 2, 1300, 100, TRUE, 2.5),
(6, 5, 410, 65, TRUE, 2.0),
(7, 10, 1840, 90, TRUE, 2.5),
(8, 7, 410, 100, TRUE, 2.0),
(9, 7, 770, 130, TRUE, 2.0),
(10, 7, 530, 120, TRUE, 2.0),
(11, 10, 950, 80, TRUE, 2.5),
(12, 13, 710, 125, TRUE, 2.5),
(13, 13, 670, 90, TRUE, 2.5),
(14, 13, 530, 145, TRUE, 2.5),
(15, 13, 530, 130, TRUE, 2.5),
(16, 14, 720, 80, TRUE, 2.0),
(17, 17, 600, 90, TRUE, 3.0),
(18, 17, 580, 80, TRUE, 3.0),
(19, 17, 740, 110, TRUE, 3.0),
(20, 19, 460, 75, TRUE, 4.0),
(21, 19, 455, 70, TRUE, 4.0),
(22, 22, 410, 120, TRUE, 2.5),
(23, 20, 360, 140, TRUE, 3.0),
(24, 22, 440, 115, TRUE, 2.5),
(25, 20, 520, 110, TRUE, 3.0),
(26, 24, 420, 87, TRUE, 2.5),
(27, 26, 520, 140, TRUE, 2.0),
(28, 27, 420, 85, TRUE, 2.5),
(29, 28, 700, 60, TRUE, 2.0),
(30, 29, 250, 55, TRUE, 2.0),
(31, 30, 420, 95, TRUE, 3.0),
(32, 31, 200, 60, TRUE, 3.0),
(33, 32, 670, 65, TRUE, 2.5),
(34, 33, 800, 70, TRUE, 2.0),
(35, 34, 290, 75, TRUE, 2.5),
(36, 34, 280, 70, TRUE, 2.5),
(37, 35, 350, 80, TRUE, 5.0),
(38, 36, 45, 120, TRUE, 6.0),
(38, 37, 70, 60, FALSE, 3.0),
(39, 38, 45, 90, TRUE, 2.5),
(40, 39, 120, 150, TRUE, 1.5),
(3, 4, 620, 110, FALSE, 3.5),
(4, 4, 1100, 200, FALSE, 3.5),
(9, 11, 1100, 180, FALSE, 3.0),
(10, 11, 900, 170, FALSE, 3.0);

-- =============================================
-- LENSES (40 records)
-- =============================================
INSERT INTO lenses (manufacturer_id, mount_id, name, lens_type, focal_length_min, focal_length_max, aperture_max, aperture_min, weight_g, filter_size_mm, release_date, price) VALUES
(1, 3, 'Canon RF 50mm f/1.2L USM', 'Prime', 50, 50, 1.2, 16.0, 950, 77, '2018-09-05', 2299.00),
(1, 3, 'Canon RF 85mm f/1.2L USM', 'Prime', 85, 85, 1.2, 16.0, 1195, 82, '2019-05-09', 2699.00),
(1, 3, 'Canon RF 24-70mm f/2.8L IS USM', 'Zoom', 24, 70, 2.8, 22.0, 900, 82, '2019-09-05', 2399.00),
(1, 3, 'Canon RF 70-200mm f/2.8L IS USM', 'Zoom', 70, 200, 2.8, 32.0, 1070, 77, '2019-11-07', 2699.00),
(1, 3, 'Canon RF 100mm f/2.8L Macro IS USM', 'Macro', 100, 100, 2.8, 32.0, 730, 67, '2021-04-14', 1399.00),
(2, 6, 'Nikon Z 50mm f/1.2 S', 'Prime', 50, 50, 1.2, 16.0, 1090, 82, '2020-09-01', 2096.00),
(2, 6, 'Nikon Z 85mm f/1.2 S', 'Prime', 85, 85, 1.2, 16.0, 1160, 82, '2023-01-10', 2796.00),
(2, 6, 'Nikon Z 24-70mm f/2.8 S', 'Zoom', 24, 70, 2.8, 22.0, 805, 82, '2019-02-14', 2296.00),
(2, 6, 'Nikon Z 70-200mm f/2.8 VR S', 'Zoom', 70, 200, 2.8, 22.0, 1360, 77, '2020-01-08', 2596.00),
(2, 6, 'Nikon Z MC 105mm f/2.8 VR S', 'Macro', 105, 105, 2.8, 32.0, 630, 62, '2021-06-02', 996.00),
(3, 8, 'Sony FE 50mm f/1.2 GM', 'Prime', 50, 50, 1.2, 16.0, 778, 72, '2021-03-23', 1998.00),
(3, 8, 'Sony FE 85mm f/1.4 GM', 'Prime', 85, 85, 1.4, 16.0, 820, 77, '2016-04-01', 1798.00),
(3, 8, 'Sony FE 24-70mm f/2.8 GM II', 'Zoom', 24, 70, 2.8, 22.0, 695, 82, '2022-04-27', 2298.00),
(3, 8, 'Sony FE 70-200mm f/2.8 GM OSS II', 'Zoom', 70, 200, 2.8, 22.0, 1045, 77, '2021-10-21', 2798.00),
(3, 8, 'Sony FE 90mm f/2.8 Macro G OSS', 'Macro', 90, 90, 2.8, 22.0, 602, 62, '2015-03-12', 1098.00),
(4, 9, 'Fujifilm XF 56mm f/1.2 R WR', 'Prime', 56, 56, 1.2, 16.0, 445, 67, '2022-09-29', 999.00),
(4, 9, 'Fujifilm XF 90mm f/2 R LM WR', 'Prime', 90, 90, 2.0, 16.0, 540, 62, '2015-07-16', 949.00),
(4, 9, 'Fujifilm XF 16-55mm f/2.8 R LM WR', 'Zoom', 16, 55, 2.8, 22.0, 655, 77, '2015-01-15', 1199.00),
(4, 9, 'Fujifilm XF 50-140mm f/2.8 R LM OIS WR', 'Zoom', 50, 140, 2.8, 22.0, 995, 72, '2014-11-01', 1599.00),
(4, 9, 'Fujifilm XF 80mm f/2.8 R LM OIS WR Macro', 'Macro', 80, 80, 2.8, 22.0, 750, 62, '2017-11-30', 1199.00),
(4, 10, 'Fujifilm GF 110mm f/2 R LM WR', 'Prime', 110, 110, 2.0, 22.0, 910, 77, '2019-05-24', 2499.00),
(4, 10, 'Fujifilm GF 32-64mm f/4 R LM WR', 'Zoom', 32, 64, 4.0, 32.0, 875, 77, '2017-02-23', 2299.00),
(10, 8, 'Sigma 35mm f/1.4 DG DN Art', 'Prime', 35, 35, 1.4, 16.0, 645, 67, '2020-12-01', 899.00),
(10, 8, 'Sigma 85mm f/1.4 DG DN Art', 'Prime', 85, 85, 1.4, 16.0, 630, 77, '2020-08-27', 1199.00),
(10, 8, 'Sigma 24-70mm f/2.8 DG DN Art', 'Zoom', 24, 70, 2.8, 22.0, 830, 82, '2019-12-05', 1099.00),
(10, 8, 'Sigma 100-400mm f/5-6.3 DG DN OS', 'Telephoto', 100, 400, 5.0, 22.0, 1135, 67, '2020-10-14', 949.00),
(10, 8, 'Sigma 105mm f/2.8 DG DN Macro Art', 'Macro', 105, 105, 2.8, 22.0, 715, 62, '2020-09-11', 799.00),
(11, 8, 'Tamron 35-150mm f/2-2.8 Di III VXD', 'Zoom', 35, 150, 2.0, 22.0, 1165, 82, '2021-10-28', 1899.00),
(11, 8, 'Tamron 28-75mm f/2.8 Di III VXD G2', 'Zoom', 28, 75, 2.8, 22.0, 540, 67, '2021-10-28', 879.00),
(11, 8, 'Tamron 70-180mm f/2.8 Di III VXD', 'Zoom', 70, 180, 2.8, 22.0, 815, 67, '2020-05-14', 1199.00),
(11, 8, 'Tamron 90mm f/2.8 Di III Macro VXD', 'Macro', 90, 90, 2.8, 32.0, 630, 62, '2023-04-20', 849.00),
(13, 8, 'Zeiss Batis 85mm f/1.8', 'Prime', 85, 85, 1.8, 22.0, 475, 67, '2015-04-13', 1199.00),
(13, 8, 'Zeiss Batis 40mm f/2 CF', 'Prime', 40, 40, 2.0, 22.0, 361, 67, '2018-04-10', 1299.00),
(14, 8, 'Samyang AF 35mm f/1.4 FE II', 'Prime', 35, 35, 1.4, 16.0, 645, 67, '2022-01-20', 599.00),
(14, 8, 'Samyang AF 85mm f/1.4 FE II', 'Prime', 85, 85, 1.4, 16.0, 568, 72, '2022-06-15', 699.00),
(14, 8, 'Samyang AF 24-70mm f/2.8 FE', 'Zoom', 24, 70, 2.8, 22.0, 1027, 82, '2023-08-01', 1099.00),
(32, 8, 'Laowa 100mm f/2.8 2x Ultra Macro APO', 'Macro', 100, 100, 2.8, 22.0, 638, 67, '2019-06-01', 449.00),
(32, 8, 'Laowa 15mm f/2 Zero-D', 'Prime', 15, 15, 2.0, 22.0, 500, 72, '2017-09-01', 849.00),
(15, 13, 'Voigtlander Nokton 50mm f/1.2 Aspherical', 'Prime', 50, 50, 1.2, 16.0, 347, 52, '2021-03-01', 1099.00),
(15, 8, 'Voigtlander APO-Lanthar 50mm f/2', 'Prime', 50, 50, 2.0, 22.0, 354, 49, '2019-01-24', 999.00);

-- =============================================
-- LENS OPTICAL SPECS (40 records)
-- =============================================
INSERT INTO lens_optical_specs (lens_id, min_focus_distance_m, max_magnification, optical_elements, optical_groups, diaphragm_blades, has_stabilization, weather_sealed) VALUES
(1, 0.40, 0.19, 15, 9, 10, FALSE, TRUE),
(2, 0.85, 0.12, 13, 9, 9, FALSE, TRUE),
(3, 0.21, 0.30, 21, 15, 9, TRUE, TRUE),
(4, 0.70, 0.23, 17, 13, 9, TRUE, TRUE),
(5, 0.26, 1.40, 17, 13, 9, TRUE, TRUE),
(6, 0.45, 0.15, 17, 15, 9, FALSE, TRUE),
(7, 0.85, 0.11, 15, 10, 9, FALSE, TRUE),
(8, 0.38, 0.22, 17, 15, 9, FALSE, TRUE),
(9, 0.50, 0.21, 21, 18, 9, TRUE, TRUE),
(10, 0.29, 1.00, 16, 11, 9, TRUE, TRUE),
(11, 0.40, 0.17, 14, 10, 11, FALSE, TRUE),
(12, 0.80, 0.12, 11, 8, 11, FALSE, TRUE),
(13, 0.21, 0.32, 15, 13, 11, FALSE, TRUE),
(14, 0.40, 0.21, 17, 14, 11, TRUE, TRUE),
(15, 0.28, 1.00, 15, 11, 9, TRUE, TRUE),
(16, 0.50, 0.09, 13, 8, 9, FALSE, TRUE),
(17, 0.60, 0.11, 11, 8, 7, FALSE, TRUE),
(18, 0.30, 0.16, 17, 12, 9, FALSE, TRUE),
(19, 1.00, 0.12, 23, 16, 7, TRUE, TRUE),
(20, 0.25, 1.00, 16, 12, 9, TRUE, TRUE),
(21, 0.90, 0.16, 14, 9, 9, FALSE, TRUE),
(22, 0.35, 0.19, 14, 11, 9, FALSE, TRUE),
(23, 0.30, 0.19, 14, 11, 11, FALSE, TRUE),
(24, 0.85, 0.12, 15, 11, 11, FALSE, TRUE),
(25, 0.18, 0.34, 15, 11, 11, FALSE, TRUE),
(26, 1.12, 0.24, 22, 16, 9, TRUE, TRUE),
(27, 0.30, 1.00, 17, 11, 9, FALSE, TRUE),
(28, 0.33, 0.17, 21, 15, 9, FALSE, TRUE),
(29, 0.18, 0.26, 17, 12, 9, FALSE, TRUE),
(30, 0.85, 0.21, 17, 12, 9, TRUE, TRUE),
(31, 0.25, 1.00, 15, 11, 9, TRUE, TRUE),
(32, 0.80, 0.13, 11, 8, 9, TRUE, TRUE),
(33, 0.35, 0.19, 9, 6, 9, FALSE, TRUE),
(34, 0.29, 0.18, 12, 8, 9, FALSE, TRUE),
(35, 0.90, 0.11, 11, 8, 11, FALSE, TRUE),
(36, 0.18, 0.30, 16, 11, 7, FALSE, TRUE),
(37, 0.25, 2.00, 12, 10, 7, FALSE, FALSE),
(38, 0.15, 0.25, 12, 9, 5, FALSE, FALSE),
(39, 0.45, 0.15, 12, 10, 12, FALSE, FALSE),
(40, 0.45, 0.15, 10, 8, 10, FALSE, TRUE);

-- =============================================
-- MOUNT ADAPTERS (40 records)
-- =============================================
INSERT INTO mount_adapters (manufacturer_id, source_mount_id, target_mount_id, name, has_autofocus, has_stabilization, price) VALUES
(1, 1, 3, 'Canon EF-EOS R Adapter', TRUE, FALSE, 99.00),
(1, 1, 3, 'Canon EF-EOS R Control Ring Adapter', TRUE, FALSE, 199.00),
(1, 1, 3, 'Canon EF-EOS R Drop-In Filter Adapter', TRUE, FALSE, 399.00),
(40, 1, 8, 'Metabones EF to E-Mount T Smart V', TRUE, FALSE, 399.00),
(40, 1, 8, 'Metabones EF to E-Mount T Speed Booster', TRUE, FALSE, 649.00),
(40, 5, 8, 'Metabones Nikon F to E-Mount T', FALSE, FALSE, 249.00),
(10, 1, 8, 'Sigma MC-11 EF to E-Mount', TRUE, FALSE, 249.00),
(10, 22, 8, 'Sigma MC-21 SA to E-Mount', TRUE, FALSE, 299.00),
(10, 1, 36, 'Sigma MC-21 EF to L-Mount', TRUE, FALSE, 299.00),
(3, 7, 8, 'Sony LA-EA5 A to E-Mount', TRUE, FALSE, 248.00),
(3, 7, 8, 'Sony LA-EA3 A to E-Mount', TRUE, FALSE, 198.00),
(4, 13, 9, 'Fujifilm M Mount Adapter', FALSE, FALSE, 189.00),
(5, 13, 11, 'Panasonic DMW-MA2M M to MFT', FALSE, FALSE, 199.00),
(5, 7, 36, 'Panasonic DMW-SLA1 A to L-Mount', FALSE, FALSE, 249.00),
(7, 13, 8, 'Leica M to L-Mount Adapter', FALSE, FALSE, 395.00),
(7, 15, 14, 'Leica S to SL Adapter', TRUE, FALSE, 595.00),
(39, 1, 8, 'Fotodiox Pro EF to E-Mount', TRUE, FALSE, 149.00),
(39, 5, 8, 'Fotodiox Pro Nikon F to E-Mount', FALSE, FALSE, 79.00),
(39, 20, 8, 'Fotodiox Pro Pentax K to E-Mount', FALSE, FALSE, 89.00),
(39, 1, 9, 'Fotodiox Pro EF to Fuji X', TRUE, FALSE, 139.00),
(27, 1, 8, 'Viltrox EF-E5 EF to E-Mount', TRUE, FALSE, 148.00),
(27, 1, 9, 'Viltrox EF-FX2 EF to Fuji X', TRUE, FALSE, 159.00),
(27, 1, 11, 'Viltrox EF-M2 II EF to MFT', TRUE, FALSE, 169.00),
(27, 5, 6, 'Viltrox NF-Z Nikon F to Z-Mount', TRUE, FALSE, 199.00),
(27, 1, 6, 'Viltrox EF-Z Nikon F to Z-Mount', TRUE, FALSE, 189.00),
(2, 5, 6, 'Nikon FTZ II Adapter', TRUE, FALSE, 246.00),
(2, 5, 6, 'Nikon FTZ Adapter', TRUE, FALSE, 246.00),
(40, 1, 11, 'Metabones EF to MFT T Speed Booster', TRUE, FALSE, 649.00),
(40, 1, 9, 'Metabones EF to Fuji X Speed Booster', TRUE, FALSE, 649.00),
(40, 13, 8, 'Metabones Leica M to E-Mount', FALSE, FALSE, 249.00),
(26, 13, 8, 'Voigtlander VM-E Close Focus Adapter', FALSE, FALSE, 299.00),
(26, 13, 6, 'Voigtlander VM-Z Close Focus Adapter', FALSE, FALSE, 349.00),
(39, 13, 8, 'Fotodiox Pro Leica M to E-Mount', FALSE, FALSE, 99.00),
(39, 13, 9, 'Fotodiox Pro Leica M to Fuji X', FALSE, FALSE, 99.00),
(39, 29, 8, 'Fotodiox Pro Contax/Yashica to E-Mount', FALSE, FALSE, 49.00),
(8, 18, 17, 'Hasselblad H to X Adapter', TRUE, FALSE, 549.00),
(8, 19, 17, 'Hasselblad V to X Adapter', FALSE, FALSE, 449.00),
(27, 1, 3, 'Viltrox EF-R3 EF to RF', TRUE, FALSE, 189.00),
(27, 5, 8, 'Viltrox NF-E1 Nikon F to E-Mount', TRUE, FALSE, 178.00),
(40, 20, 8, 'Metabones Pentax K to E-Mount', FALSE, FALSE, 199.00);

-- =============================================
-- ADDITIONAL RECORDS (20+ per table)
-- More brands, budget options, and cinema/video
-- =============================================

-- MANUFACTURERS (20 more - cinema, budget, legacy brands)
INSERT INTO manufacturers (name, country, founded_year, headquarters, website, specialization) VALUES
('ARRI', 'Germany', 1917, 'Munich, Germany', 'https://www.arri.com', 'Cinema'),
('Kinefinity', 'China', 2011, 'Shenzhen, China', 'https://www.kinefinity.com', 'Cinema'),
('Z CAM', 'China', 2013, 'Shenzhen, China', 'https://www.z-cam.com', 'Cinema'),
('Insta360', 'China', 2014, 'Shenzhen, China', 'https://www.insta360.com', 'Cameras'),
('Kandao', 'China', 2016, 'Shenzhen, China', 'https://www.kandaovr.com', 'Cameras'),
('Minolta', 'Japan', 1928, 'Osaka, Japan', 'https://www.konicaminolta.com', 'Both'),
('Konica', 'Japan', 1873, 'Tokyo, Japan', 'https://www.konicaminolta.com', 'Both'),
('Zenit', 'Russia', 1942, 'Krasnogorsk, Russia', 'https://www.zfresco.com', 'Both'),
('Kiev', 'Ukraine', 1946, 'Kyiv, Ukraine', 'https://www.arsenal-photo.com', 'Both'),
('Chinon', 'Japan', 1948, 'Nagano, Japan', 'https://www.chinon.co.jp', 'Both'),
('Yashica', 'Japan', 1949, 'Tokyo, Japan', 'https://www.yashica.com', 'Both'),
('Miranda', 'Japan', 1955, 'Tokyo, Japan', 'https://www.miranda.com', 'Cameras'),
('Praktica', 'Germany', 1919, 'Dresden, Germany', 'https://www.praktica.de', 'Both'),
('Cooke', 'United Kingdom', 1893, 'Leicester, UK', 'https://www.cookeoptics.com', 'Cinema'),
('Angenieux', 'France', 1935, 'Saint-Heand, France', 'https://www.angenieux.com', 'Cinema'),
('Panavision', 'United States', 1954, 'Los Angeles, California', 'https://www.panavision.com', 'Cinema'),
('Schneider', 'Germany', 1913, 'Bad Kreuznach, Germany', 'https://www.schneiderkreuznach.com', 'Lenses'),
('Rokinon', 'South Korea', 1972, 'Changwon, South Korea', 'https://www.rokinon.com', 'Lenses'),
('Pergear', 'China', 2018, 'Shenzhen, China', 'https://www.pergear.com', 'Lenses'),
('AstrHori', 'China', 2020, 'Shenzhen, China', 'https://www.astrhori.com', 'Lenses');

-- SENSORS (20 more - cinema and budget)
INSERT INTO sensors (name, type, format_size, megapixels, iso_min, iso_max) VALUES
('ARRI ALEV III', 'CMOS', 'Full Frame', 6.5, 160, 3200),
('ARRI ALEV 4', 'CMOS', 'Full Frame', 4.5, 160, 6400),
('ARRI ALEXA 35', 'CMOS', 'Full Frame', 4.6, 160, 6400),
('RED Komodo 6K', 'CMOS', 'Full Frame', 19.9, 250, 40000),
('RED Gemini 5K', 'CMOS', 'Full Frame', 15.4, 800, 51200),
('Kinefinity CMOS FF', 'CMOS', 'Full Frame', 24.0, 200, 25600),
('Z CAM S35', 'CMOS', 'APS-C', 19.0, 200, 12800),
('Z CAM VV', 'CMOS', 'Full Frame', 35.0, 200, 12800),
('Blackmagic S35', 'CMOS', 'APS-C', 25.0, 200, 25600),
('Blackmagic FF', 'CMOS', 'Full Frame', 12.0, 200, 25600),
('Insta360 1-inch 360', 'CMOS', '1-inch', 48.0, 100, 6400),
('Canon APS-C Budget', 'CMOS', 'APS-C', 24.1, 100, 12800),
('Nikon DX Entry', 'CMOS', 'APS-C', 24.2, 100, 25600),
('Sony APS-C Entry', 'CMOS', 'APS-C', 24.2, 100, 51200),
('Panasonic MFT Entry', 'CMOS', 'Micro Four Thirds', 16.0, 200, 25600),
('Samsung NX', 'CMOS', 'APS-C', 28.2, 100, 25600),
('Minolta CCD', 'CCD', 'APS-C', 6.1, 100, 3200),
('Foveon X3 Quattro', 'CMOS', 'APS-C', 39.0, 100, 6400),
('Medium Format Leaf', 'CCD', 'Medium Format', 80.0, 50, 800),
('Canon Cinema S35', 'CMOS', 'APS-C', 8.9, 100, 102400);

-- MOUNTS (20 more - cinema and legacy)
INSERT INTO mounts (manufacturer_id, name, flange_distance_mm, throat_diameter_mm, is_electronic) VALUES
(41, 'ARRI PL', 52.00, 54.00, FALSE),
(41, 'ARRI LPL', 44.00, 62.00, TRUE),
(56, 'Panavision PV', 57.15, 57.00, FALSE),
(54, 'Cooke i/Technology', 52.00, 54.00, TRUE),
(42, 'Kinefinity KM', 18.00, 50.00, TRUE),
(43, 'Z CAM M', 18.00, 46.00, TRUE),
(46, 'Minolta A', 44.50, 50.00, TRUE),
(47, 'Konica AR', 40.50, 47.00, FALSE),
(48, 'Zenit M42', 45.46, 42.00, FALSE),
(49, 'Kiev 88', 74.10, 66.00, FALSE),
(50, 'Chinon K', 45.46, 44.00, FALSE),
(51, 'Yashica/Contax', 45.50, 48.00, FALSE),
(52, 'Miranda', 41.50, 44.00, FALSE),
(53, 'Praktica B', 44.40, 49.00, TRUE),
(17, 'RED RF', 20.00, 54.00, TRUE),
(18, 'BMPCC MFT', 19.25, 38.00, TRUE),
(18, 'BMPCC EF', 44.00, 54.00, TRUE),
(41, 'ARRI Amira PL', 52.00, 54.00, FALSE),
(55, 'Angenieux PL', 52.00, 54.00, FALSE),
(57, 'Schneider B4', 48.00, 38.00, TRUE);

-- IMAGE PROCESSORS (20 more)
INSERT INTO image_processors (manufacturer_id, name, generation, release_year, max_burst_fps, max_video_resolution, bit_depth, ai_features) VALUES
(41, 'ARRI Image Processing', 1, 2019, 3, '4.5K60', 16, NULL),
(41, 'ARRI Codex', 2, 2022, 4, '4.6K120', 16, NULL),
(42, 'Kinefinity KineMAX', 1, 2017, 5, '8K24', 14, NULL),
(42, 'Kinefinity MAVO', 2, 2021, 8, '6K60', 14, NULL),
(43, 'Z CAM Zynaptiq', 1, 2020, 8, '8K30', 12, NULL),
(43, 'Z CAM ZenQ', 2, 2023, 12, '8K60', 14, NULL),
(44, 'Insta360 FlowState', 1, 2019, 30, '5.7K30', 10, 'AI Stabilization'),
(44, 'Insta360 FlowState 2', 2, 2022, 30, '8K30', 12, 'AI Reframe, Subject Track'),
(45, 'Kandao Obsidian', 1, 2018, 30, '8K30', 10, '360 Stitching'),
(46, 'Minolta AP', 1, 2006, 3, '720p30', 12, NULL),
(1, 'DIGIC 7', 7, 2016, 14, '4K30', 14, 'Face Detection'),
(2, 'EXPEED 3', 3, 2012, 6, '1080p60', 14, NULL),
(3, 'BIONZ VE', 1, 2008, 5, '1080p30', 12, NULL),
(17, 'RED DSMC2 Dragon', 1, 2016, 24, '6K60', 16, NULL),
(17, 'RED Komodo', 2, 2020, 40, '6K40', 16, 'Eye Tracking'),
(18, 'Blackmagic Gen 4', 4, 2019, 18, '6K30', 12, NULL),
(56, 'Panavision DXL', 1, 2017, 6, '8K24', 16, NULL),
(54, 'Cooke /i', 1, 2015, 1, '4K24', 14, 'Lens Metadata'),
(55, 'Angenieux EZ', 1, 2018, 1, '4K60', 14, NULL),
(57, 'Schneider DV', 1, 2016, 1, '4K30', 14, NULL);

-- CAMERA BODIES (20 more - budget and cinema)
INSERT INTO camera_bodies (manufacturer_id, sensor_id, mount_id, processor_id, name, body_type, release_date, price, weight_g, body_material) VALUES
(41, 41, 41, 41, 'ARRI ALEXA Mini LF', 'Cinema', '2019-04-04', 54500.00, 2600, 'Aluminum'),
(41, 43, 41, 42, 'ARRI ALEXA 35', 'Cinema', '2022-06-01', 77000.00, 2800, 'Aluminum'),
(42, 46, 45, 43, 'Kinefinity MAVO Edge 8K', 'Cinema', '2021-09-15', 11999.00, 1550, 'Aluminum'),
(43, 47, 46, 45, 'Z CAM E2-S6', 'Cinema', '2019-06-01', 1999.00, 750, 'Aluminum'),
(43, 48, 46, 46, 'Z CAM E2-F6', 'Cinema', '2020-01-15', 2995.00, 780, 'Aluminum'),
(17, 44, 41, 55, 'RED Komodo 6K', 'Cinema', '2020-07-01', 5995.00, 998, 'Aluminum'),
(17, 45, 25, 54, 'RED Gemini 5K S35', 'Cinema', '2018-10-01', 19500.00, 1420, 'Aluminum'),
(18, 49, 57, 56, 'Blackmagic URSA Mini Pro 12K', 'Cinema', '2020-07-17', 5995.00, 2050, 'Carbon Fiber'),
(18, 50, 56, 56, 'Blackmagic Pocket Cinema 4K', 'Cinema', '2018-09-10', 1295.00, 722, 'Polycarbonate'),
(44, 51, 46, 47, 'Insta360 ONE RS 1-Inch 360', 'Compact', '2022-06-28', 799.00, 239, 'Plastic'),
(1, 52, 4, 51, 'Canon EOS M50 Mark II', 'Mirrorless', '2020-10-14', 599.00, 387, 'Polycarbonate'),
(1, 52, 2, 51, 'Canon EOS Rebel T8i', 'DSLR', '2020-02-13', 749.00, 515, 'Polycarbonate'),
(2, 53, 6, 52, 'Nikon Z30', 'Mirrorless', '2022-06-29', 709.00, 405, 'Polycarbonate'),
(2, 53, 5, 52, 'Nikon D3500', 'DSLR', '2018-08-30', 449.00, 415, 'Polycarbonate'),
(3, 54, 8, 53, 'Sony A6100', 'Mirrorless', '2019-08-28', 748.00, 396, 'Polycarbonate'),
(3, 54, 8, 53, 'Sony A6400', 'Mirrorless', '2019-01-15', 898.00, 403, 'Magnesium Alloy'),
(5, 55, 11, 16, 'Panasonic G100', 'Mirrorless', '2020-06-24', 599.00, 345, 'Polycarbonate'),
(4, 15, 9, 13, 'Fujifilm X-T30 II', 'Mirrorless', '2021-09-02', 899.00, 378, 'Magnesium Alloy'),
(6, 23, 12, 19, 'Olympus OM-D E-M10 Mark IV', 'Mirrorless', '2020-08-04', 699.00, 383, 'Polycarbonate'),
(1, 60, 1, 5, 'Canon EOS C70', 'Cinema', '2020-09-24', 5499.00, 1190, 'Aluminum');

-- BODY FEATURES (20 more)
INSERT INTO body_features (body_id, weather_sealed, operating_temp_min, operating_temp_max, shutter_durability, has_gps, has_bluetooth, has_wifi) VALUES
(41, TRUE, -20, 45, 1000000, FALSE, FALSE, TRUE),
(42, TRUE, -20, 45, 1000000, FALSE, FALSE, TRUE),
(43, TRUE, -10, 45, 500000, FALSE, TRUE, TRUE),
(44, TRUE, -10, 45, 500000, FALSE, TRUE, TRUE),
(45, TRUE, -10, 45, 500000, FALSE, TRUE, TRUE),
(46, TRUE, -10, 45, 500000, FALSE, TRUE, TRUE),
(47, TRUE, -10, 45, 500000, FALSE, FALSE, TRUE),
(48, TRUE, -10, 45, 300000, FALSE, TRUE, TRUE),
(49, FALSE, 0, 40, 200000, FALSE, TRUE, TRUE),
(50, FALSE, 0, 40, 100000, FALSE, TRUE, TRUE),
(51, FALSE, 0, 40, 100000, FALSE, TRUE, TRUE),
(52, FALSE, 0, 40, 100000, FALSE, TRUE, TRUE),
(53, FALSE, 0, 40, 100000, FALSE, TRUE, TRUE),
(54, FALSE, 0, 40, 100000, FALSE, TRUE, TRUE),
(55, FALSE, 0, 40, 200000, FALSE, TRUE, TRUE),
(56, TRUE, 0, 40, 200000, FALSE, TRUE, TRUE),
(57, FALSE, 0, 40, 100000, FALSE, TRUE, TRUE),
(58, TRUE, -10, 40, 150000, FALSE, TRUE, TRUE),
(59, FALSE, 0, 40, 100000, FALSE, TRUE, TRUE),
(60, TRUE, 0, 40, 500000, FALSE, TRUE, TRUE);

-- BODY SPECS (20 more)
INSERT INTO body_specs (body_id, shutter_speed_min, shutter_speed_max, burst_fps, video_resolution, has_ibis, ibis_stops, evf_resolution, lcd_size, lcd_articulating) VALUES
(41, '1s', '1/8000s', 40.0, '4.5K60', FALSE, NULL, NULL, 4.3, TRUE),
(42, '1s', '1/8000s', 30.0, '4.6K120', FALSE, NULL, NULL, 4.3, TRUE),
(43, '1s', '1/8000s', 75.0, '8K24', FALSE, NULL, NULL, 5.0, TRUE),
(44, '1s', '1/8000s', 120.0, '6K60', FALSE, NULL, NULL, 2.9, TRUE),
(45, '1s', '1/8000s', 120.0, '6K60', FALSE, NULL, NULL, 2.9, TRUE),
(46, '1s', '1/8000s', 40.0, '6K40', FALSE, NULL, NULL, 2.9, TRUE),
(47, '1s', '1/8000s', 30.0, '6K60', FALSE, NULL, NULL, 4.7, TRUE),
(48, '1s', '1/8000s', 80.0, '12K60', FALSE, NULL, NULL, 5.0, TRUE),
(49, '60s', '1/4000s', 23.0, '4K60', FALSE, NULL, NULL, 5.0, TRUE),
(50, '30s', '1/8000s', 30.0, '5.7K30', FALSE, NULL, NULL, 2.0, FALSE),
(51, '30s', '1/4000s', 10.0, '4K30', FALSE, NULL, 2360000, 3.0, TRUE),
(52, '30s', '1/4000s', 7.0, '4K30', FALSE, NULL, NULL, 3.0, TRUE),
(53, '30s', '1/4000s', 11.0, '4K30', FALSE, NULL, 2360000, 3.0, TRUE),
(54, '30s', '1/4000s', 5.0, '1080p60', FALSE, NULL, NULL, 3.0, FALSE),
(55, '30s', '1/4000s', 11.0, '4K30', FALSE, NULL, 1440000, 3.0, TRUE),
(56, '30s', '1/4000s', 11.0, '4K30', FALSE, NULL, 2360000, 3.0, TRUE),
(57, '60s', '1/4000s', 10.0, '4K30', TRUE, 5.0, 3686400, 3.0, TRUE),
(58, '30s', '1/4000s', 8.0, '4K30', FALSE, NULL, 2360000, 3.0, TRUE),
(59, '60s', '1/4000s', 15.0, '4K30', TRUE, 4.5, 2360000, 3.0, TRUE),
(60, '1s', '1/2000s', 60.0, '4K120', FALSE, NULL, NULL, 4.0, TRUE);

-- AUTOFOCUS SYSTEMS (20 more)
INSERT INTO autofocus_systems (name, type, focus_points, cross_type_points, eye_tracking, tracking_types, low_light_ev, af_speed_rating) VALUES
('ARRI Manual Focus', 'Contrast Detection', 1, 0, FALSE, 'None', 0.0, 'Manual'),
('RED Phase Detect', 'Phase Detection', 300, 300, TRUE, 'Eye, Face', -4.0, '0.08s'),
('Kinefinity Contrast AF', 'Contrast Detection', 225, 0, TRUE, 'Face', -3.0, '0.15s'),
('Z CAM Phase Hybrid', 'Hybrid', 273, 273, TRUE, 'Eye, Face', -4.0, '0.08s'),
('Blackmagic DaVinci AF', 'Contrast Detection', 225, 0, TRUE, 'Face', -3.0, '0.12s'),
('Insta360 AI AF', 'Contrast Detection', 100, 0, FALSE, 'Face', -2.0, '0.20s'),
('Canon Dual Pixel Entry', 'Dual Pixel', 143, 143, TRUE, 'Eye, Face', -4.0, '0.10s'),
('Nikon Hybrid Entry', 'Hybrid', 209, 209, TRUE, 'Eye, Face', -4.0, '0.10s'),
('Sony Fast Hybrid Entry', 'Hybrid', 425, 425, TRUE, 'Eye, Face', -3.0, '0.06s'),
('Panasonic DFD Entry', 'Contrast Detection', 49, 0, FALSE, 'Face', -4.0, '0.10s'),
('Olympus Contrast Entry', 'Contrast Detection', 121, 0, TRUE, 'Eye, Face', -4.0, '0.08s'),
('Fujifilm Hybrid Entry', 'Hybrid', 117, 117, TRUE, 'Eye, Face', -3.0, '0.08s'),
('Canon C-AF', 'Dual Pixel', 384, 384, TRUE, 'Eye, Face, Animal', -5.5, '0.04s'),
('Cinema Manual Only', 'Contrast Detection', 1, 0, FALSE, 'None', 0.0, 'Manual'),
('Budget Contrast AF', 'Contrast Detection', 9, 0, FALSE, 'Face', -1.0, '0.25s'),
('Entry Phase AF', 'Phase Detection', 11, 11, FALSE, 'Face', -1.0, '0.15s'),
('Mirrorless Entry AF', 'Hybrid', 99, 99, TRUE, 'Eye, Face', -2.0, '0.12s'),
('Video Continuous AF', 'Contrast Detection', 49, 0, TRUE, 'Face', -3.0, '0.10s'),
('Touch Focus AF', 'Contrast Detection', 225, 0, FALSE, 'Face', -2.0, '0.15s'),
('ARRI Multicam AF', 'Contrast Detection', 100, 0, FALSE, 'None', -2.0, '0.20s');

-- BODY AUTOFOCUS (20 more)
INSERT INTO body_autofocus (body_id, af_id, firmware_version_added, is_primary, notes) VALUES
(41, 41, '1.0.0', TRUE, 'Manual focus assist'),
(42, 60, '1.0.0', TRUE, 'LiDAR compatible'),
(43, 43, '1.0.0', TRUE, 'Contrast based'),
(44, 44, '1.0.0', TRUE, 'Phase hybrid'),
(45, 44, '1.0.0', TRUE, 'Phase hybrid'),
(46, 42, '1.0.0', TRUE, 'RED Phase AF'),
(47, 42, '1.0.0', TRUE, 'RED Phase AF'),
(48, 45, '1.0.0', TRUE, 'DaVinci AF'),
(49, 45, '1.0.0', TRUE, 'DaVinci AF'),
(50, 46, '1.0.0', TRUE, 'AI-based tracking'),
(51, 47, '1.0.0', TRUE, 'Entry-level Dual Pixel'),
(52, 47, '1.0.0', TRUE, 'Entry-level Dual Pixel'),
(53, 48, '1.0.0', TRUE, 'Hybrid entry'),
(54, 56, '1.0.0', TRUE, 'Basic phase AF'),
(55, 49, '1.0.0', TRUE, 'Fast Hybrid entry'),
(56, 49, '1.0.0', TRUE, 'Fast Hybrid entry'),
(57, 50, '1.0.0', TRUE, 'DFD entry'),
(58, 52, '1.0.0', TRUE, 'Fuji hybrid entry'),
(59, 51, '1.0.0', TRUE, 'Olympus contrast'),
(60, 53, '1.0.0', TRUE, 'Cinema Dual Pixel');

-- VIEWFINDERS (20 more)
INSERT INTO viewfinders (body_id, type, resolution, magnification, refresh_rate_hz, coverage_percent) VALUES
(41, 'EVF', 1920000, 0.00, 60, 100.00),
(42, 'EVF', 2560000, 0.00, 60, 100.00),
(43, 'EVF', 1920000, 0.00, 60, 100.00),
(44, 'EVF', 1280000, 0.00, 60, 100.00),
(45, 'EVF', 1280000, 0.00, 60, 100.00),
(46, 'None', NULL, 0.00, NULL, 0.00),
(47, 'EVF', 1920000, 0.00, 60, 100.00),
(48, 'None', NULL, 0.00, NULL, 0.00),
(49, 'None', NULL, 0.00, NULL, 0.00),
(50, 'None', NULL, 0.00, NULL, 0.00),
(51, 'EVF', 2360000, 0.69, 120, 100.00),
(52, 'OVF', NULL, 0.82, NULL, 95.00),
(53, 'EVF', 2360000, 0.68, 60, 100.00),
(54, 'OVF', NULL, 0.85, NULL, 95.00),
(55, 'EVF', 1440000, 0.70, 60, 100.00),
(56, 'EVF', 2360000, 0.70, 120, 100.00),
(57, 'EVF', 3686400, 0.73, 120, 100.00),
(58, 'EVF', 2360000, 0.62, 60, 100.00),
(59, 'EVF', 2360000, 0.62, 120, 100.00),
(60, 'EVF', 1770000, 0.00, 60, 100.00);

-- STORAGE TYPES (5 more - cinema formats)
INSERT INTO storage_types (name, form_factor, bus_interface, max_capacity_gb, max_speed_mbps, uhs_class, video_speed_class) VALUES
('ARRI Codex Compact Drive', 'Codex', 'USB-C', 2048, 5000, NULL, NULL),
('RED Mini-Mag', 'RED Proprietary', 'PCIe', 960, 3000, NULL, NULL),
('Sony AXS', 'AXS', 'PCIe', 1024, 4800, NULL, NULL),
('Blackmagic Cfast', 'CFast', 'SATA III', 512, 535, NULL, NULL),
('Cinema SSD', 'SSD', 'USB 3.2', 4096, 2000, NULL, NULL);

-- BODY STORAGE SLOTS (25 more)
INSERT INTO body_storage_slots (body_id, storage_type_id, slot_number, is_primary, supports_relay, supports_backup, max_write_speed_mbps) VALUES
(41, 13, 1, TRUE, TRUE, TRUE, 5000),
(42, 13, 1, TRUE, TRUE, TRUE, 5000),
(43, 17, 1, TRUE, TRUE, TRUE, 2000),
(44, 7, 1, TRUE, FALSE, FALSE, 800),
(45, 7, 1, TRUE, FALSE, FALSE, 800),
(46, 14, 1, TRUE, TRUE, TRUE, 3000),
(47, 14, 1, TRUE, TRUE, TRUE, 3000),
(48, 7, 1, TRUE, TRUE, TRUE, 1700),
(49, 5, 1, TRUE, FALSE, FALSE, 525),
(49, 4, 2, FALSE, TRUE, TRUE, 300),
(50, 10, 1, TRUE, FALSE, FALSE, 100),
(51, 4, 1, TRUE, FALSE, FALSE, 250),
(52, 4, 1, TRUE, FALSE, FALSE, 250),
(53, 4, 1, TRUE, FALSE, FALSE, 250),
(54, 4, 1, TRUE, FALSE, FALSE, 250),
(55, 4, 1, TRUE, FALSE, FALSE, 250),
(56, 4, 1, TRUE, FALSE, FALSE, 250),
(57, 4, 1, TRUE, FALSE, FALSE, 250),
(58, 4, 1, TRUE, FALSE, FALSE, 250),
(59, 4, 1, TRUE, FALSE, FALSE, 250),
(60, 4, 1, TRUE, TRUE, TRUE, 300),
(60, 4, 2, FALSE, TRUE, TRUE, 300),
(48, 17, 2, FALSE, TRUE, TRUE, 2000),
(43, 4, 2, FALSE, TRUE, TRUE, 300),
(44, 4, 2, FALSE, TRUE, TRUE, 300);

-- BATTERIES (20 more)
INSERT INTO batteries (manufacturer_id, model, capacity_mah, voltage, weight_g) VALUES
(41, 'ARRI B-Mount', 6900, 24.00, 430),
(41, 'ARRI Gold Mount', 9800, 14.40, 680),
(17, 'RED Brick', 5200, 14.80, 365),
(17, 'RED V-Lock', 9900, 14.40, 640),
(42, 'Kinefinity KineBattery', 4400, 14.80, 280),
(43, 'Z CAM LP-E6', 2000, 7.40, 78),
(18, 'Blackmagic LP-E6', 2200, 7.40, 82),
(44, 'Insta360 1445mAh', 1445, 7.40, 65),
(1, 'LP-E10', 860, 7.40, 37),
(2, 'EN-EL14a', 1230, 7.40, 49),
(3, 'NP-FW50', 1020, 7.20, 57),
(5, 'DMW-BLG10', 1025, 7.20, 46),
(6, 'BLS-50', 1210, 7.20, 51),
(4, 'NP-W126S', 1260, 7.20, 47),
(56, 'Panavision ProPak', 14000, 14.40, 890),
(46, 'Minolta NP-400', 1500, 7.40, 75),
(47, 'Konica DR-LB4', 1300, 3.70, 32),
(54, 'V-Lock Generic', 6600, 14.40, 450),
(27, 'Viltrox LP-E6', 2000, 7.40, 76),
(29, 'Meike LP-E6', 1800, 7.40, 74);

-- BODY BATTERIES (20 more)
INSERT INTO body_batteries (body_id, battery_id, shots_per_charge, video_minutes, included_in_box, charging_time_hrs) VALUES
(41, 41, 200, 180, TRUE, 3.0),
(42, 42, 180, 150, TRUE, 4.0),
(43, 45, 250, 120, TRUE, 2.5),
(44, 46, 300, 90, TRUE, 2.0),
(45, 46, 300, 90, TRUE, 2.0),
(46, 43, 150, 100, TRUE, 3.5),
(47, 44, 150, 90, TRUE, 4.0),
(48, 47, 200, 120, TRUE, 2.5),
(49, 47, 180, 60, TRUE, 2.0),
(50, 48, 70, 70, TRUE, 1.5),
(51, 49, 250, 70, TRUE, 2.0),
(52, 49, 800, 60, TRUE, 2.0),
(53, 50, 320, 75, TRUE, 2.0),
(54, 50, 1500, 50, TRUE, 2.0),
(55, 51, 360, 60, TRUE, 2.0),
(56, 51, 400, 70, TRUE, 2.0),
(57, 52, 290, 60, TRUE, 2.0),
(58, 54, 380, 70, TRUE, 2.0),
(59, 53, 360, 60, TRUE, 2.0),
(60, 2, 120, 240, TRUE, 2.5);

-- LENSES (20 more - budget and cinema)
INSERT INTO lenses (manufacturer_id, mount_id, name, lens_type, focal_length_min, focal_length_max, aperture_max, aperture_min, weight_g, filter_size_mm, release_date, price) VALUES
(54, 41, 'Cooke S7/i 50mm T2.0', 'Prime', 50, 50, 2.0, 22.0, 2450, 110, '2020-04-01', 24500.00),
(54, 41, 'Cooke Anamorphic/i 75mm T2.3', 'Prime', 75, 75, 2.3, 22.0, 3200, 110, '2018-03-01', 45000.00),
(55, 41, 'Angenieux EZ-1 30-90mm T2', 'Zoom', 30, 90, 2.0, 22.0, 2400, 114, '2016-09-01', 26990.00),
(55, 41, 'Angenieux Optimo 24-290mm', 'Zoom', 24, 290, 2.8, 22.0, 11500, 162, '2015-01-01', 125000.00),
(13, 41, 'Zeiss Supreme Prime 50mm T1.5', 'Prime', 50, 50, 1.5, 16.0, 1600, 95, '2018-06-01', 19900.00),
(13, 41, 'Zeiss CP.3 85mm T2.1', 'Prime', 85, 85, 2.1, 22.0, 1000, 95, '2017-04-01', 4990.00),
(58, 8, 'Rokinon 35mm f/1.4 AS UMC', 'Prime', 35, 35, 1.4, 22.0, 660, 77, '2011-03-01', 399.00),
(58, 8, 'Rokinon 85mm f/1.4 AS IF UMC', 'Prime', 85, 85, 1.4, 22.0, 540, 72, '2010-06-01', 299.00),
(58, 8, 'Rokinon Cine DS 24mm T1.5', 'Prime', 24, 24, 1.5, 22.0, 680, 77, '2014-01-01', 549.00),
(31, 8, '7Artisans 35mm f/1.2', 'Prime', 35, 35, 1.2, 16.0, 230, 43, '2018-01-01', 139.00),
(31, 8, '7Artisans 55mm f/1.4', 'Prime', 55, 55, 1.4, 16.0, 270, 49, '2017-01-01', 119.00),
(30, 8, 'TTArtisan 50mm f/1.2', 'Prime', 50, 50, 1.2, 16.0, 420, 52, '2020-08-01', 98.00),
(30, 8, 'TTArtisan 35mm f/1.4', 'Prime', 35, 35, 1.4, 16.0, 180, 39, '2020-01-01', 75.00),
(59, 8, 'Pergear 35mm f/1.6', 'Prime', 35, 35, 1.6, 16.0, 135, 43, '2021-01-01', 69.00),
(59, 8, 'Pergear 25mm f/1.8', 'Prime', 25, 25, 1.8, 16.0, 115, 43, '2021-06-01', 59.00),
(60, 8, 'AstrHori 85mm f/1.8', 'Prime', 85, 85, 1.8, 16.0, 450, 62, '2022-03-01', 169.00),
(28, 8, 'Yongnuo YN 50mm f/1.8', 'Prime', 50, 50, 1.8, 22.0, 150, 52, '2017-01-01', 59.00),
(28, 1, 'Yongnuo YN 35mm f/2.0', 'Prime', 35, 35, 2.0, 22.0, 155, 52, '2015-01-01', 89.00),
(29, 8, 'Meike 35mm f/1.7', 'Prime', 35, 35, 1.7, 16.0, 155, 49, '2018-01-01', 79.00),
(27, 8, 'Viltrox 85mm f/1.8 II', 'Prime', 85, 85, 1.8, 16.0, 490, 72, '2021-01-01', 399.00);

-- LENS OPTICAL SPECS (20 more)
INSERT INTO lens_optical_specs (lens_id, min_focus_distance_m, max_magnification, optical_elements, optical_groups, diaphragm_blades, has_stabilization, weather_sealed) VALUES
(41, 0.50, 0.10, 21, 14, 11, FALSE, TRUE),
(42, 0.80, 0.08, 31, 20, 11, FALSE, TRUE),
(43, 0.60, 0.20, 21, 17, 16, FALSE, TRUE),
(44, 1.20, 0.06, 33, 20, 15, FALSE, TRUE),
(45, 0.45, 0.20, 13, 10, 11, FALSE, TRUE),
(46, 1.00, 0.10, 10, 8, 14, FALSE, TRUE),
(47, 0.30, 0.20, 12, 10, 8, FALSE, FALSE),
(48, 0.85, 0.11, 9, 7, 8, FALSE, FALSE),
(49, 0.30, 0.18, 13, 12, 8, FALSE, FALSE),
(50, 0.30, 0.17, 8, 6, 9, FALSE, FALSE),
(51, 0.35, 0.12, 7, 5, 12, FALSE, FALSE),
(52, 0.35, 0.15, 10, 7, 10, FALSE, FALSE),
(53, 0.30, 0.17, 7, 5, 10, FALSE, FALSE),
(54, 0.35, 0.12, 7, 5, 10, FALSE, FALSE),
(55, 0.25, 0.17, 6, 4, 10, FALSE, FALSE),
(56, 0.80, 0.12, 10, 7, 9, FALSE, FALSE),
(57, 0.45, 0.15, 7, 5, 7, FALSE, FALSE),
(58, 0.29, 0.22, 5, 4, 7, FALSE, FALSE),
(59, 0.35, 0.17, 5, 4, 9, FALSE, FALSE),
(60, 0.80, 0.11, 10, 7, 9, TRUE, TRUE);

-- MOUNT ADAPTERS (20 more - cinema and budget)
INSERT INTO mount_adapters (manufacturer_id, source_mount_id, target_mount_id, name, has_autofocus, has_stabilization, price) VALUES
(41, 1, 41, 'ARRI EF to PL Adapter', FALSE, FALSE, 850.00),
(41, 41, 42, 'ARRI PL to LPL Adapter', FALSE, FALSE, 450.00),
(17, 1, 55, 'RED Canon EF Mount', TRUE, FALSE, 1500.00),
(17, 5, 55, 'RED Nikon Mount', FALSE, FALSE, 1200.00),
(17, 41, 55, 'RED PL Mount', FALSE, FALSE, 1000.00),
(18, 41, 56, 'Blackmagic PL Mount Kit', FALSE, FALSE, 295.00),
(18, 1, 56, 'Blackmagic EF Mount', TRUE, FALSE, 195.00),
(42, 1, 45, 'Kinefinity EF Mount', TRUE, FALSE, 399.00),
(42, 41, 45, 'Kinefinity PL Mount', FALSE, FALSE, 349.00),
(43, 1, 46, 'Z CAM EF Mount', TRUE, FALSE, 199.00),
(43, 41, 46, 'Z CAM PL Mount', FALSE, FALSE, 179.00),
(39, 41, 8, 'Fotodiox PL to E-Mount', FALSE, FALSE, 149.00),
(39, 41, 3, 'Fotodiox PL to RF', FALSE, FALSE, 159.00),
(39, 41, 6, 'Fotodiox PL to Z-Mount', FALSE, FALSE, 159.00),
(27, 41, 8, 'Viltrox PL to E-Mount', FALSE, FALSE, 129.00),
(40, 41, 8, 'Metabones PL to E-Mount', FALSE, FALSE, 399.00),
(40, 41, 3, 'Metabones PL to RF', FALSE, FALSE, 449.00),
(56, 41, 46, 'Panavision PV to PL', FALSE, FALSE, 295.00),
(39, 48, 8, 'Fotodiox M42 to E-Mount', FALSE, FALSE, 25.00),
(39, 51, 8, 'Fotodiox C/Y to E-Mount', FALSE, FALSE, 35.00);

-- =============================================
-- ADDITIONAL RECORDS FOR FILTER DIVERSITY
-- Consumer/Prosumer Focus
-- =============================================

-- =============================================
-- MANUFACTURERS (25 more - diverse countries)
-- =============================================
INSERT INTO manufacturers (name, country, founded_year, headquarters, website, specialization) VALUES
('Meopta', 'Czech Republic', 1933, 'Prerov, Czech Republic', 'https://www.meopta.com', 'Lenses'),
('PIXII', 'France', 2016, 'Paris, France', 'https://www.pixii.fr', 'Cameras'),
('Lumenera', 'Canada', 2001, 'Ottawa, Canada', 'https://www.lumenera.com', 'Cameras'),
('Photron', 'India', 1998, 'Mumbai, India', 'https://www.photron.in', 'Accessories'),
('Digitek', 'India', 2002, 'New Delhi, India', 'https://www.digitek.net.in', 'Accessories'),
('Neewer', 'China', 2010, 'Shenzhen, China', 'https://www.neewer.com', 'Accessories'),
('Godox', 'China', 1993, 'Shenzhen, China', 'https://www.godox.com', 'Accessories'),
('K&F Concept', 'China', 2011, 'Shenzhen, China', 'https://www.kentfaith.com', 'Accessories'),
('Andoer', 'China', 2013, 'Shenzhen, China', 'https://www.andoer.com', 'Accessories'),
('NiSi', 'China', 2005, 'Nanjing, China', 'https://www.nisifilters.com', 'Lenses'),
('Venus Optics', 'China', 2013, 'Hefei, China', 'https://www.vfresco.com', 'Lenses'),
('Sirui', 'China', 2001, 'Zhongshan, China', 'https://www.sirui.com', 'Both'),
('Zhongyi Optics', 'China', 2012, 'Shenyang, China', 'https://www.zyoptics.net', 'Lenses'),
('Brightin Star', 'China', 2019, 'Shenzhen, China', 'https://www.brightinstar.com', 'Lenses'),
('Commlite', 'China', 2009, 'Shenzhen, China', 'https://www.commlite.com', 'Accessories'),
('Kamlan', 'China', 2017, 'Shenzhen, China', 'https://www.kamlan.com', 'Lenses'),
('Thypoch', 'China', 2022, 'Shenzhen, China', 'https://www.thypoch.com', 'Lenses'),
('Meyer Optik Gorlitz', 'Germany', 1896, 'Gorlitz, Germany', 'https://www.meyer-optik-goerlitz.com', 'Lenses'),
('Kipon', 'China', 2007, 'Shanghai, China', 'https://www.kipon.com', 'Accessories'),
('Argraph', 'United States', 1945, 'New York, United States', 'https://www.argraph.com', 'Accessories'),
('Holga', 'Hong Kong', 1982, 'Hong Kong', 'https://www.holga.net', 'Cameras'),
('Lomo', 'Russia', 1914, 'Saint Petersburg, Russia', 'https://www.lomography.com', 'Cameras'),
('Gevaert', 'Belgium', 1894, 'Antwerp, Belgium', 'https://www.agfa.com', 'Both'),
('Ferrania', 'Italy', 1882, 'Cairo Montenotte, Italy', 'https://www.filmferrania.it', 'Both'),
('Adox', 'Germany', 1860, 'Bad Soden, Germany', 'https://www.adox.de', 'Both');

-- =============================================
-- SENSORS (12 more - entry-level and compact)
-- =============================================
INSERT INTO sensors (name, type, format_size, megapixels, iso_min, iso_max) VALUES
('Canon APS-C Entry 24MP', 'CMOS', 'APS-C', 24.1, 100, 25600),
('Canon APS-C Entry 18MP', 'CMOS', 'APS-C', 18.0, 100, 12800),
('Canon 1-inch Compact', 'BSI-CMOS', '1-inch', 20.1, 125, 12800),
('Nikon APS-C Entry 24MP', 'CMOS', 'APS-C', 24.2, 100, 25600),
('Nikon APS-C Retro', 'CMOS', 'APS-C', 20.9, 100, 51200),
('Sony APS-C Entry 24MP', 'CMOS', 'APS-C', 24.2, 100, 32000),
('Sony 1-inch Compact', 'Stacked CMOS', '1-inch', 20.1, 100, 12800),
('Fujifilm X-Trans 3', 'CMOS', 'APS-C', 24.3, 200, 12800),
('Fujifilm X-Trans Entry', 'CMOS', 'APS-C', 26.1, 160, 12800),
('Panasonic MFT Entry 16MP', 'CMOS', 'Micro Four Thirds', 16.0, 200, 25600),
('Ricoh APS-C GR', 'CMOS', 'APS-C', 24.2, 100, 102400),
('Compact 1-inch Generic', 'BSI-CMOS', '1-inch', 20.0, 125, 12800);

-- =============================================
-- IMAGE PROCESSORS (12 more - entry-level)
-- =============================================
INSERT INTO image_processors (manufacturer_id, name, generation, release_year, max_burst_fps, max_video_resolution, bit_depth, ai_features) VALUES
(1, 'DIGIC 4+', 4, 2013, 5, '1080p30', 14, NULL),
(1, 'DIGIC 7 Entry', 7, 2017, 6, '4K24', 14, 'Face Detection'),
(2, 'EXPEED 4 Entry', 4, 2014, 5, '1080p60', 14, NULL),
(2, 'EXPEED 6 Entry', 6, 2019, 11, '4K30', 14, 'Eye AF'),
(3, 'BIONZ X Entry', 2, 2014, 11, '4K30', 14, 'Eye AF'),
(3, 'BIONZ X Compact', 2, 2019, 20, '4K30', 14, 'Eye AF'),
(4, 'X-Processor Pro Entry', 1, 2017, 8, '4K30', 14, 'Face Detection'),
(4, 'X-Processor 4 Entry', 4, 2020, 8, '4K30', 14, 'Eye AF'),
(5, 'Venus Engine HD2', 2, 2015, 8, '4K30', 12, NULL),
(5, 'Venus Engine 9', 9, 2019, 10, '4K30', 12, 'DFD AF'),
(21, 'GR Engine 6', 6, 2019, 4, '1080p60', 14, NULL),
(6, 'TruePic VIII Entry', 8, 2020, 8, '4K30', 12, 'Face Detection');

-- =============================================
-- LENSES (30 more - Tilt-Shift, Fisheye, Telephoto)
-- =============================================
INSERT INTO lenses (manufacturer_id, mount_id, name, lens_type, focal_length_min, focal_length_max, aperture_max, aperture_min, weight_g, filter_size_mm, release_date, price) VALUES
-- TILT-SHIFT LENSES (10)
(1, 1, 'Canon TS-E 17mm f/4L', 'Tilt-Shift', 17, 17, 4.0, 22.0, 820, NULL, '2009-05-01', 2149.00),
(1, 1, 'Canon TS-E 24mm f/3.5L II', 'Tilt-Shift', 24, 24, 3.5, 22.0, 780, 82, '2009-05-01', 1899.00),
(1, 1, 'Canon TS-E 50mm f/2.8L Macro', 'Tilt-Shift', 50, 50, 2.8, 32.0, 945, 77, '2017-08-25', 2199.00),
(1, 1, 'Canon TS-E 90mm f/2.8L Macro', 'Tilt-Shift', 90, 90, 2.8, 32.0, 915, 77, '2017-08-25', 2199.00),
(2, 5, 'Nikon PC-E 19mm f/4E ED', 'Tilt-Shift', 19, 19, 4.0, 32.0, 885, NULL, '2016-09-01', 3399.00),
(2, 5, 'Nikon PC-E 24mm f/3.5D ED', 'Tilt-Shift', 24, 24, 3.5, 32.0, 730, 77, '2008-01-01', 2199.00),
(2, 5, 'Nikon PC-E 45mm f/2.8D ED', 'Tilt-Shift', 45, 45, 2.8, 32.0, 740, 77, '2008-07-01', 1999.00),
(2, 5, 'Nikon PC-E 85mm f/2.8D', 'Tilt-Shift', 85, 85, 2.8, 32.0, 635, 77, '2008-07-01', 1999.00),
(32, 8, 'Laowa 15mm f/4.5 Zero-D Shift', 'Tilt-Shift', 15, 15, 4.5, 22.0, 597, NULL, '2020-07-01', 1199.00),
(32, 8, 'Laowa 20mm f/4 Zero-D Shift', 'Tilt-Shift', 20, 20, 4.0, 22.0, 747, 82, '2021-09-01', 1099.00),

-- FISHEYE LENSES (10)
(1, 3, 'Canon RF 5.2mm f/2.8L Dual Fisheye', 'Fisheye', 5, 5, 2.8, 16.0, 350, NULL, '2021-10-01', 1999.00),
(1, 1, 'Canon EF 8-15mm f/4L Fisheye USM', 'Fisheye', 8, 15, 4.0, 22.0, 540, NULL, '2010-07-01', 1349.00),
(2, 5, 'Nikon AF-S 8-15mm f/3.5-4.5E ED Fisheye', 'Fisheye', 8, 15, 3.5, 22.0, 485, NULL, '2017-06-01', 1249.00),
(10, 8, 'Sigma 15mm f/2.8 EX DG Diagonal Fisheye', 'Fisheye', 15, 15, 2.8, 22.0, 370, NULL, '2007-04-01', 609.00),
(14, 8, 'Samyang 8mm f/2.8 UMC Fisheye II', 'Fisheye', 8, 8, 2.8, 22.0, 290, NULL, '2014-01-01', 279.00),
(14, 9, 'Samyang 12mm f/2.8 ED AS NCS Fisheye', 'Fisheye', 12, 12, 2.8, 22.0, 530, NULL, '2014-07-01', 399.00),
(32, 8, 'Laowa 4mm f/2.8 Circular Fisheye', 'Fisheye', 4, 4, 2.8, 16.0, 135, NULL, '2018-09-01', 199.00),
(31, 8, '7Artisans 7.5mm f/2.8 II Fisheye', 'Fisheye', 8, 8, 2.8, 22.0, 270, NULL, '2020-03-01', 139.00),
(29, 8, 'Meike 8mm f/3.5 Fisheye', 'Fisheye', 8, 8, 3.5, 22.0, 280, NULL, '2018-05-01', 99.00),
(12, 8, 'Tokina SZ 8mm f/2.8 Fisheye', 'Fisheye', 8, 8, 2.8, 22.0, 280, NULL, '2021-09-01', 299.00),

-- TELEPHOTO LENSES (10)
(1, 3, 'Canon RF 800mm f/11 IS STM', 'Telephoto', 800, 800, 11.0, 32.0, 1260, 95, '2020-07-09', 899.00),
(1, 3, 'Canon RF 600mm f/11 IS STM', 'Telephoto', 600, 600, 11.0, 32.0, 930, 82, '2020-07-09', 699.00),
(1, 3, 'Canon RF 100-500mm f/4.5-7.1L IS USM', 'Telephoto', 100, 500, 4.5, 32.0, 1370, 77, '2020-07-09', 2699.00),
(2, 6, 'Nikon Z 800mm f/6.3 VR S', 'Telephoto', 800, 800, 6.3, 32.0, 2385, 127, '2022-04-07', 6496.00),
(2, 6, 'Nikon Z 180-600mm f/5.6-6.3 VR', 'Telephoto', 180, 600, 5.6, 32.0, 1955, 95, '2023-07-12', 1696.00),
(3, 8, 'Sony FE 200-600mm f/5.6-6.3 G OSS', 'Telephoto', 200, 600, 5.6, 32.0, 2115, 95, '2019-06-11', 1998.00),
(10, 8, 'Sigma 150-600mm f/5-6.3 DG DN OS Sports', 'Telephoto', 150, 600, 5.0, 22.0, 2100, 95, '2021-08-06', 1499.00),
(11, 8, 'Tamron 150-500mm f/5-6.7 Di III VC VXD', 'Telephoto', 150, 500, 5.0, 32.0, 1725, 82, '2021-06-10', 1399.00),
(11, 8, 'Tamron 50-400mm f/4.5-6.3 Di III VC VXD', 'Telephoto', 50, 400, 4.5, 32.0, 1155, 67, '2022-09-29', 1299.00),
(14, 8, 'Samyang AF 135mm f/1.8 FE', 'Telephoto', 135, 135, 1.8, 16.0, 772, 82, '2023-01-15', 799.00);

-- =============================================
-- LENS OPTICAL SPECS (30 more - for new lenses)
-- =============================================
INSERT INTO lens_optical_specs (lens_id, min_focus_distance_m, max_magnification, optical_elements, optical_groups, diaphragm_blades, has_stabilization, weather_sealed) VALUES
-- Tilt-Shift lenses (IDs 61-70)
(61, 0.25, 0.14, 18, 12, 8, FALSE, TRUE),
(62, 0.21, 0.34, 16, 11, 8, FALSE, TRUE),
(63, 0.27, 0.50, 23, 17, 9, FALSE, TRUE),
(64, 0.39, 0.50, 23, 17, 9, FALSE, TRUE),
(65, 0.25, 0.18, 17, 13, 9, FALSE, TRUE),
(66, 0.21, 0.37, 13, 10, 9, FALSE, TRUE),
(67, 0.25, 0.50, 12, 9, 9, FALSE, TRUE),
(68, 0.39, 0.50, 9, 6, 9, FALSE, TRUE),
(69, 0.20, 0.25, 17, 11, 5, FALSE, FALSE),
(70, 0.25, 0.22, 16, 11, 14, FALSE, FALSE),
-- Fisheye lenses (IDs 71-80)
(71, 0.20, 0.07, 12, 10, 9, FALSE, TRUE),
(72, 0.15, 0.39, 15, 11, 7, FALSE, TRUE),
(73, 0.16, 0.34, 15, 10, 7, FALSE, TRUE),
(74, 0.15, 0.26, 7, 6, 7, FALSE, FALSE),
(75, 0.30, 0.13, 11, 8, 6, FALSE, FALSE),
(76, 0.20, 0.15, 12, 8, 7, FALSE, FALSE),
(77, 0.08, 0.12, 9, 7, 5, FALSE, FALSE),
(78, 0.12, 0.10, 11, 9, 7, FALSE, FALSE),
(79, 0.15, 0.12, 9, 6, 6, FALSE, FALSE),
(80, 0.20, 0.10, 11, 8, 7, FALSE, FALSE),
-- Telephoto lenses (IDs 81-90)
(81, 6.00, 0.14, 11, 8, 9, TRUE, TRUE),
(82, 4.50, 0.16, 10, 7, 9, TRUE, TRUE),
(83, 0.90, 0.33, 20, 14, 9, TRUE, TRUE),
(84, 5.00, 0.10, 22, 15, 9, TRUE, TRUE),
(85, 1.30, 0.25, 25, 17, 9, TRUE, TRUE),
(86, 2.40, 0.20, 24, 17, 11, TRUE, TRUE),
(87, 0.58, 0.28, 25, 15, 9, TRUE, TRUE),
(88, 0.60, 0.32, 25, 16, 7, TRUE, TRUE),
(89, 0.25, 0.50, 18, 12, 7, TRUE, TRUE),
(90, 0.75, 0.18, 13, 10, 9, FALSE, TRUE);

-- =============================================
-- CAMERA BODIES (25 more - entry/consumer/compact)
-- =============================================
INSERT INTO camera_bodies (manufacturer_id, sensor_id, mount_id, processor_id, name, body_type, release_date, price, weight_g, body_material) VALUES
-- Entry-level DSLRs (IDs 61-66)
(1, 61, 2, 62, 'Canon EOS Rebel SL3', 'DSLR', '2019-04-10', 649.00, 449, 'Polycarbonate'),
(1, 62, 2, 61, 'Canon EOS 4000D', 'DSLR', '2018-02-26', 379.00, 436, 'Polycarbonate'),
(2, 64, 5, 63, 'Nikon D3500', 'DSLR', '2018-08-30', 449.00, 365, 'Polycarbonate'),
(2, 64, 5, 63, 'Nikon D5600', 'DSLR', '2016-11-10', 699.00, 465, 'Polycarbonate'),
(9, 40, 20, 30, 'Pentax K-70', 'DSLR', '2016-07-22', 649.00, 688, 'Polycarbonate'),
(9, 40, 20, 29, 'Pentax KF', 'DSLR', '2022-11-17', 849.00, 684, 'Polycarbonate'),

-- Entry/Budget Mirrorless (IDs 67-76)
(1, 61, 3, 5, 'Canon EOS R10', 'Mirrorless', '2022-05-24', 979.00, 429, 'Polycarbonate'),
(1, 61, 3, 5, 'Canon EOS R50', 'Mirrorless', '2023-02-08', 679.00, 376, 'Polycarbonate'),
(1, 62, 3, 62, 'Canon EOS R100', 'Mirrorless', '2023-05-24', 479.00, 356, 'Polycarbonate'),
(2, 64, 6, 64, 'Nikon Z50', 'Mirrorless', '2019-10-10', 859.00, 450, 'Magnesium Alloy'),
(2, 65, 6, 64, 'Nikon Z fc', 'Mirrorless', '2021-06-28', 959.00, 445, 'Magnesium Alloy'),
(3, 66, 8, 65, 'Sony A6000', 'Mirrorless', '2014-02-12', 448.00, 344, 'Magnesium Alloy'),
(3, 66, 8, 65, 'Sony A6100', 'Mirrorless', '2019-08-28', 598.00, 396, 'Polycarbonate'),
(3, 66, 8, 65, 'Sony ZV-E10', 'Mirrorless', '2021-07-27', 698.00, 343, 'Polycarbonate'),
(4, 68, 9, 67, 'Fujifilm X-T200', 'Mirrorless', '2020-01-23', 699.00, 370, 'Polycarbonate'),
(4, 69, 9, 68, 'Fujifilm X-S10', 'Mirrorless', '2020-10-15', 999.00, 465, 'Polycarbonate'),

-- Compact cameras (IDs 77-85)
(3, 67, 8, 66, 'Sony RX100 VII', 'Compact', '2019-07-25', 1298.00, 302, 'Aluminum'),
(3, 67, 8, 66, 'Sony RX100 VA', 'Compact', '2019-07-25', 948.00, 299, 'Aluminum'),
(1, 63, 4, 62, 'Canon PowerShot G7 X Mark III', 'Compact', '2019-07-09', 749.00, 304, 'Aluminum'),
(1, 63, 4, 62, 'Canon PowerShot G5 X Mark II', 'Compact', '2019-07-09', 899.00, 340, 'Aluminum'),
(4, 69, 9, 68, 'Fujifilm X100V', 'Compact', '2020-02-04', 1399.00, 478, 'Aluminum'),
(4, 69, 9, 15, 'Fujifilm X100VI', 'Compact', '2024-02-20', 1599.00, 521, 'Aluminum'),
(21, 71, 20, 71, 'Ricoh GR III', 'Compact', '2019-03-15', 899.00, 257, 'Magnesium Alloy'),
(21, 71, 20, 71, 'Ricoh GR IIIx', 'Compact', '2021-10-01', 999.00, 262, 'Magnesium Alloy'),
(5, 72, 11, 70, 'Panasonic LX100 II', 'Compact', '2018-08-22', 997.00, 392, 'Aluminum');

-- =============================================
-- BODY FEATURES (25 more - for new cameras)
-- =============================================
INSERT INTO body_features (body_id, weather_sealed, operating_temp_min, operating_temp_max, shutter_durability, has_gps, has_bluetooth, has_wifi) VALUES
-- Entry DSLRs (61-66)
(61, FALSE, 0, 40, 100000, FALSE, TRUE, TRUE),
(62, FALSE, 0, 40, 100000, FALSE, FALSE, TRUE),
(63, FALSE, 0, 40, 100000, FALSE, TRUE, TRUE),
(64, FALSE, 0, 40, 100000, FALSE, TRUE, TRUE),
(65, TRUE, -10, 40, 100000, FALSE, TRUE, TRUE),
(66, TRUE, -10, 40, 100000, FALSE, TRUE, TRUE),
-- Entry Mirrorless (67-76)
(67, FALSE, 0, 40, 200000, FALSE, TRUE, TRUE),
(68, FALSE, 0, 40, 200000, FALSE, TRUE, TRUE),
(69, FALSE, 0, 40, 100000, FALSE, TRUE, TRUE),
(70, TRUE, 0, 40, 200000, FALSE, TRUE, TRUE),
(71, FALSE, 0, 40, 200000, FALSE, TRUE, TRUE),
(72, FALSE, 0, 40, 100000, FALSE, TRUE, TRUE),
(73, FALSE, 0, 40, 100000, FALSE, TRUE, TRUE),
(74, FALSE, 0, 40, 100000, FALSE, TRUE, TRUE),
(75, FALSE, 0, 40, 100000, FALSE, TRUE, TRUE),
(76, TRUE, -10, 40, 200000, FALSE, TRUE, TRUE),
-- Compact cameras (77-85)
(77, FALSE, 0, 40, 200000, FALSE, TRUE, TRUE),
(78, FALSE, 0, 40, 200000, FALSE, TRUE, TRUE),
(79, FALSE, 0, 40, 100000, FALSE, TRUE, TRUE),
(80, FALSE, 0, 40, 100000, FALSE, TRUE, TRUE),
(81, TRUE, -10, 40, 300000, FALSE, TRUE, TRUE),
(82, TRUE, -10, 40, 500000, FALSE, TRUE, TRUE),
(83, FALSE, 0, 40, 200000, FALSE, TRUE, TRUE),
(84, FALSE, 0, 40, 200000, FALSE, TRUE, TRUE),
(85, FALSE, 0, 40, 100000, FALSE, TRUE, TRUE);

-- =============================================
-- BODY SPECS (25 more - for new cameras)
-- =============================================
INSERT INTO body_specs (body_id, shutter_speed_min, shutter_speed_max, burst_fps, video_resolution, has_ibis, ibis_stops, evf_resolution, lcd_size, lcd_articulating) VALUES
-- Entry DSLRs (61-66) - NO IBIS
(61, '30s', '1/4000s', 5.0, '4K24', FALSE, NULL, NULL, 3.0, TRUE),
(62, '30s', '1/4000s', 3.0, '1080p30', FALSE, NULL, NULL, 2.7, FALSE),
(63, '30s', '1/4000s', 5.0, '1080p60', FALSE, NULL, NULL, 3.0, TRUE),
(64, '30s', '1/4000s', 5.0, '1080p60', FALSE, NULL, NULL, 3.2, TRUE),
(65, '30s', '1/6000s', 6.0, '1080p60', FALSE, NULL, NULL, 3.0, TRUE),
(66, '30s', '1/6000s', 6.0, '4K30', FALSE, NULL, NULL, 3.0, TRUE),
-- Entry Mirrorless (67-76) - MIXED IBIS
(67, '30s', '1/16000s', 15.0, '4K60', FALSE, NULL, 2360000, 3.0, TRUE),
(68, '30s', '1/16000s', 12.0, '4K30', FALSE, NULL, 2360000, 3.0, TRUE),
(69, '30s', '1/4000s', 6.5, '4K24', FALSE, NULL, 2360000, 3.0, TRUE),
(70, '30s', '1/4000s', 11.0, '4K30', FALSE, NULL, 2360000, 3.2, TRUE),
(71, '30s', '1/4000s', 11.0, '4K30', FALSE, NULL, 2360000, 3.0, TRUE),
(72, '30s', '1/4000s', 11.0, '4K30', FALSE, NULL, 1440000, 3.0, TRUE),
(73, '30s', '1/4000s', 11.0, '4K30', FALSE, NULL, 1440000, 3.0, TRUE),
(74, '30s', '1/4000s', 11.0, '4K30', FALSE, NULL, 2360000, 3.0, TRUE),
(75, '30s', '1/4000s', 8.0, '4K30', FALSE, NULL, 2360000, 3.0, TRUE),
(76, '30s', '1/4000s', 8.0, '4K30', TRUE, 6.0, 2360000, 3.0, TRUE),
-- Compact cameras (77-85) - MIXED IBIS
(77, '30s', '1/32000s', 20.0, '4K30', FALSE, NULL, 2360000, 3.0, TRUE),
(78, '30s', '1/32000s', 11.0, '4K30', FALSE, NULL, 2360000, 3.0, TRUE),
(79, '1s', '1/2000s', 20.0, '4K30', FALSE, NULL, 2360000, 3.0, TRUE),
(80, '30s', '1/2000s', 20.0, '4K30', FALSE, NULL, 2360000, 3.0, TRUE),
(81, '30s', '1/4000s', 11.0, '4K30', TRUE, 6.5, 3690000, 3.0, TRUE),
(82, '30s', '1/4000s', 13.0, '6K30', TRUE, 6.5, 3690000, 3.0, TRUE),
(83, '30s', '1/4000s', 4.0, '1080p60', TRUE, 4.0, NULL, 3.0, FALSE),
(84, '30s', '1/4000s', 4.0, '1080p60', TRUE, 4.0, NULL, 3.0, FALSE),
(85, '60s', '1/4000s', 11.0, '4K30', TRUE, 5.0, 2760000, 3.0, TRUE);

-- =============================================
-- BATTERIES (12 more - entry-level and compact)
-- =============================================
INSERT INTO batteries (manufacturer_id, model, capacity_mah, voltage, weight_g) VALUES
(1, 'LP-E17 Gen2', 1150, 7.20, 46),
(1, 'LP-E10', 860, 7.40, 37),
(1, 'NB-13L', 1250, 3.60, 22),
(2, 'EN-EL14a', 1230, 7.40, 49),
(2, 'EN-EL25', 1120, 7.60, 44),
(3, 'NP-BX1', 1240, 3.60, 19),
(3, 'NP-FW50', 1020, 7.20, 57),
(4, 'NP-W126S', 1260, 7.20, 47),
(4, 'NP-W235', 2200, 7.20, 100),
(21, 'DB-110', 1350, 3.60, 26),
(5, 'DMW-BLG10', 1025, 7.20, 46),
(9, 'D-LI109', 1050, 7.20, 39);

-- =============================================
-- BODY BATTERIES (35 more - many-to-many links)
-- =============================================
INSERT INTO body_batteries (body_id, battery_id, shots_per_charge, video_minutes, included_in_box, charging_time_hrs) VALUES
-- Entry DSLRs
(61, 62, 1070, 80, TRUE, 2.0),
(62, 62, 500, 50, TRUE, 2.0),
(63, 64, 970, 75, TRUE, 2.0),
(64, 64, 1550, 80, TRUE, 2.0),
(65, 72, 460, 60, TRUE, 2.0),
(66, 72, 580, 75, TRUE, 2.0),
-- Entry Mirrorless
(67, 61, 430, 65, TRUE, 2.5),
(68, 61, 420, 60, TRUE, 2.5),
(69, 62, 290, 50, TRUE, 2.0),
(70, 65, 320, 75, TRUE, 2.0),
(71, 65, 350, 80, TRUE, 2.0),
(72, 67, 360, 60, TRUE, 2.0),
(73, 67, 410, 70, TRUE, 2.0),
(74, 67, 325, 80, TRUE, 2.0),
(75, 68, 390, 60, TRUE, 2.5),
(76, 69, 325, 70, TRUE, 3.0),
-- Compact cameras
(77, 66, 260, 75, TRUE, 1.5),
(78, 66, 240, 60, TRUE, 1.5),
(79, 63, 235, 60, TRUE, 2.0),
(80, 63, 235, 55, TRUE, 2.0),
(81, 68, 300, 65, TRUE, 2.5),
(82, 69, 310, 70, TRUE, 3.0),
(83, 70, 200, 45, TRUE, 2.0),
(84, 70, 200, 45, TRUE, 2.0),
(85, 71, 290, 60, TRUE, 2.5),
-- Extra many-to-many relationships (cameras using multiple battery types)
(61, 61, 800, 60, FALSE, 2.5),
(67, 62, 350, 55, FALSE, 2.0),
(70, 64, 280, 55, FALSE, 2.0),
(72, 66, 280, 45, FALSE, 1.5),
(73, 66, 320, 55, FALSE, 1.5),
(74, 66, 260, 50, FALSE, 1.5),
(76, 68, 280, 55, FALSE, 2.5),
(3, 2, 400, 70, FALSE, 2.5),
(4, 2, 720, 120, FALSE, 2.5),
(8, 8, 350, 80, FALSE, 2.0);

