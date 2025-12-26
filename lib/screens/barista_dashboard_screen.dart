import 'dart:async';
import 'package:flutter/material.dart';
import '../services/order_service.dart';
import '../models/order_model.dart';
import 'package:intl/intl.dart';

class BaristaDashboardScreen extends StatefulWidget {
  const BaristaDashboardScreen({super.key});

  @override
  State<BaristaDashboardScreen> createState() => _BaristaDashboardScreenState();
}

class _BaristaDashboardScreenState extends State<BaristaDashboardScreen> {
  final OrderService _orderService = OrderService();
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    // Auto-refresh every 15 seconds to check for new orders
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _fetchOrders(isSilent: true);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchOrders({bool isSilent = false}) async {
    if (!isSilent) setState(() => _isLoading = true);
    
    final data = await _orderService.getKitchenOrders();
    
    if (mounted) {
      setState(() {
        _orders = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(String orderId, String currentStatus) async {
    String nextStatus = 'BARU';
    if (currentStatus == 'BARU') nextStatus = 'SEDANG DIBUAT';
    else if (currentStatus == 'SEDANG DIBUAT') nextStatus = 'SELESAI';
    else return;

    final success = await _orderService.updateStatus(orderId, nextStatus);
    if (success) {
      _fetchOrders(isSilent: true);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Order updated to $nextStatus")));
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'BARU': return Colors.green;
      case 'SEDANG DIBUAT': return Colors.orange;
      case 'SELESAI': return Colors.grey;
      default: return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter out completed ones if list is too long, or keep them for display
    // For now show all active + recently completed
    final activeOrders = _orders.where((o) => o.statusPesanan != 'BATAL' && o.statusPesanan != 'SELESAI').toList();
    final completedOrders = _orders.where((o) => o.statusPesanan == 'SELESAI').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dapur / Barista"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.brown,
        actions: [
          IconButton(onPressed: () => _fetchOrders(), icon: const Icon(Icons.refresh)),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          )
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Pesanan Masuk (Active)", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              activeOrders.isEmpty 
                  ? const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Tidak ada pesanan aktif")))
                  : _buildOrderGrid(activeOrders),
              
              const Divider(height: 40),
              const Text("Riwayat Selesai (Hari Ini)", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 10),
              _buildOrderGrid(completedOrders, isHistory: true),
            ],
          ),
        ),
    );
  }

  Widget _buildOrderGrid(List<OrderModel> orders, {bool isHistory = false}) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Columns
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          color: isHistory ? Colors.grey[200] : Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: _getStatusColor(order.statusPesanan), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(order.idOrder, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order.statusPesanan),
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: Text(order.statusPesanan, style: const TextStyle(color: Colors.white, fontSize: 10)),
                    )
                  ],
                ),
                Text(DateFormat('HH:mm').format(order.tanggal ?? DateTime.now()), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: order.items.length,
                    itemBuilder: (ctx, i) {
                      final item = order.items[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(color: Colors.brown[100], borderRadius: BorderRadius.circular(4)),
                              child: Text("${item.jumlah}x", style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(item.namaMenu, maxLines: 2, overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                if (!isHistory) 
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: order.statusPesanan == 'BARU' ? Colors.orange : Colors.green,
                      ),
                      onPressed: () => _updateStatus(order.idOrder, order.statusPesanan),
                      child: Text(
                        order.statusPesanan == 'BARU' ? "PROSES" : "SELESAI",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  )
              ],
            ),
          ),
        );
      },
    );
  }
}
