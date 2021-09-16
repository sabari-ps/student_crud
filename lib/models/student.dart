class Student {
  late int studentId;
  late String studentName;
  late String studentEmail;
  late int studentPhone;
  late String studentPlace;

  Student({
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.studentPhone,
    required this.studentPlace,
  });

  Student.fromMap(Map<String, dynamic> data) {
    studentId = data['student_id'];
    studentName = data['student_name'];
    studentEmail = data['student_email'];
    studentPhone = data['student_phone'];
    studentPlace = data['student_place'];
  }

  Map<String, dynamic> toMap() => {
        'student_id': studentId,
        'student_name': studentName,
        'student_email': studentEmail,
        'student_phone': studentPhone,
        'student_place': studentPlace,
      };
}
