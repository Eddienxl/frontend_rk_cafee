import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/order_model.dart';
import '../providers/order_provider.dart';
import '../widgets/custom_button.dart';

/// Halaman Kitchen Display untuk melihat dan mengelola pesanan
/// Menerapkan prinsip OOP:
/// - Tab layout untuk mobile (Baru, Proses, Selesai)
/// - State Management dengan Provider
class KitchenPage extends StatefulWidget {
  const KitchenPage({super.key});

  @override
  State<KitchenPage> createState() => _KitchenPageState();
}

class _KitchenPageState extends State<KitchenPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchKitchenOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Kitchen Display'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<OrderProvider>().fetchKitchenOrders(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Consumer<OrderProvider>(
              builder: (context, p, _) => Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Baru'),
                    if (p.ordersBaru.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${p.ordersBaru.length}',
                          style: const TextStyle(color: AppConstants.primaryColor, fontSize: 12),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Consumer<OrderProvider>(
              builder: (context, p, _) => Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Proses'),
                    if (p.ordersSedangDibuat.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${p.ordersSedangDibuat.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Consumer<OrderProvider>(
              builder: (context, p, _) => Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Selesai'),
                    if (p.ordersSelesai.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${p.ordersSelesai.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return TabBarView(
            controller: _tabController,
            children: [
              // Tab Baru
              _buildOrderList(
                orders: provider.ordersBaru,
                color: Colors.blue,
                nextStatus: OrderStatus.sedangDibuat,
                buttonText: 'Proses',
                emptyText: 'Tidak ada pesanan baru',
              ),
              // Tab Sedang Dibuat
              _buildOrderList(
                orders: provider.ordersSedangDibuat,
                color: Colors.orange,
                nextStatus: OrderStatus.selesai,
                buttonText: 'Selesai',
                emptyText: 'Tidak ada pesanan diproses',
              ),
              // Tab Selesai
              _buildOrderList(
                orders: provider.ordersSelesai,
                color: Colors.green,
                nextStatus: null,
                buttonText: null,
                emptyText: 'Tidak ada pesanan selesai',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderList({
    required List<OrderModel> orders,
    required Color color,
    OrderStatus? nextStatus,
    String? buttonText,
    required String emptyText,
  }) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(emptyText, style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingSmall),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order, nextStatus, buttonText, color);
      },
    );
  }

  Widget _buildOrderCard(OrderModel order, OrderStatus? nextStatus, String? buttonText, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingSmall),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('#${order.idOrder.substring(0, 8)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(order.waktuOrder ?? '', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
            const Divider(),
            Text(order.namaMenu ?? '-', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Text('Jumlah: ${order.jumlahOrder}x', style: TextStyle(color: Colors.grey[600])),
            if (nextStatus != null && buttonText != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: buttonText,
                  height: 36,
                  variant: nextStatus == OrderStatus.selesai ? ButtonVariant.success : ButtonVariant.primary,
                  onPressed: () => _updateStatus(order.idOrder, nextStatus),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(String orderId, OrderStatus newStatus) async {
    final provider = context.read<OrderProvider>();
    await provider.updateOrderStatus(orderId, newStatus);
  }
}

