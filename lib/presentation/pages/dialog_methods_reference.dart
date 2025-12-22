// Add these two methods to PosPage _PosPageState class

void _showAddMenuDialog() {
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  String _selectedKategori = AppConstants.kategoriMenu.isNotEmpty ? AppConstants.kategoriMenu[0] : 'Coffee';
  String? _uploadedImageUrl;
  bool _isUploading = false;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Tambah Menu'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(controller: _idController, hintText: 'ID Menu (unik)'),
                  const SizedBox(height: 8),
                  CustomTextField(controller: _nameController, hintText: 'Nama Menu'),
                  const SizedBox(height: 8),
                  CustomTextField(controller: _priceController, hintText: 'Harga', keyboardType: TextInputType.number),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedKategori,
                    items: AppConstants.kategoriMenu.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                    onChanged: (v) { if (v != null) setState(() => _selectedKategori = v); },
                    decoration: const InputDecoration(labelText: 'Kategori'),
                  ),
                  const SizedBox(height: 12),
                  const Text('Foto Menu *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 8),
                  _uploadedImageUrl == null
                      ? ElevatedButton.icon(
                          icon: const Icon(Icons.image),
                          label: _isUploading ? const Text('Uploading...') : const Text('Upload Foto'),
                          onPressed: _isUploading ? null : () async {
                            setState(() => _isUploading = true);
                            final imageUrl = await FileUploadService.uploadImageFile();
                            setState(() {
                              _uploadedImageUrl = imageUrl;
                              _isUploading = false;
                            });
                            if (imageUrl != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Foto berhasil diupload')),
                              );
                            }
                          },
                        )
                      : Column(
                          children: [
                            Container(
                              width: 200,
                              height: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[200],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(_uploadedImageUrl!, fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.refresh),
                              label: const Text('Ganti Foto'),
                              onPressed: () async {
                                setState(() => _isUploading = true);
                                final imageUrl = await FileUploadService.uploadImageFile();
                                setState(() {
                                  if (imageUrl != null) _uploadedImageUrl = imageUrl;
                                  _isUploading = false;
                                });
                              },
                            ),
                          ],
                        ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
              ElevatedButton(
                onPressed: _isUploading || _uploadedImageUrl == null ? null : () async {
                  final id = _idController.text.trim();
                  final name = _nameController.text.trim();
                  final harga = double.tryParse(_priceController.text.trim()) ?? 0.0;
                  final kategori = _selectedKategori;

                  if (id.isEmpty || name.isEmpty || _uploadedImageUrl == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ID, Nama, dan Foto wajib diisi')),
                    );
                    return;
                  }

                  final body = {
                    'id_menu': id,
                    'nama_menu': name,
                    'harga': harga,
                    'kategori': kategori,
                    'status_tersedia': true,
                    'image_url': _uploadedImageUrl,
                  };

                  try {
                    final success = await context.read<MenuProvider>().createMenu(body);
                    if (success) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Menu berhasil dibuat')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Gagal membuat menu')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      );
    },
  );
}

void _showEditMenuDialog(MenuModel menu) {
  final _nameController = TextEditingController(text: menu.namaMenu);
  final _priceController = TextEditingController(text: menu.harga.toString());
  String _selectedKategori = menu.kategori ?? AppConstants.kategoriMenu.first;
  String? _newImageUrl = menu.imageUrl;
  bool _isUploading = false;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit Menu'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('ID: ${menu.idMenu}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  const SizedBox(height: 12),
                  CustomTextField(controller: _nameController, hintText: 'Nama Menu'),
                  const SizedBox(height: 8),
                  CustomTextField(controller: _priceController, hintText: 'Harga', keyboardType: TextInputType.number),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedKategori,
                    items: AppConstants.kategoriMenu.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                    onChanged: (v) { if (v != null) setState(() => _selectedKategori = v); },
                    decoration: const InputDecoration(labelText: 'Kategori'),
                  ),
                  const SizedBox(height: 12),
                  const Text('Foto Menu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 8),
                  if (_newImageUrl != null)
                    Container(
                      width: 200,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[200],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(_newImageUrl!, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.image),
                    label: _isUploading ? const Text('Uploading...') : const Text(_newImageUrl != null ? 'Ganti Foto' : 'Upload Foto'),
                    onPressed: _isUploading ? null : () async {
                      setState(() => _isUploading = true);
                      final imageUrl = await FileUploadService.uploadImageFile();
                      setState(() {
                        if (imageUrl != null) _newImageUrl = imageUrl;
                        _isUploading = false;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
              ElevatedButton(
                onPressed: _isUploading ? null : () async {
                  final name = _nameController.text.trim();
                  final harga = double.tryParse(_priceController.text.trim()) ?? 0.0;
                  final kategori = _selectedKategori;

                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nama menu wajib diisi')),
                    );
                    return;
                  }

                  final body = {
                    'nama_menu': name,
                    'harga': harga,
                    'kategori': kategori,
                    if (_newImageUrl != null) 'image_url': _newImageUrl,
                  };

                  try {
                    final success = await context.read<MenuProvider>().updateMenu(menu.idMenu, body);
                    if (success) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Menu berhasil diupdate')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Gagal update menu')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      );
    },
  );
}
