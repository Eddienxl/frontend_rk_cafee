import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';
class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final UserService _userService = UserService();
  List<UserModel> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final users = await _userService.getUsers();
      if (mounted) {
        setState(() {
          _users = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showAddEditDialog({UserModel? user}) {
    final usernameController = TextEditingController(text: user?.username ?? '');
    final passwordController = TextEditingController();
    String selectedRole = user?.role ?? 'KASIR';
    final roles = ['OWNER', 'KASIR', 'BARISTA'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user == null ? 'Tambah User' : 'Edit User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (user == null) // Username tidak boleh edit?
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password (Kosongkan jika tetap)'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedRole,
              items: roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (val) => selectedRole = val!,
              decoration: const InputDecoration(labelText: 'Role'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              
              bool success;
              if (user == null) {
                // Add
                success = await _userService.createUser(
                  usernameController.text, 
                  passwordController.text, 
                  selectedRole
                );
              } else {
                // Edit
                success = await _userService.updateUser(
                  user.id, 
                  passwordController.text.isEmpty ? null : passwordController.text, 
                  selectedRole
                );
              }

              if (success) {
                _fetchUsers();
              } else {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal simpan')));
                setState(() => _isLoading = false);
              }
              
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _deleteUser(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus User'),
        content: Text('Yakin hapus ${user.username}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              final success = await _userService.deleteUser(user.id);
              if (success) {
                _fetchUsers();
              } else {
                if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal hapus')));
                 setState(() => _isLoading = false);
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
    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen User (Karyawan)')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(user.role.isNotEmpty ? user.role[0] : '?')),
                  title: Text(user.username),
                  subtitle: Text(user.role),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => _showAddEditDialog(user: user)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteUser(user)),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAddEditDialog(),
      ),
    );
  }
}
