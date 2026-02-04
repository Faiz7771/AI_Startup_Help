import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({Key? key}) : super(key: key);

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  List<BookmarkedIdea> _bookmarks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
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
        Uri.parse('$storedIp/myapp/get_bookmarks/'),
        body: {'student_id': log_id},
      );

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata['status'] == 'ok') {
          var arr = jsondata["data"] ?? [];

          List<BookmarkedIdea> tempBookmarks = [];
          for (int i = 0; i < arr.length; i++) {
            tempBookmarks.add(BookmarkedIdea(
              id: arr[i]['id']?.toString() ?? '',
              description: arr[i]['description']?.toString() ?? '',
              date: arr[i]['date']?.toString() ?? '',
              reply: arr[i]['reply']?.toString() ?? '',
              expname: arr[i]['Expert Name']?.toString() ?? '',
              status: arr[i]['Expert Status']?.toString() ?? '',
              bookmarkId: arr[i]['bookmark_id']?.toString() ?? '',
            ));
          }

          setState(() {
            _bookmarks = tempBookmarks;
            _isLoading = false;
          });
        } else {
          throw Exception(jsondata['message'] ?? 'Failed to load bookmarks');
        }
      } else {
        throw Exception('Failed to load bookmarks: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading bookmarks: $e');
      Fluttertoast.showToast(msg: "Failed to load bookmarks");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeBookmark(String bookmarkId) async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String? storedIp = sp.getString('ip');
      String? log_id = sp.getString('l_id');

      if (storedIp == null || log_id == null) {
        Fluttertoast.showToast(msg: "Server URL or login info not found");
        return;
      }

      final uri = Uri.parse('$storedIp/myapp/remove_bookmark/');
      var multipartRequest = http.MultipartRequest('POST', uri);
      multipartRequest.fields['student_id'] = log_id;
      multipartRequest.fields['bookmark_id'] = bookmarkId;

      var response = await multipartRequest.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == "Bookmark removed successfully!") {
        Fluttertoast.showToast(msg: "Bookmark removed!");
        _loadBookmarks(); // Refresh the list
      } else {
        Fluttertoast.showToast(msg: data['message'] ?? "Failed to remove bookmark");
      }
    } catch (e) {
      print('Error removing bookmark: $e');
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bookmarked Ideas',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        elevation: 4,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: Colors.orange.shade700,
        ),
      )
          : _bookmarks.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border_rounded,
              size: 60,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No bookmarks yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bookmark ideas to see them here!',
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
        itemCount: _bookmarks.length,
        itemBuilder: (context, index) {
          final bookmark = _bookmarks[index];
          return _buildBookmarkCard(bookmark);
        },
      ),
    );
  }

  Widget _buildBookmarkCard(BookmarkedIdea bookmark) {
    bool isPending = bookmark.reply.toLowerCase() == 'pending';
    bool isExpertApproved = bookmark.status.toLowerCase() == 'approved';

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
            // Header with bookmark badge and remove button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.bookmark_rounded,
                        size: 14,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'BOOKMARKED',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                  onPressed: () => _removeBookmark(bookmark.bookmarkId),
                  tooltip: 'Remove bookmark',
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
              bookmark.description,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade800,
              ),
            ),

            const SizedBox(height: 12),

            // Date
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  'Requested on: ${bookmark.date}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Expert Response Section
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
                    bookmark.reply,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),

            // Expert Details (only if expert exists and not pending)
            if (!isPending && bookmark.expname.isNotEmpty)
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
                            bookmark.expname,
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
                                '${bookmark.status} Expert',
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
}

class BookmarkedIdea {
  final String id;
  final String description;
  final String date;
  final String reply;
  final String expname;
  final String status;
  final String bookmarkId;

  BookmarkedIdea({
    required this.id,
    required this.description,
    required this.date,
    required this.reply,
    required this.expname,
    required this.status,
    required this.bookmarkId,
  });
}