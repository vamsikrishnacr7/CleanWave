import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/admin_login_page.dart';
import 'screens/location_selection_page.dart';
//import 'screens/welcome_page.dart'; 

void main() async {
   WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      

      initialRoute: '/location_selection',
      routes: {
        '/location_selection': (context) => LocationSelectionPage(),
      },
    );
  }
}
