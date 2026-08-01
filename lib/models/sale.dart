class Sale {
  final String id;
  final String date;
  final String referenceNo;
  final String customerId;
  final String customer;
  final String billerId;
  final String biller;
  final String warehouseId;
  final double total;
  final double productTax;
  final double orderTax;
  final double grandTotal;
  final String saleStatus;
  final String paymentStatus;
  final int totalItems;
  final CreatedBy? createdBy;

  Sale({
    required this.id,
    required this.date,
    required this.referenceNo,
    required this.customerId,
    required this.customer,
    required this.billerId,
    required this.biller,
    required this.warehouseId,
    required this.total,
    required this.productTax,
    required this.orderTax,
    required this.grandTotal,
    required this.saleStatus,
    required this.paymentStatus,
    required this.totalItems,
    this.createdBy,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      referenceNo: json['reference_no']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      customer: json['customer']?.toString() ?? '',
      billerId: json['biller_id']?.toString() ?? '',
      biller: json['biller']?.toString() ?? '',
      warehouseId: json['warehouse_id']?.toString() ?? '',
      total: _parseDouble(json['total']),
      productTax: _parseDouble(json['product_tax']),
      orderTax: _parseDouble(json['order_tax']),
      grandTotal: _parseDouble(json['grand_total']),
      saleStatus: json['sale_status']?.toString() ?? 'pending',
      paymentStatus: json['payment_status']?.toString() ?? 'pending',
      totalItems: _parseInt(json['total_items']),
      createdBy: json['created_by'] != null
          ? CreatedBy.fromJson(json['created_by'])
          : null,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}

class CreatedBy {
  final String id;
  final String firstName;
  final String lastName;
  final String email;

  CreatedBy({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory CreatedBy.fromJson(Map<String, dynamic> json) {
    return CreatedBy(
      id: json['id']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }

  String get fullName => '$firstName $lastName'.trim();
}
