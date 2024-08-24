import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PublicVolunteeringFormPage extends StatefulWidget {
  final String location;
  PublicVolunteeringFormPage({required this.location});

  @override
  _PublicVolunteeringFormPageState createState() => _PublicVolunteeringFormPageState();
}

class _PublicVolunteeringFormPageState extends State<PublicVolunteeringFormPage> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _phoneNumber;
  List<String> _selectedDates = [];
  int? _hours;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Volunteer Form - ${widget.location}'),
        centerTitle: true,
      ),
      body: Container(
        color: Color.fromARGB(255, 208, 243, 214),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                
                TextFormField(
                  decoration: InputDecoration(labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.blueAccent,fontWeight: FontWeight.w200,fontSize: 20)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _name = value;
                  },
                ),
        
                
                TextFormField(
                  decoration: InputDecoration(labelText: 'Phone Number',
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w200,
                    fontSize: 20,
                    color: Colors.blueAccent,
                  )),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                      return 'Please enter a valid 10-digit phone number';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _phoneNumber = value;
                  },
                ),
        
                
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Select dates you are comfortable with:',
                    style: TextStyle(fontSize: 20,color: Colors.blueAccent,fontWeight: FontWeight.w200,),
                  ),
                ),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: List.generate(31, (index) {
                    final date = (index + 1).toString();
                    return ChoiceChip(
                      label: Text(date),
                      selected: _selectedDates.contains(date),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedDates.add(date);
                          } else {
                            _selectedDates.remove(date);
                          }
                        });
                      },
                      selectedColor: Color.fromARGB(255, 240, 80, 134),
                      backgroundColor: Colors.grey[300],
                    );
                  }),
                ),
        
                
                TextFormField(
                  decoration: InputDecoration(labelText: 'Number of Hours You Can Work',labelStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w200,
                    color: Colors.blueAccent,
                  )),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the number of hours you can work';
                    }
                    final hours = int.tryParse(value);
                    if (hours == null || hours <= 0) {
                      return 'Please enter a valid number of hours';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _hours = int.tryParse(value!);
                  },
                ),
        
                SizedBox(height: 20),
        
                
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      
                      _submitForm();
                    }
                  },
                  child: Text('Submit',
                  style:TextStyle( 
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                    color: Colors.black54,
                  )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    
    FirebaseFirestore.instance.collection('voluntary_activities')
      .doc(widget.location)
      .collection('forms')
      .add({
        'name': _name,
        'phone_number': _phoneNumber,
        'selected_dates': _selectedDates,
        'hours': _hours,
        'work_assigned': false,  
        'submitted_at': Timestamp.now(),
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Form submitted successfully!')),
        );

        _formKey.currentState?.reset();
        setState(() {
          _selectedDates.clear();
        });
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit form: $error')),
        );
      });
  }
}
