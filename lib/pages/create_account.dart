import 'package:flutter/material.dart';
import 'dart:async';
import '../widgets/header.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  String userName;

  submit() {
    final form = _formKey.currentState;
    if (form.validate()) {
      _formKey.currentState.save();
      SnackBar snackBar = SnackBar(content: Text("welcome $userName"));
      _scaffoldKey.currentState.showSnackBar(snackBar);
      Timer(Duration(seconds: 2), () {
        Navigator.pop(context, userName);
      });
    }
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context,
          titleText: "Setup your Profile", removeBackButton: true),
      body: ListView(
        children: [
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 25),
                  child: Center(
                      child: Text(
                    "Create a UserName",
                    style: TextStyle(fontSize: 25),
                  )),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      validator: (val) {
                        if (val.trim().length < 3 || val.isEmpty) {
                          return "User Name is too Short";
                        }
                        return null;
                      },
                      onSaved: (val) => userName = val,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "User Name",
                          labelStyle: TextStyle(fontSize: 15.0),
                          hintText: "User Name must be at least 3 characters"),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: submit,
                  child: Container(
                    height: 50.0,
                    width: 350.0,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    child: Center(
                      child: Text(
                        "Submit",
                        style: TextStyle(
                          fontSize: 15.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
