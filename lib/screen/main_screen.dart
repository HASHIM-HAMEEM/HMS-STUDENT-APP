import 'package:app/screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _studentDetails = '';
  List<Map<String, dynamic>> _transactionLogs = [];
  String purl = 'https://cc88-52-160-41-102.ngrok-free.app/';

  @override
  void initState() {
    super.initState();
    _fetchStudentDetails();
    _fetchTransactionLogs();
  }

  Future<String?> _getJwtToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt');
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
    //Navigator.of(context).pushReplacementNamed('/login'); // Navigate to login screen
  }

  Future<void> _fetchStudentDetails() async {
    try {
      final jwt = await _getJwtToken();
      final url = Uri.parse('$purl/api/students/getdetails');

      print("Fetching student details...");

      final response = await http.post(
        url,
        headers: {
          'X-Auth-Token': jwt ?? '',
          'Content-Type': 'application/json',
        },
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _studentDetails = _formatStudentDetails(data);
        });
      } else {
        setState(() {
          _studentDetails = 'Failed to load student details.';
        });
      }
    } catch (e) {
      print("Error fetching student details: $e");
      setState(() {
        _studentDetails = 'Failed to load student details.';
      });
    }
  }

  Future<void> _fetchTransactionLogs() async {
    try {
      final jwt = await _getJwtToken();
      final url = Uri.parse('$purl/api/students/getlog');

      print("Fetching transaction logs..  ");
      print(jwt);
      final response = await http.post(
        url,
        headers: {
          'X-Auth-Token': jwt ?? '',
          'Content-Type': 'application/json',
        },
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _transactionLogs = List<Map<String, dynamic>>.from(data);
        });
      } else {
        setState(() {
          _transactionLogs = [];
        });
      }
    } catch (e) {
      print("Error fetching transaction logs: $e");
      setState(() {
        _transactionLogs = [];
      });
    }
  }

  String _formatStudentDetails(Map<String, dynamic> data) {
    return '''
Name: ${data['s_name']}
Status: ${data['s_status']}
Email: ${data['s_email']}
Address: ${data['s_address']}
Phone: ${data['s_phone']}
DOB: ${data['s_dob']}
Room No: ${data['s_roomNo']}
Parent: ${data['s_parantage']}
Pincode: ${data['s_pincode']}
Roll No: ${data['s_rollno']}
Date of Admission: ${data['s_dateadm']}
''';
  }

  List<Widget> _buildTransactionList() {
    return _transactionLogs.map((log) {
      // Determine the color based on the transaction type
      Color rowColor =
          log['dt_ct'] == 'dt' ? Colors.red[200]! : Colors.green[200]!;

      return Container(
        color: rowColor, // Set the background color based on transaction type
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction ID: ${log['transiction_id']}',
              style: TextStyle(fontSize: 10),
            ),
            Text('Date: ${log['date']}'),
            Text('Remarks: ${log['remarks']}'),
            Divider(
              color: Colors.black,
            ), // Add a divider after each transaction
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Main Screen')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                child: ListTile(
                  title: Text('Student Details'),
                  subtitle: Text(_studentDetails.isNotEmpty
                      ? _studentDetails
                      : 'Loading...'),
                ),
              ),
              SizedBox(height: 10),
              Card(
                child: Column(
                  children: [
                    ..._buildTransactionList(),
                    if (_transactionLogs.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('No transactions available.'),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Card(
                child: ListTile(
                  title: Text('Credits'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Developed by [Your Name]'),
                      TextButton(
                        onPressed: _logout,
                        child: Text('Logout'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
