import 'package:flutter/material.dart';
import 'package:kokushi_connect/auth.dart';
import 'package:kokushi_connect/base_page.dart';
import 'custom_app_bar.dart';
import 'db_control.dart';
import 'join_dojo_page.dart';
import 'home_page.dart';

class CreateDojoPage extends StatefulWidget {
  CreateDojoPage({this.auth, this.db});
  final BaseAuth auth;
  final Database db;
  @override
  State<StatefulWidget> createState() => _CreateDojoPageState();
}

class _CreateDojoPageState extends State<CreateDojoPage> {

  final formKey = GlobalKey<FormState>();
  String _dojoName;
  String _address;
  String _dojocode;

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void createDojo(String _dojoName, String _address, String _dojocode) async {
    await widget.db.createDojo(_dojoName, _address, _dojocode);
    String dojoId = await widget.db.getDojoIdByDojoCode(_dojocode);
    await widget.db.setUserDojo(dojoId, await widget.auth.currentUser());
  } 

  void validateAndSubmit() {
    try {
      createDojo(_dojoName, _address, _dojocode);
    }
    catch (e) {
      print('Error: $e');
    }
  }

  void moveToHomePage() {
    if (validateAndSave()) {
      validateAndSubmit();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BasePage(auth: widget.auth, db: widget.db),
        )
      );
    }
  }

  void moveToJoinDojoPage() {
    Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => JoinDojoPage(auth: widget.auth, db: widget.db),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text('Create Dojo'),
        context: context,
        auth: widget.auth,
        db: widget.db,
      ),

      body: Container(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Name'),
                    validator: (value) => value.isEmpty? 'Name can\'t be empty' : null,
                    onSaved: (value) => _dojoName = value,
                  ),

                  TextFormField(
                    decoration: InputDecoration(labelText: 'Address'),
                    validator: (value) => value.isEmpty? 'Address can\'t be empty' : null,
                    onSaved: (value) => _address = value,
                  ),

                  TextFormField(
                    decoration: InputDecoration(labelText: 'Dojo Code (used when student joining a dojo'),
                    validator: (value) { if(value.isEmpty & (value.length <= 10) & (value.length >= 6)) {
                       return 'Dojo Code must be between 6 and 10 characters long';
                    }
                    },
                    onSaved: (value) => _dojocode = value,
                  ),
                  RaisedButton(
                    child: Text('Create Dojo', style: TextStyle(fontSize: 20)),
                    onPressed: moveToHomePage,
                  ),
                  FlatButton(
                    child: Text('Join Dojo', style: TextStyle(fontSize: 20)),
                    onPressed: moveToJoinDojoPage,
                  ),
                ]
            ),
          )
      ),
    );
  }
}