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
  String purl = 'https://72d7-104-40-23-115.ngrok-free.app';

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
          log['dt_ct'] == 'dt' ? Colors.red[50]! : Colors.green[50]!;
      IconData icon =
          log['dt_ct'] == 'dt' ? Icons.arrow_downward : Icons.arrow_upward;
      Color iconColor = log['dt_ct'] == 'dt' ? Colors.red : Colors.green;

      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
        child: Container(
          decoration: BoxDecoration(
            color: rowColor, // Background color based on transaction type
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon,
                  color: iconColor, size: 28), // Icon for transaction type
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaction ID: ${log['transiction_id']}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Date: ${log['date']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Remarks: ${log['remarks']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Student Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(Icons.person, color: Colors.blue),
                  title: Text(
                    'Student Details',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: _studentDetails.isNotEmpty
                      ? Text(_studentDetails)
                      : Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 10),
                            Text('Loading student details...'),
                          ],
                        ),
                ),
              ),
              SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transaction Logs',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      _transactionLogs.isNotEmpty
                          ? Column(
                              children: _buildTransactionList(),
                            )
                          : Center(
                              child: Column(
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 10),
                                  Text('Loading transactions...'),
                                ],
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'HMS Student App',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            SizedBox(height: 10),
            Card(
              child: ListTile(
                title: Text('Credits'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Developed by Hashim and Team'),
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
    );
  }
}
