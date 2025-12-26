import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/order_service.dart';
import '../../models/order_model.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class BaristaOrderScreen extends StatefulWidget {
  const BaristaOrderScreen({super.key});

  @override
  State<BaristaOrderScreen> createState() => _BaristaOrderScreenState();
}

class _BaristaOrderScreenState extends State<BaristaOrderScreen> {
  final OrderService _orderService = OrderService();
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
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
    if (!isSilent && mounted) setState(() => _isLoading = true);
    try {
      final data = await _orderService.getKitchenOrders();
      if (mounted) {
        setState(() {
          _orders = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted && !isSilent) setState(() => _isLoading = false);
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: const Color(0xFF5D4037),
          content: Text("Order dipindahkan ke: $nextStatus", style: GoogleFonts.inter(color: Colors.white)),
        ));
      }
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
    final activeOrders = _orders.where((o) => o.statusPesanan != 'BATAL' && o.statusPesanan != 'SELESAI').toList();
    final completedOrders = _orders.where((o) => o.statusPesanan == 'SELESAI').toList();

    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: _fetchOrders,
      backgroundColor: const Color(0xFF5D4037),
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Antrean Aktif 🔥", style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF5D4037))),
              IconButton(onPressed: () => _fetchOrders(), icon: const Icon(Icons.refresh, color: Color(0xFF5D4037))),
            ],
          ),
          const SizedBox(height: 16),
          activeOrders.isEmpty 
              ? Center(child: Padding(padding: const EdgeInsets.all(40), child: Text("Belum ada pesanan masuk", style: GoogleFonts.inter(color: Colors.grey))))
              : _buildOrderGrid(activeOrders),
          
          const SizedBox(height: 40),
          Text("Riwayat Hari Ini ✅", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[600])),
          const SizedBox(height: 16),
          completedOrders.isEmpty
              ? Center(child: Padding(padding: const EdgeInsets.all(20), child: Text("Belum ada pesanan selesai", style: GoogleFonts.inter(color: Colors.grey, fontSize: 13))))
              : _buildOrderGrid(completedOrders, isHistory: true),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildOrderGrid(List<OrderModel> orders, {bool isHistory = false}) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, 
        childAspectRatio: 0.85, 
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final statusColor = _getStatusColor(order.statusPesanan);
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("#${order.idOrder.toString().substring(0, 8)}", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(DateFormat('HH:mm').format(order.tanggal ?? DateTime.now()), style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Text(order.statusPesanan, style: GoogleFonts.inter(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: order.items.length,
                  itemBuilder: (ctx, i) {
                    final item = order.items[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.brown[50], borderRadius: BorderRadius.circular(4)),
                            child: Text("${item.jumlah}x", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.brown)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(item.namaMenu, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 12))),
                        ],
                      ),
                    );
                  },
                ),
              ),
              if (!isHistory) 
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: order.statusPesanan == 'BARU' ? Colors.orange : Colors.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => _updateStatus(order.idOrder, order.statusPesanan),
                    child: Text(
                      order.statusPesanan == 'BARU' ? "KERJAKAN" : "SELESAI",
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                )
            ],
          ),
        );
      },
    );
  }
}
