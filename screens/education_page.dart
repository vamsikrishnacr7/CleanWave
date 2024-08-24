import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

class EducationPage extends StatefulWidget {
  final String location;

     EducationPage({required this.location});

  
  _EducationPageState createState() => _EducationPageState();
}

class _EducationPageState extends State<EducationPage> with SingleTickerProviderStateMixin {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late TabController _tabController;
  bool _isLoading = true;

  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<File?> _downloadPdf(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/${url.split('/').last}');
        await file.writeAsBytes(response.bodyBytes);
        return file;
      }
    } catch (e) {
      print('Error downloading PDF: $e');
    }
    return null;
  }

  String _formatTimestamp(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    final DateFormat formatter = DateFormat('yMMMd').add_jm();
    return formatter.format(dateTime);
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunch(uri.toString())) {
      await launch(uri.toString());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot open URL: $url')),
      );
    }
  }

  
  Widget build(BuildContext context) {
    return _isLoading
        ? Scaffold(
            backgroundColor: Colors.teal[50],
            body: Center(
              child: SpinKitCubeGrid(
                color: Colors.teal,
                size: 100.0,
              ),
            ),
          )
        : DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  'Educational Resources',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Color.fromARGB(255, 35, 47, 57),
                  bottom: TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Color.fromARGB(255, 151, 246, 154),
                  tabs: [
                    Tab(text: 'PDFs'),
                    Tab(text: 'Videos'),
                  ], ),
              ),
              body: TabBarView(
                controller: _tabController,
                  children: [
                  
                  Container(
                    padding: EdgeInsets.all(16),
                    color: Colors.teal[50],
                    child: StreamBuilder<QuerySnapshot>(
                      stream: firestore
                          .collection('documents')
                          .where('location', isEqualTo: widget.location)
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(child: Text('No educational resources available.'));
                        }

                        final books = snapshot.data!.docs;

                        return ListView.builder(
                          itemCount: books.length,
                          itemBuilder: (context, index) {
                            final item = books[index];
                            final fileUrl = item['fileUrl'] ?? '';
                            final title = item['title'] ?? 'Untitled';
                            final timestamp = item['timestamp'] as Timestamp;

                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              color: Colors.white,
                              child: ListTile(
                                contentPadding: EdgeInsets.all(16),
                                title: Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                subtitle: Text(
                                  _formatTimestamp(timestamp),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                trailing: Icon(Icons.file_present, color: Colors.brown),
                                onTap: () async {
                                  if (fileUrl.isNotEmpty) {
                                    final file = await _downloadPdf(fileUrl);
                                    if (file != null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PdfViewerScreen(file: file),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Failed to download PDF')),
                                      );
                                    }
                                  }
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  
                  Container(
                    padding: EdgeInsets.all(16),
                     color: Colors.teal[50],
                    child: StreamBuilder<QuerySnapshot>(
                        stream: firestore
                          .collection('videos')
                          .where('location', isEqualTo: widget.location)
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(child: Text('No educational videos available.'));
                        }

                        final videos = snapshot.data!.docs;

                        return ListView.builder(
                            itemCount: videos.length,
                            itemBuilder: (context, index) {
                            final item = videos[index];
                            final videoUrl = item['fileUrl'] ?? '';
                            final title = item['title'] ?? 'Untitled';
                            final timestamp = item['timestamp'] as Timestamp;

                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              color: Colors.white,
                              child: ListTile(
                                contentPadding: EdgeInsets.all(16),
                                title: Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                subtitle: Text(
                                  _formatTimestamp(timestamp),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blueAccent,
                                  ), ),
                                trailing: Icon(Icons.play_arrow, color: Colors.red),
                                onTap: () async {
                                  final Uri uri = Uri.parse(videoUrl);
                                  if (await canLaunch(uri.toString())) {
                                    await launch(uri.toString());
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Failed to open video')),
                                    );
                                  }
                                },
                              ), );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}

class PdfViewerScreen extends StatelessWidget {
  final File file;

  PdfViewerScreen({required this.file});

  
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text('PDF Viewer'),
        backgroundColor: Colors.teal,
      ),
      body: Container(

        color: Colors.teal[50],
        child: PDFView(
           filePath: file.path,
        ),
      ),
    );
  }
}
