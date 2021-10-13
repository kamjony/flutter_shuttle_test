import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:latlong2/latlong.dart';

class NearbyLocation extends StatefulWidget {
  const NearbyLocation({Key? key, required this.lat, required this.long}) : super(key: key);

  final lat;
  final long;

  @override
  _NearbyLocationState createState() => _NearbyLocationState();
}



class _NearbyLocationState extends State<NearbyLocation> {
  List<dynamic> orderList = [];
  List<dynamic> productList = [];

  var location;

  var address;
  ScrollController _scrollController = ScrollController();



  DatabaseReference db = FirebaseDatabase(
      databaseURL: "https://shuttletest-8ce9c-default-rtdb.asia-southeast1.firebasedatabase.app"
  ).reference();

  DatabaseReference db2 = FirebaseDatabase(
      databaseURL: "https://shuttletest-8ce9c-default-rtdb.asia-southeast1.firebasedatabase.app"
  ).reference();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("${widget.lat} , ${widget.long}");

  }

  getLocationName(double lat, lng) async {
    // From coordinates
    final coordinates = new Coordinates(lat, lng);
    var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    location = addresses.first;
    // print("${first.featureName} : ${first.addressLine}");
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            new FutureBuilder(
                future: db.child("order").once(),
                builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
                  if (snapshot.hasData) {
                    orderList.clear();
                    final values = snapshot.data!.value;
                    values.forEach((values) {
                      orderList.add(values);
                      // for (int i = 0; i < orderList.length; i++) {
                      //   productList.add(orderList[i]["products"]);
                      //   print('productList: ' + productList.toString());
                      // }
                    });

                    for (var entry in orderList) {
                      print("key" + entry["products"][0].toString());

                      productList.addAll(entry["products"]);
                      print('listSize: '+ productList.length.toString());
                    }

                    print('orderList: ' + orderList[3].toString());

                    return ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: productList.length,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          var productLat = productList[index]['vendor']['location']['latitude'];
                          var productLong = productList[index]['vendor']['location']['longitude'];
                          var productId = productList[index]['productId'];

                          final Distance distance = new Distance();

                          final km = distance.as(LengthUnit.Kilometer,
                              new LatLng(widget.lat, widget.long),new LatLng(productLat,productLong));


                          if (km < 3.0) {
                            var newLat = productList[index]['vendor']['location']['latitude'];
                            var newLong = productList[index]['vendor']['location']['longitude'];

                            return Column(
                              children: [
                                Text('Order Id: '),
                                SizedBox(height: 5,),
                                Text('Product Id: ' + productList[index]['productId'].toString()),
                                SizedBox(height: 5,),
                                Text('Vendor Id: ' + productList[index]['vendor']['vendorId'].toString()),
                                SizedBox(height: 5,),
                                new FutureBuilder(
                                  future: getLocationName(newLat, newLong),
                                  builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                                    if (location != null) {
                                      return Text("Location: " + location.addressLine);
                                    }
                                    return Text("");
                                  },

                                ),
                                SizedBox(height: 20,),
                              ],
                            );
                          } else {
                            return Container(
                              color: Colors.blue,
                            );
                          }


                        }
                    );
                  }
                  return CircularProgressIndicator();
                }),
          ],
        ),
      )
    );
  }
}
