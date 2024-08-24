import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; 
import 'admin_page.dart';

class AdminLoginPage extends StatefulWidget {
  final String location;

  AdminLoginPage({required this.location});

  
  AdminLoginPageState createState() => AdminLoginPageState();
}

class AdminLoginPageState extends State<AdminLoginPage> {
  final userIdController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> login() async {
    final userId = userIdController.text;
    final password = passwordController.text;

    
    showDialog(
      context: context,
       barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          color: Colors.black.withOpacity(0.5),
           child: Center(
            child: Column(
            mainAxisSize: MainAxisSize.min,
              children: [
                SpinKitFoldingCube(
                  color: Colors.pink, 
                  size: 100.0, 
                ),
                SizedBox(height: 16),
                Text(
                  'verifying your credentials',
                  style: TextStyle(color: Colors.white),
                ),],
            ),),
        ),
      ),
    );

    try {
      
      final locationInfo = FirebaseFirestore.instance.collection('locations').doc(widget.location);

      
      await Future.delayed(Duration(seconds: 2)); 

      
      final locationDetails = await locationInfo.get();

      if (locationDetails.exists) {
        final data = locationDetails.data();
        final adminId = data?['Admin_Id'] ?? '';
        final adminPassword = data?['Password'] ?? '';

        
        if (adminId == userId && adminPassword == password) {
          await Future.delayed(Duration(milliseconds: 500)); 
          Navigator.of(context).pop(); 
          Navigator.pushReplacement(
             context,
            MaterialPageRoute(
              builder: (context) => AdminPage(location: widget.location),
            ), );
        } else {
          Navigator.of(context).pop(); 
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid credentials')),
          );
        }
      } else {
        Navigator.of(context).pop(); 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location not found')),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         title: Text('Admin Login'),
      ),
      body:SingleChildScrollView(
        child: Container(
        color: Colors.teal[50],
        padding: const EdgeInsets.all(16.0),
         child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  ),
                ],
                 border: Border.all(
                  color: Colors.teal[700]!,
                  width: 2,
                ),
              ),
              child: TextField(
                controller: userIdController,
                style: TextStyle(color: Colors.teal[800]),
                decoration: InputDecoration(
                  fillColor: Colors.teal[100],
                  filled: true,
                  labelText: 'Admin ID',
                  labelStyle: TextStyle(color: Colors.teal[700]),
                  hintText: 'Enter Admin ID',
                  hintStyle: TextStyle(color: Colors.white),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),


            SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Colors.teal[700]!,
                  width: 2,
                ),
              ),
              child: TextField(
                controller: passwordController,
                 obscureText: true,
                style: TextStyle(color: Colors.teal[800]),
                decoration: InputDecoration(
                  fillColor: Colors.teal[100],
                  filled: true,
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.teal[700]),
                  hintText: 'Enter Password',
                  hintStyle: TextStyle(color: Colors.white),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: login,
              icon: Icon(Icons.login, size: 24),
              label: Text(
                 'Login',
                style: TextStyle(fontSize: 18), ),
            ),

            SizedBox(height:20),
            Container(
                child: Image(
                  image: AssetImage('assets/images/login_image.png'),
                  fit: BoxFit.cover,
                ),),
          ],
        ),
      ),
      ), );
  }
}
