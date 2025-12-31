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
  TextEditingController _complaint=TextEditingController();
  List complaint=[];
  List reply=[];
  List date=[];
  String? ipstr ;

  Future<void> showreplies() async{
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String? storedIp = sp.getString('ip');
      String? ipstr = sp.getString('ip');
      String? log_id = sp.getString('l_id');
      var data = await http.post(Uri.parse('$ipstr/myapp/Complaints_user_post/'), body: {
        'login_id':log_id
      });
      var jsondata = json.decode(data.body);
      var arr = jsondata["data"];
      for (int i = 0; i < arr.length; i++) {
        complaint.add(arr[i]['complaint']??"");
        reply.add(arr[i]['reply']??"");
        date.add(arr[i]['date']??"");
      }
      setState(() {
        complaint = complaint;
        reply = reply;
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
          title: Text('Send a Complaint'),
        ),
        body: Center(
            child: Column(
              children: [
                const SizedBox(height: 18),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Enter Complaint', hintText: 'Enter Complaint'), controller: _complaint,
                ),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: Send_data, child: const Text("Submit")),
                const SizedBox(height: 30),
                SizedBox(height: 300,width: 800,
                  child: ListView.builder(itemCount: complaint.length ,itemBuilder: (context, index) {return
                    Card(
                      child: Column(
                        children: [
                          Text("Complaint: ${complaint[index]}"),
                          Text("Reply: ${reply[index]}"),
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
    final uri=Uri.parse('$ipstr/myapp/Complaints_user/');
    var request=http.MultipartRequest('POST', uri);
    request.fields['user_id']=log_id;
    request.fields['complaints']= _complaint.text.trim();
    try{
      var response= await request.send();
      var respStr= await response.stream.bytesToString();
      var data= jsonDecode(respStr);
      if (response.statusCode == 200 && data['status'] == "Complaint Submitted Successfully!") {
        Fluttertoast.showToast(msg: "Complaint Submitted Successfully!");
      }
    }
    catch(e){
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }
}
