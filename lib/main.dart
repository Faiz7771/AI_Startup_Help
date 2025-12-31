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

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _ipController= TextEditingController();
  Future<void> sharedpref() async{
    final _ipc=_ipController.text.trim();
    SharedPreferences SP= await SharedPreferences.getInstance();
    final url= 'http://$_ipc:8000';
    final img_url = 'http://$_ipc:8000';
    SP.setString('ip', url);
    Navigator.push(context, MaterialPageRoute(builder: (context)=>Login()));
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("AI STARTUP HELP"),
        actions: [IconButton(onPressed: (){}, icon: Icon(Icons.account_circle))],
        elevation: 4,

      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: SingleChildScrollView(
            child: Column(
              children: [
                Text('Enter ip address :'),
                const SizedBox(height: 18),
                TextFormField(
                    controller: _ipController,
                    decoration: InputDecoration(labelText: 'ip', hintText: 'ip')),
                const SizedBox(height: 18),
                ElevatedButton(onPressed: sharedpref, child: Text('Connect'))
              ],
            )
        ),
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
// FLASHCARD STYLE BUTTON (FOR FUTURE HOMEPAGE UI)
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100, // increase from ~140
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          image: DecorationImage(
            image: AssetImage(imagePath),
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.45),
              BlendMode.darken,
            ),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFFFFBB71),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================
// RESPONSIVE GRID USAGE EXAMPLE (HOMEPAGE)
// =====================================================
/*
GridView.count(
  crossAxisCount: MediaQuery.of(context).size.width < 400 ? 1 : 2,
  crossAxisSpacing: 16,
  mainAxisSpacing: 16,
  padding: const EdgeInsets.all(16),
  children: [
    FlashCardButton(
      title: 'Ask Doubts',
      imagePath: 'assets/doubts.jpg',
      onTap: () {},
    ),
    FlashCardButton(
      title: 'Experts',
      imagePath: 'assets/experts.jpg',
      onTap: () {},
    ),
  ],
);
*/

