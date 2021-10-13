// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

List<Order> orderFromJson(String str) => List<Order>.from(json.decode(str).map((x) => Order.fromJson(x)));

String orderToJson(List<Order> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Order {
  Order({
    required this.id,
    required this.userId,
    required this.status,
    this.products,
  });

  String id;
  String userId;
  String status;
  dynamic products;

  factory Order.fromJson(Map<dynamic, dynamic> json) => Order(
    id: json["_id"],
    userId: json["userId"],
    status: json["status"],
    products: json["products"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "userId": userId,
    "status": status,
    "products": products,
  };

  @override toString() => 'id: $id, userId: $userId, status: $status, products: $products';
}

class Product {
  Product({
    required this.productId,
    required this.quantity,
    required this.price,
    required this.vendor,
    required this.name,
  });

  String productId;
  int quantity;
  String price;
  Vendor vendor;
  String name;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    productId: json["productId"],
    quantity: json["quantity"],
    price: json["price"],
    vendor: Vendor.fromJson(json["vendor"]),
    name: json["name"] == null ? null : json["name"],
  );

  Map<String, dynamic> toJson() => {
    "productId": productId,
    "quantity": quantity,
    "price": price,
    "vendor": vendor.toJson(),
    "name": name == null ? null : name,
  };
}

class Vendor {
  Vendor({
    required this.vendorId,
    required this.location,
  });

  String vendorId;
  Location location;

  factory Vendor.fromJson(Map<String, dynamic> json) => Vendor(
    vendorId: json["vendorId"],
    location: Location.fromJson(json["location"]),
  );

  Map<String, dynamic> toJson() => {
    "vendorId": vendorId,
    "location": location.toJson(),
  };
}

class Location {
  Location({
    required this.latitude,
    required this.longitude,
  });

  double latitude;
  double longitude;

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    latitude: json["latitude"].toDouble(),
    longitude: json["longitude"].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "latitude": latitude,
    "longitude": longitude,
  };
}
