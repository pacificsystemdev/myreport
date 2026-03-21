class User {
  final int userId;
  final String username;
  final String role;
  String token;

  User({
    required this.userId,
    required this.username,
    required this.role,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] ?? 0,
      username: json['username'] ?? '',
      role: json['role'] ?? '',
      token: json['token'] ?? '',
    );
  }
}

class Report {
  final int reportId;
  final int userId;
  final String workactivity;
  final String workactivitywithCust;
  final String customerName;
  final String customerContact;
  final double customerFee;
  final DateTime reportDate;
  final DateTime createDate;

  Report({
    required this.reportId,
    required this.userId,
    required this.workactivity,
    required this.workactivitywithCust,
    required this.customerName,
    required this.customerContact,
    required this.customerFee,
    required this.reportDate,
    required this.createDate,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic dateStr) {
      if (dateStr == null || dateStr.toString().isEmpty) return DateTime.now();
      try {
        return DateTime.parse(dateStr.toString());
      } catch (e) {
        return DateTime.now();
      }
    }

    double parseFee(dynamic fee) {
      if (fee == null) return 0.0;
      return double.tryParse(fee.toString()) ?? 0.0;
    }

    return Report(
      reportId: json['reportId'] ?? 0,
      userId: (json['UserID'] ?? 0) as int,
      workactivity: json['workactivity']?.toString() ?? '',
      workactivitywithCust: json['workactivitywithCust']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      customerContact: json['customerContact']?.toString() ?? '',
      customerFee: parseFee(json['customerFee']),
      reportDate: parseDate(json['ReportDate']),
      createDate: parseDate(json['CreateDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workactivity': workactivity,
      'workactivitywithCust': workactivitywithCust,
      'customerName': customerName,
      'customerContact': customerContact,
      'customerFee': customerFee,
    };
  }
}
