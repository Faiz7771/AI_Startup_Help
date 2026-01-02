import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class StudentDetailsPage extends StatefulWidget {
  const StudentDetailsPage({super.key});

  @override
  State<StudentDetailsPage> createState() => _StudentDetailsPageState();
}

class _StudentDetailsPageState extends State<StudentDetailsPage> {
  // Controllers for all fields
  TextEditingController _academicsController = TextEditingController();
  TextEditingController _techSkillsController = TextEditingController();
  TextEditingController _interestsController = TextEditingController();
  TextEditingController _prefIndustryController = TextEditingController();
  TextEditingController _investmentCapController = TextEditingController();

  // Multi-select support for various fields
  List<String> _selectedAcademics = [];
  List<String> _selectedTechSkills = [];
  List<String> _selectedInterests = [];
  List<String> _selectedIndustries = [];

  // Dropdown options
  final List<String> _academicOptions = [
    'High School',
    'Bachelor\'s Degree',
    'Master\'s Degree',
    'PhD',
    'Diploma',
    'Certificate Course',
    'Online Course',
    'Self-Taught',
  ];

  final List<String> _techSkillsOptions = [
    'Python Programming',
    'Machine Learning',
    'Web Development',
    'Mobile App Development',
    'Data Science',
    'Cloud Computing',
    'UI/UX Design',
    'Database Management',
    'Cybersecurity',
    'Blockchain',
    'IoT',
    'AI/ML',
    'DevOps',
  ];

  final List<String> _interestOptions = [
    'Technology Startups',
    'E-commerce',
    'Healthcare Tech',
    'FinTech',
    'EdTech',
    'Green Energy',
    'Social Impact',
    'Gaming',
    'AI Research',
    'Robotics',
  ];

  final List<String> _industryOptions = [
    'Technology',
    'Healthcare',
    'Finance',
    'Education',
    'Retail',
    'Manufacturing',
    'Agriculture',
    'Entertainment',
    'Real Estate',
    'Transportation',
  ];

  final List<String> _investmentOptions = [
    'Less than ₹50,000',
    '₹50,000 - ₹1,00,000',
    '₹1,00,000 - ₹5,00,000',
    '₹5,00,000 - ₹10,00,000',
    '₹10,00,000 - ₹50,00,000',
    'More than ₹50,00,000',
    'Looking for Investors',
  ];

  bool _isSaving = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // No need to fetch existing details
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.shade100,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.school_rounded,
                        color: Colors.orange.shade700,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Complete your academic and professional profile to get personalized startup recommendations',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Academics Section
                _buildSectionHeader(
                  'Academic Qualifications',
                  Icons.book_rounded,
                ),
                const SizedBox(height: 8),
                Text(
                  'Select all that apply',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _academicOptions.map((option) {
                    return FilterChip(
                      label: Text(option),
                      selected: _selectedAcademics.contains(option),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedAcademics.add(option);
                          } else {
                            _selectedAcademics.remove(option);
                          }
                        });
                      },
                      backgroundColor: Colors.grey.shade100,
                      selectedColor: Colors.orange.shade100,
                      checkmarkColor: Colors.orange.shade700,
                      labelStyle: TextStyle(
                        color: _selectedAcademics.contains(option)
                            ? Colors.orange.shade700
                            : Colors.black87,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      side: BorderSide(
                        color: _selectedAcademics.contains(option)
                            ? Colors.orange.shade700
                            : Colors.grey.shade300,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Additional Academic Details (Free Text)
                TextFormField(
                  controller: _academicsController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Additional Academic Details',
                    hintText: 'e.g., Specializations, Awards, Research Papers...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.orange.shade700,
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.note_add_rounded,
                      color: Colors.orange.shade600,
                    ),
                  ),
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 32),

                // Technical Skills Section
                _buildSectionHeader(
                  'Technical Skills',
                  Icons.computer_rounded,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _techSkillsOptions.map((skill) {
                    return FilterChip(
                      label: Text(skill),
                      selected: _selectedTechSkills.contains(skill),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedTechSkills.add(skill);
                          } else {
                            _selectedTechSkills.remove(skill);
                          }
                        });
                      },
                      backgroundColor: Colors.grey.shade100,
                      selectedColor: Colors.orange.shade100,
                      checkmarkColor: Colors.orange.shade700,
                      labelStyle: TextStyle(
                        color: _selectedTechSkills.contains(skill)
                            ? Colors.orange.shade700
                            : Colors.black87,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      side: BorderSide(
                        color: _selectedTechSkills.contains(skill)
                            ? Colors.orange.shade700
                            : Colors.grey.shade300,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Additional Skills (Free Text)
                TextFormField(
                  controller: _techSkillsController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Additional Technical Skills',
                    hintText: 'e.g., Specific frameworks, tools, certifications...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.orange.shade700,
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.code_rounded,
                      color: Colors.orange.shade600,
                    ),
                  ),
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 32),

