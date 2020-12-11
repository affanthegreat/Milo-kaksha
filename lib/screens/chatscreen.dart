import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kaksha/screens/utils/constants.dart';

final _firestore = Firestore.instance;
FirebaseUser loggedInUser;
 String coll;

// ignore: must_be_immutable
class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  String collectionID;
  final ClientRole userRole;
  
  ChatScreen({this.collectionID,this.userRole});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;

  String messageText;

  final textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    coll =widget.collectionID ;
    
  }

  void getCurrentUser() async {
    try {
      final currentUser = await _auth.currentUser();
      if (currentUser != null) {
        loggedInUser = currentUser;
      }
    } catch (e) {
      print(e);
      //TODO: handle get current user errors
      kErrorMsgAlert(context).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.6),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: null,
        title: Text("Broadcast ID :${widget.collectionID}",style: TextStyle(color: Colors.white,fontSize: 14,fontWeight: FontWeight.bold),),

//        actions: <Widget>[
//          IconButton(
//              icon: Icon(Icons.close),
//              onPressed: () {
//                //Implement logout functionality
//                Navigator.push(context,MaterialPageRoute(builder: (context) => CallPage(channelName: widget.collectionID,role: widget.userRole,userName: loggedInUser.displayName,)));
//              }),
//        ],
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FlatButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: Text("Close Messages",style: TextStyle(color: Colors.black),),
            color: Colors.greenAccent,
          ),
        )
      ],
        elevation: 0,
        backgroundColor: Colors.black.withOpacity(0),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      color: Colors.black.withOpacity(0.7),
                      child: TextField(
                        style: TextStyle(color: Colors.white),
                        autofocus: true,
                        controller: textEditingController,
                        onChanged: (value) {
                          //Do something with the user input.
                          messageText = value;
                        },
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      //Implement send functionality.
                      textEditingController.clear();
                      _firestore.collection(widget.collectionID).add({
                        'msg': messageText,
                        'sender': loggedInUser.displayName,
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                    color:  Colors.black.withOpacity(0.7),
                    
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection(coll).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator(
            backgroundColor: Colors.lightBlue,
          );
        }

        List<TextBubble> messageBubbles = [];

        final messages = snapshot.data.documents.reversed;
        for (var message in messages) {
          final msg = message.data['msg'];
          final sender = message.data['sender'];

          if (msg != null) {
            messageBubbles.add(TextBubble(
              msg: msg,
              sender: sender,
              isMe: loggedInUser.displayName == sender,
            ));
          }
        }
        return Expanded(
            child: ListView(reverse: true, children: messageBubbles));
      },
    );
  }
}

class TextBubble extends StatelessWidget {
  TextBubble({this.msg, this.sender, this.isMe = false});

  final String msg;
  final String sender;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
               CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            sender,
            style: TextStyle(
              fontSize: 13.0,
              color: Colors.white,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 8.0, top: 5.0),
            child: Material(
              elevation: 5.0,
              borderRadius: BorderRadius.only(
                      topRight: Radius.circular(15.0),
                      topLeft: Radius.circular(15.0),
                      bottomRight: Radius.circular(15.0),
                    ),
              color: Colors.grey.shade700,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 10.0,
                ),
                child: Text(
                  msg,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
