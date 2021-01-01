import 'package:flutter/material.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';

class ConversationCallScreen extends StatefulWidget {
  final P2PSession _callSession;
  final bool _isIncoming;

  @override
  State<StatefulWidget> createState() {
    return _ConversationCallScreenState(_callSession, _isIncoming);
  }

  ConversationCallScreen(this._callSession, this._isIncoming);
}

class _ConversationCallScreenState extends State<ConversationCallScreen>
    implements RTCSessionStateCallback<P2PSession> {
  static const String TAG = '_ConversationCallScreenState';
  P2PSession _callSession;
  bool _isIncoming;
  bool _isSpeakerEnabled = true;
  bool _isMicMute = false;

  Map<int, RTCVideoRenderer> streams = <int, RTCVideoRenderer>{};

  _ConversationCallScreenState(this._callSession, this._isIncoming);

  @override
  void initState() {
    super.initState();

    _callSession.onLocalStreamReceived = _addLocalMediaStream;
    _callSession.onRemoteStreamReceived = _addRemoteMediaStream;
    _callSession.onSessionClosed = _onSessionClosed;

    _callSession.setSessionCallbacksListener(this);
    if (_isIncoming) {
      _callSession.acceptCall();
    } else {
      _callSession.startCall();
    }
  }

  @override
  void dispose() {
    super.dispose();
    streams.forEach((int opponentId, RTCVideoRenderer stream) async {
      log('[dispose] dispose renderer for $opponentId', TAG);
      await stream.dispose();
    });
  }

  void _addLocalMediaStream(MediaStream stream) {
    log('_addLocalMediaStream', TAG);
    _onStreamAdd(CubeChatConnection.instance.currentUser.id, stream);
  }

  void _addRemoteMediaStream(dynamic session, int userId, MediaStream stream) {
    log('_addRemoteMediaStream for user $userId', TAG);
    _onStreamAdd(userId, stream);
  }

  void _removeMediaStream(dynamic callSession, int userId) {
    log('_removeMediaStream for user $userId', TAG);
    RTCVideoRenderer videoRenderer = streams[userId];
    if (videoRenderer == null) return;

    videoRenderer.srcObject = null;
    videoRenderer.dispose();

    setState(() {
      streams.remove(userId);
    });
  }

  void _onSessionClosed(dynamic session) {
    log('_onSessionClosed', TAG);
    _callSession.removeSessionCallbacksListener();

    Navigator.pop(context);
  }

  void _onStreamAdd(int opponentId, MediaStream stream) async {
    log('_onStreamAdd for user $opponentId', TAG);

    RTCVideoRenderer streamRender = RTCVideoRenderer();
    await streamRender.initialize();
    streamRender.srcObject = stream;
    setState(() => streams[opponentId] = streamRender);
  }

  List<Widget> renderStreamsGrid(Orientation orientation) {
    List<Widget> streamsExpanded = streams.entries
        .map(
          (MapEntry<int, RTCVideoRenderer> entry) => Expanded(
            child: RTCVideoView(
              entry.value,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              mirror: true,
            ),
          ),
        )
        .toList();
    if (streams.length > 2) {
      List<Widget> rows = <Widget>[];

      for (int i = 0; i < streamsExpanded.length; i += 2) {
        int chunkEndIndex = i + 2;

        if (streamsExpanded.length < chunkEndIndex) {
          chunkEndIndex = streamsExpanded.length;
        }

        List<Widget> chunk = streamsExpanded.sublist(i, chunkEndIndex);

        rows.add(
          Expanded(
            child: orientation == Orientation.portrait
                ? Row(children: chunk)
                : Column(children: chunk),
          ),
        );
      }

      return rows;
    }

    return streamsExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onBackPressed(context),
      child: Stack(
        children: <Widget>[
          Scaffold(
              body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 24),
                  child: Text(
                    'Audio call',
                    style: TextStyle(fontSize: 28),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Members:',
                    style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
                  ),
                ),
                Text(
                  _callSession.opponentsIds.join(', '),
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          )),
          Align(
            alignment: Alignment.bottomCenter,
            child: _getActionsPanel(),
          ),
        ],
      ),
    );
  }

  Widget _getActionsPanel() {
    return Container(
      margin: EdgeInsets.only(bottom: 16, left: 8, right: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32)),
        child: Container(
          padding: EdgeInsets.all(4),
          color: Colors.black26,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 4),
                child: FloatingActionButton(
                  elevation: 0,
                  heroTag: 'Mute',
                  child: Icon(
                    Icons.mic,
                    color: _isMicMute ? Colors.grey : Colors.white,
                  ),
                  onPressed: () => _muteMic(),
                  backgroundColor: Colors.black38,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 4),
                child: FloatingActionButton(
                  elevation: 0,
                  heroTag: 'Speaker',
                  child: Icon(
                    Icons.volume_up,
                    color: _isSpeakerEnabled ? Colors.white : Colors.grey,
                  ),
                  onPressed: () => _switchSpeaker(),
                  backgroundColor: Colors.black38,
                ),
              ),
              Expanded(
                child: SizedBox(),
                flex: 1,
              ),
              Padding(
                padding: EdgeInsets.only(left: 0),
                child: FloatingActionButton(
                  child: Icon(
                    Icons.call_end,
                    color: Colors.white,
                  ),
                  backgroundColor: Colors.red,
                  onPressed: () => _endCall(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _endCall() {
    _callSession.hungUp();
  }

  Future<bool> _onBackPressed(BuildContext context) {
    return Future<bool>.value(false);
  }

  _muteMic() {
    setState(() {
      _isMicMute = !_isMicMute;
      _callSession.setMicrophoneMute(_isMicMute);
    });
  }

  _switchSpeaker() {
    setState(() {
      _isSpeakerEnabled = !_isSpeakerEnabled;
      _callSession.enableSpeakerphone(_isSpeakerEnabled);
    });
  }

  @override
  void onConnectedToUser(P2PSession session, int userId) {
    log('onConnectedToUser userId= $userId');
  }

  @override
  void onConnectionClosedForUser(P2PSession session, int userId) {
    log('onConnectionClosedForUser userId= $userId');
    _removeMediaStream(session, userId);
  }

  @override
  void onDisconnectedFromUser(P2PSession session, int userId) {
    log('onDisconnectedFromUser userId= $userId');
  }
}
