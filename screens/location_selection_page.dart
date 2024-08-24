import 'package:flutter/material.dart';

import 'home_page.dart'; 

class LocationSelectionPage extends StatefulWidget {
  
  LocationSelectionPageState createState() => LocationSelectionPageState();
}

class LocationSelectionPageState extends State<LocationSelectionPage> {
  String? yourlocation;

  final Map<String, String> locations = {
    'Tirupati': 'vamsi',
    'Yerpedu': 'jaswanth',
    'Venkatagiri': 'manoj',
  };

  void showLocationDialog() async {
    final selectedLocation = await showDialog<String>(
       context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Select Location'),
          children: locations.keys.map((location) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, location);
              },
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.red),
                  SizedBox(width: 8.0),
                  Text(location),],
              ),);
          }).toList(),
        );
      },
    );

    if (selectedLocation!= null) {
      setState(() {
        yourlocation = selectedLocation;});
      goHome();}
  }

  void goHome() {
    if (yourlocation != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(location: yourlocation!),),
      );
    }
  }

  
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text('Select Location',
        style:TextStyle(
          color: Colors.white,),
        ),
        centerTitle:true,
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/location.jpg'), 
                fit: BoxFit.cover, 
              ),
            ),
          ),
          Center(
              child: Padding(
              padding: EdgeInsets.all(16.0),
              child: ElevatedButton(
            
                onPressed: showLocationDialog,
                child: Text(
                  yourlocation ?? 'Select Location',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.8),
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  minimumSize: Size(200,50)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
