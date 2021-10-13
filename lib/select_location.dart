import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shuttle_test/nearby_location.dart';

class SelectLocation extends StatefulWidget {
  const SelectLocation({Key? key}) : super(key: key);

  @override
  _SelectLocationState createState() => _SelectLocationState();
}

class _SelectLocationState extends State<SelectLocation> {

  List<dynamic> locationList = [];
  List<dynamic> productList =[];

  DatabaseReference db = FirebaseDatabase(
      databaseURL: "https://shuttletest-8ce9c-default-rtdb.asia-southeast1.firebasedatabase.app"
  ).reference().child("location");


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: EdgeInsets.all(32),
        child: FutureBuilder(
            future: db.once(),
            builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
              if (snapshot.hasData) {
                locationList.clear();
                productList.clear();
                final values = snapshot.data!.value;
                values.forEach((values) {
                  locationList.add(values);
                });

                return new ListView.builder(
                    shrinkWrap: true,
                    itemCount: locationList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        child: InkWell(
                          onTap: () {
                            print(locationList[index]["latitude"]);
                            print(locationList[index]["longitude"]);
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => NearbyLocation(lat: locationList[index]["latitude"], long: locationList[index]["longitude"])
                            ));
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(height: 15,),
                              Container(
                                padding: EdgeInsets.all(5),
                                  child: Center(child: Text(locationList[index]["name"]))),
                              SizedBox(height: 15,),
                            ],
                          ),
                        ),
                      );
                    });
              }
              return CircularProgressIndicator();
            }),
      ),
    );
  }
}
