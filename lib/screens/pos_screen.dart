import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/data_service.dart';
import '../services/admin_service.dart';
import '../models/menu_model.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final DataService _dataService = DataService();
  final AuthService _authService = AuthService();
  // Service Admin untuk delete menu
  // TODO: Better injection, but for now direct import in next step if generic service not enough
  // We'll use DataService if we move delete there, or import AdminService. 
  // Let's import AdminService in file header first.
  
  List<MenuModel> _menus = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _userRole = ''; // Check role

  @override
  void initState() {
    super.initState();
    _fetchMenus();
    _checkRole();
  }

  void _checkRole() async {
    final prefs = await SharedPreferences.getInstance(); // Quick dirty way or use AuthService
    setState(() {
      _userRole = prefs.getString('role') ?? '';
    });
  }

  Future<void> _fetchMenus() async {
    try {
      final menus = await _dataService.getMenus();
      setState(() {
        _menus = menus;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _confirmDeleteMenu(MenuModel menu) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Menu'),
        content: Text('Hapus ${menu.nama} permanen?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              final success = await AdminService().deleteMenu(menu.id);
              if (success) _fetchMenus();
              else {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal hapus menu')));
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    // Scaffold & AppBar Removed to avoid nested scaffold issues in DashboardScreen
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage.isNotEmpty
            ? Center(child: Text('Error: $_errorMessage'))
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, 
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _menus.length,
                  itemBuilder: (context, index) {
                    final menu = _menus[index];
                    return _buildMenuCard(menu);
                  },
                ),
              );
  }

  Widget _buildMenuCard(MenuModel menu) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF5D4037), width: 1),
      ),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('${menu.nama} dipilih')),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: menu.imageUrl.isNotEmpty
                    ? Image.network(
                        menu.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.fastfood, size: 50, color: Colors.grey),
                      )
                    : const Icon(Icons.fastfood, size: 50, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    menu.nama,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormat.format(menu.harga),
                    style: const TextStyle(color: Color(0xFF5D4037), fontWeight: FontWeight.w600),
                  ),
                  if (_userRole == 'OWNER') 
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () => _confirmDeleteMenu(menu),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
