import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart';

class CreateDocumentPage extends StatefulWidget {
  _CreateDocumentPageState createState() => _CreateDocumentPageState();
}

class _CreateDocumentPageState extends State<CreateDocumentPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _file;

  Future<void> _createPdf() async {
    final pdf = pw.Document();

    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Text('Document Title: ${_titleController.text}'),
        );
      },
    ));

    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Text('Document Description: ${_descriptionController.text}'),
        );
      },
    ));

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/document.pdf');
    await file.writeAsBytes(await pdf.save());

    setState(() {
      _file = file;
    });
  }

  Future<void> _uploadDocument(BuildContext context) async {
    if (_file != null) {
      try {
        String fileName = basename(_file!.path);
        firebase_storage.Reference storageReference = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('notifications'); 
        await storageReference.putFile(File('')); 
        storageReference = storageReference.child(fileName);
        firebase_storage.UploadTask uploadTask = storageReference.putFile(_file!);

        await uploadTask.whenComplete(() async {
          String downloadURL = await storageReference.getDownloadURL();

          
          await FirebaseFirestore.instance.collection('notifications').add({
            'message': 'New document created: ${_titleController.text}',
            'fileURL': downloadURL,
            'timestamp': FieldValue.serverTimestamp(),
          });

          
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Document uploaded successfully!')));
        });
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading document: $error')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please create a document first')));
    }
  }

  
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Document'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Document Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Document Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createPdf,
              child: Text('Generate PDF'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _uploadDocument(context),
              child: Text('Upload PDF to Firebase'),
            ),
          ],
        ),
      ),
    );
  }
}