import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController _uname = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _pass = TextEditingController();
  TextEditingController _place = TextEditingController();
  TextEditingController _district = TextEditingController();
  TextEditingController _state = TextEditingController();
  TextEditingController _phno = TextEditingController();
  TextEditingController _pin = TextEditingController();
  File? img;
  bool _obscurePassword = true;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Account"),
        backgroundColor: Colors.orange.shade700,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.person_add_alt_1_rounded,
                        size: 60,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Create New Account',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Join AIStartupHelp community today',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Username Field
                Text(
                  'Username',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.orange.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextFormField(
                    controller: _uname,
                    decoration: InputDecoration(
                      hintText: 'Enter your username',
                      prefixIcon: Icon(Icons.person_outline, color: Colors.orange.shade600),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter username';
                      }
                      return null;
                    },
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),

                // Email Field
                Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.orange.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Enter your email address',
                      prefixIcon: Icon(Icons.email_outlined, color: Colors.orange.shade600),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),

                // Password Field
                Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.orange.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextFormField(
                    controller: _pass,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      prefixIcon: Icon(Icons.lock_outline, color: Colors.orange.shade600),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: Colors.grey.shade600,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),

                // Address Fields (2 columns for Place/District)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Place',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.orange.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: TextFormField(
                              controller: _place,
                              decoration: InputDecoration(
                                hintText: 'Enter place',
                                prefixIcon: Icon(Icons.location_city_outlined, color: Colors.orange.shade600),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter place';
                                }
                                return null;
                              },
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'District',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.orange.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: TextFormField(
                              controller: _district,
                              decoration: InputDecoration(
                                hintText: 'Enter district',
                                prefixIcon: Icon(Icons.map_outlined, color: Colors.orange.shade600),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter district';
                                }
                                return null;
                              },
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // State Field
                Text(
                  'State',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.orange.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextFormField(
                    controller: _state,
                    decoration: InputDecoration(
                      hintText: 'Enter state',
                      prefixIcon: Icon(Icons.public_outlined, color: Colors.orange.shade600),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter state';
                      }
                      return null;
                    },
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),

                // Image Picker
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.photo_library_outlined, color: Colors.orange.shade600),
                    title: Text(
                      img == null ? 'Choose Profile Picture' : 'Image Selected',
                      style: TextStyle(
                        color: img == null ? Colors.grey.shade600 : Colors.green.shade700,
                      ),
                    ),
                    subtitle: img != null ? Text(img!.path.split('/').last) : null,
                    trailing: img != null
                        ? Icon(Icons.check_circle, color: Colors.green.shade600)
                        : Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade600),
                    onTap: pickimage,
                  ),
                ),
                const SizedBox(height: 16),

                // Phone Number Field
                Text(
                  'Phone Number',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.orange.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextFormField(
                    controller: _phno,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Enter phone number',
                      prefixIcon: Icon(Icons.phone_outlined, color: Colors.orange.shade600),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter phone number';
                      }
                      if (value.length < 10) {
                        return 'Please enter valid phone number';
                      }
                      return null;
                    },
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),

                // Pincode Field
                Text(
                  'Pincode',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.orange.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextFormField(
                    controller: _pin,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter pincode',
                      prefixIcon: Icon(Icons.location_on_outlined, color: Colors.orange.shade600),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter pincode';
                      }
                      if (value.length != 6) {
                        return 'Pincode must be 6 digits';
                      }
                      return null;
                    },
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 30),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () {
                      if (_formKey.currentState!.validate()) {
                        Send_data();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.app_registration_rounded, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          'CREATE ACCOUNT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Terms and Conditions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'By creating an account, you agree to our Terms of Service and Privacy Policy',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> pickimage() async {
    final pickedimg = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedimg != null) {
      setState(() {
        img = File(pickedimg.path);
      });
      Fluttertoast.showToast(msg: 'Image selected successfully!');
    } else {
      Fluttertoast.showToast(msg: 'No image selected.');
    }
  }

  Future<void> Send_data() async {
    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String? ipstr = sp.getString('ip');
      if (ipstr == null) {
        Fluttertoast.showToast(msg: "Server URL not found");
        return;
      }

      final uri = Uri.parse('$ipstr/myapp/register_page/');
      var request = http.MultipartRequest('POST', uri);

      // Add text fields
      request.fields['name'] = _uname.text.trim();
      request.fields['email'] = _email.text.trim();
      request.fields['password'] = _pass.text.trim();
      request.fields['place'] = _place.text.trim();
      request.fields['district'] = _district.text.trim();
      request.fields['state'] = _state.text.trim();
      request.fields['phone'] = _phno.text.trim();
      request.fields['pin'] = _pin.text.trim();

      // Add image file if selected
      if (img != null) {
        request.files.add(await http.MultipartFile.fromPath('photo', img!.path));
      }

      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (response.statusCode == 200) {
        if (data['status'] == "Customer registered successfully!") {
          Fluttertoast.showToast(msg: "Registration successful!");
          await Future.delayed(Duration(seconds: 1));
          Navigator.pop(context); // Go back to login page
        } else if (data['status'] == "User already exists!") {
          Fluttertoast.showToast(msg: "User already exists!");
        } else {
          Fluttertoast.showToast(msg: "Registration failed!");
        }
      } else {
        Fluttertoast.showToast(msg: "Server error: ${response.statusCode}");
      }
    } catch (e) {
      print('Registration error: $e');
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}