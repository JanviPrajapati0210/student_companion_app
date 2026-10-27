// Dart concept demonstration:
// - Class definition with encapsulation (private fields with getters/setters)
// - Default, parameterized, and named constructors (Student.initial(), Student.fromJson())
// - Null safety, String, int data types
// - Serialization to and from Map<String, dynamic>

class Student {
  String _id;
  String _name;
  String _enrollmentNumber;
  String _department;
  int _semester;
  String _email;
  String _phone;
  String _profileImageUrl;

  // Parameterized constructor
  Student({
    required String id,
    required String name,
    required String enrollmentNumber,
    required String department,
    required int semester,
    required String email,
    required String phone,
    String profileImageUrl = '',
  })  : _id = id,
        _name = name,
        _enrollmentNumber = enrollmentNumber,
        _department = department,
        _semester = semester,
        _email = email,
        _phone = phone,
        _profileImageUrl = profileImageUrl;

  // Named constructor for initial default student state
  Student.initial()
      : _id = 'STU-2026-042',
        _name = 'Alex Morgan',
        _enrollmentNumber = '24AIML052',
        _department = 'Artificial Intelligence & Machine Learning',
        _semester = 4,
        _email = 'alex.morgan@charusat.edu.in',
        _phone = '+91 98765 43210',
        _profileImageUrl = '';

  // Getters for encapsulation
  String get id => _id;
  String get name => _name;
  String get enrollmentNumber => _enrollmentNumber;
  String get department => _department;
  int get semester => _semester;
  String get email => _email;
  String get phone => _phone;
  String get profileImageUrl => _profileImageUrl;

  // Setters with validation
  set name(String value) {
    if (value.trim().isNotEmpty) {
      _name = value.trim();
    }
  }

  set department(String value) {
    if (value.trim().isNotEmpty) {
      _department = value.trim();
    }
  }

  set semester(int value) {
    if (value >= 1 && value <= 8) {
      _semester = value;
    }
  }

  set email(String value) {
    if (value.contains('@')) {
      _email = value.trim();
    }
  }

  set phone(String value) {
    if (value.trim().length >= 10) {
      _phone = value.trim();
    }
  }

  // Convert to Map for JSON / SharedPreferences storage
  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'name': _name,
      'enrollmentNumber': _enrollmentNumber,
      'department': _department,
      'semester': _semester,
      'email': _email,
      'phone': _phone,
      'profileImageUrl': _profileImageUrl,
    };
  }

  // Named constructor from Map
  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] ?? 'STU-001',
      name: map['name'] ?? 'Student User',
      enrollmentNumber: map['enrollmentNumber'] ?? '',
      department: map['department'] ?? '',
      semester: map['semester'] is int ? map['semester'] : 1,
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
    );
  }

  // CopyWith pattern for immutable updates
  Student copyWith({
    String? name,
    String? department,
    int? semester,
    String? email,
    String? phone,
  }) {
    return Student(
      id: _id,
      name: name ?? _name,
      enrollmentNumber: _enrollmentNumber,
      department: department ?? _department,
      semester: semester ?? _semester,
      email: email ?? _email,
      phone: phone ?? _phone,
      profileImageUrl: _profileImageUrl,
    );
  }
}
