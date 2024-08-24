import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import 'voluntaryActivitiespage.dart';

class ContributionsPage extends StatelessWidget {
  final String location;

  ContributionsPage({required this.location});

  
  Widget build(BuildContext context) {
    return Scaffold(
         appBar: AppBar(
         title: Text('Contributions'),
          centerTitle: true,
      ),

      
      body: Container(
        color:  Color.fromARGB(255, 170, 217, 255),
        child: Column(
          children: [
            
            Padding(
              padding:  EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                DonateMoneyPage(location: location)),
                      );
                    },
                    child: Text('Donate Money',
                    style: TextStyle( 
                      fontWeight: FontWeight.w300,
                      color: Colors.black,
                      fontSize: 20,
                    )),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PublicVolunteeringFormPage(
                                location: location)),
                      );
                    },
                    child: Text('Volunteer',
                    style: TextStyle( 
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.w300,
                    ),),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),],
                  ),
                ),


            SizedBox(height: 80),

              Container(
              height: 400, 
              width: double.infinity,
              decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
                 image: DecorationImage(
                  image: 
                  AssetImage('assets/images/donate.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
         ),
        ),);
      }
       }

class DonateMoneyPage extends StatefulWidget {
  final String location;

  DonateMoneyPage({required this.location});

  
  _DonateMoneyPageState createState() => _DonateMoneyPageState();
}

class _DonateMoneyPageState extends State<DonateMoneyPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _mobileNumberController =
      TextEditingController();
  final TextEditingController _transactionIdController =
      TextEditingController();

  final String donationPhoneNumber =
      '9182952053'; 

  Future<void> _openUPIPaymentApp() async {
    final String amount = _amountController.text;

    final Uri upiUri = Uri(
      scheme: 'upi',
      path: 'pay',
      queryParameters: {
        'pa': donationPhoneNumber, 
        'pn': 'Your Organization Name', 
        'amt': amount, 
      },
    );

    final String uriString = upiUri.toString();

    if (await canLaunch(uriString)) {
      await launch(uriString);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No UPI apps found')),
      );
    }
  }

  Future<void> _submitDonation() async {
    String name = _nameController.text;
    String amount = _amountController.text;
    String mobileNumber = _mobileNumberController.text;
    String transactionId = _transactionIdController.text;

    if (name.isNotEmpty &&
        amount.isNotEmpty &&
        mobileNumber.isNotEmpty &&
        transactionId.isNotEmpty) {
      double donationAmount = double.tryParse(amount) ?? 0.0;
      await FirebaseFirestore.instance.collection('payments').add({
      'name': name,
      'amount': donationAmount,
      'mobileNumber': mobileNumber,
      'transactionId': transactionId,
      'location': widget.location,
      'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thank you for your donation!')),
        );

      _nameController.clear();
      _amountController.clear();
      _mobileNumberController.clear();
      _transactionIdController.clear();
    } 
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
  }
     }
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Donate Money')),
       body: SingleChildScrollView(
          child: Padding(
         padding:  EdgeInsets.all(16.0),
           child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _openUPIPaymentApp,
                child: Text('UPI Pay'),
                style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                ),
              ),
              SizedBox(height: 10),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: AssetImage('assets/images/your_image.png'),
                    fit: BoxFit.cover,
                  ),
                  ),
                ),
              SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Amount'),
              ),
              TextField(
                controller: _mobileNumberController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: 'Mobile Number'),
              ),
              TextField(
                controller: _transactionIdController,
                decoration: InputDecoration(labelText: 'Transaction ID'),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitDonation,
                child: Text('Submit'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),],
             ),
           ),
         ),);
          }
          
       }
