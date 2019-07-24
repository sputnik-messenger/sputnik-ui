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

import 'package:matrix_rest_api/matrix_client_api_r0.dart' hide State;
import 'package:matrix_rest_api/matrix_identity_service_api_v1.dart';
import 'package:sputnik_matrix_sdk/matrix_manager/matrix_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:sputnik_ui/tool/file_saver.dart';

import 'conversations_list_route.dart';

class LoginRoute extends StatefulWidget {
  final MatrixManager matrixManager;
  final WidgetBuilder artwork;
  final WidgetBuilder background;
  final FileSaver fileSaver;
  final String defaultDeviceName;
  final WidgetBuilder conversationBackground;

  const LoginRoute({
    Key key,
    this.matrixManager,
    this.artwork,
    this.background,
    this.fileSaver,
    this.defaultDeviceName,
    this.conversationBackground,
  }) : super(key: key);

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
    deviceName.text = widget.defaultDeviceName;
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
            widget.background(context),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 50.0),
                      child: FractionallySizedBox(widthFactor: 0.7, child: widget.artwork(context)),
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
                                          builder: (context) => StoreProvider(
                                              store: widget.matrixManager.matrixStore,
                                              child: ConversationListRoute(
                                                accountController,
                                              )),
                                        ));
                                    accountController.startContinuousSync();
                                  } catch (e, s) {
                                    debugPrint(s.toString());
                                    setState(() {
                                      if (e is Response) {
                                        error = e.body.toString();
                                      } else {
                                        error = e.toString();
                                      }
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
