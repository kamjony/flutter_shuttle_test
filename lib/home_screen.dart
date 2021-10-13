import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:http/http.dart' as http;
import 'package:shuttle_test/select_location.dart';

import 'model/order.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.currentUser}) : super(key: key);

  final User currentUser;



  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String? _token;

  List<dynamic> orderList = [];
  List<dynamic> productList =[];

  ScrollController _scrollController = ScrollController();
  DatabaseReference db = FirebaseDatabase(
      databaseURL: "https://shuttletest-8ce9c-default-rtdb.asia-southeast1.firebasedatabase.app"
  ).reference();




  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseMessaging.instance.subscribeToTopic('topic');


  }

  Future<void> sendPushMessage() async {
    _token = await FirebaseMessaging.instance.getToken();
    print(_token);
    if (_token == null) {
      print('Unable to send FCM message, no token exists.');
      return;
    }

    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=AAAAA-0hBf8:APA91bHO4XKPl-1rbipqHVmqM53a59hgeXAYRcLZf_oxM42LX0K8LRXUfpbZ-IMVK3hX4cq13Vs0pX_cdcUIlONNL0JSJ9X3RKSO4zAEJyccWolhucDfmOHNjj0LSum9kKApAEbyGHfd',
        },
        body: constructFCMPayload(_token),
      );
      print('FCM request for device sent!');
    } catch (e) {
      print(e);
    }
  }

  /// The API endpoint here accepts a raw FCM payload for demonstration purposes.
  String constructFCMPayload(String? token) {
    return jsonEncode({
      'to': '/topics/topic',
      "priority": "high",
      'notification': {
        'title': 'Status',
        'body': 'Order Status Changed',
        'text': "Text"
      },
    });
  }

  updateStatusInDB(String text, int index){
    db.child('order/${index}/status').set(text);
    sendPushMessage();
    print('success');
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8,),
              Text("You are Logged in succesfully", style: TextStyle(color: Colors.lightBlue, fontSize: 18),),
              SizedBox(height: 8,),
              Text("${widget.currentUser.phoneNumber}", style: TextStyle(color: Colors.grey, fontSize: 18),),
              FutureBuilder(
                  future: db.child("order").once(),
                  builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
                    if (snapshot.hasData) {
                      orderList.clear();
                      productList.clear();
                      final values = snapshot.data!.value;
                      values.forEach((values) {
                        orderList.add(values);
                      });

                      return new ListView.builder(
                          shrinkWrap: true,
                          itemCount: orderList.length,
                          itemBuilder: (BuildContext context, int index) {
                          List<dynamic> product = orderList[index]["products"];
                          var totalQuantity = 0;
                          var totalPrice = 0.00;

                          var userId = orderList[index]["userId"];
                          var orderId = orderList[index]["_id"];

                          //this is to calculate total quantity & price of products in an order
                          for (var entry in product) {
                            print("key" + entry["quantity"].toString());
                            int quan = entry["quantity"];
                            var price = entry["price"];
                            if (quan != null) {
                              totalQuantity = totalQuantity + quan;
                            }
                            if (price != null){
                              print('$price');
                              totalPrice  = totalPrice + price;
                            }
                          }
                          print("totalQuantity: " + totalQuantity.toString());
                          print("totalPrice: " + totalPrice.toString());


                            return InkWell(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text("Update Status to: "),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            InkWell(child: Text('pending'), onTap: () {
                                              updateStatusInDB('pending', index);
                                              Navigator.of(context).pop();
                                              setState(() {
                                              });
                                            },),
                                            SizedBox(height: 5,),
                                            InkWell(child: Text('confirmed'), onTap: () {
                                              updateStatusInDB('confirmed', index);
                                              Navigator.of(context).pop();
                                              setState(() {

                                              });
                                            },),
                                            SizedBox(height: 5,),
                                            InkWell(child: Text('cancelled'), onTap: () {
                                              updateStatusInDB('cancelled', index);
                                              Navigator.of(context).pop();
                                              setState(() {

                                              });
                                            },),
                                          ],
                                        ),
                                      );
                                    });
                              },
                              child: Card(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text("orderId: " +orderList[index]["_id"]),
                                    SizedBox(height: 5,),
                                    new FutureBuilder(
                                        future: db.child("user").orderByChild("_id").equalTo("$userId").once(),
                                        builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
                                          if (snapshot.hasData){
                                            final values = snapshot.data!.value;
                                            for (var entry in values.entries) {
                                              return Text("userName: " + entry.value['name']);
                                            }
                                          }
                                          return CircularProgressIndicator();
                                          }
                                        ),
                                    SizedBox(height: 5,),
                                    Text("Status: " +orderList[index]["status"]),
                                    SizedBox(height: 5,),
                                    Text("Total Quantity: " +totalQuantity.toString()),
                                    SizedBox(height: 5,),
                                    Text("Total Price: \$" +totalPrice.toString()),
                                  ],
                                ),
                              ),
                            );
                          });
                    }
                    return CircularProgressIndicator();
                  }),
              ElevatedButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => SelectLocation()
                    ));
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                  ),
                  child: Text("Go to Location Selector")),

            ],
          ),
        ),
      ),
    );
  }
}

