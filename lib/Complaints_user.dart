import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Complaints extends StatefulWidget {
  const Complaints({super.key});

  @override
  State<Complaints> createState() => _ComplaintsState();
}

class _ComplaintsState extends State<Complaints> {
  TextEditingController _complaint = TextEditingController();
  List<ComplaintData> _complaints = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _ipstr;

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String? storedIp = sp.getString('ip');
      String? log_id = sp.getString('l_id');

      if (log_id == null || storedIp == null) {
        throw Exception('Login information not found');
      }

      var response = await http.post(
        Uri.parse('$storedIp/myapp/Complaints_user_post/'),
        body: {'login_id': log_id},
      );

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        var arr = jsondata["data"] ?? [];

        List<ComplaintData> tempComplaints = [];
        for (int i = 0; i < arr.length; i++) {
          tempComplaints.add(ComplaintData(
            complaint: arr[i]['complaint']?.toString() ?? '',
            reply: arr[i]['reply']?.toString() ?? '',
            date: arr[i]['date']?.toString() ?? '',
          ));
        }

        setState(() {
          _complaints = tempComplaints;
          _ipstr = storedIp;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load complaints');
      }
    } catch (e) {
      print('Error loading complaints: $e');
      Fluttertoast.showToast(msg: "Failed to load complaints");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Complaints',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Column(
        children: [
          // Submit Complaint Card
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.report_problem_outlined,
                      color: Colors.orange.shade700,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Submit a Complaint',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Text(
                  'Describe your issue or concern:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextFormField(
                    controller: _complaint,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Type your complaint here...',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitComplaint,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send_rounded, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'SUBMIT COMPLAINT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Complaints History Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Complaint History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
                Text(
                  '${_complaints.length} complaints',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Complaints List
          Expanded(
            child: _isLoading
                ? Center(
              child: CircularProgressIndicator(
                color: Colors.orange.shade700,
              ),
            )
                : _complaints.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 60,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No complaints yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your submitted complaints will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _complaints.length,
              itemBuilder: (context, index) {
                final complaint = _complaints[index];
                return _buildComplaintCard(complaint, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintCard(ComplaintData complaint, int index) {
    bool isPending = complaint.reply.toLowerCase() == 'pending' || complaint.reply.isEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Complaint Status Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isPending ? Colors.orange.shade100 : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isPending ? Icons.access_time_rounded : Icons.check_circle_rounded,
                        size: 14,
                        color: isPending ? Colors.orange.shade700 : Colors.green.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isPending ? 'PENDING' : 'RESOLVED',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isPending ? Colors.orange.shade700 : Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  complaint.date,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Complaint Text
            Text(
              'Your Complaint:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              complaint.complaint,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade800,
              ),
            ),

            const SizedBox(height: 16),

            // Admin Response
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.admin_panel_settings_rounded,
                        size: 18,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Admin Response:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isPending ? 'Your complaint is being reviewed. We will respond soon.' : complaint.reply,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade800,
                      fontStyle: isPending ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitComplaint() async {
    if (_complaint.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Please enter your complaint");
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String? storedIp = sp.getString('ip');
      String? log_id = sp.getString('l_id');

      if (storedIp == null || log_id == null) {
        Fluttertoast.showToast(msg: "Server URL or login info not found");
        return;
      }

      final uri = Uri.parse('$storedIp/myapp/Complaints_user/');
      var request = http.MultipartRequest('POST', uri);
      request.fields['user_id'] = log_id;
      request.fields['complaints'] = _complaint.text.trim();

      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == "Complaint Submitted Successfully!") {
        Fluttertoast.showToast(msg: "Complaint submitted successfully!");
        _complaint.clear();
        _loadComplaints(); // Refresh the list
      } else {
        Fluttertoast.showToast(msg: "Failed to submit complaint");
      }
    } catch (e) {
      print('Error submitting complaint: $e');
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

class ComplaintData {
  final String complaint;
  final String reply;
  final String date;

  ComplaintData({
    required this.complaint,
    required this.reply,
    required this.date,
  });
}