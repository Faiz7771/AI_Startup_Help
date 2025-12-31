import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Editprof extends StatefulWidget {
  const Editprof({super.key});

  @override
  State<Editprof> createState() => _EditprofState();
}

class _EditprofState extends State<Editprof> {
  TextEditingController _uname = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _place = TextEditingController();
  TextEditingController _district = TextEditingController();
  TextEditingController _state = TextEditingController();
  TextEditingController _phno = TextEditingController();
  TextEditingController _pin = TextEditingController();
  File? img;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit your Profile'),
        backgroundColor: Colors.orangeAccent
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                    labelText: "Username", hintText: "Username"),
                controller: _uname,
              ),
              TextFormField(
                decoration: InputDecoration(
                    labelText: "Email", hintText: "Email"), controller: _email,
              ),
              TextFormField(
                decoration: InputDecoration(
                    labelText: "Place", hintText: "Place"), controller: _place,
              ),
              TextFormField(
                decoration: InputDecoration(
                    labelText: "District", hintText: "District"),
                controller: _district,
              ),
              TextFormField(
                decoration: InputDecoration(
                    labelText: "State", hintText: "State"), controller: _state,
              ),
              ElevatedButton(
                  onPressed: pickimage, child: Text('Choose an Image')),
              TextFormField(
                decoration: InputDecoration(
                    labelText: "Phone Number", hintText: "Phone Number"),
                controller: _phno,
              ),
              TextFormField(
                decoration: InputDecoration(
                    labelText: "Pincode", hintText: "Pincode"),
                controller: _pin,
              ),
              ElevatedButton(onPressed: Send_data, child: Text('Submit'))
            ],
          ),
        ),
      ),
    );
  }
  @override
  void initState(){
    super.initState();
    profiledetails();
  }

  Future<void> profiledetails() async{
    print('hgcfcytf');
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? storedIp = sp.getString('ip');
    String? ipstr = sp.getString('ip');
    String? log_id = sp.getString('l_id');
    final res = await http.post(Uri.parse('$ipstr/myapp/Editprof/'), body: {
      'login_id': log_id
    });
    final data = json.decode(res.body);
    setState(() {
      ipstr = storedIp ?? '';
      _uname.text=data['name'];
      _email.text=data['email'];
      _place.text=data['place'];
      _district.text=data['district'];
      _state.text=data['state'];
      _phno.text=data['phone'];
      _pin.text=data['pin'];
      img=data['photo'];
    });
  }

  Future<void> pickimage() async {
    final pickedimg = await ImagePicker().pickImage(
        source: ImageSource.gallery);
    if (pickedimg != null) {
      setState(() {
        img = File(pickedimg.path);
      });
    }
    else {
      print('Image not detected');
      Fluttertoast.showToast(msg: 'Image not detected!! Select an image.');
    }
  }

  Future<void> Send_data() async{
    SharedPreferences sp=await SharedPreferences.getInstance();
    String? ipstr=sp.getString('ip');
    String log_id=sp.getString('l_id')??"";

    if (ipstr == null){
      Fluttertoast.showToast(msg: "Server URL not found");
      return;
    }
    final uri=Uri.parse('$ipstr/myapp/Editprof_post/');
    var request=http.MultipartRequest('POST', uri);
    request.fields['login_id']=log_id;
    request.fields['name']= _uname.text.trim();
    request.fields['email']= _email.text.trim();
    request.fields['place']= _place.text.trim();
    request.fields['district']= _district.text.trim();
    request.fields['state']= _state.text.trim();
    request.fields['phone']= _phno.text.trim();
    request.fields['pin']= _pin.text.trim();
    if (img != null){
      request.files
          .add(await http.MultipartFile.fromPath('photo', img!.path));
    }
    try{
      var response= await request.send();
      var respStr= await response.stream.bytesToString();
      var data= jsonDecode(respStr);
      if (response.statusCode == 200 && data['status'] == "User details Edited Successfully!") {
        Fluttertoast.showToast(msg: "Customer registered successfully!");
      }
    }
    catch(e){
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }
}
