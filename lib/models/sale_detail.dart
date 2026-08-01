import 'sale.dart';

class SaleDetail {
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
  final List<SaleItem> items;
  final Warehouse? warehouse;
  final CreatedBy? createdBy;

  SaleDetail({
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
    required this.items,
    this.warehouse,
    this.createdBy,
  });

  factory SaleDetail.fromJson(Map<String, dynamic> json) {
    var itemsList = <SaleItem>[];
    if (json['items'] != null) {
      itemsList = (json['items'] as List)
          .map((item) => SaleItem.fromJson(item))
          .toList();
    }

    return SaleDetail(
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
      items: itemsList,
      warehouse: json['warehouse'] != null
          ? Warehouse.fromJson(json['warehouse'])
          : null,
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

class SaleItem {
  final String productId;
  final String productCode;
  final String productName;
  final String productType;
  final double netUnitPrice;
  final double unitPrice;
  final double quantity;
  final String productUnitCode;
  final double itemTax;
  final double subtotal;

  SaleItem({
    required this.productId,
    required this.productCode,
    required this.productName,
    required this.productType,
    required this.netUnitPrice,
    required this.unitPrice,
    required this.quantity,
    required this.productUnitCode,
    required this.itemTax,
    required this.subtotal,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      productId: json['product_id']?.toString() ?? '',
      productCode: json['product_code']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? '',
      productType: json['product_type']?.toString() ?? 'standard',
      netUnitPrice: _parseDouble(json['net_unit_price']),
      unitPrice: _parseDouble(json['unit_price']),
      quantity: _parseDouble(json['quantity']),
      productUnitCode: json['product_unit_code']?.toString() ?? 'PCS',
      itemTax: _parseDouble(json['item_tax']),
      subtotal: _parseDouble(json['subtotal']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}

class Warehouse {
  final String id;
  final String code;
  final String name;

  Warehouse({
    required this.id,
    required this.code,
    required this.name,
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}
