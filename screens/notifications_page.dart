import 'package:flutter/material.dart';
import 'create_document_page.dart'; 

class NotificationsPage extends StatelessWidget {
  final String location;

  NotificationsPage({required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications - $location'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Notifications page for $location'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateDocumentPage()),
                );
              },
              child: Text('Create a Document'),
            ),
          ],
        ),
      ),
    );
  }
}