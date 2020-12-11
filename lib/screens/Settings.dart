import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kaksha/screens/Recents.dart';
import 'package:kaksha/screens/dashboard.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool focus1 = true;
  bool focus3 = false;
  bool focus2 = false;
  String email;
  String userName;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  _signOut() async {
    await _auth.signOut();
    FlutterToast.showToast(msg: "Logged Out");
    GoogleSignIn().signOut();

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade50,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: <Widget>[

          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      "Settings",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 32,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.2,
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.greenAccent,width: 0.9),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Text(
                            "Your Info",
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.black
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text("Name :",
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w400,
                                color: Colors.black
                            ),
                          ),
                          Text("$userName",
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                              color: Colors.black
                          ),)
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text("Email :",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.black
                            ),
                          ),
                          Text("$email",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black
                            ),)
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("*These values correspond to your signed in Gmail Account",style: TextStyle(color: Colors.grey,fontSize: 12),),
                    ),

                  ],
                ),

              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Divider(thickness: 1,color: Colors.grey.shade200,),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.2,
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.greenAccent,width: 0.9),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Text(
                            "About App",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.black
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Milo Beta",
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                            color: Colors.black
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Version 1.0",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Colors.black
                        ),
                      ),
                    ),

                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Divider(thickness: 1,color: Colors.grey.shade200,),
              ),
              GestureDetector(
                onTap: () async {
                  const url = "https://undercover-canister.000webhostapp.com/";
                  if(await canLaunch(url)){
                    await launch(url);
                  }else{
                    throw 'Could Launch URL';
                  }
                },
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.07,
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black,width: 0.3)
                  ),
                  child: Center(
                    child: Text("Privacy Policy",style: TextStyle(fontSize: 21,fontWeight: FontWeight.w700
                    ),),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Divider(thickness: 1,color: Colors.grey.shade200,),
              ),
              GestureDetector(
                onTap: _signOut,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.08,
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black,width: 0.3)
                  ),
                  child: Center(
                    child: Text("Sign Out",style: TextStyle(fontSize: 25,fontWeight: FontWeight.w700
                    ),),
                  ),
                ),
              )

            ],
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
                                Navigator.push(context,MaterialPageRoute(builder: (context) => RecentsPage()));
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
