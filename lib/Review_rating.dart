import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Review extends StatefulWidget {
  const Review({super.key});

  @override
  State<Review> createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  TextEditingController _reviewController = TextEditingController();
  int _selectedRating = 0;
  bool _isLoading = false;
  bool _isSubmitting = false;

  List<ReviewData> _reviews = [];
  String? _ipstr;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
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
        Uri.parse('$storedIp/myapp/Rating_review_post/'),
        body: {'login_id': log_id},
      );

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        var arr = jsondata["data"] ?? [];
        print(arr);
        print('bdfjbefejbfej');

        setState(() {
          _reviews = arr.map<ReviewData>((item) => ReviewData(
            rating: int.tryParse(item['rating']?.toString() ?? '0') ?? 0,
            review: item['review']?.toString() ?? '',
            username: item['username']?.toString() ?? 'Anonymous',
            date: item['date']?.toString() ?? '',
          )).toList();
          _ipstr = storedIp;
        });
      }
    } catch (e) {
      print('Error loading reviews: $e');
      Fluttertoast.showToast(msg: "Failed to load reviews");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitReview() async {
    if (_selectedRating == 0) {
      Fluttertoast.showToast(msg: "Please select a rating");
      return;
    }

    if (_reviewController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Please enter your review");
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String? storedIp = sp.getString('ip');
      String? log_id = sp.getString('l_id');

      if (log_id == null || storedIp == null) {
        throw Exception('Login information not found');
      }

      final uri = Uri.parse('$storedIp/myapp/Expert_idea/');
      var request = http.MultipartRequest('POST', uri);
      request.fields['user_id'] = log_id;
      request.fields['rating'] = _selectedRating.toString();
      request.fields['review'] = _reviewController.text.trim();

      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == "Complaint Submitted Successfully!") {
        Fluttertoast.showToast(msg: "Review submitted successfully!");
        _reviewController.clear();
        _selectedRating = 0;
        _loadReviews(); // Refresh the list
      } else {
        Fluttertoast.showToast(msg: "Failed to submit review");
      }
    } catch (e) {
      print('Error submitting review: $e');
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ratings & Reviews',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Submit Review Card
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
                  Text(
                    'Share Your Experience',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Star Rating
                  Text(
                    'Rate your experience:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedRating = index + 1;
                          });
                        },
                        child: Icon(
                          index < _selectedRating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          size: 40,
                          color: index < _selectedRating
                              ? Colors.amber.shade700
                              : Colors.grey.shade400,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    _selectedRating == 0
                        ? '‎ '
                        : '${_selectedRating} ${_selectedRating == 1 ? 'star' : 'stars'} selected',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Review Input
                  Text(
                    'Write your review:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextFormField(
                      controller: _reviewController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Share your thoughts about the app...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitReview,
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
                            'SUBMIT REVIEW',
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

            // Reviews List Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'User Reviews',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                  ),
                  Text(
                    '${_reviews.length} reviews',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Reviews List
            _isLoading
                ? Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.orange.shade700,
                ),
              ),
            )
                : _reviews.isEmpty
                ? Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.reviews_outlined,
                      size: 60,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No reviews yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Be the first to share your experience!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: _reviews.length,
              itemBuilder: (context, index) {
                final review = _reviews[index];
                return _buildReviewCard(review);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(ReviewData review) {
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
            // User and Rating Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.orange.shade100,
                        child: Icon(
                          Icons.person,
                          color: Colors.orange.shade700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review.username,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              review.date,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Star Rating Display
                Row(
                  children: List.generate(5, (index) {
                    print(review.rating);
                    return Icon(
                      index < review.rating
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      size: 18,
                      color: index < review.rating
                          ? Colors.amber.shade700
                          : Colors.grey.shade400,
                    );
                  }),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Review Text
            Text(
              review.review,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade800,
                height: 1.5,
              ),
            ),

            // Divider
            if (_reviews.indexOf(review) != _reviews.length - 1)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Divider(
                  color: Colors.grey.shade200,
                  height: 1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ReviewData {
  final int rating;
  final String review;
  final String username;
  final String date;

  ReviewData({
    required this.rating,
    required this.review,
    required this.username,
    required this.date,
  });
}