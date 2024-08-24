import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class AchievementsViewPage extends StatefulWidget {
  final String location;

     AchievementsViewPage({required this.location});

  @override
  _AchievementsViewPageState createState() => _AchievementsViewPageState();
}

class _AchievementsViewPageState extends State<AchievementsViewPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      print('Error in downloading : $e');
    }
    return null;
  }

  String _formatTimestamp(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    final DateFormat formatter = DateFormat('yMMMd').add_jm(); 
    return formatter.format(dateTime);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Achievements - ${widget.location}'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        color: Colors.teal[50], 
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('achievements')
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
              return Center(child: Text('No achievements available.'));
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[800], 
                      ),
                    ),
                    subtitle: Text(
                      _formatTimestamp(timestamp),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.teal[600], 
                      ),
                    ),
                    trailing: Icon(Icons.file_present, color: Colors.teal),
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
