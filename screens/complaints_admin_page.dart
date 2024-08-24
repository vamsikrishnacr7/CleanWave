import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ComplaintsAdminPage extends StatelessWidget {
final String location;

  ComplaintsAdminPage({required this.location});

  
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complaints - $location'),
      ),
      body: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
              .collection('complaints')
              .where('location', isEqualTo: location)
             .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, complaintsbox) {
          if (complaintsbox.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
           }
          if (complaintsbox.hasError) {
            return Center(child: Text('Error: ${complaintsbox.error}'));
            }
          if (!complaintsbox.hasData || complaintsbox.data!.docs.isEmpty) {
            return Center(child: Text('No complaints available.'));
           }

          final complaints = complaintsbox.data!.docs;

          return ListView.builder(
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final complaint = complaints[index];
              final complaintId = complaint.id;
              final complaintText = complaint['complaint'] ?? 'No complaint';
              final street = complaint['street'] ?? 'No street';
              final sublocality = complaint['sublocality'] ?? 'No sublocality';
              final mobile = complaint['mobile'] ?? 'No mobile';
              final name = complaint['name'] ?? 'No name';
              final imageUrls = List<String>.from(complaint['images'] ?? []);
              final bool isResolved = complaint['resolved'] ?? false;

              return ListTile(
  title: Text('Complaint from $name'),
  subtitle: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
  Text('Complaint: $complaintText'),
 Text('Street: $street'),
 Text('Sublocality: $sublocality'),
  Text('Mobile: $mobile'),
      SizedBox(height: 10),
                      Wrap(
                      spacing: 10.0,
                      runSpacing: 10.0,
                      children: imageUrls
                          .map((imageUrl) => GestureDetector(
                                onTap: () => openimage(imageUrl),
                                child: Image.network(
                                  imageUrl,
                                   width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ))
                        .toList(),),
                    ],
                      ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: 
                      Icon(Icons.message, color: Colors.blue), 
                      onPressed: () => _openSmsApp(context, mobile),
                    ),
                    Switch(
                      value: isResolved,
                      onChanged: (value) {
                        changeresolved(context, complaintId, isResolved);
                      },
                        ),
                    ],),);
                },
                   );
               },
             ),);
          }

  void openimage(String imageUrl) {
    launch(imageUrl);
  }

  void _openSmsApp(BuildContext context, String mobile) async {
    final smsUri = Uri(
       scheme: 'sms',
        path: mobile,
    );

    try {
      if (await canLaunch(smsUri.toString())) {
        await launch(smsUri.toString());

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to open messages app')),
        );
       }
    } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening messaging app: $e')),
      );
     }
     }

  void changeresolved(BuildContext context, String complaintId, bool currentStatus) async {
    final messenger = ScaffoldMessenger.of(context);

    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete this complaint?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Yes'),
          ),],
         ),
        );

    if (shouldDelete == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SpinKitCircle(
                 color: Colors.blue,
                 size: 50.0,
              ),
              SizedBox(height: 20),
              Text('Deleting complaint...'),
            ],
           ),),
          );

      await Future.delayed(Duration(seconds: 2));

      try {
        await FirebaseFirestore.instance.collection('complaints').doc(complaintId).delete();
        Navigator.of(context).pop();
        messenger.showSnackBar(SnackBar(
          content: Text('Complaint deleted successfully!'),
        ));
      } catch (e) {
        Navigator.of(context).pop();
        messenger.showSnackBar(SnackBar(
          content: Text('Error deleting complaint: $e'),
        ));
      }
      }
   }
    }
