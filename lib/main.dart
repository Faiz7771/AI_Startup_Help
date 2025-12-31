// ================================
// main.dart (PROFESSIONAL THEME SETUP)
// ================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Startup Help',
      theme: AppTheme.lightTheme,
      home: const MyHomePage(title: 'Login'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _ipController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isConnecting = false;

  Future<void> sharedpref() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isConnecting = true;
    });

    try {
      final _ipc = _ipController.text.trim();
      SharedPreferences SP = await SharedPreferences.getInstance();
      final url = 'http://$_ipc:8000';
      SP.setString('ip', url);

      // Add a small delay for better UX
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection failed: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  String? _validateIP(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an IP address';
    }

    // Basic IP validation (simple pattern)
    final ipPattern = RegExp(r'^\d{1,3}(\.\d{1,3}){3}$');
    if (!ipPattern.hasMatch(value.trim())) {
      return 'Please enter a valid IP address (e.g., 192.168.1.100)';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "AI STARTUP HELP",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.account_circle, size: 28),
          )
        ],
        elevation: 4,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo/Icon Section
              Container(
                margin: const EdgeInsets.only(bottom: 32),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.wifi_find_rounded,
                  size: 64,
                  color: AppTheme.primaryOrange,
                ),
              ),

              // Title
              const Text(
                'Server Configuration',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              const Text(
                'Enter your server IP address to connect',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Form Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // IP Input Field
                      const Text(
                        'Server IP Address',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _ipController,
                        validator: _validateIP,
                        decoration: InputDecoration(
                          hintText: 'e.g., 192.168.1.100',
                          hintStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: const Icon(
                            Icons.dns_rounded,
                            color: AppTheme.primaryOrange,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.info_outline_rounded,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('IP Address Help'),
                                  content: const Text(
                                    'Enter the IP address of your AI Startup Help server.\n\n'
                                        'Format: XXX.XXX.XXX.XXX\n'
                                        'Port: 8000 (default)\n\n'
                                        'Example: 192.168.1.100',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppTheme.primaryOrange,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        onFieldSubmitted: (_) => sharedpref(),
                      ),

                      const SizedBox(height: 24),

                      // Connection Status & Button
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Connection Button
                          ElevatedButton(
                            onPressed: _isConnecting ? null : sharedpref,
                            child: _isConnecting
                                ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Connecting...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            )
                                : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.link_rounded,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Connect to Server',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withOpacity(0.95),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Help Text
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.blue.shade100,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.help_outline_rounded,
                                  color: Colors.blue.shade600,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Ensure the server is running on port 8000',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Quick Help Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Common IP Addresses:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildIPChip('127.0.0.1', 'Localhost'),
                        _buildIPChip('192.168.1.1', 'Router'),
                        _buildIPChip('10.0.0.1', 'Network'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIPChip(String ip, String label) {
    return ActionChip(
      label: Text('$ip ($label)'),
      onPressed: () {
        _ipController.text = ip;
        if (_formKey.currentState != null) {
          _formKey.currentState!.validate();
        }
      },
      backgroundColor: Colors.white,
      avatar: Icon(
        Icons.copy_all_rounded,
        size: 16,
        color: AppTheme.primaryOrange,
      ),
      side: BorderSide(
        color: Colors.grey.shade300,
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

// ================================
// CENTRALIZED THEME CONFIGURATION
// ================================
class AppTheme {
  static const Color primaryOrange = Color(0xFFFF7B00);
  static const Color black = Colors.black;
  static const Color white = Colors.white;

  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: white,
      primaryColor: primaryOrange,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: primaryOrange,
        foregroundColor: white,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryOrange, width: 1.5),
        ),
      ),
    );
  }
}

// =====================================================
// FLASHCARD STYLE BUTTON (ALTERNATIVE - FILLED BACKGROUND)
// =====================================================
class FlashCardButton extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;

  const FlashCardButton({
    super.key,
    required this.title,
    required this.imagePath,
    required this.onTap,
  });

  // Helper method to abbreviate long titles
  String get _displayTitle {
    // Return abbreviated versions for long titles
    final titleMap = {
      'Issue a Complaint': 'Complaint',
      'Submit Personal Details': 'Submit Details',
      'Look into Trending Ideas': 'Trending Ideas',
      'Request Expert Idea': 'Expert Request',
      'Review and Rate our app✨': 'Rate & Review',
    };

    return titleMap[title] ?? title;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.grey.shade900, // Solid dark background
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Position your logo image on the right side
            Positioned(
              right: 8,
              top: 8,
              bottom: 8,
              child: Container(
                width: 80, // Adjust based on your logo size
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Text on the left side - WITH FLEXIBLE CONTAINER
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              right: 90, // Leave space for logo
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  _displayTitle, // Use abbreviated title
                  style: const TextStyle(
                    color: Color(0xFFFFBB71),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.2, // Better line spacing
                  ),
                  maxLines: 3, // Allow up to 3 lines
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}