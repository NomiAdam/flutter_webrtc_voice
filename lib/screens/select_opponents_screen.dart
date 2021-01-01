import 'package:flutter/material.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:flutter_webrtc_voice/constants/configs.dart';
import 'package:flutter_webrtc_voice/screens/conversation_call_screen.dart';
import 'package:flutter_webrtc_voice/screens/incoming_call_screen.dart';

class SelectOpponentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onBackPressed(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Logged in as ${CubeChatConnection.instance.currentUser.fullName}',
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () => _logOut(context),
              icon: Icon(
                Icons.exit_to_app,
                color: Colors.white,
              ),
            ),
          ],
        ),
        body: BodyLayout(),
      ),
    );
  }

  Future<bool> _onBackPressed() {
    return Future<bool>.value(false);
  }

  _logOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want logout current user'),
          actions: <Widget>[
            FlatButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                signOut().then(
                  (_) {
                    CubeChatConnection.instance.destroy();
                    P2PClient.instance.destroy();
                    Navigator.pop(context); // cancel current Dialog
                    _navigateToLoginScreen(context);
                  },
                ).catchError(
                  (_) {
                    P2PClient.instance.destroy();
                    Navigator.pop(context); // cancel current Dialog
                    _navigateToLoginScreen(context);
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  _navigateToLoginScreen(BuildContext context) {
    Navigator.pop(context);
  }
}

class BodyLayout extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BodyLayoutState();
  }
}

class _BodyLayoutState extends State<BodyLayout> {
  Set<int> _selectedUsers;
  P2PClient _callClient;
  P2PSession _currentCall;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(48),
        child: Column(
          children: <Widget>[
            Text(
              'Select users to call:',
              style: TextStyle(fontSize: 22),
            ),
            Expanded(
              child: _getOpponentsList(context),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 24),
                  child: FloatingActionButton(
                    heroTag: 'AudioCall',
                    child: Icon(
                      Icons.call,
                      color: Colors.white,
                    ),
                    backgroundColor: Colors.green,
                    onPressed: () =>
                        _startCall(CallType.AUDIO_CALL, _selectedUsers),
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  Widget _getOpponentsList(BuildContext context) {
    CubeUser currentUser = CubeChatConnection.instance.currentUser;
    final List<CubeUser> users =
        cubeUsers.where((CubeUser user) => user.id != currentUser.id).toList();

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          child: CheckboxListTile(
            title: Center(
              child: Text(
                users[index].fullName,
              ),
            ),
            value: _selectedUsers.contains(users[index].id),
            onChanged: (bool checked) {
              setState(() {
                if (checked) {
                  _selectedUsers.add(users[index].id);
                } else {
                  _selectedUsers.remove(users[index].id);
                }
              });
            },
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _selectedUsers = {};
    _initCustomMediaConfigs();
    _initCalls();
  }

  void _initCalls() {
    _callClient = P2PClient.instance;

    _callClient.init();

    _callClient.onReceiveNewSession = (P2PSession callSession) {
      if (_currentCall != null &&
          _currentCall.sessionId != callSession.sessionId) {
        callSession.reject();
        return;
      }

      _showIncomingCallScreen(callSession);
    };

    _callClient.onSessionClosed = (P2PSession callSession) {
      if (_currentCall != null &&
          _currentCall.sessionId == callSession.sessionId) {
        _currentCall = null;
      }
    };
  }

  void _startCall(int callType, Set<int> opponents) {
    if (opponents.isEmpty) return;

    P2PSession callSession = _callClient.createCallSession(callType, opponents);
    _currentCall = callSession;
    Navigator.push(
      context,
      MaterialPageRoute<ConversationCallScreen>(
        builder: (BuildContext context) =>
            ConversationCallScreen(callSession, false),
      ),
    );
  }

  void _showIncomingCallScreen(P2PSession callSession) {
    Navigator.push(
      context,
      MaterialPageRoute<IncomingCallScreen>(
        builder: (BuildContext context) => IncomingCallScreen(callSession),
      ),
    );
  }

  void _initCustomMediaConfigs() {
    RTCMediaConfig mediaConfig = RTCMediaConfig.instance;
    mediaConfig.minHeight = 720;
    mediaConfig.minWidth = 1280;
    mediaConfig.minFrameRate = 30;
  }
}
