

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kaksha/screens/Settings.dart';
import 'package:kaksha/screens/dashboard.dart';

class RecentsPage extends StatefulWidget {
  @override
  _RecentsPageState createState() => _RecentsPageState();
}


class _RecentsPageState extends State<RecentsPage> {
  bool focus1 = false;
  bool focus3 = true;
  bool focus2 = false;
  String email;
  String userName;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  getCurrentUser() async {
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.displayName;
    // Similarly we can get email as well
    //final uemail = user.email;
    print("hey"+uid);

    setState(() {
      email = user.email;
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

  Widget buildItem(BuildContext context , DocumentSnapshot document){
    return Column(
      children: <Widget>[
        Container(
          height: 100,

          child: FlatButton(
            child: Row(
              children: <Widget>[

                Flexible(
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Text(
                            'BroadCast ID :${document['room']}',
                            style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 18),
                          ),
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.fromLTRB(10.0, 25.0, 0.0, 5.0),
                        ),
                        Container(
                          child: Text(
                            "Time :${DateTime.fromMillisecondsSinceEpoch(int.parse(document['time']) ).toString()}",
                            style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400,fontSize: 16),
                          ),
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                        )
                      ],
                    ),
                    margin: EdgeInsets.only(left: 20.0),
                  ),
                ),
              ],
            ),
            onPressed: () {

            },
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(25.0, 2.0, 25.0, 2.0),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0),),
          ),
          decoration: BoxDecoration(
            border: Border.all(color:Colors.greenAccent,width: 1),
            borderRadius: BorderRadius.circular(12)
          ),
          margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
        ),
      ],
    );

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey.shade50,
        elevation: 0,
        title: Text("Broadcast History",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 28),),
      ),
      body: Stack(
        children: <Widget>[
          Container(
              child: StreamBuilder(
                stream: Firestore.instance.collection('recents')
                    .document(email)
                    .collection(email).orderBy('time', descending: false).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData ) {
                    return Center(
                        child:Text("No History Found",style: TextStyle(color: Colors.black),)
                    );
                  } else {
                    return ListView.builder(
                      padding: EdgeInsets.all(10.0),
                      itemBuilder: (context, index) =>
                          buildItem(context, snapshot.data.documents[index]),
                      itemCount: snapshot.data.documents.length,
                    );
                  }
                },
              )
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

                                    Navigator.push(context,MaterialPageRoute(builder: (context) => Settings()));

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

                                Navigator.push(context,MaterialPageRoute(builder: (context) => MainScreen()));

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
        ],
      ),
    );
  }
}
