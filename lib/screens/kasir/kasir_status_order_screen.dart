import 'package:flutter/material.dart';
import '../../services/order_service.dart';
import '../../models/order_model.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class KasirStatusOrderScreen extends StatefulWidget {
  const KasirStatusOrderScreen({super.key});

  @override
  State<KasirStatusOrderScreen> createState() => _KasirStatusOrderScreenState();
}

class _KasirStatusOrderScreenState extends State<KasirStatusOrderScreen> {
  final OrderService _orderService = OrderService();
  List<OrderModel> _activeOrders = [];
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    // Auto-refresh every 30s
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) => _fetchOrders());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    try {
      // Reuse kitchen endpoint to get all active orders
      final orders = await _orderService.getKitchenOrders();
      if (mounted) {
        setState(() {
          _activeOrders = orders;
          // Sort descending by Time
          _activeOrders.sort((a, b) => b.tanggal?.compareTo(a.tanggal ?? DateTime.now()) ?? 0);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'BARU': return Colors.blue;
      case 'SEDANG DIBUAT': return Colors.orange;
      case 'SELESAI': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_activeOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 80, color: Colors.brown[100]),
            const SizedBox(height: 16),
            const Text("Belum ada pesanan aktif.", style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _activeOrders.length,
        itemBuilder: (context, index) {
          final order = _activeOrders[index];
          final color = _getStatusColor(order.statusPesanan);

          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Order #${order.idOrder}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: color),
                        ),
                        child: Text(order.statusPesanan, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(DateFormat('dd MMM yyyy, HH:mm').format(order.tanggal ?? DateTime.now()), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const Divider(height: 24),
                  const Text("Item Pesanan:", style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${item.jumlah}x ${item.namaMenu}"),
                        // If we had price here we could show it, but for status screen quantity is most important
                      ],
                    ),
                  )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
