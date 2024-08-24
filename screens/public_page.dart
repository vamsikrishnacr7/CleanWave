import 'package:flutter/material.dart';
import 'AchevementsViewPage.dart';
import 'complaints_page.dart';
import 'notifications_page.dart';
import 'education_page.dart';
import 'contributions_page.dart';
import 'workProgress.dart';

class PublicPage extends StatelessWidget {
  final String location;

  PublicPage({required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Public Page - $location',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 27,
        ),
        ),
        
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 94, 167, 227), 
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal[400]!, Colors.orange[300]!], 
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            
          ),
          border: Border.all(
              color: Colors.black,
              width: 5
            ),
        ),
        child: Padding(
          padding:  EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              createButton(
                context,
                'Complaints',
                Icons.report_problem,
                ComplaintsPage(location: location),
                Colors.redAccent,
              ),
           
              createButton(
                context,
                'Sanitation Education',
                Icons.book,
                EducationPage(location: location),
                Color.fromARGB(255, 235, 126, 162),
              ),
              createButton(
                context,
                'Work Progress',
                Icons.work,
                WorkProgressPage(location: location),
                Color.fromARGB(255, 84, 153, 237),
              ),
              createButton(
                context,
                'Contributions',
                Icons.monetization_on,
                ContributionsPage(location: location),
                Colors.orangeAccent,
              ),
              createButton(
                context,
                'Achievements',
                Icons.star,
                AchievementsViewPage(location: location),
                Colors.purpleAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget createButton(BuildContext context, String text, IconData icon, Widget page, Color containerColor) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: containerColor, 
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: containerColor, 
          foregroundColor: Colors.white, 
        ),
        onPressed: () => openPage(context, page),
        icon: Icon(icon, size: 28), 
        label: Text(
          text,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600, 
          ),
        ),
      ),
    );
  }

  void openPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}
