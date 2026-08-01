import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/sales_provider.dart';
import '../models/checkout_payload.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  // Header states
  int _customerId = 1;
  int _warehouseId = 1;
  int _billerId = 1;
  String _saleStatus = 'pending';
  String _paymentStatus = 'pending';
  final _noteController = TextEditingController();
  final _shippingController = TextEditingController();

  // Payment states
  final _paymentAmountController = TextEditingController();
  String _paidBy = 'cash';

  // Selected items state
  final List<CheckoutItem> _items = [];

  // Local controller states for "Add Item" form
  final _productIdController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _optionIdController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();

  // Demo Product presets to help the user test easily
  final List<Map<String, dynamic>> _demoProducts = [
    {'id': 24, 'name': 'BOTELLA ACEITERA 500ML (\$47.600)'},
    {'id': 12, 'name': 'PRODUCTO PRUEBA 1 (\$10.000)'},
    {'id': 15, 'name': 'PRODUCTO PRUEBA 2 (\$5.500)'},
  ];

  @override
  void dispose() {
    _noteController.dispose();
    _shippingController.dispose();
    _paymentAmountController.dispose();
    _productIdController.dispose();
    _quantityController.dispose();
    _optionIdController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _addItem() {
    final int? prodId = int.tryParse(_productIdController.text);
    final double? qty = double.tryParse(_quantityController.text);
    if (prodId == null || qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID de Producto y Cantidad válidos son obligatorios.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final int? optId = int.tryParse(_optionIdController.text);
    final double? price = double.tryParse(_priceController.text);
    final String disc = _discountController.text.trim();

    setState(() {
      _items.add(CheckoutItem(
        productId: prodId,
        quantity: qty,
        optionId: optId,
        price: price,
        discount: disc.isNotEmpty ? disc : null,
      ));

      // Clear item fields
      _productIdController.clear();
      _quantityController.text = '1';
      _optionIdController.clear();
      _priceController.clear();
      _discountController.clear();
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Future<void> _submitCheckout() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe agregar al menos un artículo al pedido.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<SalesProvider>(context, listen: false);

    CheckoutPayment? payment;
    if (_paymentStatus != 'pending') {
      final double? payAmount = double.tryParse(_paymentAmountController.text);
      if (payAmount == null || payAmount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debe ingresar un monto válido de pago.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
      payment = CheckoutPayment(amount: payAmount, paidBy: _paidBy);
    }

    final payload = CheckoutPayload(
      customerId: _customerId,
      warehouseId: _warehouseId,
      billerId: _billerId,
      saleStatus: _saleStatus,
      paymentStatus: _paymentStatus,
      note: _noteController.text.trim(),
      shipping: double.tryParse(_shippingController.text),
      items: _items,
      payment: payment,
    );

    try {
      final result = await provider.checkout(payload);
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.teal),
                  SizedBox(width: 10),
                  Text('Pedido Creado'),
                ],
              ),
              content: Text(
                '${result['message']}\n\n'
                'Referencia: ${result['reference_no']}\n'
                'ID del Pedido: ${result['sale_id']}',
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to list
                  },
                  child: const Text('Aceptar'),
                )
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al realizar Checkout: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'es_CL',
      symbol: '\$',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Pedido / Checkout', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Consumer<SalesProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 90.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Form Header
                      const Text(
                        'Datos del Pedido (Cabecera)',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: _customerId.toString(),
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'ID Cliente',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (val) {
                                        _customerId = int.tryParse(val) ?? 1;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: _warehouseId.toString(),
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'ID Bodega',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (val) {
                                        _warehouseId = int.tryParse(val) ?? 1;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: _billerId.toString(),
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'ID Facturador',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (val) {
                                        _billerId = int.tryParse(val) ?? 1;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      initialValue: _saleStatus,
                                      decoration: const InputDecoration(
                                        labelText: 'Estado Venta',
                                        border: OutlineInputBorder(),
                                      ),
                                      items: const [
                                        DropdownMenuItem(value: 'pending', child: Text('Pendiente')),
                                        DropdownMenuItem(value: 'completed', child: Text('Completado')),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) setState(() => _saleStatus = val);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      initialValue: _paymentStatus,
                                      decoration: const InputDecoration(
                                        labelText: 'Estado Pago',
                                        border: OutlineInputBorder(),
                                      ),
                                      items: const [
                                        DropdownMenuItem(value: 'pending', child: Text('Pendiente')),
                                        DropdownMenuItem(value: 'paid', child: Text('Pagado')),
                                        DropdownMenuItem(value: 'partial', child: Text('Parcial')),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) setState(() => _paymentStatus = val);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _shippingController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Costo Envío (Opcional)',
                                  prefixIcon: Icon(Icons.local_shipping_rounded),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _noteController,
                                decoration: const InputDecoration(
                                  labelText: 'Notas del Pedido (Opcional)',
                                  prefixIcon: Icon(Icons.note_alt_rounded),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Section: Add Items
                      const Text(
                        'Agregar Artículo',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        elevation: 0,
                        color: Colors.grey.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Quick selections for presets
                              Wrap(
                                spacing: 8,
                                children: _demoProducts.map((p) {
                                  return ActionChip(
                                    label: Text(p['name']),
                                    onPressed: () {
                                      setState(() {
                                        _productIdController.text = p['id'].toString();
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 10),

                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _productIdController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'ID Producto *',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _quantityController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: const InputDecoration(
                                        labelText: 'Cantidad *',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _priceController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: const InputDecoration(
                                        labelText: 'Precio Unitario (Opcional)',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _discountController,
                                      decoration: const InputDecoration(
                                        labelText: 'Descto (e.g. 10 / 10%)',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _optionIdController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'ID Opción / Variante (Opcional)',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: _addItem,
                                icon: const Icon(Icons.add_rounded),
                                label: const Text('Agregar a Lista', style: TextStyle(fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueGrey.shade700,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Section: Selected Items List
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Artículos Seleccionados',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                          ),
                          Text(
                            'Total Items: ${_items.length}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_items.isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 30),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.shopping_basket_outlined, size: 40, color: Colors.black26),
                              SizedBox(height: 10),
                              Text(
                                'Aún no has agregado artículos.',
                                style: TextStyle(color: Colors.black38),
                              )
                            ],
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.grey.shade100,
                                  child: Text(
                                    item.productId.toString(),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ),
                                title: Text('Cantidad: ${item.quantity}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (item.price != null) Text('Precio unitario personalizado: ${currencyFormatter.format(item.price)}'),
                                    if (item.discount != null) Text('Descuento: ${item.discount}'),
                                    if (item.optionId != null) Text('Variante ID: ${item.optionId}'),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.redAccent),
                                  onPressed: () => _removeItem(index),
                                ),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 20),

                      // Section: Payment details if payment status is paid/partial
                      if (_paymentStatus != 'pending') ...[
                        const Text(
                          'Detalles del Pago',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                        ),
                        const SizedBox(height: 8),
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _paymentAmountController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: const InputDecoration(
                                    labelText: 'Monto a Pagar *',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Ingrese el monto abonado';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Ingrese un monto numérico válido';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                                DropdownButtonFormField<String>(
                                  initialValue: _paidBy,
                                  decoration: const InputDecoration(
                                    labelText: 'Método de Pago',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 'cash', child: Text('Efectivo (Cash)')),
                                    DropdownMenuItem(value: 'credit_card', child: Text('Tarjeta de Crédito')),
                                    DropdownMenuItem(value: 'gift_card', child: Text('Tarjeta de Regalo (Gift Card)')),
                                    DropdownMenuItem(value: 'deposit', child: Text('Depósito Bancario')),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) setState(() => _paidBy = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Bottom Checkout Button
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      )
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: provider.isProcessingOperation ? null : _submitCheckout,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Confirmar Checkout y Enviar',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ),

              // Loading overlay when updating/deleting
              if (provider.isProcessingOperation)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(width: 16),
                            Text('Procesando Checkout...', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
            ],
          );
        },
      ),
    );
  }
}
