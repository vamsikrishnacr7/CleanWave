import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class WorkProgressPage extends StatefulWidget {
  final String location;

  WorkProgressPage({required this.location});

  _WorkProgressPageState createState() => _WorkProgressPageState();
}

class _WorkProgressPageState extends State<WorkProgressPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

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
    final DateFormat formatter = DateFormat('yMMMd').add_jm(); // Customize the format as needed
    return formatter.format(dateTime);
  }

  
  Widget build(BuildContext context) {
     return Scaffold(
        appBar: AppBar(
        title: Text('Work Progress - ${widget.location}',
        style: TextStyle( 
          fontSize: 27,
          fontWeight: FontWeight.w800,
          color: Colors.black,
          ),),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 230, 229, 229),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        color: Colors.teal[50], 
        child: StreamBuilder<QuerySnapshot>(
          stream: firestore
              .collection('workprogress')
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
              return Center(child: Text('No work progress updates available.'));
            }

            final items = snapshot.data!.docs;

            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final fileUrl = item['fileUrl'] ?? '';
                final title = item['fileName'] ?? 'Untitled'; 
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
    );
  }
}

class PdfViewerScreen extends StatelessWidget {
  final File file;

  PdfViewerScreen({required this.file});

  @override
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
