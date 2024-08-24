import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourcePage extends StatefulWidget {
  final String location;

  ResourcePage({required this.location});

  ResourcePageState createState() => ResourcePageState();
}

class ResourcePageState extends State<ResourcePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  File? _documentFile;
  String _title = '';
  String _videoUrl = '';
  bool _showDocuments = true;

  Future<void> _showAddDocumentDialog() async {
    await showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
        return Padding(
           padding: const EdgeInsets.all(16.0),
           child: Column(
          mainAxisSize: MainAxisSize.min,
            children: <Widget>[
            TextField(
                decoration: InputDecoration(labelText: 'Enter document title'),
                onChanged: (value) {
                   setState(() {
                    _title = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
                  if (result != null) {
                     final file = File(result.files.single.path!);
                     setState(() {
                      _documentFile = file;
                    });
                    _showCustomSnackBar('Document selected. Please upload it now.');
                  } else {
                    _showCustomSnackBar('No document selected.');
                  }
                },
                child: Text('Select Document'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_documentFile == null || _title.isEmpty) {
                    _showCustomSnackBar('Please provide both a title and select a document.');
                    return;
                  }

                  final fileName = _documentFile!.uri.pathSegments.last;
                  final fileRef = _storage.ref().child('documents/${widget.location}/$fileName');

                  try {
                    final uploadTask = fileRef.putFile(_documentFile!);
                    await uploadTask;
                    final fileUrl = await fileRef.getDownloadURL();

                    await _firestore.collection('documents').add({
                      'location': widget.location,
                      'fileUrl': fileUrl,
                      'title': _title,
                      'timestamp': FieldValue.serverTimestamp(),
                    });

                    setState(() {
                      _documentFile = null;
                      _title = '';
                    });
                    _showCustomSnackBar('Document uploaded successfully');
                    Navigator.of(context).pop();
                  } catch (e) {
                    print('Error uploading document: $e');
                    _showCustomSnackBar('Failed to upload document.');
                  }
                },
                child: Text('Upload Document'),
              ),],
            ),);
           },
          );
         }

  Future<void> _showAddVideoDialog() async {
    await showModalBottomSheet(
       context: context,
       builder: (BuildContext context) {
      return Padding(
          padding: const EdgeInsets.all(16.0),
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(labelText: 'Enter video title'),
                onChanged: (value) {
                  setState(() {
                    _title = value;
                  });
                },
                ),
              TextField(
                decoration: InputDecoration(labelText: 'YouTube URL'),
                onChanged: (value) {
                  setState(() {
                    _videoUrl = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_title.isEmpty || _videoUrl.isEmpty) {
                    _showCustomSnackBar('Please provide both a title and a YouTube URL.');
                    return;
                   }

                  await _firestore.collection('videos').add({
                    'title': _title,
                    'fileUrl': _videoUrl,
                    'location': widget.location,
                    'timestamp': FieldValue.serverTimestamp(),
                  });

                  setState(() {
                    _title = '';
                    _videoUrl = '';
                  });
                  _showCustomSnackBar('YouTube video URL added successfully');
                  Navigator.of(context).pop();
                },
                child: Text('Add Video URL'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCustomSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resources'),
        backgroundColor: Colors.teal,
        actions: <Widget>[
          IconButton(
            icon: Icon(_showDocuments ? Icons.video_library : Icons.description),
            onPressed: () {
              setState(() {
                _showDocuments = !_showDocuments;
              });
            },
          ),],
      ),
      body: _showDocuments
          ? StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('documents').where('location', isEqualTo: widget.location).snapshots(),
              builder: (context, pdfresult) {
                if (pdfresult.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (pdfresult.hasError) {
                  return Center(child: Text('Error occurred while loading documents. Please try again later.'));
                }
                if (!pdfresult.hasData || pdfresult.data!.docs.isEmpty) {
                  return Center(child: Text('No documents available.'));
                }
                final documentList = pdfresult.data!.docs;
                return ListView.builder(
                  itemCount: documentList.length,
                  itemBuilder: (context, index) {
                    final document = documentList[index];
                    final docId = document.id;
                    final title = document['title'] ?? 'Untitled';
                    final fileUrl = document['fileUrl'] ?? '';

                    return ListTile(
                      title: Text(title),
                      subtitle: Text('No description'),
                      onTap: () {
                        if (fileUrl.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DocumentViewerScreen(url: fileUrl, title: title),
                            ),
                          );
                        }
                      },
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await _firestore.collection('documents').doc(docId).delete();
                          _showCustomSnackBar('Document deleted successfully');
                        },
                      ),
                    );
                  },
                );
              },
            )
          : StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('videos').where('location', isEqualTo: widget.location).snapshots(),
              builder: (context, videoresult) {
                if (videoresult.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (videoresult.hasError) {
                  return Center(child: Text('Error occurred while loading videos. Please try again later.'));
                }
                if (!videoresult.hasData || videoresult.data!.docs.isEmpty) {
                  return Center(child: Text('No videos available.'));
                }
                final videoList = videoresult.data!.docs;
                return ListView.builder(
                  itemCount: videoList.length,
                  itemBuilder: (context, index) {
                    final video = videoList[index];
                    final vidId = video.id;
                    final title = video['title'] ?? 'Untitled';
                    final videoUrl = video['fileUrl'] ?? '';

                    return ListTile(
                      title: Text(title),
                      subtitle: Text('YouTube URL'),
                      onTap: () async {
                        if (await canLaunch(videoUrl)) {
                          await launch(videoUrl);
                        } else {
                          _showCustomSnackBar('Cannot open URL');
                        }
                      },
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          await _firestore.collection('videos').doc(vidId).delete();
                          _showCustomSnackBar('Video deleted successfully');
                        },
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showDocuments ? _showAddDocumentDialog : _showAddVideoDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}

class DocumentViewerScreen extends StatelessWidget {
  final String url;
  final String title;

  DocumentViewerScreen({required this.url, required this.title});

  
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Document Viewer'),
      ),
      body: Container(
        color: Color.fromARGB(255, 236, 162, 186),
        child: Center(
          child: Text('Document: $title\nURL: $url'),
        ),
      ),
    );
  }
}
