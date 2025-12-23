import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/constants/app_constants.dart';
import 'core/network/api_client.dart';
import 'data/datasources/auth_api_service.dart';
import 'data/datasources/menu_api_service.dart';
import 'data/datasources/order_api_service.dart';
import 'data/datasources/bahan_baku_api_service.dart';
import 'data/datasources/bom_api_service.dart';
import 'data/datasources/laporan_api_service.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/menu_provider.dart';
import 'presentation/providers/cart_provider.dart';
import 'presentation/providers/order_provider.dart';
import 'presentation/providers/inventory_provider.dart';
import 'presentation/providers/bom_provider.dart';
import 'presentation/providers/laporan_provider.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/pos_page.dart';

/// Main entry point aplikasi RK Cafe POS
/// Menerapkan prinsip OOP:
/// - Dependency Injection: semua dependencies di-inject melalui Provider
/// - Inversion of Control: Provider mengontrol lifecycle dependencies
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RKCafeApp());
}

class RKCafeApp extends StatelessWidget {
  const RKCafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi API Client (singleton-like pattern)
    final apiClient = ApiClient();

    // Inisialisasi Services
    final authService = AuthApiService(apiClient);
    final menuService = MenuApiService(apiClient);
    final orderService = OrderApiService(apiClient);
    final bahanService = BahanBakuApiService(apiClient);
    final bomService = BomApiService(apiClient);
    final laporanService = LaporanApiService(apiClient);

    return MultiProvider(
      providers: [
        // Provider untuk Auth
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService, apiClient),
        ),
        // Provider untuk Menu
        ChangeNotifierProvider(
          create: (_) => MenuProvider(menuService),
        ),
        // Provider untuk Cart (tidak perlu service, state lokal)
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
        // Provider untuk Order
        ChangeNotifierProvider(
          create: (_) => OrderProvider(orderService),
        ),
        // Provider untuk Inventory
        ChangeNotifierProvider(
          create: (_) => InventoryProvider(bahanService),
        ),
        // Provider untuk BOM (Bill of Materials)
        ChangeNotifierProvider(
          create: (_) => BomProvider(bomService),
        ),
        // Provider untuk Laporan Penjualan
        ChangeNotifierProvider(
          create: (_) => LaporanProvider(laporanService),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: const AuthWrapper(),
      ),
    );
  }

  /// Build theme aplikasi
  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryColor,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
      ),
    );
  }
}

/// Widget untuk mengecek status autentikasi
/// Menentukan apakah user ke LoginPage atau PosPage
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.checkAuthStatus();
    if (mounted) {
      setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Memuat...'),
            ],
          ),
        ),
      );
    }

        if (auth.isLoggedIn) {
          return const PosPage();
        }
        return const LoginPage();
  }
}
