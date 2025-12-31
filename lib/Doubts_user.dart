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
  TextEditingController _doubt=TextEditingController();
  List doubt=[];
  List status=[];
  List reply=[];
  List date=[];
  String? ipstr ;

  Future<void> showreplies() async{
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String? storedIp = sp.getString('ip');
      String? ipstr = sp.getString('ip');
      String? log_id = sp.getString('l_id');
      var data = await http.post(Uri.parse('$ipstr/myapp/Doubts_user_post/'), body: {
        'login_id':log_id
      });
      var jsondata = json.decode(data.body);
      var arr = jsondata["data"];
      for (int i = 0; i < arr.length; i++) {
        doubt.add(arr[i]['doubt']??"");
        status.add(arr[i]['status']??"");
        reply.add(arr[i]['reply']??"");
        date.add(arr[i]['date']??"");
      }
      setState(() {
        doubt = doubt;
        status = status;
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
          title: Text('Send a Doubt'),
        ),
        body: Center(
            child: Column(
              children: [
                const SizedBox(height: 18),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Enter Doubt to Expert', hintText: 'Enter Doubt'), controller: _doubt,
                ),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: Send_data, child: const Text("Submit")),
                const SizedBox(height: 30),
                SizedBox(height: 300,width: 800,
                  child: ListView.builder(itemCount: doubt.length ,itemBuilder: (context, index) {return
                    Card(
                      child: Column(
                        children: [
                          Text("doubt: ${doubt[index]}"),
                          Text("status: ${status[index]}"),
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
    final uri=Uri.parse('$ipstr/myapp/Doubts_user/');
    var request=http.MultipartRequest('POST', uri);
    request.fields['user_id']=log_id;
    request.fields['doubt']= _doubt.text.trim();
    try{
      var response= await request.send();
      var respStr= await response.stream.bytesToString();
      var data= jsonDecode(respStr);
      if (response.statusCode == 200 && data['status'] == "Doubt Submitted Successfully!") {
        Fluttertoast.showToast(msg: "Doubt Submitted Successfully!");
      }
    }
    catch(e){
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }
}
