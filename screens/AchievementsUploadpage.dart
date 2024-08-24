import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart'; 
import 'dart:io'; 
import 'package:path/path.dart' as path;

class AchievementsUploadPage extends StatefulWidget {
  final String location;

  AchievementsUploadPage({required this.location});

  AchievementsUploadPageState createState() => AchievementsUploadPageState();
}

class AchievementsUploadPageState extends State<AchievementsUploadPage> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  File? _pickedFile;

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
      if (result != null) {
        setState(() {
          _pickedFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      print('Error picking file: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error picking file')));
    }
  }

  Future<void> _uploadFile() async {
    if (_pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No file selected')));
      return;
    }

    try {
      final String fileName = path.basename(_pickedFile!.path);

      
      final Reference storageRef = _storage.ref().child('achievements/${widget.location}/$fileName');
      await storageRef.putFile(_pickedFile!);


      final String fileUrl = await storageRef.getDownloadURL();

      await _firestore.collection('achievements').add({
        'location': widget.location,
        'fileName': fileName,
        'fileUrl': fileUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF uploaded successfully')));
      setState(() {
        _pickedFile = null; 
      });
    } catch (e) {
      print('Error uploading file: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading file')));
    }
  }

  
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Achievements - ${widget.location}'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickFile,
              child: Text('Pick PDF'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.teal,
              ),
            ),
            SizedBox(height: 20),
            _pickedFile != null
                ? Text('Selected File: ${path.basename(_pickedFile!.path)}')
                : Text('No file selected'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadFile,
              child: Text('Upload PDF'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
