class CheckoutPayload {
  int customerId;
  int warehouseId;
  int billerId;
  String saleStatus;
  String paymentStatus;
  String? note;
  double? shipping;
  List<CheckoutItem> items;
  CheckoutPayment? payment;

  CheckoutPayload({
    this.customerId = 1,
    this.warehouseId = 1,
    this.billerId = 1,
    this.saleStatus = 'pending',
    this.paymentStatus = 'pending',
    this.note,
    this.shipping,
    required this.items,
    this.payment,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'customer_id': customerId,
      'warehouse_id': warehouseId,
      'biller_id': billerId,
      'sale_status': saleStatus,
      'payment_status': paymentStatus,
    };

    if (note != null && note!.isNotEmpty) {
      data['note'] = note;
    }

    if (shipping != null && shipping! > 0) {
      data['shipping'] = shipping;
    }

    data['items'] = items.map((item) => item.toJson()).toList();

    if (paymentStatus != 'pending' && payment != null) {
      data['payment'] = payment!.toJson();
    }

    return data;
  }
}

class CheckoutItem {
  int productId;
  double quantity;
  int? optionId;
  double? price;
  String? discount;

  CheckoutItem({
    required this.productId,
    required this.quantity,
    this.optionId,
    this.price,
    this.discount,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'product_id': productId,
      'quantity': quantity,
    };

    // Only set if not null
    if (optionId != null) data['option_id'] = optionId;
    if (price != null) data['price'] = price;
    if (discount != null && discount!.isNotEmpty) data['discount'] = discount;

    return data;
  }
}

class CheckoutPayment {
  double amount;
  String paidBy; // cash, credit_card, gift_card, deposit

  CheckoutPayment({
    required this.amount,
    required this.paidBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'paid_by': paidBy,
    };
  }
}
