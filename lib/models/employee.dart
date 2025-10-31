class Employee {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // 'admin' or 'employee'
  final double salary;
  final DateTime joiningDate;
  final int totalLeavesPerMonth; // Default 4
  final int usedLeaves; // Current month
  final bool isActive;
  final String? profileImage;
  final String? address;
  final String? emergencyContact;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.salary,
    required this.joiningDate,
    this.totalLeavesPerMonth = 4,
    this.usedLeaves = 0,
    this.isActive = true,
    this.profileImage,
    this.address,
    this.emergencyContact,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'salary': salary,
      'joiningDate': joiningDate.toIso8601String(),
      'totalLeavesPerMonth': totalLeavesPerMonth,
      'usedLeaves': usedLeaves,
      'isActive': isActive,
      'profileImage': profileImage,
      'address': address,
      'emergencyContact': emergencyContact,
    };
  }

  // Create from Firestore Map
  factory Employee.fromMap(Map<String, dynamic> map) {
    print('📄 Parsing Employee from map: $map');

    // Handle joiningDate - can be Timestamp or String
    DateTime joiningDate;
    if (map['joiningDate'] is String) {
      print('📅 joiningDate is String: ${map['joiningDate']}');
      joiningDate = DateTime.parse(map['joiningDate']);
    } else if (map['joiningDate'] != null) {
      print('📅 joiningDate is Timestamp');
      // Firebase Timestamp
      joiningDate = (map['joiningDate'] as dynamic).toDate();
    } else {
      print('⚠️ joiningDate is null, using current date');
      joiningDate = DateTime.now();
    }

    final employee = Employee(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'employee',
      salary: (map['salary'] ?? 0).toDouble(),
      joiningDate: joiningDate,
      totalLeavesPerMonth: map['totalLeavesPerMonth'] ?? 4,
      usedLeaves: map['usedLeaves'] ?? 0,
      isActive: map['isActive'] ?? true,
      profileImage: map['profileImage'],
      address: map['address'],
      emergencyContact: map['emergencyContact'],
    );

    print('✅ Employee parsed: ${employee.name} (${employee.role})');
    return employee;
  }

  // Copy with method for updates
  Employee copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    double? salary,
    DateTime? joiningDate,
    int? totalLeavesPerMonth,
    int? usedLeaves,
    bool? isActive,
    String? profileImage,
    String? address,
    String? emergencyContact,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      salary: salary ?? this.salary,
      joiningDate: joiningDate ?? this.joiningDate,
      totalLeavesPerMonth: totalLeavesPerMonth ?? this.totalLeavesPerMonth,
      usedLeaves: usedLeaves ?? this.usedLeaves,
      isActive: isActive ?? this.isActive,
      profileImage: profileImage ?? this.profileImage,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
    );
  }

  // Calculate remaining leaves
  int get remainingLeaves => totalLeavesPerMonth - usedLeaves;

  // Check if admin
  bool get isAdmin => role == 'admin';
}
