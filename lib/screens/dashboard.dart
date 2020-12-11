import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kaksha/screens/Recents.dart';
import 'package:kaksha/screens/Settings.dart';
import 'package:kaksha/screens/broadcast.dart';
import 'package:kaksha/screens/chatscreen.dart';
import 'package:permission_handler/permission_handler.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

String userName;
String email;

class _MainScreenState extends State<MainScreen> {
  bool focus1 = false;
  bool focus3 = false;
  bool focus2 = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _handleCameraAndMic() async {
    await PermissionHandler().requestPermissions(
      [PermissionGroup.camera, PermissionGroup.microphone],
    );
  }

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  void dataHandler(String channelName) async {
    try {
      await Firestore.instance
          .collection('recents')
          .document(email).collection(email).document(channelName)
          .setData({
        'room': channelName,
        'time': DateTime
            .now()
            .millisecondsSinceEpoch
            .toString()
      });
    }
    catch(e){
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.grey.shade50,
            automaticallyImplyLeading: false,
          ),
          body: Stack(children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                "Hello $userName!",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 32),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(35.0),
                      child: Text(
                        "You can create a broadcast or join someones' broadcast created using this App.",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await _handleCameraAndMic();

                      var eHash = email.hashCode;
                      FlutterToast.showToast(
                          msg: 'Channel with $eHash created.');
                      dataHandler(eHash.toString());
                      await Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => CallPage(
                                    channelName: eHash.toString(),
                                    role: ClientRole.Broadcaster,
                                    userName: userName,
                                  )));

                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.height * 0.06,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                                color: Colors.greenAccent, width: 1)),
                        child: Center(
                          child: Text(
                            "Start a broadcast",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 19,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(PageRouteBuilder(
                          opaque: false,
                          pageBuilder: (BuildContext context, _, __) => S()));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.height * 0.06,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                                color: Colors.greenAccent, width: 1)),
                        child: Center(
                          child: Text(
                            "Join a broadcast",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 19,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Container(
                              height: 70,
                              width: 80,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(40),
                                  color: Colors.greenAccent),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        focus1 = true;
                                        focus2 = false;
                                        focus3 = false;
                                      });
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Settings()));
                                      print("hello!");
                                    },
                                    icon: Icon(
                                      Icons.settings,
                                      color: focus1
                                          ? Colors.blueAccent
                                          : Colors.black,
                                      size: 27,
                                    ),
                                  ),
                                  Text(
                                    "Settings",
                                    style: TextStyle(
                                        color: focus1
                                            ? Colors.blueAccent
                                            : Colors.black),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          height: 1,
                          color: Colors.black,
                        ),
                        Container(
                          height: 70,
                          width: 80,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              color: Colors.greenAccent),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    focus2 = true;
                                    focus1 = false;
                                    focus3 = false;
                                  });

                                  print("hello!");
                                },
                                icon: Icon(
                                  Icons.home,
                                  color:
                                      focus2 ? Colors.blueAccent : Colors.black,
                                  size: 27,
                                ),
                              ),
                              Text(
                                "Home",
                                style: TextStyle(
                                    color: focus2
                                        ? Colors.blueAccent
                                        : Colors.black),
                              )
                            ],
                          ),
                        ),
                        Divider(
                          height: 1,
                          color: Colors.black,
                        ),
                        Container(
                          height: 70,
                          width: 80,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              color: Colors.greenAccent),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    focus3 = true;
                                    focus2 = false;
                                    focus1 = false;
                                  });
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => RecentsPage()));
                                  print("hello!");
                                },
                                icon: Icon(
                                  Icons.history,
                                  color:
                                      focus3 ? Colors.blueAccent : Colors.black,
                                  size: 27,
                                ),
                              ),
                              Text(
                                "History",
                                style: TextStyle(
                                    color: focus3
                                        ? Colors.blueAccent
                                        : Colors.black),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            )
          ]),
        ));
  }
}

class S extends StatefulWidget {
  @override
  _SState createState() => _SState();
}

class _SState extends State<S> {
  String channelName;

  Future<void> _handleCameraAndMic() async {
    await PermissionHandler().requestPermissions(
      [PermissionGroup.camera, PermissionGroup.microphone],
    );
  }

  void dataHandler(String channelName) async {
    try {
      await Firestore.instance
          .collection('recents')
          .document(email).collection(email).document(channelName)
          .setData({
        'room': channelName,
        'time': DateTime
            .now()
            .millisecondsSinceEpoch
            .toString()
      });
        await Firestore.instance
            .collection('useraddons')
            .document(channelName).collection(channelName).document(userName)
            .setData({
          'userName': userName,
          'time': DateTime
              .now()
              .millisecondsSinceEpoch
              .toString()
        });

    }
    catch(e){
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.55),
      body: Center(
        child: Container(
          height: 200,
          width: 275,
          decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200, width: 1)),
          child: Center(
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Enter BroadCast ID",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: (value) {
                      channelName = value;
                    },
                    decoration: new InputDecoration(
                        labelText: 'Broadcast ID',
                        hintText: '123',
                        helperText: 'Enter Broadcast ID',
                        border: new OutlineInputBorder(
                            borderSide:
                                new BorderSide(color: Colors.greenAccent))),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await _handleCameraAndMic();
                    if (channelName != null)  {
                      await FlutterToast.showToast(msg: '$channelName joined.');
                      await dataHandler(channelName);
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => CallPage(
                                    channelName: channelName,
                                    role: ClientRole.Audience,
                                    userName: userName,
                                  )));
                    } else {
                      FlutterToast.showToast(
                          msg: 'Channel Name cannot be Null');
                    }
                  },
                  child: Container(
                    height: 50,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: Colors.grey, width: 1),
                    ),
                    child: Center(
                      child: Text(
                        "Join",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