                // Interests Section
                _buildSectionHeader(
                  'Areas of Interest',
                  Icons.favorite_rounded,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _interestOptions.map((interest) {
                    return FilterChip(
                      label: Text(interest),
                      selected: _selectedInterests.contains(interest),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedInterests.add(interest);
                          } else {
                            _selectedInterests.remove(interest);
                          }
                        });
                      },
                      backgroundColor: Colors.grey.shade100,
                      selectedColor: Colors.orange.shade100,
                      checkmarkColor: Colors.orange.shade700,
                      labelStyle: TextStyle(
                        color: _selectedInterests.contains(interest)
                            ? Colors.orange.shade700
                            : Colors.black87,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      side: BorderSide(
                        color: _selectedInterests.contains(interest)
                            ? Colors.orange.shade700
                            : Colors.grey.shade300,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Additional Interests (Free Text)
                TextFormField(
                  controller: _interestsController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Additional Interests',
                    hintText: 'e.g., Specific technologies, market sectors...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.orange.shade700,
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.explore_rounded,
                      color: Colors.orange.shade600,
                    ),
                  ),
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 32),

                // Preferred Industry Section
                _buildSectionHeader(
                  'Preferred Industry',
                  Icons.business_rounded,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _industryOptions.map((industry) {
                    return FilterChip(
                      label: Text(industry),
                      selected: _selectedIndustries.contains(industry),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedIndustries.add(industry);
                          } else {
                            _selectedIndustries.remove(industry);
                          }
                        });
                      },
                      backgroundColor: Colors.grey.shade100,
                      selectedColor: Colors.orange.shade100,
                      checkmarkColor: Colors.orange.shade700,
                      labelStyle: TextStyle(
                        color: _selectedIndustries.contains(industry)
                            ? Colors.orange.shade700
                            : Colors.black87,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      side: BorderSide(
                        color: _selectedIndustries.contains(industry)
                            ? Colors.orange.shade700
                            : Colors.grey.shade300,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Additional Industry Details
                TextFormField(
                  controller: _prefIndustryController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Specific Industry Interests',
                    hintText: 'e.g., AI in Healthcare, FinTech innovations...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.orange.shade700,
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.work_rounded,
                      color: Colors.orange.shade600,
                    ),
                  ),
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 32),

                // Investment Capacity Section
                _buildSectionHeader(
                  'Investment Capacity',
                  Icons.attach_money_rounded,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _investmentCapController.text.isEmpty
                      ? null
                      : _investmentCapController.text,
                  items: _investmentOptions
                      .map((option) => DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _investmentCapController.text = value ?? '';
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Select Investment Range',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.orange.shade700,
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.orange.shade600,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select investment capacity';
                    }
                    return null;
                  },
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 40),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: _isSaving
                        ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'SAVING...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save_rounded, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          'SAVE STUDENT DETAILS',
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

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.orange.shade700,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      try {
        await _saveStudentDetails();
      } catch (e) {
        Fluttertoast.showToast(msg: "Error: ${e.toString()}");
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _saveStudentDetails() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? ipstr = sp.getString('ip');
    String userId = sp.getString('l_id') ?? "";

    if (ipstr == null) {
      Fluttertoast.showToast(msg: "Server URL not found");
      return;
    }

    // Combine selected items with text fields
    String academics = [
      ..._selectedAcademics,
      _academicsController.text.trim()
    ].where((e) => e.isNotEmpty).join(',');

    String techSkills = [
      ..._selectedTechSkills,
      _techSkillsController.text.trim()
    ].where((e) => e.isNotEmpty).join(',');

    String interests = [
      ..._selectedInterests,
      _interestsController.text.trim()
    ].where((e) => e.isNotEmpty).join(',');

    String prefIndustry = [
      ..._selectedIndustries,
      _prefIndustryController.text.trim()
    ].where((e) => e.isNotEmpty).join(',');

    try {
      final response = await http.post(
        Uri.parse('$ipstr/myapp/save_student_details/'),
        body: {
          'login_id': userId,
          'academics': academics,
          'tech_skills': techSkills,
          'interests': interests,
          'pref_industry': prefIndustry,
          'investment_cap': _investmentCapController.text.trim(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == "success") {
          Fluttertoast.showToast(
            msg: "Student details saved successfully!",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
          );
          Navigator.pop(context);
        } else {
          Fluttertoast.showToast(msg: "Failed to save details");
        }
      }
    } catch (e) {
      print('Error saving student details: $e');
      Fluttertoast.showToast(msg: "Network error occurred");
    }
  }
}