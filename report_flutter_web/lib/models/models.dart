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
      userId: int.tryParse(json['userId'].toString()) ?? 0,
      username: json['username'] ?? '',
      role: json['role'] ?? '',
      token: json['accessToken'] ?? json['token'] ?? '',
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

    return Report(
      reportId:
          int.tryParse(
            json['reportId']?.toString() ??
                json['ReportID']?.toString() ??
                json['ReportId']?.toString() ??
                '',
          ) ??
          0,
      userId:
          int.tryParse(
            json['UserID']?.toString() ?? json['userId']?.toString() ?? '',
          ) ??
          0,
      workactivity: json['workactivity']?.toString() ?? '',
      workactivitywithCust: json['workactivitywithCust']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      customerContact: json['customerContact']?.toString() ?? '',
      customerFee: double.tryParse(json['customerFee']?.toString() ?? '0') ?? 0,
      reportDate: parseDate(json['ReportDate'] ?? json['reportDate']),
      createDate: parseDate(json['CreateDate'] ?? json['createDate']),
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
