import 'package:flutter/material.dart';
import '../../data/models/menu_model.dart';
import '../constants/api_constants.dart';

/// Mapper gambar untuk menu.
///
/// Menggunakan Picsum seeded images sehingga setiap menu akan selalu mendapatkan
/// gambar yang sama (deterministik). Untuk menjaga keserasian tema, juga
/// menyediakan warna overlay per kategori.
class MenuImageMapper {
  /// Return a deterministic URL untuk gambar menu (picsum.photos seeded).
  /// Seed dibentuk dari `idMenu` jika ada, atau dari nama menu.
  static String imageUrlFor(MenuModel menu, {int width = 400, int height = 300}) {
    final seedSource = (menu.idMenu ?? menu.namaMenu ?? 'menu').replaceAll(' ', '_');
    final seed = Uri.encodeComponent(seedSource.toLowerCase());
    return 'https://picsum.photos/seed/$seed/$width/$height';
  }

  /// If the menu already contains an `imageUrl` (from DB), normalize it to
  /// picsum's expected path format (width/height). Also returns a generated
  /// picsum URL when `menu.imageUrl` is null or empty.
  static String resolvedImageUrlFor(MenuModel menu, {int width = 400, int height = 300}) {
    final raw = menu.imageUrl?.trim();
    if (raw == null || raw.isEmpty) return imageUrlFor(menu, width: width, height: height);

    // If it's already a full URL (http:// or https://), use it directly
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }

    // If it's a relative path like '/uploads/...', prepend the API base (host + port)
    if (raw.startsWith('/uploads/')) {
      try {
        final baseUri = Uri.parse(ApiConstants.baseUrl);
        final origin = '${baseUri.scheme}://${baseUri.host}${baseUri.port != 80 && baseUri.port != 443 ? ':${baseUri.port}' : ''}';
        return '$origin$raw';
      } catch (_) {
        return raw;
      }
    }

    // Normalize patterns like '/.../400x300' to '/.../400/300' (old picsum format)
    try {
      final uri = Uri.parse(raw);
      final segments = List<String>.from(uri.pathSegments);
      if (segments.isNotEmpty) {
        final last = segments.last;
        final match = RegExp(r'^(\d+)x(\d+)$').firstMatch(last);
        if (match != null) {
          segments.removeLast();
          segments.add(match.group(1)!);
          segments.add(match.group(2)!);
          final newPath = segments.join('/');
          final normalized = Uri(
            scheme: uri.scheme.isEmpty ? 'https' : uri.scheme,
            host: uri.host.isEmpty ? 'picsum.photos' : uri.host,
            path: newPath,
          ).toString();
          return normalized;
        }
      }
      return raw;
    } catch (_) {
      return raw;
    }
  }

  /// Warna overlay berdasarkan kategori untuk memastikan tone seragam.
  static Color overlayColorFor(MenuModel menu) {
    final kategori = (menu.kategori ?? '').toLowerCase();
    if (kategori.contains('coffee') || kategori.contains('kopi')) return const Color(0xFF6F4E37); // coffee brown
    if (kategori.contains('non') || kategori.contains('tea') || kategori.contains('non coffee')) return const Color(0xFF2E8B57); // greenish
    if (kategori.contains('food') || kategori.contains('makanan')) return const Color(0xFFB7410E); // warm orange
    if (kategori.contains('add') || kategori.contains('addon') || kategori.contains('add on')) return const Color(0xFF6A5ACD); // purple
    return const Color(0xFF37474F); // default slate
  }
}
