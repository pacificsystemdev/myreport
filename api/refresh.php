<?php
header('Content-Type: application/json');

// ✅ FIXED FUNCTION
function getAuthorizationHeader() {
    $headers = null;

    if (isset($_SERVER['HTTP_AUTHORIZATION'])) {
        $headers = trim($_SERVER["HTTP_AUTHORIZATION"]);
    } else if (function_exists('apache_request_headers')) {
        $requestHeaders = apache_request_headers();

        foreach ($requestHeaders as $key => $value) {
            if (strtolower($key) == 'authorization') {
                $headers = trim($value);
                break;
            }
        }
    }

    return $headers;
}

// ✅ GET TOKEN
function getBearerToken() {
    $headers = getAuthorizationHeader();

    if (!empty($headers)) {
        if (preg_match('/Bearer\s(\S+)/', $headers, $matches)) {
            return $matches[1];
        }
    }

    return null;
}

$token = getBearerToken();

// ❌ TOKEN NOT FOUND
if (!$token) {
    echo json_encode([
        "success" => false,
        "message" => "Missing access token"
    ]);
    exit;
}

// ✅ DEBUG (IMPORTANT)
error_log("TOKEN RECEIVED: " . $token);

// =====================
// ✅ VALIDATE TOKEN (simple test)
// =====================

// 👉 Replace this with database validation later
if ($token) {
    echo json_encode([
        "success" => true,
        "message" => "Token received successfully",
        "token" => $token
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Invalid token"
    ]);
}
?>