import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContributionsAdminPage extends StatefulWidget {
  final String location;

  ContributionsAdminPage({required this.location});

  @override
  _ContributionsAdminPageState createState() => _ContributionsAdminPageState();
}

class _ContributionsAdminPageState extends State<ContributionsAdminPage> {
  String _selectedView = 'contributors'; 


  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Contributions - ${widget.location}'),
      ),
      body:Container(
        color: Color.fromARGB(255, 171, 212, 245),
        child: Column(
          children: [
              Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedView = 'contributors';
                    });
                  },
                  child: 
                  Text('Contributors'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedView = 'funds';
                    });
                  },
                  child: Text('Funds and Products'),
                ),
              ],
            ),
            Expanded(
              child: _selectedView == 'contributors'
                  ? _buildContributorsList()
                  : _buildFundsView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContributorsList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('payments').where('location', isEqualTo: widget.location).snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
  child: Icon(
    Icons.hourglass_empty,
    color: Colors.blueAccent,
    size: 50.0,
  ),
);

        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No contributions found.'));
        }
        return ListView(
          children: snapshot.data!.docs.map((doc) {
            return ListTile(
              title: Text('${doc['name']} - ₹${doc['amount']}'),
              subtitle: Text('Mobile: ${doc['mobileNumber']}'),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildFundsView() {
    return FutureBuilder(
      future: _calculateTotalFunds(),
      builder: (context, AsyncSnapshot<double> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return Center(child: Text('No funds available.'));
        }
        return Center(
          child: Text(
            'Total Funds: ₹${snapshot.data!.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

Future<double> _calculateTotalFunds() async {
    double totalFunds = 0;

    QuerySnapshot amountsection = await FirebaseFirestore.instance.collection('payments').where('location', isEqualTo: widget.location).get();

amountsection.docs.forEach((doc) {
      totalFunds += doc['amount'];
    });

    return totalFunds;
  }
}
