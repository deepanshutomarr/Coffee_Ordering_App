import 'package:brew_crew/models/user.dart';
import 'package:brew_crew/services/database.dart';
import 'package:brew_crew/shared/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:brew_crew/shared/constants.dart';
import 'package:provider/provider.dart';

class SettingsForm extends StatefulWidget {
  const SettingsForm({super.key});

  @override
  State<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  final _formKey = GlobalKey<FormState>();
  final List<String> sugars = ['0', '1', '2', '3', '4'];

  // Form values
  late String _currentName;
  late String _currentSugars;
  late int _currentStrength;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser>(context);

    return StreamBuilder<UserData>(
        stream: DatabaseService(uid: user.uid).userData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            UserData? userData = snapshot.data;

            return Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  const Text(
                    'Update your brew settings',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    initialValue: userData?.name,
                    decoration: textInputDecoration,
                    validator: (val) =>
                        val!.isEmpty ? 'Please enter a name' : null,
                    onChanged: (val) => setState(() => _currentName = val),
                  ),
                  const SizedBox(height: 20.0),

                  // dropdown
                  DropdownButtonFormField(
                    decoration: textInputDecoration,
                    value: _currentSugars,
                    items: sugars.map((sugar) {
                      return DropdownMenuItem(
                        value: sugar,
                        child: Text('$sugar sugars'),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _currentSugars = val!),
                  ),

                  // slider
                  Slider(
                    value: (_currentStrength).toDouble(),
                    activeColor: Colors.brown[_currentStrength],
                    inactiveColor: Colors.brown[_currentStrength],
                    min: 100.0,
                    max: 900.0,
                    divisions: 8,
                    onChanged: (val) =>
                        setState(() => _currentStrength = val.round()),
                  ),

                  ElevatedButton(
                      child: const Text(
                        'Update',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await DatabaseService(uid: user.uid).updateUserData(
                              _currentSugars, _currentName, _currentStrength);
                          Navigator.pop(context);
                        }
                      })
                ],
              ),
            );
          } else {
            return const Loading();
          }
        });
  }
}
