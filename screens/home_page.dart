import 'package:flutter/material.dart';

import 'public_page.dart';
import 'admin_login_page.dart'; 
import 'location_selection_page.dart'; 

class HomePage extends StatelessWidget {
  final String location;

  HomePage({required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(

        title: Text('CLEAN WAVE',
         style: TextStyle(
           fontSize:27,
          fontWeight: FontWeight.w800,),

        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(210, 238, 236, 236),

      ),
      body: Stack(
        children: [
          
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                image: AssetImage('assets/images/water_homepage.jpg'), 
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.1), 
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Text(
                    'Welcome to CleanWave',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color:  Color.fromARGB(255, 8, 244, 15),
                    ),
                  ),
                  SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PublicPage(location: location),
                        ),
                      );
                    },
                    icon: Icon(Icons.people),
                    label: Text('Public User'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      minimumSize: Size(200, 50),
                      textStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                      ),
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminLoginPage(location: location),
                        ),
                      );
                    },
                    icon: Icon(Icons.shield),
                    label: Text('Admin'),
                    style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                       minimumSize: Size(200, 50),
                      textStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w300,),
                      backgroundColor: Colors.deepOrange,
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.tealAccent.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start, 
                          children: [
                            Text(
                              'Current Location:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              location,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.location_on),
                           color: Colors.red,
                            onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LocationSelectionPage(),
                              ),);},
                        ), ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}