import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kaksha/screens/chatscreen.dart';
import 'package:kaksha/screens/dashboard.dart';

import 'utils/settings.dart';

class CallPage extends StatefulWidget {
  /// non-modifiable channel name of the page
  final String channelName;

  /// non-modifiable client role of the page
  final ClientRole role;

  final String userName;

  /// Creates a call page with given channel name.
  const CallPage({Key key, this.channelName, this.role, this.userName})
      : super(key: key);

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  static final _users = <int>[];
  final _firestore = Firestore.instance;
  final _infoStrings = <String>[];
  String userName;
  String email;
  bool muted = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  getCurrentUser() async {
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.displayName;
    // Similarly we can get email as well
    //final uemail = user.email;
    print(uid);
    email = user.email;
    setState(() {
      userName = uid;
    });
    //print(uemail);
  }

  int x = 0;

  @override
  void dispose() {
    // clear users
    _users.clear();
    // destroy sdk
    AgoraRtcEngine.leaveChannel();
    AgoraRtcEngine.destroy();
    _delmessages();
    super.dispose();
  }

  void _delmessages() {
    if ((email.hashCode).toString() == widget.channelName) {
      _firestore.collection(widget.channelName).getDocuments().then((snapshot) {
        for (DocumentSnapshot ds in snapshot.documents) {
          ds.reference.delete();
        }
      });
      _firestore
          .collection('useraddons')
          .document(widget.channelName)
          .collection(widget.channelName)
          .getDocuments()
          .then((snapshot) {
        for (DocumentSnapshot ds in snapshot.documents) {
          ds.reference.delete();
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // initialize agora sdk
    initialize();
  }

  Future<void> initialize() async {
    if (APP_ID.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await AgoraRtcEngine.enableWebSdkInteroperability(true);
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = Size(1280, 720);
    configuration.orientationMode = VideoOutputOrientationMode.Adaptative;
    await AgoraRtcEngine.setVideoEncoderConfiguration(configuration);
    await AgoraRtcEngine.joinChannel(null, widget.channelName, null, 0);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    await AgoraRtcEngine.create(APP_ID);
    await AgoraRtcEngine.enableVideo();
    await AgoraRtcEngine.enableAudio();
    await AgoraRtcEngine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await AgoraRtcEngine.setClientRole(widget.role);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    AgoraRtcEngine.onError = (dynamic code) {
      setState(() {
        final info = 'onError: $code';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onJoinChannelSuccess = (
      String channel,
      int uid,
      int elapsed,
    ) {
      setState(() {
        final info = 'onJoinChannel: $channel, uid: $uid';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onLeaveChannel = () {
      setState(() {
        _infoStrings.add('onLeaveChannel');
        _users.clear();
      });
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      setState(() {
        isOnline = true;
        final info = 'userJoined: $userName';
        _infoStrings.add(info);
        _users.add(uid);
      });
    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      setState(() {
        isOnline = false;
        final info = 'userOffline: $userName';
        _infoStrings.add(info);
        _users.remove(uid);
      });
    };

    AgoraRtcEngine.onFirstRemoteVideoFrame = (
      int uid,
      int width,
      int height,
      int elapsed,
    ) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoStrings.add(info);
      });
    };
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<AgoraRenderWidget> list = [];
    if (widget.role == ClientRole.Broadcaster) {
      list.add(AgoraRenderWidget(0, local: true, preview: true));
    }
    _users.forEach((int uid) => list.add(AgoraRenderWidget(uid)));
    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper

  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
          children: <Widget>[_videoView(views[0])],
        ));
      default:
        return Container();
    }
  }

  /// Toolbar layout
  Widget _toolbar() {
    if (widget.role == ClientRole.Audience)
      return Container(
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RawMaterialButton(
              onPressed: _chatScreen,
              child: Icon(
                Icons.message,
                color: Colors.black,
                size: 20.0,
              ),
              elevation: 2.0,
              fillColor: Colors.greenAccent,
              padding: const EdgeInsets.all(12.0),
            ),
            RawMaterialButton(
              onPressed: () => _onCallEnd(context),
              child: Icon(
                Icons.call_end,
                color: Colors.white,
                size: 20.0,
              ),
              elevation: 2.0,
              fillColor: Colors.redAccent,
              padding: const EdgeInsets.all(12.0),
            ),
          ],
        ),
      );
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RawMaterialButton(
              onPressed: _chatScreen,
              child: Icon(
                Icons.message,
                color: Colors.black,
                size: 15.0,
              ),
              elevation: 2.0,
              fillColor: Colors.greenAccent,
              padding: const EdgeInsets.all(12.0),
            ),
            RawMaterialButton(
              onPressed: _onToggleMute,
              child: Icon(
                muted ? Icons.mic_off : Icons.mic,
                color: muted ? Colors.white : Colors.black,
                size: 15.0,
              ),
              elevation: 2.0,
              fillColor: muted ? Colors.blueAccent : Colors.greenAccent,
              padding: const EdgeInsets.all(12.0),
            ),
            RawMaterialButton(
              onPressed: () => _onCallEnd(context),
              child: Icon(
                Icons.call_end,
                color: Colors.white,
                size: 15.0,
              ),
              elevation: 2.0,
              fillColor: Colors.redAccent,
              padding: const EdgeInsets.all(12.0),
            ),
            RawMaterialButton(
              onPressed: _onSwitchCamera,
              child: Icon(
                Icons.switch_camera,
                color: Colors.black,
                size: 15.0,
              ),
              elevation: 2.0,
              fillColor: Colors.greenAccent,
              padding: const EdgeInsets.all(12.0),
            )
          ],
        ),
        Container(
            child: Center(
                child: Text(
          "Share your Broadcast ID with others.",
          style: TextStyle(color: Colors.grey.shade700),
        )))
      ]),
    );
  }

  /// Info panel to show logs

  Widget buildItem(BuildContext context, DocumentSnapshot document) {

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 3,
        horizontal: 10,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 2,
                horizontal: 5,
              ),
              decoration: BoxDecoration(
                color: Colors.greenAccent,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                "${document['userName']} has joined",
                style: TextStyle(color: Colors.black),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _onCallEnd(BuildContext context) {
    Navigator.pop(context);
  }

  void _chatScreen() {
    Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) => ChatScreen(
              collectionID: widget.channelName,
              userRole: widget.role,
            )));
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    AgoraRtcEngine.muteLocalAudioStream(muted);
  }

  bool isOnline = true;

  void _onSwitchCamera() {
    AgoraRtcEngine.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Broadcast ID :${widget.channelName} ",
          style: TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black.withOpacity(0),

      ),
      resizeToAvoidBottomPadding: false,
      body: Center(
        child: Stack(
          children: <Widget>[
            (isOnline || widget.role == ClientRole.Broadcaster)
                ? _viewRows()
                : Container(
                    child: Center(
                      child: Text(
                        "Looks like there's no broadcaster here.",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
            _toolbar(),
            StreamBuilder(
              stream: Firestore.instance
                  .collection('useraddons')
                  .document(widget.channelName)
                  .collection(widget.channelName)
                  .orderBy('time', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: Text(
                    "No User joined",
                    style: TextStyle(color: Colors.black),
                  ));
                } else {

                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 80),
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: 0.5,
                      child: ListView.builder(
                        padding: EdgeInsets.all(10.0),
                        itemBuilder: (context, index) =>
                            buildItem(context, snapshot.data.documents[index]),
                        itemCount: snapshot.data.documents.length,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
