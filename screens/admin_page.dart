import 'package:flutter/material.dart';
import 'AchievementsUploadpage.dart';
import 'complaints_admin_page.dart';
import 'notifications_page.dart';
import 'contributions_admin_page.dart';
import 'voluntary_activities_admin_page.dart';
import 'resources_page.dart';
import 'workprogressManagement.dart';

class AdminPage extends StatelessWidget {
  final String location;

  AdminPage({required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin Page - $location',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            shrinkWrap: true, 
            physics: NeverScrollableScrollPhysics(), 
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            children: [
              createCard(
                context,
                'Manage Complaints',
                ComplaintsAdminPage(location: location),
                Icons.report_problem,
              ),
              createCard(
                context,
                'Manage Contributions',
                ContributionsAdminPage(location: location),
                Icons.attach_money,
              ),
              createCard(
                context,
                'Manage Archives',
                AchievementsUploadPage(location: location),
                Icons.archive,
              ),
              createCard(
                context,
                'Manage Voluntary Activities',
                VoluntaryActivitiesAdminPage(location: location),
                Icons.volunteer_activism,
              ),
              createCard(
                context,
                'Work Progress Management',
                WorkProgressManagement(location: location),
                Icons.work,
              ),
              createCard(
                context,
                'Upload Resources',
                ResourcePage(location: location),
                Icons.upload,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget createCard(BuildContext context, String title, Widget page, IconData icon) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: Colors.black),
              SizedBox(height: 8),
              Text(title,textAlign: TextAlign.center,style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
