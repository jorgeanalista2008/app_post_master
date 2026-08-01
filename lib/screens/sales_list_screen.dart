import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sales_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/sale_card.dart';
import '../widgets/error_view.dart';
import 'settings_screen.dart';
import 'sale_detail_screen.dart';
import 'checkout_screen.dart';
import 'login_screen.dart';
import 'about_screen.dart';
import 'terms_policies_screen.dart';

class SalesListScreen extends StatefulWidget {
  const SalesListScreen({super.key});

  @override
  State<SalesListScreen> createState() => _SalesListScreenState();
}

class _SalesListScreenState extends State<SalesListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final provider = Provider.of<SalesProvider>(context, listen: false);
    if (!provider.isConfigLoaded) {
      provider.loadConfig().then((_) {
        _checkConfigAndFetch();
      });
    } else {
      _checkConfigAndFetch();
    }
  }

  void _checkConfigAndFetch() {
    final provider = Provider.of<SalesProvider>(context, listen: false);
    if (provider.config == null || provider.config!.apiKey.isEmpty) {
      // API not configured yet, redirect to settings
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      );
    } else {
      provider.fetchSales(refresh: true);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final provider = Provider.of<SalesProvider>(context, listen: false);
      if (!provider.isLoadingSales && provider.hasMore) {
        provider.fetchSales();
      }
    }
  }

  void _showFilterBottomSheet() {
    final provider = Provider.of<SalesProvider>(context, listen: false);
    final customerController = TextEditingController(
      text: provider.filterCustomerId?.toString() ?? '',
    );
    final startController = TextEditingController(
      text: provider.filterStartDate ?? '',
    );
    final endController = TextEditingController(
      text: provider.filterEndDate ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 20,
            right: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filtrar Pedidos',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Customer ID Input
                TextField(
                  controller: customerController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'ID Cliente',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),

                // Date Fields
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: startController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Fecha Inicio',
                          hintText: 'YYYY-MM-DD',
                          prefixIcon: const Icon(Icons.date_range_rounded),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            startController.text = date.toString().split(' ')[0];
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: endController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Fecha Fin',
                          hintText: 'YYYY-MM-DD',
                          prefixIcon: const Icon(Icons.date_range_rounded),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            endController.text = date.toString().split(' ')[0];
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          provider.clearFilters();
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Limpiar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final customerId = int.tryParse(customerController.text);
                          provider.setFilters(
                            customerId: customerId,
                            startDate: startController.text.trim(),
                            endDate: endController.text.trim(),
                          );
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Aplicar Filtros'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            Consumer<AuthProvider>(
              builder: (context, auth, child) {
                final user = auth.currentUser;
                return UserAccountsDrawerHeader(
                  accountName: Text(
                    user?.name ?? 'Usuario',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  accountEmail: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.email ?? 'usuario@dsdneo.cl'),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.tealAccent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.tealAccent.withValues(alpha: 0.6)),
                        ),
                        child: Text(
                          user?.role ?? 'Vendedor',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.tealAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      (user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : 'U',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E3A8A),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt_rounded),
              title: const Text('Pedidos (Ventas)'),
              selected: true,
              onTap: () {
                Navigator.pop(context); // Close drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('Acerca de'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.gavel_rounded),
              title: const Text('Normas y Políticas'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TermsPoliciesScreen()),
                );
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              onTap: () async {
                Navigator.pop(context); // Close drawer
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text(
          'DSD-Neo Pedidos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filtrar',
            onPressed: _showFilterBottomSheet,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Configuración API',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
        elevation: 0,
      ),
      body: Consumer<SalesProvider>(
        builder: (context, provider, child) {
          if (!provider.isConfigLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.config == null || provider.config!.apiKey.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.api_rounded, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    const Text(
                      'API sin configurar',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Por favor, configure la URL base del servidor y su clave API para comenzar.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        );
                      },
                      icon: const Icon(Icons.settings_rounded),
                      label: const Text('Ir a Configuración'),
                    )
                  ],
                ),
              ),
            );
          }

          if (provider.salesError != null && provider.sales.isEmpty) {
            return ErrorView(
              errorMessage: provider.salesError!,
              onRetry: () => provider.fetchSales(refresh: true),
            );
          }

          final hasActiveFilters = provider.filterCustomerId != null ||
              (provider.filterStartDate != null && provider.filterStartDate!.isNotEmpty) ||
              (provider.filterEndDate != null && provider.filterEndDate!.isNotEmpty);

          return Column(
            children: [
              // Active Filters Indicators
              if (hasActiveFilters)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 16, color: Colors.blueGrey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Filtros activos: ${[
                            if (provider.filterCustomerId != null) 'Cliente ID: ${provider.filterCustomerId}',
                            if (provider.filterStartDate != null && provider.filterStartDate!.isNotEmpty)
                              'Desde: ${provider.filterStartDate}',
                            if (provider.filterEndDate != null && provider.filterEndDate!.isNotEmpty)
                              'Hasta: ${provider.filterEndDate}',
                          ].join(', ')}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.blueGrey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: provider.clearFilters,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Limpiar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.fetchSales(refresh: true),
                  child: provider.sales.isEmpty && !provider.isLoadingSales
                      ? ListView(
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                            Center(
                              child: Column(
                                children: [
                                  Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade300),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No se encontraron pedidos',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Intenta cambiar los filtros o recarga la página.',
                                    style: TextStyle(color: Colors.grey.shade400),
                                  ),
                                ],
                              ),
                            )
                          ],
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: provider.sales.length + (provider.hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == provider.sales.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24.0),
                                child: Center(
                                  child: CircularProgressIndicator(strokeWidth: 2.5),
                                ),
                              );
                            }

                            final sale = provider.sales[index];
                            return SaleCard(
                              sale: sale,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => SaleDetailScreen(saleId: sale.id),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CheckoutScreen()),
          );
        },
        icon: const Icon(Icons.add_shopping_cart_rounded),
        label: const Text('Nuevo Pedido', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
