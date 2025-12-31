import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Expert_idea extends StatefulWidget {
  const Expert_idea({super.key});

  @override
  State<Expert_idea> createState() => _Expert_ideaState();
}

class _Expert_ideaState extends State<Expert_idea> {
  TextEditingController _request = TextEditingController();
  List<ExpertRequest> _requests = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _ipstr;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
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
        Uri.parse('$storedIp/myapp/Expert_idea_post/'),
        body: {'login_id': log_id},
      );

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        var arr = jsondata["data"] ?? [];

        List<ExpertRequest> tempRequests = [];
        for (int i = 0; i < arr.length; i++) {
          tempRequests.add(ExpertRequest(
            description: arr[i]['description']?.toString() ?? '',
            date: arr[i]['date']?.toString() ?? '',
            reply: arr[i]['reply']?.toString() ?? '',
            expname: arr[i]['Expert Name']?.toString() ?? '',
            status: arr[i]['Expert Status']?.toString() ?? '',
          ));
        }

        setState(() {
          _requests = tempRequests;
          _ipstr = storedIp;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load requests');
      }
    } catch (e) {
      print('Error loading requests: $e');
      Fluttertoast.showToast(msg: "Failed to load requests");
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
          'Expert Idea Request',
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
          // Request Form Card
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
                      Icons.lightbulb_outline_rounded,
                      color: Colors.orange.shade700,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Request Expert Advice',
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
                  'Describe your startup idea or challenge:',
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
                    controller: _request,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Type your idea or question here...',
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
                    onPressed: _isSubmitting ? null : _submitRequest,
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
                          'SEND TO EXPERT',
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

          // Requests History Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Request History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
                Text(
                  '${_requests.length} requests',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Requests List
          Expanded(
            child: _isLoading
                ? Center(
              child: CircularProgressIndicator(
                color: Colors.orange.shade700,
              ),
            )
                : _requests.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.forum_outlined,
                    size: 60,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No requests yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Send your first idea to an expert!',
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
              itemCount: _requests.length,
              itemBuilder: (context, index) {
                final request = _requests[index];
                return _buildRequestCard(request, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(ExpertRequest request, int index) {
    bool isPending = request.reply.toLowerCase() == 'pending';
    bool isExpertApproved = request.status.toLowerCase() == 'approved';

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
            // Request Status Header
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
                        isPending ? 'PENDING' : 'RESPONDED',
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
                  request.date,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Request Description
            Text(
              'Your Request:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              request.description,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade800,
              ),
            ),

            const SizedBox(height: 16),

            // Expert Response
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
                        Icons.school_rounded,
                        size: 18,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Expert Response:',
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
                    request.reply,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),

            // Expert Details (only if not pending)
            if (!isPending && request.expname.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.orange.shade100,
                      radius: 20,
                      child: Icon(
                        Icons.person,
                        color: Colors.orange.shade700,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.expname,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          // Show expert verification status
                          Row(
                            children: [
                              Icon(
                                isExpertApproved
                                    ? Icons.verified_rounded
                                    : Icons.pending_actions_rounded,
                                size: 14,
                                color: isExpertApproved
                                    ? Colors.green.shade600
                                    : Colors.orange.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${request.status} Expert',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isExpertApproved
                                      ? Colors.green.shade600
                                      : Colors.grey.shade600,
                                  fontWeight: isExpertApproved
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ],
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

  Future<void> _submitRequest() async {
    if (_request.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Please enter your request");
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

      final uri = Uri.parse('$storedIp/myapp/Expert_idea/');
      var request = http.MultipartRequest('POST', uri);
      request.fields['student_id'] = log_id;
      request.fields['description'] = _request.text.trim();

      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == "Request Submitted Successfully!") {
        Fluttertoast.showToast(msg: "Request submitted successfully!");
        _request.clear();
        _loadRequests(); // Refresh the list
      } else {
        Fluttertoast.showToast(msg: "Failed to submit request");
      }
    } catch (e) {
      print('Error submitting request: $e');
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

class ExpertRequest {
  final String description;
  final String date;
  final String reply;
  final String expname;
  final String status;

  ExpertRequest({
    required this.description,
    required this.date,
    required this.reply,
    required this.expname,
    required this.status,
  });
}