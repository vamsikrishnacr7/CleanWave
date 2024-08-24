import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; 

class ComplaintsPage extends StatefulWidget {
  final String location;

  ComplaintsPage({required this.location});

  
  ComplaintsPageState createState() => ComplaintsPageState();
}

    class ComplaintsPageState extends State<ComplaintsPage> {
   final TextEditingController complaintController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
   final TextEditingController sublocalityController = TextEditingController();
   final TextEditingController mobileNumberController = TextEditingController();
   final TextEditingController nameController = TextEditingController();
  List<File> images = [];

  final ImagePicker _picker = ImagePicker();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: Text('Submit Complaint - ${widget.location}'),),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
          children: [
              TextField(
                controller: complaintController,
                decoration: InputDecoration(labelText: 'Complaint'),
                maxLines: 3,
              ),
              TextField(
                 controller: streetController,
                decoration: InputDecoration(labelText: 'Street'),
              ),
              TextField(
                controller: sublocalityController,
                decoration: InputDecoration(labelText: 'Sublocality'),
              ),
              TextField(
                controller: mobileNumberController,
                decoration: InputDecoration(labelText: 'Mobile Number'),
                keyboardType: TextInputType.phone,
                ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
             ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: chooseimages,
                child: Text('Add Images'),
               ),
              SizedBox(height: 20.0),
              showimages(),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: submit,
                child: Text('Submit'),
              ),
            ],),
        ),
       ),
      );
         }

  Widget showimages() {
    return images.isEmpty
        ? Text('No images selected.')
            : Wrap(
            spacing: 8.0,
            children: images.map((image) {
              return Stack(
              children: [
                  Image.file(
                    image,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon:
                       Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          images.remove(image);
                        });
                       },
                      ),
                    ), ],
                   );
              }).toList(),
               );
            }

  Future<void> chooseimages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        images = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  void submit() async {
    final complaintText = complaintController.text.trim();
    final street = streetController.text.trim();
     final sublocality = sublocalityController.text.trim();
    final mobileNumber = mobileNumberController.text.trim();
    final name = nameController.text.trim();

    if (complaintText.isEmpty || street.isEmpty || sublocality.isEmpty || mobileNumber.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill all the entries'),
      ));
        return;
    }

    final mobileRegex =RegExp(r'^\d{10}$');
    if (!mobileRegex.hasMatch(mobileNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter a valid 10-digit mobile number!'),
      ));
      return;
    }

      try {
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
                  SpinKitWave(
                    color: Colors.pink, 
                    size: 100.0, 
                  ),
                  SizedBox(height: 16),
                  Text(
                      'Submitting your complaint...',
                    style: TextStyle(color: Colors.white),
                  ), ],
              ),
            ),
           ),
            ),
      );

      await Future.delayed(Duration(seconds: 2));
      
      final addDetails = await FirebaseFirestore.instance.collection('complaints').add({
        'complaint': complaintText,
        'street': street,
        'sublocality': sublocality,
        'location': widget.location,
        'mobile': mobileNumber,
        'name': name,
        'timestamp': FieldValue.serverTimestamp(),
        'resolved': false,
        'images': [], 
      });

      if (images.isNotEmpty) {
        await uploadImages(addDetails.id);
      }

      Navigator.of(context).pop(); 

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Complaint submitted successfully!'),
      ));

      complaintController.clear();
      streetController.clear();
      sublocalityController.clear();
      mobileNumberController.clear();
      nameController.clear();
      setState(() {
        images.clear();
      });
    } catch (e) {
      Navigator.of(context).pop(); 
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error submitting complaint: $e'),
      ));
    }
  }

  Future<void> uploadImages(String complaintId) async {
    try {
      List<String> imageUrls = [];
        final storage = FirebaseStorage.instance;

      for (var image in images) {
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final imagesource = storage.ref().child('complaints/$complaintId/$fileName');
        await imagesource.putFile(image);
        final imageUrl = await imagesource.getDownloadURL();
        imageUrls.add(imageUrl);
      }

      print('Uploaded image URLs: $imageUrls');

      await FirebaseFirestore.instance.collection('complaints').doc(complaintId).update({
        'images': imageUrls,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error uploading images: $e'),
      ));
    }
    }
  }
