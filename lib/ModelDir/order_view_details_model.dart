class OrderViewDataModel {
  String? message;
  OrderViewData? data;

  OrderViewDataModel({this.message, this.data});

  OrderViewDataModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? OrderViewData.fromJson(json['data']) : null;
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

class OrderViewData {
  Order? order;
  List<Items>? items;
  Payment? payment;
  List<Tracking>? tracking;

  OrderViewData({this.order, this.items, this.payment, this.tracking});

  OrderViewData.fromJson(Map<String, dynamic> json) {
    order = json['order'] != null ? Order.fromJson(json['order']) : null;
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(Items.fromJson(v));
      });
    }
    payment =
    json['payment'] != null ? Payment.fromJson(json['payment']) : null;
    if (json['tracking'] != null) {
      tracking = <Tracking>[];
      json['tracking'].forEach((v) {
        tracking!.add(Tracking.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (order != null) {
      data['order'] = order!.toJson();
    }
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    if (payment != null) {
      data['payment'] = payment!.toJson();
    }
    if (tracking != null) {
      data['tracking'] = tracking!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Order {
  dynamic id;
  dynamic orderNo;
  dynamic userid;
  dynamic citymanagerid;
  dynamic hubmanagerid;
  dynamic deliverypartnerid;
  dynamic totalAmount;
  dynamic deliveryCharge;
  dynamic finalAmount;
  Null paymentMethod;
  dynamic paymentStatus;
  dynamic status;
  dynamic createdAt;
  dynamic updatedAt;
  dynamic customerName;
  dynamic customerPhone;
  dynamic hubName;
  dynamic deliveryName;
  dynamic deliveryPhone;
  dynamic address;
  dynamic city;
  dynamic pincode;
  dynamic landmark;

  Order(
      {this.id,
        this.orderNo,
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
        this.customerName,
        this.customerPhone,
        this.hubName,
        this.deliveryName,
        this.deliveryPhone,
        this.address,
        this.city,
        this.pincode,
        this.landmark});

  Order.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderNo = json['order_no'];
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
    customerName = json['customer_name'];
    customerPhone = json['customer_phone'];
    hubName = json['hub_name'];
    deliveryName = json['delivery_name'];
    deliveryPhone = json['delivery_phone'];
    address = json['address'];
    city = json['city'];
    pincode = json['pincode'];
    landmark = json['landmark'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_no'] = orderNo;
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
    data['customer_name'] = customerName;
    data['customer_phone'] = customerPhone;
    data['hub_name'] = hubName;
    data['delivery_name'] = deliveryName;
    data['delivery_phone'] = deliveryPhone;
    data['address'] = address;
    data['city'] = city;
    data['pincode'] = pincode;
    data['landmark'] = landmark;
    return data;
  }
}

class Items {
  dynamic id;
  dynamic productId;
  dynamic productName;
  dynamic price;
  dynamic qty;
  dynamic totalPrice;
  dynamic img;

  Items(
      {this.id,
        this.productId,
        this.productName,
        this.price,
        this.qty,
        this.totalPrice,
        this.img});

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['product_id'];
    productName = json['product_name'];
    price = json['price'];
    qty = json['qty'];
    totalPrice = json['total_price'];
    img = json['img'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['product_id'] = productId;
    data['product_name'] = productName;
    data['price'] = price;
    data['qty'] = qty;
    data['total_price'] = totalPrice;
    data['img'] = img;
    return data;
  }
}

class Payment {
  dynamic transactionId;
  dynamic paymentMethod;
  dynamic amount;
  dynamic status;

  Payment({this.transactionId, this.paymentMethod, this.amount, this.status});

  Payment.fromJson(Map<String, dynamic> json) {
    transactionId = json['transaction_id'];
    paymentMethod = json['payment_method'];
    amount = json['amount'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['transaction_id'] = transactionId;
    data['payment_method'] = paymentMethod;
    data['amount'] = amount;
    data['status'] = status;
    return data;
  }
}

class Tracking {
  dynamic status;
  dynamic createdAt;

  Tracking({this.status, this.createdAt});

  Tracking.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['created_at'] = createdAt;
    return data;
  }
}
