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
  bool _isLoading = true;
  String? _profileImageUrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    profiledetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: Colors.orange.shade700,
        ),
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Profile Picture Section
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.orange.shade300,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: img != null
                                  ? Image.file(
                                img!,
                                fit: BoxFit.cover,
                              )
                                  : _profileImageUrl != null
                                  ? Image.network(
                                _profileImageUrl!,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                          : null,
                                      color: Colors.orange.shade700,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.orange.shade700,
                                  );
                                },
                              )
                                  : Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.orange.shade700,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              child: IconButton(
                                onPressed: pickimage,
                                icon: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tap camera icon to change photo',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Username Field
                _buildLabel('Username'),
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
                      prefixIcon: Icon(Icons.person_outline,
                          color: Colors.orange.shade600),
                      border: InputBorder.none,
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
                _buildLabel('Email'),
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
                      hintText: 'Enter your email',
                      prefixIcon: Icon(Icons.email_outlined,
                          color: Colors.orange.shade600),
                      border: InputBorder.none,
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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

                // Address Fields (2 columns)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Place'),
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
                                prefixIcon: Icon(Icons.location_city_outlined,
                                    color: Colors.orange.shade600),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 18),
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
                          _buildLabel('District'),
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
                                prefixIcon: Icon(Icons.map_outlined,
                                    color: Colors.orange.shade600),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 18),
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
                _buildLabel('State'),
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
                      prefixIcon: Icon(Icons.public_outlined,
                          color: Colors.orange.shade600),
                      border: InputBorder.none,
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
                const SizedBox(height: 16),

                // Phone Number Field
                _buildLabel('Phone Number'),
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
                      prefixIcon:
                      Icon(Icons.phone_outlined, color: Colors.orange.shade600),
                      border: InputBorder.none,
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
                _buildLabel('Pincode'),
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
                      prefixIcon: Icon(Icons.location_on_outlined,
                          color: Colors.orange.shade600),
                      border: InputBorder.none,
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save_rounded, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          'SAVE CHANGES',
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.orange.shade700,
        ),
      ),
    );
  }

  Future<void> profiledetails() async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String? storedIp = sp.getString('ip');
      String? log_id = sp.getString('l_id');

      if (log_id == null || storedIp == null) {
        throw Exception('Login information not found');
      }

      final res = await http.post(
        Uri.parse('$storedIp/myapp/Editprof/'),
        body: {'login_id': log_id},
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          _uname.text = data['name'] ?? '';
          _email.text = data['email'] ?? '';
          _place.text = data['place'] ?? '';
          _district.text = data['district'] ?? '';
          _state.text = data['state'] ?? '';
          _phno.text = data['phone'] ?? '';
          _pin.text = data['pin'] ?? '';

          // Store the profile image URL from backend
          String photoPath = data['photo']?.toString() ?? '';
          if (photoPath.isNotEmpty) {
            _profileImageUrl = '$storedIp/$photoPath';
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      Fluttertoast.showToast(msg: "Failed to load profile details");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> pickimage() async {
    final pickedimg = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedimg != null) {
      setState(() {
        img = File(pickedimg.path);
      });
      Fluttertoast.showToast(msg: 'Profile picture selected');
    } else {
      Fluttertoast.showToast(msg: 'No image selected');
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      await Send_data();
    }
  }

  Future<void> Send_data() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? ipstr = sp.getString('ip');
    String log_id = sp.getString('l_id') ?? "";

    if (ipstr == null) {
      Fluttertoast.showToast(msg: "Server URL not found");
      return;
    }

    try {
      final uri = Uri.parse('$ipstr/myapp/Editprof_post/');
      var request = http.MultipartRequest('POST', uri);
      request.fields['login_id'] = log_id;
      request.fields['name'] = _uname.text.trim();
      request.fields['email'] = _email.text.trim();
      request.fields['place'] = _place.text.trim();
      request.fields['district'] = _district.text.trim();
      request.fields['state'] = _state.text.trim();
      request.fields['phone'] = _phno.text.trim();
      request.fields['pin'] = _pin.text.trim();

      if (img != null) {
        request.files.add(
            await http.MultipartFile.fromPath('photo', img!.path));
      }

      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (response.statusCode == 200 &&
          data['status'] == "User details Edited Successfully!") {
        Fluttertoast.showToast(msg: "Profile updated successfully!");
        Navigator.pop(context); // Go back to previous screen
      } else {
        Fluttertoast.showToast(msg: "Failed to update profile");
      }
    } catch (e) {
      print('Error updating profile: $e');
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
    }
  }
}