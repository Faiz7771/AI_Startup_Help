import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Doubt extends StatefulWidget {
  const Doubt({super.key});

  @override
  State<Doubt> createState() => _DoubtState();
}

class _DoubtState extends State<Doubt> {
  TextEditingController _doubt = TextEditingController();
  List<DoubtData> _doubts = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _ipstr;

  @override
  void initState() {
    super.initState();
    _loadDoubts();
  }

  Future<void> _loadDoubts() async {
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
        Uri.parse('$storedIp/myapp/Doubts_user_post/'),
        body: {'login_id': log_id},
      );

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        var arr = jsondata["data"] ?? [];

        List<DoubtData> tempDoubts = [];
        for (int i = 0; i < arr.length; i++) {
          tempDoubts.add(DoubtData(
            doubt: arr[i]['doubt']?.toString() ?? '',
            status: arr[i]['status']?.toString() ?? '',
            reply: arr[i]['reply']?.toString() ?? '',
            date: arr[i]['date']?.toString() ?? '',
          ));
        }

        setState(() {
          _doubts = tempDoubts;
          _ipstr = storedIp;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load doubts');
      }
    } catch (e) {
      print('Error loading doubts: $e');
      Fluttertoast.showToast(msg: "Failed to load doubts");
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
          'Ask Doubts',
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
          // Submit Doubt Card
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
                      Icons.question_answer_outlined,
                      color: Colors.orange.shade700,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Ask Your Doubt',
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
                  'What would you like to ask our experts?',
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
                    controller: _doubt,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Type your doubt or question here...',
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
                    onPressed: _isSubmitting ? null : _submitDoubt,
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
                          'ASK DOUBT',
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

          // Doubts History Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Previous Doubts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
                Text(
                  '${_doubts.length} doubts',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Doubts List
          Expanded(
            child: _isLoading
                ? Center(
              child: CircularProgressIndicator(
                color: Colors.orange.shade700,
              ),
            )
                : _doubts.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.quiz_outlined,
                    size: 60,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No doubts yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ask your first question to our experts!',
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
              itemCount: _doubts.length,
              itemBuilder: (context, index) {
                final doubt = _doubts[index];
                return _buildDoubtCard(doubt, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoubtCard(DoubtData doubt, int index) {
    bool isAnswered = doubt.status.toLowerCase() == 'answered' && doubt.reply.isNotEmpty;

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
            // Doubt Status Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isAnswered ? Colors.green.shade100 : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isAnswered ? Icons.check_circle_rounded : Icons.access_time_rounded,
                        size: 14,
                        color: isAnswered ? Colors.green.shade700 : Colors.orange.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isAnswered ? 'ANSWERED' : 'PENDING',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isAnswered ? Colors.green.shade700 : Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  doubt.date,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Doubt Text
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.question_mark_rounded,
                    size: 20,
                    color: Colors.orange.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Question:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doubt.doubt,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isAnswered ? Colors.green.shade50 : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          isAnswered ? Icons.lightbulb_outline_rounded : Icons.hourglass_top_rounded,
                          size: 16,
                          color: isAnswered ? Colors.green.shade700 : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isAnswered ? 'Expert Answer:' : 'Status:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isAnswered ? Colors.green.shade700 : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isAnswered ? doubt.reply : 'Your question is being reviewed by our experts.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade800,
                      fontStyle: isAnswered ? FontStyle.normal : FontStyle.italic,
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

  Future<void> _submitDoubt() async {
    if (_doubt.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Please enter your doubt");
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

      final uri = Uri.parse('$storedIp/myapp/Doubts_user/');
      var request = http.MultipartRequest('POST', uri);
      request.fields['user_id'] = log_id;
      request.fields['doubt'] = _doubt.text.trim();

      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == "Doubt Submitted Successfully!") {
        Fluttertoast.showToast(msg: "Doubt submitted successfully!");
        _doubt.clear();
        _loadDoubts(); // Refresh the list
      } else {
        Fluttertoast.showToast(msg: "Failed to submit doubt");
      }
    } catch (e) {
      print('Error submitting doubt: $e');
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

class DoubtData {
  final String doubt;
  final String status;
  final String reply;
  final String date;

  DoubtData({
    required this.doubt,
    required this.status,
    required this.reply,
    required this.date,
  });
}