import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

class WorkProgressManagement extends StatefulWidget {
  final String location;

  WorkProgressManagement({required this.location});

  
  _WorkProgressManagementState createState() => _WorkProgressManagementState();
}

class _WorkProgressManagementState extends State<WorkProgressManagement> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Work Progress Management - ${widget.location}'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('workprogress')
            .where('location', isEqualTo: widget.location)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No documents found.'));
          }
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text(doc['fileName']),
                  subtitle: Text('Uploaded on: ${doc['timestamp'].toDate()}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'Delete') {
                        await _deleteDocument(doc);
                      } else if (value == 'Update') {
                        await _updateDocument(doc);
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return {'Delete', 'Update'}.map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice),
                        );
                      }).toList();
                    },
                  ),
                  onTap: () async {
                    await _openPDF(doc['fileUrl']);
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadDocument,
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _uploadDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      String fileName = result.files.single.name;
      String filePath = result.files.single.path!;
      
      Reference storageRef = FirebaseStorage.instance
          .ref('workprogress/${widget.location}/$fileName');

      UploadTask uploadTask = storageRef.putFile(File(filePath));
      TaskSnapshot snapshot = await uploadTask;
      String fileUrl = await snapshot.ref.getDownloadURL();
      
      await FirebaseFirestore.instance.collection('workprogress').add({
        'fileName': fileName,
        'fileUrl': fileUrl,
        'location': widget.location,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Document uploaded successfully')),
      );
    }
  }

  Future<void> _deleteDocument(DocumentSnapshot doc) async {
    await FirebaseStorage.instance.refFromURL(doc['fileUrl']).delete();
    await FirebaseFirestore.instance.collection('workprogress').doc(doc.id).delete();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Document deleted successfully')),
    );
  }

  Future<void> _updateDocument(DocumentSnapshot doc) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      String newFileName = result.files.single.name;
      String newFilePath = result.files.single.path!;
      await FirebaseStorage.instance.refFromURL(doc['fileUrl']).delete();
      Reference newStorageRef = FirebaseStorage.instance
          .ref('workprogress/${widget.location}/$newFileName');
      UploadTask uploadTask = newStorageRef.putFile(File(newFilePath));
      TaskSnapshot snapshot = await uploadTask;
      String newFileUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('workprogress')
          .doc(doc.id)
          .update({
        'fileName': newFileName,
        'fileUrl': newFileUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Document updated successfully')),
      );
    }
  }

  Future<void> _openPDF(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
