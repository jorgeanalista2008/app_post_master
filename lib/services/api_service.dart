import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/sale.dart';
import '../models/sale_detail.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'Error $statusCode: $message';
}

class ApiService {
  final ApiConfig config;

  ApiService(this.config);

  /// Performs a helper request and validates response
  void _validateResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    String errorMsg;
    try {
      final body = json.decode(response.body);
      errorMsg = body['message'] ?? 'Error desconocido';
    } catch (_) {
      errorMsg = response.body.isNotEmpty ? response.body : 'Error sin mensaje del servidor';
    }

    switch (response.statusCode) {
      case 400:
        throw ApiException(400, 'Datos incorrectos: $errorMsg');
      case 401:
        throw ApiException(401, 'No autorizado: Llave API incorrecta o vencida.');
      case 404:
        throw ApiException(404, 'No encontrado: El recurso no existe.');
      case 500:
        throw ApiException(500, 'Error interno del servidor: $errorMsg');
      default:
        throw ApiException(response.statusCode, 'Error inesperado ($errorMsg)');
    }
  }

  /// GET /sales
  Future<Map<String, dynamic>> getSales({
    int? customerId,
    int start = 1,
    int limit = 10,
    String? startDate,
    String? endDate,
    String include = 'items,warehouse',
  }) async {
    final queryParams = <String, dynamic>{
      'start': start,
      'limit': limit,
      'include': include,
    };

    if (customerId != null) queryParams['customer_id'] = customerId;
    if (startDate != null && startDate.isNotEmpty) queryParams['start_date'] = startDate;
    if (endDate != null && endDate.isNotEmpty) queryParams['end_date'] = endDate;

    final uri = config.getUri('sales', queryParams);

    try {
      final response = await http.get(uri, headers: config.headers);
      _validateResponse(response);

      final body = json.decode(response.body);
      final List<dynamic> dataList = body['data'] ?? [];
      final List<Sale> sales = dataList.map((item) => Sale.fromJson(item)).toList();

      return {
        'sales': sales,
        'limit': body['limit'] ?? limit,
        'start': body['start'] ?? start,
        'total': body['total'] ?? 0,
      };
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(500, 'Error de conexión: $e');
    }
  }

  /// GET /sales/{id}
  Future<SaleDetail> getSaleById(String id) async {
    final uri = config.getUri('sales/$id');

    try {
      final response = await http.get(uri, headers: config.headers);
      _validateResponse(response);

      final body = json.decode(response.body);
      return SaleDetail.fromJson(body);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(500, 'Error de conexión: $e');
    }
  }

  /// POST /sales (Checkout)
  Future<Map<String, dynamic>> createSale(Map<String, dynamic> payload) async {
    final uri = config.getUri('sales');

    try {
      final response = await http.post(
        uri,
        headers: config.headers,
        body: json.encode(payload),
      );
      _validateResponse(response);

      final body = json.decode(response.body);
      return {
        'message': body['message'] ?? 'Pedido creado con éxito',
        'sale_id': body['sale_id'],
        'reference_no': body['reference_no'] ?? '',
        'status': body['status'] ?? false,
      };
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(500, 'Error de conexión: $e');
    }
  }

  /// POST /sales/status
  Future<Map<String, dynamic>> updateSaleStatus(
    int id,
    String status, {
    String? note,
  }) async {
    final uri = config.getUri('sales/status');
    final payload = {
      'id': id,
      'status': status,
    };

    if (note != null && note.isNotEmpty) {
      payload['note'] = note;
    }

    try {
      final response = await http.post(
        uri,
        headers: config.headers,
        body: json.encode(payload),
      );
      _validateResponse(response);

      final body = json.decode(response.body);
      return {
        'message': body['message'] ?? 'Estado actualizado con éxito',
        'status': body['status'] ?? false,
      };
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(500, 'Error de conexión: $e');
    }
  }

  /// DELETE /sales/{id}
  Future<Map<String, dynamic>> deleteSale(String id) async {
    final uri = config.getUri('sales/$id');

    try {
      final response = await http.delete(uri, headers: config.headers);
      _validateResponse(response);

      final body = json.decode(response.body);
      return {
        'message': body['message'] ?? 'Pedido cancelado con éxito',
        'status': body['status'] ?? false,
      };
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(500, 'Error de conexión: $e');
    }
  }

  /// Basic test to check if the credentials and URL work
  Future<bool> testConnection() async {
    final uri = config.getUri('sales', {'limit': 1});
    try {
      final response = await http.get(uri, headers: config.headers);
      // If we get 200 or even 404 (indicating endpoint exists but resource not found, though API Key was verified),
      // or anything that indicates authenticating worked.
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
