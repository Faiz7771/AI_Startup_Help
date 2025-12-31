import 'package:ai_startup_help/Change_pass.dart';
import 'package:ai_startup_help/Edit_Profile.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class manage_prof extends StatefulWidget {
  const manage_prof({super.key});

  @override
  State<manage_prof> createState() => _Manage_profState();
}

class _Manage_profState extends State<manage_prof> {
  String? name;
  String? email;
  String? place;
  String? district;
  String? state;
  String? phone;
  String? pin;
  String? photo;
  String? ipstr ;

  Future<void> myprofile() async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? storedIp = sp.getString('ip');
    ipstr = sp.getString('ip');
    String? log_id = sp.getString('l_id');
    final res = await http.post(Uri.parse('$ipstr/myapp/manage_profile/'), body: {
      'login_id': log_id
    });
    final data = json.decode(res.body);
    setState(() {
      ipstr = storedIp ?? '';
      name=data['name'];
      email=data['email'];
      place=data['place'];
      district=data['district'];
      state=data['state'];
      phone=data['phone'];
      pin=data['pin'];
      photo=data['photo'];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myprofile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Profile'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Image.network('$ipstr$photo'),
              Text("Name: $name"),
              Text("Email: $email"),
              Text("Place: $place"),
              Text("District: $district"),
              Text("State: $state"),
              Text("Phone: $phone"),
              Text("Pin: $pin"),
              ElevatedButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=> Editprof()));
              }, child: const Text("Edit Details")),
              TextButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=> Changepass()));
              }, child: const Text("Change Password"))
            ],
          ),
        ),
      ),
    );
  }
}
