<?php
// Database configuration
define('DB_HOST', '192.168.99.253:3306');
define('DB_NAME', 'cust_manag_sys');
define('DB_USER', 'root');
define('DB_PASS', 'Admin_Pacific_219');

try {
    $pdo = new PDO("mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4", DB_USER, DB_PASS);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    die(json_encode(['error' => 'Connection failed: ' . $e->getMessage()]));
}
?>

