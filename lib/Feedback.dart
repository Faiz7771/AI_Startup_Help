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
  TextEditingController _feedback=TextEditingController();
  List feedback=[];
  List date=[];
  String? ipstr ;

  Future<void> showreplies() async{
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String? storedIp = sp.getString('ip');
      String? ipstr = sp.getString('ip');
      String? log_id = sp.getString('l_id');
      var data = await http.post(Uri.parse('$ipstr/myapp/Feedback_user_post/'), body: {
        'login_id':log_id
      });
      var jsondata = json.decode(data.body);
      var arr = jsondata["data"];
      for (int i = 0; i < arr.length; i++) {
        feedback.add(arr[i]['feedback']??"");
        date.add(arr[i]['date']??"");
      }
      setState(() {
        feedback = feedback;
        date = date;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    showreplies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Send a Feedback'),
        ),
        body: Center(
            child: Column(
              children: [
                const SizedBox(height: 18),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Enter Feedback!✨', hintText: 'Enter Feedback'), controller: _feedback,
                ),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: Send_data, child: const Text("Submit")),
                const SizedBox(height: 30),
                SizedBox(height: 300,width: 800,
                  child: ListView.builder(itemCount: feedback.length ,itemBuilder: (context, index) {return
                    Card(
                      child: Column(
                        children: [
                          Text("Feedback: ${feedback[index]}"),
                          Text("Date: ${date[index]}"),
                        ],
                      ),
                    );} ),
                )
              ],)
        )
    );
  }
  Future<void> Send_data() async{
    SharedPreferences sp=await SharedPreferences.getInstance();
    String? ipstr=sp.getString('ip');
    String log_id=sp.getString('l_id')??"";
    if (ipstr == null){
      Fluttertoast.showToast(msg: "Server URL not found");
      return;
    }
    final uri=Uri.parse('$ipstr/myapp/Feedback_user/');
    var request=http.MultipartRequest('POST', uri);
    request.fields['user_id']=log_id;
    request.fields['feedback']= _feedback.text.trim();
    try{
      var response= await request.send();
      var respStr= await response.stream.bytesToString();
      var data= jsonDecode(respStr);
      if (response.statusCode == 200 && data['status'] == "Feedback Submitted Successfully!") {
        Fluttertoast.showToast(msg: "Feedback Submitted Successfully!");
      }
    }
    catch(e){
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }
}

