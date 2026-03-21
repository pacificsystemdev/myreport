<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once 'config.php';

$input = json_decode(file_get_contents('php://input'), true);
$method = $_SERVER['REQUEST_METHOD'];
$userId = $input['userId'] ?? $_GET['userId'] ?? null;
$token = $input['token'] ?? $_GET['token'] ?? null;

if (!$userId) {
    echo json_encode(['success' => false, 'error' => 'Missing userId']);
    exit;
}

// Token validation DISABLED for testing - ENABLE in production
// if ($method === 'POST' || $method === 'PUT') {
//     if (!$token) {
//         echo json_encode(['success' => false, 'error' => 'Missing token']);
//         exit;
//     }
//     $expectedTokenPrefix = md5($userId);
//     if (strpos($token, $expectedTokenPrefix) !== 0) {
//         echo json_encode(['success' => false, 'error' => 'Invalid token']);
//         exit;
//     }
// }

try {
    if ($method === 'POST') {
        // Submit new report
        $data = [
            'UserID' => $userId,
            'workactivity' => $input['workactivity'] ?? '',
            'workactivitywithCust' => $input['workactivitywithCust'] ?? '',
            'customerName' => $input['customerName'] ?? '',
            'customerContact' => $input['customerContact'] ?? '',
            'customerFee' => $input['customerFee'] ?? 0,
            'ReportDate' => !empty($input['reportDate']) ? date('Y-m-d H:i:s', strtotime($input['reportDate'])) : date('Y-m-d H:i:s'),
            'CreateDate' => date('Y-m-d H:i:s')
        ];

        $stmt = $pdo->prepare("INSERT INTO tblreports (UserID, workactivity, workactivitywithCust, customerName, customerContact, customerFee, ReportDate, CreateDate) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
        $stmt->execute([$data['UserID'], $data['workactivity'], $data['workactivitywithCust'], $data['customerName'], $data['customerContact'], $data['customerFee'], $data['ReportDate'], $data['CreateDate']]);

        echo json_encode(['success' => true, 'reportId' => $pdo->lastInsertId()]);

    } elseif ($method === 'PUT') {
        $reportId = $input['reportId'] ?? 0;
        if (!$reportId) {
            echo json_encode(['success' => false, 'error' => 'Missing reportId']);
            exit;
        }

        $data = [
            'workactivity' => $input['workactivity'] ?? '',
            'workactivitywithCust' => $input['workactivitywithCust'] ?? '',
            'customerName' => $input['customerName'] ?? '',
            'customerContact' => $input['customerContact'] ?? '',
            'customerFee' => $input['customerFee'] ?? 0,
            'ReportDate' => !empty($input['reportDate']) ? date('Y-m-d H:i:s', strtotime($input['reportDate'])) : date('Y-m-d H:i:s'),
        ];

        $stmt = $pdo->prepare("UPDATE tblreports SET workactivity = ?, workactivitywithCust = ?, customerName = ?, customerContact = ?, customerFee = ?, ReportDate = ? WHERE reportId = ? AND UserID = ?");
        $stmt->execute([$data['workactivity'], $data['workactivitywithCust'], $data['customerName'], $data['customerContact'], $data['customerFee'], $data['ReportDate'], $reportId, $userId]);

        $rows = $stmt->rowCount();
        echo json_encode(['success' => true, 'updated' => $rows > 0]);

    } else {
        // GET list own reports ordered by ReportDate DESC
        $year = $input['year'] ?? $_GET['year'] ?? null;
        $month = $input['month'] ?? $_GET['month'] ?? null;
        $query = "SELECT * FROM tblreports WHERE UserID = ?";
        $params = [$userId];
        if ($year) {
            $query .= " AND YEAR(ReportDate) = ?";
            $params[] = $year;
        }
        if ($month) {
            $query .= " AND MONTH(ReportDate) = ?";
            $params[] = $month;
        }
        $query .= " ORDER BY ReportDate DESC LIMIT 50";
        $stmt = $pdo->prepare($query);
        $stmt->execute($params);
        $reports = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode(['success' => true, 'reports' => $reports]);
    }
} catch (PDOException $e) {
    echo json_encode(['error' => 'Query failed: ' . $e->getMessage()]);
}
?>

