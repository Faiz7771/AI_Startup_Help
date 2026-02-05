import 'dart:convert';
import 'package:ai_startup_help/Complaints_user.dart';
import 'package:ai_startup_help/Details.dart';
import 'package:ai_startup_help/Doubts_user.dart';
import 'package:ai_startup_help/Expert_request.dart';
import 'package:ai_startup_help/Feedback.dart';
import 'package:ai_startup_help/Manage_profile.dart';
import 'package:ai_startup_help/Review_rating.dart';
import 'package:ai_startup_help/bookmark_page.dart';
import 'package:ai_startup_help/main.dart';
import 'package:ai_startup_help/start%20up%20ideas.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
// import 'chat ai.dart';


class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  String img = '';
  String? ipstr = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    getdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          // Notification Bell Icon
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsPage()),
              );
            },
            icon: Icon(Icons.notifications),
            tooltip: 'Notifications',
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => manage_prof()),
              );
            },
            icon: _isLoading
                ? SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              backgroundImage: img.isNotEmpty && ipstr != null
                  ? NetworkImage('$ipstr/$img')
                  : null,
              child: img.isEmpty
                  ? Icon(Icons.person, color: Colors.orange.shade700, size: 20)
                  : null,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: Colors.orange.shade700,
        ),
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Welcome Section
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.shade100),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.rocket_launch_rounded,
                      size: 60,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Welcome to AI Startup Help',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your entrepreneurial journey starts here',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // FlashCardButtons in Grid Layout
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.6, // Adjusted for FlashCardButton aspect
                children: [
                  FlashCardButton(
                    title: 'Get a Startup Idea',
                    imagePath: 'assets/Idea.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChatbotPage()),
                      );
                    },
                  ),
                  FlashCardButton(
                    title: 'Submit Personal Details',
                    imagePath: 'assets/Details.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => StudentDetailsPage()),
                      );
                    },
                  ),
                  FlashCardButton(
                    title: 'Request Expert Idea',
                    imagePath: 'assets/Expert.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Expert_idea()),
                      );
                    },
                  ),
                  FlashCardButton(
                    title: 'Ask Doubts',
                    imagePath: 'assets/Doubt.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Doubt()),
                      );
                    },
                  ),
                  FlashCardButton(
                    title: 'Issue a Complaint',
                    imagePath: 'assets/Complaint.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Complaints()),
                      );
                    },
                  ),
                  FlashCardButton(
                    title: 'Send Feedback',
                    imagePath: 'assets/Feedback.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Feedbackuser()),
                      );
                    },
                  ),
                  FlashCardButton(
                    title: 'Review and Rate our app✨',
                    imagePath: 'assets/Review.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Review()),
                      );
                    },
                  ),
                  FlashCardButton(
                    title: 'Saved Ideas',
                    imagePath: 'assets/bookmark.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BookmarkPage()),
                      );
                    },
                  ),
                ],
              ),

              // Spacing at bottom
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getdata() async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      ipstr = sp.getString('ip');
      String? storedIp = sp.getString('ip');
      String? log_id = sp.getString('l_id');

      if (log_id == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final res = await http.post(
        Uri.parse('$ipstr/myapp/user_home/'),
        body: {'login_id': log_id},
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        String fetchedImg = data['photo'].toString();
        print('Fetched image: $fetchedImg');

        setState(() {
          ipstr = storedIp ?? '';
          img = fetchedImg;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
}

// ================================
// Add this NotificationsPage class at the end of the file
// ================================

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> notifications = [];
  bool _isLoading = true;
  String? ipstr = '';

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      ipstr = sp.getString('ip');

      final response = await http.get(
        Uri.parse('$ipstr/myapp/get_notifications/'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          notifications = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print('Failed to fetch notifications: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: Colors.orange.shade700,
        ),
      )
          : notifications.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off,
              size: 60,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        color: Colors.orange.shade700,
        onRefresh: fetchNotifications,
        child: ListView.builder(
          padding: EdgeInsets.all(8),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              elevation: 2,
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_active,
                    color: Colors.orange.shade700,
                  ),
                ),
                title: Text(
                  notification['title'] ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    Text(
                      notification['notification'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Date: ${notification['date'] ?? ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          },
        ),
      ),
    );
  }
}