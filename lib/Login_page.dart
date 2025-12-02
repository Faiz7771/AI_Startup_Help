import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _userctr=TextEditingController();
  TextEditingController _passctr=TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
    body: Center(
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Username', hintText: 'Enter your username'), controller: _userctr,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Password', hintText: 'Enter password'), controller: _passctr,
            ),
            ElevatedButton(onPressed: Send_data, child: const Text('Login'))
          ],
        )

    ),
    );
  }
  Future<void> Send_data() async{
    SharedPreferences sp=await SharedPreferences.getInstance();
    String? ipstr=sp.getString('ip');
    print(ipstr);
    final res= await http.post(Uri.parse('$ipstr/myapp/app_login/'), body: {
      'Username': _userctr.text.trim(),
      'Password': _passctr.text.trim(),
    });

  }
}