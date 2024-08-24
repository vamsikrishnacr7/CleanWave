import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class VoluntaryActivitiesAdminPage extends StatefulWidget {
  final String location;

    VoluntaryActivitiesAdminPage({required this.location});

  
  VoluntaryActivitiesAdminPageState createState() => VoluntaryActivitiesAdminPageState();
}

class VoluntaryActivitiesAdminPageState extends State<VoluntaryActivitiesAdminPage> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Voluntary Activities - ${widget.location}'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('voluntary_activities')
            .doc(widget.location)
            .collection('forms')
            .snapshots(),
        builder: (context, contributorsList) {
          if (!contributorsList.hasData) {
            return Center(child: CircularProgressIndicator());
           }

          var forms = contributorsList.data!.docs;

          return ListView.builder(
            itemCount: forms.length,
            itemBuilder: (context, index) {
              var form = forms[index];
              var isWorkAssigned = form['work_assigned'] ?? false;

              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                title: Text(form['name'] ?? 'No Name'),
                subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                       Text('Phone: ${form['phone_number'] ?? 'No Phone Number'}'),
                      Text('Dates: ${form['selected_dates'].join(', ')}'),
                      Text('Hours: ${form['hours'] ?? 'Not specified'}'),
                       Text('Work Assigned: ${isWorkAssigned ? 'Yes' : 'No'}'),
                    ], ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.message, color: Colors.blue),
                        onPressed: () {
                          sendmessage(form['phone_number']);
                        },
                        ),
                      IconButton(
                        icon: Icon(Icons.call, color: Color.fromARGB(255, 87, 203, 91)),
                        onPressed: () {
                          makecall(form['phone_number']);
                        },
                        ),
                      IconButton(
                        icon: Icon(isWorkAssigned ? Icons.check_circle : Icons.      radio_button_unchecked),
                          onPressed: () {
                            togglewordassigned(form.id, !isWorkAssigned);
                        },
                      ),],
                     ),
                  ),
                   );
               },
             );
           },
        ),);
          }

  void sendmessage(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) return;

    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: <String, String>{
        'body': 'Hello, thank you for volunteering! lets begin our work',
      },
    );
    if (await canLaunch(smsUri.toString())) {
      await launch(smsUri.toString());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch SMS app')),
      );
    }
     }

  void makecall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) return;

    final Uri callUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunch(callUri.toString())) {
      await launch(callUri.toString());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch phone app')),
      );
    }
  }

  void togglewordassigned(String formId, bool isWorkAssigned) {
    FirebaseFirestore.instance
        .collection('voluntary_activities')
        .doc(widget.location)
        .collection('forms')
        .doc(formId)
        .update({'work_assigned': isWorkAssigned});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isWorkAssigned ? 'Work marked as assigned' : 'Work marked as not assigned')),
    );
  }
}
