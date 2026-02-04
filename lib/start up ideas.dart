import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Cyberpunk Blue Theme Design System
class AppColors {
  // New Blue Theme Colors
  static const Color primaryBlue = Color(0xFF00D4FF); // Electric Blue
  static const Color primaryCyan = Color(0xFF00FFFF); // Neon Cyan
  static const Color primaryDarkBlue = Color(0xFF0066FF); // Deep Blue
  static const Color darkBackground = Color(0xFF0A0A1A); // Dark Space Blue
  static const Color darkSurface = Color(0xFF121230); // Darker Blue Surface
  static const Color accentNeon = Color(0xFF00FF9D); // Neon Green/Teal
  static const Color glassWhite = Color(0x0DFFFFFF);
  static const Color glassBorder = Color(0x1EFFFFFF);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFCCCCFF); // Light Blue Tint
  static const Color textMuted = Color(0xFF8888AA);
  static const Color successGreen = Color(0xFF00FF88);
  static const Color errorRed = Color(0xFFFF006E); // Hot Pink
  static const Color warningYellow = Color(0xFFFFE600); // Neon Yellow
  static const Color infoCyan = Color(0xFF00FFFF);
  static const Color purpleAccent = Color(0xFF9D4EDD); // Purple for contrast
}

class GlassEffects {
  static Widget buildGlassCard({
    required Widget child,
    double borderRadius = 20,
    double blur = 20,
    Color color = AppColors.glassWhite,
    Color borderColor = AppColors.glassBorder,
    EdgeInsets padding = const EdgeInsets.all(20),
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }

  static Widget buildGlassButton({
    required String text,
    required VoidCallback onPressed,
    bool isPrimary = true,
    double width = double.infinity,
    bool isLoading = false,
    IconData? icon,
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        gradient: isPrimary ? LinearGradient(
          colors: const [AppColors.primaryDarkBlue, AppColors.primaryBlue, AppColors.primaryCyan],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ) : null,
        borderRadius: BorderRadius.circular(16),
        border: !isPrimary ? Border.all(color: AppColors.primaryBlue, width: 2) : null,
        boxShadow: isPrimary ? [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.6),
            blurRadius: 15,
            spreadRadius: 3,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppColors.accentNeon.withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0.3,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NeuralBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Main grid lines - now in blue
    final gridPaint = Paint()
      ..color = AppColors.primaryBlue.withOpacity(0.1)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Neon accent lines
    final neonPaint = Paint()
      ..color = AppColors.accentNeon.withOpacity(0.08)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final path = Path();
    final nodes = 15;
    final spacing = size.width / nodes;

    // Draw grid
    for (int i = 0; i <= nodes; i++) {
      for (int j = 0; j <= nodes; j++) {
        final x = i * spacing;
        final y = j * spacing;

        if (i < nodes) {
          path.moveTo(x, y);
          path.lineTo(x + spacing, y);
        }

        if (j < nodes) {
          path.moveTo(x, y);
          path.lineTo(x, y + spacing);
        }
      }
    }
    canvas.drawPath(path, gridPaint);

    // Draw connecting neon lines (diagonal pattern)
    for (int i = 0; i < nodes; i++) {
      for (int j = 0; j < nodes; j++) {
        if ((i + j) % 3 == 0) {
          final x1 = i * spacing;
          final y1 = j * spacing;
          final x2 = (i + 1) * spacing;
          final y2 = (j + 1) * spacing;

          canvas.drawLine(Offset(x1, y1), Offset(x2, y2), neonPaint);
        }
      }
    }

    // Draw nodes/connection points
    for (int i = 0; i <= nodes; i++) {
      for (int j = 0; j <= nodes; j++) {
        final x = i * spacing;
        final y = j * spacing;

        final dotPaint = Paint()
          ..color = AppColors.primaryCyan.withOpacity(0.15)
          ..style = PaintingStyle.fill;

        final glowPaint = Paint()
          ..color = AppColors.primaryCyan.withOpacity(0.05)
          ..style = PaintingStyle.fill;

        // Glow effect
        canvas.drawCircle(Offset(x, y), 4, glowPaint);
        // Main dot
        canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String reply = "";
  bool isLoading = false;
  List<Map<String, dynamic>> messages = [
    {
      'text': 'Hello! I\'m your AI Assistant. How can I help you today?',
      'isUser': false,
      'time': 'Now',
    }
  ];

  Future<void> sendMessage() async {
    final message = _controller.text.trim();
    if (message.isEmpty) return;

    // Add user message
    setState(() {
      messages.add({
        'text': message,
        'isUser': true,
        'time': 'Now',
      });
      isLoading = true;
    });

    _controller.clear();

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? url = prefs.getString("ip");
      String? userId = prefs.getString("l_id");

      if (url == null) {
        throw Exception("Server URL not found");
      }

      final response = await http.post(
        Uri.parse("$url/myapp/chatbot_response/"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'message': message,
          'user_id': userId ?? '1',
        }),
      );

      final data = json.decode(response.body);
      final aiReply = data['reply']?.toString() ?? 'I apologize, but I couldn\'t process your request.';

      setState(() {
        messages.add({
          'text': aiReply,
          'isUser': false,
          'time': 'Now',
        });
        isLoading = false;
      });

      // Scroll to bottom after AI response
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } catch (e) {
      setState(() {
        messages.add({
          'text': 'Error: Failed to get response. Please check your connection and try again.',
          'isUser': false,
          'time': 'Now',
        });
        isLoading = false;
      });
    }
  }

  Widget _buildAnimatedBackground() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topLeft,
              radius: 1.5,
              colors: [
                AppColors.darkBackground,
                Colors.black,
                const Color(0xFF05051A),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        // Blue gradient overlays
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primaryBlue.withOpacity(0.1),
                  Colors.transparent,
                ],
                stops: const [0.1, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          left: -100,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accentNeon.withOpacity(0.08),
                  Colors.transparent,
                ],
                stops: const [0.1, 1.0],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _NeuralBackgroundPainter(),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, int index) {
    final isUser = message['isUser'] as bool;
    final text = message['text'] as String;
    final time = message['time'] as String;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryCyan.withOpacity(0.9),
                    AppColors.primaryDarkBlue.withOpacity(0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryCyan.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 18,
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: isUser
                        ? LinearGradient(
                      colors: [
                        AppColors.primaryDarkBlue.withOpacity(0.8),
                        AppColors.purpleAccent.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                        : LinearGradient(
                      colors: [
                        AppColors.darkSurface.withOpacity(0.9),
                        const Color(0xFF1A1A3A).withOpacity(0.9),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(4),
                      bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
                    ),
                    border: Border.all(
                      color: isUser
                          ? AppColors.primaryBlue.withOpacity(0.4)
                          : AppColors.glassBorder,
                      width: 1,
                    ),
                    boxShadow: [
                      if (isUser)
                        BoxShadow(
                          color: AppColors.primaryBlue.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (isUser)
            const SizedBox(width: 12),
          if (isUser)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryBlue.withOpacity(0.9),
                    AppColors.accentNeon.withOpacity(0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 18,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          _buildAnimatedBackground(),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                GlassEffects.buildGlassCard(
                  borderRadius: 0,
                  blur: 15,
                  color: AppColors.darkSurface.withOpacity(0.7),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.darkSurface.withOpacity(0.5),
                            border: Border.all(
                              color: AppColors.primaryBlue.withOpacity(0.3),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryBlue.withOpacity(0.2),
                                blurRadius: 5,
                                spreadRadius: 1,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            color: AppColors.textWhite,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CYBER ASSISTANT',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                foreground: Paint()
                                  ..shader = LinearGradient(
                                    colors: const [
                                      AppColors.primaryCyan,
                                      AppColors.primaryBlue,
                                      AppColors.accentNeon,
                                    ],
                                    stops: [0.0, 0.5, 1.0],
                                  ).createShader(const Rect.fromLTWH(0, 0, 200, 0)),
                                letterSpacing: 1,
                                shadows: [
                                  Shadow(
                                    color: AppColors.primaryCyan.withOpacity(0.5),
                                    blurRadius: 10,
                                    offset: const Offset(0, 0),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'Neural Network Powered',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.accentNeon.withOpacity(0.15),
                              AppColors.successGreen.withOpacity(0.15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.accentNeon, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentNeon.withOpacity(0.3),
                              blurRadius: 5,
                              spreadRadius: 1,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppColors.accentNeon,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accentNeon.withOpacity(0.8),
                                    blurRadius: 5,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'ONLINE',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.accentNeon,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Chat Messages
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 16, bottom: 80),
                    itemCount: messages.length + (isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < messages.length) {
                        return _buildMessageBubble(messages[index], index);
                      } else {
                        // Typing indicator
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primaryCyan.withOpacity(0.9),
                                      AppColors.primaryDarkBlue.withOpacity(0.9),
                                    ],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.smart_toy,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GlassEffects.buildGlassCard(
                                  borderRadius: 20,
                                  blur: 5,
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildTypingDot(0),
                                      const SizedBox(width: 8),
                                      _buildTypingDot(1),
                                      const SizedBox(width: 8),
                                      _buildTypingDot(2),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ),

                // Input Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.darkSurface.withOpacity(0.9),
                        const Color(0xFF0F0F2A).withOpacity(0.9),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.darkSurface,
                                const Color(0xFF1A1A3A),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3), width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 1,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _controller,
                            style: TextStyle(color: AppColors.textWhite),
                            decoration: InputDecoration(
                              hintText: 'Type your message...',
                              hintStyle: TextStyle(color: AppColors.textMuted),
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  _controller.clear();
                                },
                                icon: Icon(
                                  Icons.clear,
                                  color: AppColors.textMuted,
                                  size: 18,
                                ),
                              ),
                            ),
                            onSubmitted: (_) => sendMessage(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: const [
                              AppColors.primaryDarkBlue,
                              AppColors.primaryBlue,
                              AppColors.primaryCyan,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryBlue.withOpacity(0.6),
                              blurRadius: 10,
                              spreadRadius: 2,
                              offset: const Offset(0, 3),
                            ),
                            BoxShadow(
                              color: AppColors.primaryCyan.withOpacity(0.4),
                              blurRadius: 5,
                              spreadRadius: 1,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: sendMessage,
                          icon: Icon(
                            Icons.send,
                            color: AppColors.textWhite,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 600),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: AppColors.primaryCyan,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryCyan.withOpacity(0.8),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      margin: EdgeInsets.only(bottom: index == 0 ? 0 : 8),
      curve: Curves.easeInOut,
    );
  }
}