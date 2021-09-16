import 'package:crud_app/database/db_helper.dart';
import 'package:crud_app/models/student.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> searchItems = [];
  bool isLoading = false;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _placeCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  void _refreshStudents() async {
    try {
      DatabaseHelper.getStudents().then((students) {
        setState(() {
          _students = students;
          searchItems = students;
          isLoading = false;
        });
      });
    } catch (err) {
      // ignore: avoid_print
      print("Exception caught: $err");
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshStudents();
    searchItems = _students;
  }

  void filterSearch(String query) async {
    List<Map<String, dynamic>> studentList = _students;
    if (query.isNotEmpty) {
      List<Map<String, dynamic>> studentData = [];
      for (var item in studentList) {
        var student = Student.fromMap(item);
        if (student.studentName.toLowerCase().contains(query.toLowerCase())) {
          studentData.add(item);
        }
      }
      setState(() {
        searchItems = [];
        searchItems.addAll(studentData);
      });
      return;
    } else {
      setState(() {
        searchItems = [];
        searchItems = _students;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "STUDENT CRUD APP",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          filterSearch(value);
                        });
                      },
                      controller: _searchCtrl,
                      decoration: const InputDecoration(
                          hintText: "Search student",
                          labelText: "Search",
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                          )),
                    ),
                  ),
                  Expanded(
                    child: (searchItems.isNotEmpty)
                        ? ListView.builder(
                            itemCount: searchItems.length,
                            itemBuilder: (context, index) {
                              Student student =
                                  Student.fromMap(searchItems[index]);
                              return Card(
                                margin: const EdgeInsets.all(12.0),
                                child: ListTile(
                                  isThreeLine: true,
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.brown,
                                    child: Text(
                                      student.studentName
                                          .toString()
                                          .substring(0, 1),
                                    ),
                                  ),
                                  title: Text(student.studentName),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(student.studentEmail),
                                      Text(student.studentPhone.toString()),
                                      Text(student.studentPlace),
                                    ],
                                  ),
                                  trailing: SizedBox(
                                    width: 100.0,
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () => _showForm(
                                              _students[index]['student_id']),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () => _deleteStudent(
                                              _students[index]['student_id']),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : (_students.isEmpty)
                            ? const Center(
                                child: Text(
                                    "Add students by clicking Floating button"),
                              )
                            : const Center(
                                child: Text("No students found!"),
                              ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _nameCtrl.clear();
          _emailCtrl.clear();
          _phoneCtrl.clear();
          _placeCtrl.clear();
          _showForm(null);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  _showForm(int? id) async {
    if (id != null) {
      final existingStudent =
          _students.firstWhere((element) => element['student_id'] == id);
      _nameCtrl.text = existingStudent['student_name'];
      _emailCtrl.text = existingStudent['student_email'];
      _phoneCtrl.text = existingStudent['student_phone'].toString();
      _placeCtrl.text = existingStudent['student_place'];
    }

    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(12.0),
        ),
      ),
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24.0,
          right: 24.0,
          top: 12.0,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                autovalidateMode: AutovalidateMode.disabled,
                controller: _nameCtrl,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(
                      RegExp('[a-zA-Z]+([a-zA-Z ]+)*'))
                ],
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter student name";
                  }
                },
                decoration: const InputDecoration(
                  labelText: "Name",
                ),
              ),
              TextFormField(
                autovalidateMode: AutovalidateMode.disabled,
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Enter an email address';
                  }
                  if (value.isNotEmpty) {
                    for (var item in _students) {
                      if (value == item['student_email']) {
                        return "Email already exists! Please check your email";
                      }
                    }
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: "Email Address",
                ),
              ),
              TextFormField(
                autovalidateMode: AutovalidateMode.disabled,
                controller: _phoneCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                maxLength: 10,
                decoration: const InputDecoration(
                  labelText: "Phone number",
                ),
                validator: (value) {
                  if (value!.length < 10) {
                    return "Phone number should contain 10 digits";
                  }
                  if (value.isNotEmpty) {
                    for (var item in _students) {
                      if (value == item['student_phone'].toString()) {
                        return "Phone number already exists! Please check";
                      }
                    }
                  }
                  return null;
                },
              ),
              TextFormField(
                autovalidateMode: AutovalidateMode.disabled,
                controller: _placeCtrl,
                keyboardType: TextInputType.name,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Enter student's place";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: "Place",
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (id == null) {
                        await _addStudent();
                        Navigator.of(context).pop();
                      }
                      if (id != null) {
                        await _updateStudent(id);
                        Navigator.of(context).pop();
                      }
                    }

                    // _nameCtrl.clear();
                    // _emailCtrl.clear();
                    // _phoneCtrl.clear();
                    // _placeCtrl.clear();
                  },
                  child: Text(id != null ? "Update" : "ADD STUDENT"))
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addStudent() async {
    await DatabaseHelper.createStudent(_nameCtrl.text, _emailCtrl.text,
        int.parse(_phoneCtrl.text), _placeCtrl.text);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Student added successfully")));
    _refreshStudents();
  }

  Future<void> _updateStudent(int id) async {
    await DatabaseHelper.updateStudent(
      id,
      _nameCtrl.text,
      _emailCtrl.text,
      int.parse(_phoneCtrl.text),
      _placeCtrl.text,
    );
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Student updated successfully")));
    _refreshStudents();
  }

  Future<void> _deleteStudent(int id) async {
    await DatabaseHelper.deleteStudent(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Successfully deleted!"),
    ));
    _refreshStudents();
  }
}
