import 'package:flutter/material.dart';
import '../../services/order_service.dart';
import '../../models/order_model.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';

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
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) => _fetchOrders());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    try {
      final orders = await _orderService.getKitchenOrders();
      if (mounted) {
        setState(() {
          _activeOrders = orders;
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
            Icon(Icons.receipt_long_outlined, size: 80, color: Colors.brown[100]),
            const SizedBox(height: 16),
            Text("Belum ada pesanan aktif 📋", style: GoogleFonts.inter(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchOrders,
      backgroundColor: const Color(0xFF5D4037),
      color: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: _activeOrders.length,
        itemBuilder: (context, index) {
          final order = _activeOrders[index];
          final color = _getStatusColor(order.statusPesanan);

          return Card(
            elevation: 2,
            shadowColor: Colors.black12,
            margin: const EdgeInsets.only(bottom: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Pesanan #${order.idOrder.toString().substring(0, 8)}...", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(DateFormat('dd MMM HH:mm').format(order.tanggal ?? DateTime.now()), style: GoogleFonts.inter(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          order.statusPesanan, 
                          style: GoogleFonts.inter(color: color, fontWeight: FontWeight.bold, fontSize: 11)
                        ),
                      )
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1),
                  ),
                  Text("Rincian Pesanan:", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF5D4037))),
                  const SizedBox(height: 12),
                  ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.brown[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text("${item.jumlah}x", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.brown)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(item.namaMenu, style: GoogleFonts.inter(fontSize: 14))),
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
