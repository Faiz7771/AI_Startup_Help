import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Feedbackuser extends StatefulWidget {
  const Feedbackuser({super.key});

  @override
  State<Feedbackuser> createState() => _FeedbackuserState();
}

class _FeedbackuserState extends State<Feedbackuser> {
  TextEditingController _feedback = TextEditingController();
  List<FeedbackData> _feedbacks = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _ipstr;

  @override
  void initState() {
    super.initState();
    _loadFeedbacks();
  }

  Future<void> _loadFeedbacks() async {
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
        Uri.parse('$storedIp/myapp/Feedback_user_post/'),
        body: {'login_id': log_id},
      );

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        var arr = jsondata["data"] ?? [];

        List<FeedbackData> tempFeedbacks = [];
        for (int i = 0; i < arr.length; i++) {
          tempFeedbacks.add(FeedbackData(
            feedback: arr[i]['feedback']?.toString() ?? '',
            date: arr[i]['date']?.toString() ?? '',
          ));
        }

        setState(() {
          _feedbacks = tempFeedbacks;
          _ipstr = storedIp;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load feedbacks');
      }
    } catch (e) {
      print('Error loading feedbacks: $e');
      Fluttertoast.showToast(msg: "Failed to load feedbacks");
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
          'Feedback',
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
          // Submit Feedback Card
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
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orange.shade50,
                  Colors.white,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.rate_review_outlined,
                      color: Colors.orange.shade700,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Share Your Feedback ✨',
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
                  'We value your thoughts and suggestions!',
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
                    controller: _feedback,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: 'What do you think about our app? Share your experience...',
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
                    onPressed: _isSubmitting ? null : _submitFeedback,
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
                          'SUBMIT FEEDBACK',
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

          // Tips for Good Feedback
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade100),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  color: Colors.orange.shade700,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Helpful Tips:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade700,
                        ),
                      ),
                      Text(
                        'Be specific about what you liked or what could be improved',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Feedback History Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Feedback History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
                Text(
                  '${_feedbacks.length} feedbacks',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Feedbacks List
          Expanded(
            child: _isLoading
                ? Center(
              child: CircularProgressIndicator(
                color: Colors.orange.shade700,
              ),
            )
                : _feedbacks.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 60,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No feedback yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Share your first feedback with us!',
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
              itemCount: _feedbacks.length,
              itemBuilder: (context, index) {
                final feedback = _feedbacks[index];
                return _buildFeedbackCard(feedback, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(FeedbackData feedback, int index) {
    // Determine emoji based on feedback content (simple detection)
    String getEmoji(String text) {
      final lowerText = text.toLowerCase();
      if (lowerText.contains('thank') ||
          lowerText.contains('great') ||
          lowerText.contains('awesome') ||
          lowerText.contains('love') ||
          lowerText.contains('good')) {
        return '😊';
      } else if (lowerText.contains('bad') ||
          lowerText.contains('problem') ||
          lowerText.contains('issue') ||
          lowerText.contains('fix')) {
        return '😔';
      } else {
        return '📝';
      }
    }

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
            // Feedback Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          getEmoji(feedback.feedback),
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Your Feedback',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    feedback.date,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Feedback Text
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                feedback.feedback,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade800,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Thank You Note
            Row(
              children: [
                Icon(
                  Icons.heart_broken_outlined,
                  size: 16,
                  color: Colors.orange.shade600,
                ),
                const SizedBox(width: 6),
                Text(
                  'Thank you for your valuable feedback!',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.orange.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitFeedback() async {
    if (_feedback.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Please enter your feedback");
      return;
    }

    if (_feedback.text.trim().length < 10) {
      Fluttertoast.showToast(msg: "Please provide more detailed feedback");
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

      final uri = Uri.parse('$storedIp/myapp/Feedback_user/');
      var request = http.MultipartRequest('POST', uri);
      request.fields['user_id'] = log_id;
      request.fields['feedback'] = _feedback.text.trim();

      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == "Feedback Submitted Successfully!") {
        Fluttertoast.showToast(msg: "Thank you for your feedback! ✨");
        _feedback.clear();
        _loadFeedbacks(); // Refresh the list
      } else {
        Fluttertoast.showToast(msg: "Failed to submit feedback");
      }
    } catch (e) {
      print('Error submitting feedback: $e');
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

class FeedbackData {
  final String feedback;
  final String date;

  FeedbackData({
    required this.feedback,
    required this.date,
  });
}