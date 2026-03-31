class HubPerformanceViewOrderDetailsModel {
  String? message;
  HubPerformanceViewOrderDetailsData? data;

  HubPerformanceViewOrderDetailsModel({this.message, this.data});

  HubPerformanceViewOrderDetailsModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? HubPerformanceViewOrderDetailsData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class HubPerformanceViewOrderDetailsData {
  Order? order;
  List<Items>? items;
  // List<Null>? timeline;

  HubPerformanceViewOrderDetailsData({this.order, this.items,
    // this.timeline
  });

  HubPerformanceViewOrderDetailsData.fromJson(Map<String, dynamic> json) {
    order = json['order'] != null ? Order.fromJson(json['order']) : null;
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(Items.fromJson(v));
      });
    }
    // if (json['timeline'] != null) {
    //   timeline = <Null>[];
    //   json['timeline'].forEach((v) {
    //     timeline!.add(new Null.fromJson(v));
    //   });
    // }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (order != null) {
      data['order'] = order!.toJson();
    }
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    // if (this.timeline != null) {
    //   data['timeline'] = this.timeline!.map((v) => v.toJson()).toList();
    // }
    return data;
  }
}

class Order {
  dynamic id;
  dynamic orderNo;
  dynamic couponid;
  dynamic userid;
  dynamic citymanagerid;
  dynamic hubmanagerid;
  dynamic deliverypartnerid;
  dynamic totalAmount;
  dynamic deliveryCharge;
  dynamic finalAmount;
  dynamic paymentMethod;
  dynamic paymentStatus;
  dynamic status;
  dynamic createdAt;
  dynamic updatedAt;
  dynamic deliveredAt;
  dynamic customerName;
  dynamic phone;
  dynamic address;
  dynamic pincode;
  dynamic landmark;
  dynamic deliveryBoy;

  Order(
      {this.id,
        this.orderNo,
        this.couponid,
        this.userid,
        this.citymanagerid,
        this.hubmanagerid,
        this.deliverypartnerid,
        this.totalAmount,
        this.deliveryCharge,
        this.finalAmount,
        this.paymentMethod,
        this.paymentStatus,
        this.status,
        this.createdAt,
        this.updatedAt,
        this.deliveredAt,
        this.customerName,
        this.phone,
        this.address,
        this.pincode,
        this.landmark,
        this.deliveryBoy});

  Order.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderNo = json['order_no'];
    couponid = json['couponid'];
    userid = json['userid'];
    citymanagerid = json['citymanagerid'];
    hubmanagerid = json['hubmanagerid'];
    deliverypartnerid = json['deliverypartnerid'];
    totalAmount = json['total_amount'];
    deliveryCharge = json['delivery_charge'];
    finalAmount = json['final_amount'];
    paymentMethod = json['payment_method'];
    paymentStatus = json['payment_status'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deliveredAt = json['delivered_at'];
    customerName = json['customer_name'];
    phone = json['phone'];
    address = json['address'];
    pincode = json['pincode'];
    landmark = json['landmark'];
    deliveryBoy = json['delivery_boy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_no'] = orderNo;
    data['couponid'] = couponid;
    data['userid'] = userid;
    data['citymanagerid'] = citymanagerid;
    data['hubmanagerid'] = hubmanagerid;
    data['deliverypartnerid'] = deliverypartnerid;
    data['total_amount'] = totalAmount;
    data['delivery_charge'] = deliveryCharge;
    data['final_amount'] = finalAmount;
    data['payment_method'] = paymentMethod;
    data['payment_status'] = paymentStatus;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['delivered_at'] = deliveredAt;
    data['customer_name'] = customerName;
    data['phone'] = phone;
    data['address'] = address;
    data['pincode'] = pincode;
    data['landmark'] = landmark;
    data['delivery_boy'] = deliveryBoy;
    return data;
  }
}

class Items {
  dynamic productName;
  dynamic price;
  dynamic qty;
  dynamic totalPrice;
  dynamic img;

  Items({this.productName, this.price, this.qty, this.totalPrice,this.img});

  Items.fromJson(Map<String, dynamic> json) {
    productName = json['product_name'];
    price = json['price'];
    qty = json['qty'];
    totalPrice = json['total_price'];
    img = json['img'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['product_name'] = productName;
    data['price'] = price;
    data['qty'] = qty;
    data['total_price'] = totalPrice;
    data['img'] = img;
    return data;
  }
}
