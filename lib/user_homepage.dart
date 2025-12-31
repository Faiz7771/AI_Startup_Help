import 'dart:convert';
import 'package:ai_startup_help/Complaints_user.dart';
import 'package:ai_startup_help/Details.dart';
import 'package:ai_startup_help/Doubts_user.dart';
import 'package:ai_startup_help/Expert_request.dart';
import 'package:ai_startup_help/Feedback.dart';
import 'package:ai_startup_help/Manage_profile.dart';
import 'package:ai_startup_help/Review_rating.dart';
import 'package:ai_startup_help/Trend_idea.dart';
import 'package:ai_startup_help/get_idea.dart';
import 'package:ai_startup_help/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  String img = '';
  String? ipstr = '';
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
        backgroundColor: Colors.black87,
        actions: [
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> manage_prof()));
          },
            icon: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              backgroundImage: img.isNotEmpty
                  ? NetworkImage('$ipstr/$img')
                  : null,
              child: img.isEmpty
                  ? const Icon(Icons.person, color: Colors.grey)
                  : null,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
            child: Column(
              children: [
                const SizedBox(height: 16),
                FlashCardButton(
                  title: 'Get a Startup Idea',
                  imagePath: 'assets/Idea.png',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> Ideas()));
                  },
                ),
                const SizedBox(height: 16),
                FlashCardButton(
                  title: 'Submit Personal Details',
                  imagePath: 'assets/Details.png',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> Details()));
                  },
                ),
                const SizedBox(height: 16),
                FlashCardButton(
                  title: 'Look into Trending Ideas',
                  imagePath: 'assets/Trending.png',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> Trending()));
                  },
                ),
                const SizedBox(height: 16),
                FlashCardButton(
                  title: 'Request Expert Idea',
                  imagePath: 'assets/Expert.png',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> Expert_idea()));
                  },
                ),
                const SizedBox(height: 16),
                FlashCardButton(
                  title: 'Ask Doubts',
                  imagePath: 'assets/Doubt.png',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> Doubt()));
                  },
                ),
                const SizedBox(height: 16),
                FlashCardButton(
                  title: 'Issue a Complaint',
                  imagePath: 'assets/Complaint.png',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> Complaints()));
                  },
                ),
                const SizedBox(height: 16),
                FlashCardButton(
                  title: 'Send Feedback',
                  imagePath: 'assets/Feedback.png',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> Feedbackuser()));
                  },
                ),
                const SizedBox(height: 16),
                FlashCardButton(
                  title: 'Review and Rate our app✨',
                  imagePath: 'assets/Review.png',

                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> Review()));
                  },
                ),
              ],
            )
        ),
      )
    );
  }

  Future<void> getdata() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    ipstr = sp.getString('ip');
    String? storedIp = sp.getString('ip');
    String? log_id = sp.getString('l_id');
    final res = await http.post(Uri.parse('$ipstr/myapp/user_home/'), body: {
      'login_id': log_id
    });
    final data = json.decode(res.body);

    String fetchedImg = data['photo'].toString();
    print('adfdf$fetchedImg');

    setState(() {
      ipstr = storedIp ?? '';
      img = fetchedImg;
    });
  }
}


