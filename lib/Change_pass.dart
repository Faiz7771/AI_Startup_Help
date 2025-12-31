import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Changepass extends StatefulWidget {
  const Changepass({super.key});

  @override
  State<Changepass> createState() => _ChangepassState();
}

class _ChangepassState extends State<Changepass> {
  TextEditingController _oldpass=TextEditingController();
  TextEditingController _newpass=TextEditingController();
  TextEditingController _confirmpass=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: Colors.orangeAccent
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children:[
              TextFormField(
                  decoration: InputDecoration(labelText: 'Current Password', hintText: 'Enter your Current Password'), controller: _oldpass,
              ),
              ElevatedButton(onPressed: Send_data, child: const Text("Submit"))
            ]
          )
        )
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
    final uri=Uri.parse('$ipstr/myapp/Changepass/');
    var request=http.MultipartRequest('POST', uri);
    request.fields['login_id']=log_id;
    request.fields['oldpass']= _oldpass.text.trim();
    request.fields['newpass']=_newpass.text.trim();
    request.fields['confirmpass']=_confirmpass.text.trim();
    try{
      var response= await request.send();
      var respStr= await response.stream.bytesToString();
      var data= jsonDecode(respStr);
      if (response.statusCode == 200 && data['status'] == "Password Changed successfully!") {
        Fluttertoast.showToast(msg: "Password Changed successfully!");
      }
    }
    catch(e){
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }
}
