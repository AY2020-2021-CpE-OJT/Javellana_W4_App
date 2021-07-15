import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phonebook App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Phonebook App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneNumberOneController = TextEditingController();
  final phoneNumberTwoController = TextEditingController();
  final phoneNumberThreeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Contact'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(labelText: 'First Name'),
              controller: firstNameController,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Last Name'),
              controller: lastNameController,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Phone Number 1'),
              controller: phoneNumberOneController,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Phone Number 2'),
              controller: phoneNumberTwoController,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Phone Number 3'),
              controller: phoneNumberThreeController,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SecondScreen()));
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class Person {
  final String firstName;
  final String lastName;
  final List<String> phoneNumber;

  Person({required this.firstName,
    required this.lastName,
    required this.phoneNumber,});

  factory Person.fromJson(Map<String, dynamic> json){
    return Person(
        lastName: json['last_name'],
        firstName: json['first_name'],
        phoneNumber: json['phone_numbers']);
  }
}

Future<Person> getPhonebook(int index) async {
  final response = await http.get(Uri.parse('http://192.168.1.8:5000/person'));
  return Person.fromJson(jsonDecode(response.body)[index]);
}

getCountDocuments() async {
  final response = await http.get(Uri.parse('http://192.168.1.8:5000/person/documents'));
  return response.body;
}

class SecondScreen extends StatefulWidget {
  const SecondScreen({Key? key}) : super(key: key);

  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  List<Future<Person>> persons = <Future<Person>>[];

  @override
  void initState() {
    super.initState();
    getCountDocuments().then((total){
      setState(() {
        for(int i = 0; i < int.parse(total); i++) {
          persons.add(getPhonebook(i));
        }
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar, body: Center(
      child: ListView.builder(itemCount: persons.length, itemBuilder: (context, index) {
        return Container(child: FutureBuilder<Person>(future: persons[index],builder: (context, snapshot) {
          if(snapshot.hasData) return Text(snapshot.data!.firstName.toString() + ' ' + snapshot.data!.lastName.toString());
          return const Center(child: Text('Loading Data'));
        }));
      }),
    ));
  }
}
