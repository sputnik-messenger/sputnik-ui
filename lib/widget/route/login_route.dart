// Copyright (C) 2019 Mohammed El Batya
//
// This file is part of sputnik_ui.
//
// sputnik_ui is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import 'dart:io';

import 'package:sputnik_matrix_sdk/matrix_manager/matrix_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_udid/flutter_udid.dart';

import 'conversations_list_route.dart';
import 'package:sputnik_animations/sputnik_animations.dart';

class LoginRoute extends StatefulWidget {
  final MatrixManager matrixManager;

  const LoginRoute({Key key, this.matrixManager}) : super(key: key);

  @override
  _LoginRouteState createState() => _LoginRouteState();
}

class _LoginRouteState extends State<LoginRoute> {
  final loginId = TextEditingController();
  final loginPassword = TextEditingController();
  final deviceName = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool loginProgress = false;
  String error = '';

  @override
  void initState() {
    super.initState();
    deviceName.text = _initDeviceName();
  }

  String _initDeviceName() {
    String name = 'Device #1 - Sputnik';
    if (Platform.isIOS || Platform.isAndroid) {
      name = 'Phone #1 - Sputnik';
    }
    return name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            ClipPath(
              clipper: TriangleClipper(),
              clipBehavior: Clip.antiAlias,
              child: AspectRatio(
                aspectRatio: 1,
                child: FractionallySizedBox(
                  widthFactor: 1,
                  child: Container(
                    color: Theme.of(context).primaryColorDark,
                  ),
                ),
              ),
            ),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 50.0),
                      child: FractionallySizedBox(widthFactor: 0.7, child: OrbitingSputnikAnimation(runAnimation: true)),
                    ),
                    TextFormField(
                      controller: loginId,
                      decoration: InputDecoration(labelText: 'matrix id, email or phone number'),
                      validator: (v) => v.trim().isEmpty ? 'must not be empty' : null,
                    ),
                    TextFormField(
                      controller: loginPassword,
                      decoration: InputDecoration(labelText: 'password'),
                      validator: (v) => v.trim().isEmpty ? 'must not be empty' : null,
                      obscureText: true,
                    ),
                    TextFormField(
                      controller: deviceName,
                      validator: (v) => v.trim().isEmpty ? 'must not be empty' : null,
                      decoration: InputDecoration(hintText: 'a name for this device', labelText: 'device name'),
                    ),
                    Text(error),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Visibility(
                          visible: loginProgress,
                          child: Column(
                            children: <Widget>[LinearProgressIndicator(), Text('... please be patient :)')],
                          )),
                    ),
                    RaisedButton(
                        color: Theme.of(context).accentColor.withOpacity(0.6),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Login',
                          ),
                        ),
                        onPressed: loginProgress
                            ? null
                            : () async {
                                if (_formKey.currentState.validate()) {
                                  String deviceId = FlutterUdid.consistentUdid.hashCode.toString();
                                  setState(() {
                                    loginProgress = true;
                                  });
                                  try {
                                    final result = await widget.matrixManager.addUser(
                                      loginId.text,
                                      loginPassword.text,
                                      deviceId,
                                      deviceName.text,
                                    );

                                    final loginResponse = result.body;
                                    await widget.matrixManager.loadAccountState(loginResponse.user_id);
                                    final accountController = widget.matrixManager.getAccountController(loginResponse.user_id);
                                    await accountController.sync();
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              StoreProvider(store: widget.matrixManager.matrixStore, child: ConversationListRoute(accountController)),
                                        ));
                                    accountController.startContinuousSync();
                                  } catch (e, s) {
                                    debugPrint(s.toString());
                                    setState(() {
                                      error = e.toString();
                                    });
                                  }
                                  setState(() {
                                    loginProgress = false;
                                  });
                                }
                              })
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.relativeLineTo(size.width * 1.1, 0.0);
    path.relativeLineTo(-size.width * 0.1, size.height * 0.85);
    path.relativeLineTo(-size.width * 0.9, -size.height * 0.2);
    path.lineTo(-0.1 * size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(TriangleClipper oldClipper) => false;
}
