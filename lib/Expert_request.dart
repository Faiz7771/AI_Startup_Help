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
  TextEditingController _request=TextEditingController();
  List description=[];
  List date=[];
  List reply=[];
  List expid=[];
  List expname=[];
  String? ipstr ;

  Future<void> showreplies() async{
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String? storedIp = sp.getString('ip');
      String? ipstr = sp.getString('ip');
      String? log_id = sp.getString('l_id');
      var data = await http.post(Uri.parse('$ipstr/myapp/Expert_idea_post/'), body: {
        'login_id':log_id
      });
      var jsondata = json.decode(data.body);
      var arr = jsondata["data"];
      for (int i = 0; i < arr.length; i++) {
        description.add(arr[i]['description']??"");
        date.add(arr[i]['date']??"");
        reply.add(arr[i]['reply']??"");
        expid.add(arr[i]['Expert ID']??"");
        expname.add(arr[i]['Expert Name']??"");
      }

      print('$description wdefleol');
      setState(() {
        description = description;
        date = date;
        reply = reply;
        expid = expid;
        expname = expname;
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
          title: Text('Send an Idea Request to Expert'),
        ),
        body: Center(
        child: Column(
        children: [
          const SizedBox(height: 18),
        TextFormField(
        decoration: InputDecoration(labelText: 'Enter Request to Expert', hintText: 'Enter Request'), controller: _request,
        ),
          const SizedBox(height: 16),
        ElevatedButton(onPressed: Send_data, child: const Text("Submit")),
          const SizedBox(height: 30),
          SizedBox(height: 300,width: 800,
            child: ListView.builder(itemCount: description.length ,itemBuilder: (context, index) {return
            Card(
              child: Column(
                children: [
                  Text("User request: ${description[index]}"),
                  Text("Expert Reply: ${reply[index]}"),
                  Text("Date: ${date[index]}"),
                  if(reply[index].toString().toLowerCase()!='pending')
                    Text("Expert ID: ${expid[index]}"),
                  if(reply[index].toString().toLowerCase()!='pending')
                    Text("Expert Name: ${expname[index]}"),
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
    final uri=Uri.parse('$ipstr/myapp/Expert_idea/');
    var request=http.MultipartRequest('POST', uri);
    request.fields['student_id']=log_id;
    request.fields['description']= _request.text.trim();
    try{
      var response= await request.send();
      var respStr= await response.stream.bytesToString();
      var data= jsonDecode(respStr);
      if (response.statusCode == 200 && data['status'] == "Request Submitted Successfully!") {
        Fluttertoast.showToast(msg: "Request Submitted Successfully!");
      }
    }
    catch(e){
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }
}