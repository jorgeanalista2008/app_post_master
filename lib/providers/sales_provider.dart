import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../models/sale.dart';
import '../models/sale_detail.dart';
import '../models/checkout_payload.dart';
import '../services/api_service.dart';

class SalesProvider with ChangeNotifier {
  ApiConfig? _config;
  ApiService? _apiService;

  // Configuration State
  ApiConfig? get config => _config;
  bool _isConfigLoaded = false;
  bool get isConfigLoaded => _isConfigLoaded;

  // Sales List State
  List<Sale> _sales = [];
  List<Sale> get sales => _sales;
  bool _isLoadingSales = false;
  bool get isLoadingSales => _isLoadingSales;
  String? _salesError;
  String? get salesError => _salesError;

  // Pagination details
  int _start = 1;
  final int _limit = 10;
  int _totalSales = 0;
  bool _hasMore = true;
  bool get hasMore => _hasMore;
  int get totalSales => _totalSales;

  // Filters State
  int? _filterCustomerId;
  int? get filterCustomerId => _filterCustomerId;
  String? _filterStartDate;
  String? get filterStartDate => _filterStartDate;
  String? _filterEndDate;
  String? get filterEndDate => _filterEndDate;

  // Sale Detail State
  SaleDetail? _selectedSaleDetail;
  SaleDetail? get selectedSaleDetail => _selectedSaleDetail;
  bool _isLoadingDetail = false;
  bool get isLoadingDetail => _isLoadingDetail;
  String? _detailError;
  String? get detailError => _detailError;

  // Operation States (Checkout, status change, cancel)
  bool _isProcessingOperation = false;
  bool get isProcessingOperation => _isProcessingOperation;

  /// Loads the API configuration from persistent SharedPreferences
  Future<void> loadConfig() async {
    _config = await ApiConfig.load();
    if (_config != null) {
      _apiService = ApiService(_config!);
    }
    _isConfigLoaded = true;
    notifyListeners();
  }

  /// Updates and saves the API settings
  Future<void> updateConfig(String baseUrl, String apiKey) async {
    _config = ApiConfig(baseUrl: baseUrl, apiKey: apiKey);
    await _config!.save();
    _apiService = ApiService(_config!);
    notifyListeners();
    // Clear list and reload with new configuration
    resetFiltersAndList();
  }

  /// Resets list and filter states
  void resetFiltersAndList() {
    _sales = [];
    _start = 1;
    _totalSales = 0;
    _hasMore = true;
    _salesError = null;
    _filterCustomerId = null;
    _filterStartDate = null;
    _filterEndDate = null;
    notifyListeners();
  }

  /// Sets filters and reloads the list
  void setFilters({int? customerId, String? startDate, String? endDate}) {
    _filterCustomerId = customerId;
    _filterStartDate = startDate;
    _filterEndDate = endDate;
    _start = 1;
    _sales = [];
    _hasMore = true;
    fetchSales(refresh: true);
  }

  /// Clears filters and reloads
  void clearFilters() {
    setFilters(customerId: null, startDate: null, endDate: null);
  }

  /// Fetches sales from API (handles initial load, pull-to-refresh, and pagination)
  Future<void> fetchSales({bool refresh = false}) async {
    if (_apiService == null) {
      _salesError = "API no configurada";
      notifyListeners();
      return;
    }

    if (refresh) {
      _start = 1;
      _sales = [];
      _hasMore = true;
    }

    if (!_hasMore && !refresh) return;

    _isLoadingSales = true;
    _salesError = null;
    notifyListeners();

    try {
      final result = await _apiService!.getSales(
        customerId: _filterCustomerId,
        start: _start,
        limit: _limit,
        startDate: _filterStartDate,
        endDate: _filterEndDate,
      );

      final List<Sale> fetchedSales = result['sales'];
      _totalSales = result['total'];
      
      if (refresh) {
        _sales = fetchedSales;
      } else {
        _sales.addAll(fetchedSales);
      }

      // Check if we reached the end
      if (_sales.length >= _totalSales || fetchedSales.length < _limit) {
        _hasMore = false;
      } else {
        _start += fetchedSales.length;
      }
    } catch (e) {
      _salesError = e.toString();
    } finally {
      _isLoadingSales = false;
      notifyListeners();
    }
  }

  /// Fetches a detailed sale item by its unique ID
  Future<void> fetchSaleDetail(String id) async {
    if (_apiService == null) return;

    _isLoadingDetail = true;
    _selectedSaleDetail = null;
    _detailError = null;
    notifyListeners();

    try {
      _selectedSaleDetail = await _apiService!.getSaleById(id);
    } catch (e) {
      _detailError = e.toString();
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  /// Creates a sale (Checkout)
  Future<Map<String, dynamic>> checkout(CheckoutPayload payload) async {
    if (_apiService == null) {
      throw ApiException(401, "API no configurada");
    }

    _isProcessingOperation = true;
    notifyListeners();

    try {
      final response = await _apiService!.createSale(payload.toJson());
      // Refresh list to show newly created sale
      fetchSales(refresh: true);
      return response;
    } finally {
      _isProcessingOperation = false;
      notifyListeners();
    }
  }

  /// Updates the status of a specific sale
  Future<void> updateSaleStatus(int id, String status, {String? note}) async {
    if (_apiService == null) return;

    _isProcessingOperation = true;
    notifyListeners();

    try {
      await _apiService!.updateSaleStatus(id, status, note: note);
      
      // If we are currently viewing this sale, refresh detail
      if (_selectedSaleDetail != null && _selectedSaleDetail!.id == id.toString()) {
        await fetchSaleDetail(id.toString());
      }
      
      // Update status in local list without reloading whole page if possible
      final index = _sales.indexWhere((s) => s.id == id.toString());
      if (index != -1) {
        final old = _sales[index];
        _sales[index] = Sale(
          id: old.id,
          date: old.date,
          referenceNo: old.referenceNo,
          customerId: old.customerId,
          customer: old.customer,
          billerId: old.billerId,
          biller: old.biller,
          warehouseId: old.warehouseId,
          total: old.total,
          productTax: old.productTax,
          orderTax: old.orderTax,
          grandTotal: old.grandTotal,
          saleStatus: status, // updated status
          paymentStatus: old.paymentStatus,
          totalItems: old.totalItems,
          createdBy: old.createdBy,
        );
      }
    } finally {
      _isProcessingOperation = false;
      notifyListeners();
    }
  }

  /// Cancels / Deletes a specific sale
  Future<void> cancelSale(String id) async {
    if (_apiService == null) return;

    _isProcessingOperation = true;
    notifyListeners();

    try {
      await _apiService!.deleteSale(id);
      
      // Remove from local list
      _sales.removeWhere((s) => s.id == id);
      
      if (_selectedSaleDetail != null && _selectedSaleDetail!.id == id) {
        _selectedSaleDetail = null;
      }
    } finally {
      _isProcessingOperation = false;
      notifyListeners();
    }
  }

  /// Tests connection with current config
  Future<bool> testConnection(String baseUrl, String apiKey) async {
    final testConfig = ApiConfig(baseUrl: baseUrl, apiKey: apiKey);
    final testService = ApiService(testConfig);
    return await testService.testConnection();
  }
}
