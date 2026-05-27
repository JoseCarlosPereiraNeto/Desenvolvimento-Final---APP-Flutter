import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../models/wish_item.dart';

class WishItemTile extends StatefulWidget {
  final WishItem item;
  final VoidCallback? onDelete;

  const WishItemTile({super.key, required this.item, this.onDelete});

  @override
  State<WishItemTile> createState() => _WishItemTileState();
}

class _WishItemTileState extends State<WishItemTile> {
  int _currentImageIndex = 0;

  String _normalizeUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return trimmed;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return 'https://$trimmed';
  }

  bool _isRemoteImage(String path) {
    final lower = path.toLowerCase();
    return lower.startsWith('http://') || lower.startsWith('https://');
  }

  Widget _buildImage(String path) {
    if (_isRemoteImage(path)) {
      return Image.network(
        path,
        fit: BoxFit.contain,
        width: double.infinity,
        alignment: Alignment.center,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade200,
            alignment: Alignment.center,
            child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
          );
        },
      );
    }

    return Image.file(
      File(path),
      fit: BoxFit.contain,
      width: double.infinity,
      alignment: Alignment.center,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade200,
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
        );
      },
    );
  }

  Future<void> _showImagePreview(String path) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: _isRemoteImage(path)
                  ? Image.network(
                      path,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.black,
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image, size: 64, color: Colors.white),
                        );
                      },
                    )
                  : Image.file(
                      File(path),
                      fit: BoxFit.contain,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.black,
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image, size: 64, color: Colors.white),
                        );
                      },
                    ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openUrl(String url) async {
    final normalized = _normalizeUrl(url);
    if (normalized.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL inválida.')),
      );
      return;
    }

    final uri = Uri.tryParse(normalized);
    if (uri == null || uri.scheme.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL inválida.')),
      );
      return;
    }

    try {
      final launched = await launchUrlString(normalized, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o link.')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o link.')),
      );
    }
  }

  Future<void> _copyLink(String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copiado para a área de transferência!')),
    );
  }

  Future<void> _confirmDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir item'),
          content: const Text('Deseja realmente excluir este item?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      widget.onDelete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (item.imageUrls.isNotEmpty)
            SizedBox(
              height: 200,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  PageView.builder(
                    itemCount: item.imageUrls.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final imageUrl = item.imageUrls[index];
                      return GestureDetector(
                        onTap: () => _showImagePreview(imageUrl),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: _buildImage(imageUrl),
                        ),
                      );
                    },
                  ),
                  if (item.imageUrls.length > 1)
                    Positioned(
                      bottom: 8,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          item.imageUrls.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: _currentImageIndex == index ? 12 : 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: _currentImageIndex == index ? Colors.white : Colors.white54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            )
          else
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.photo, size: 64, color: Colors.grey),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text('Valor estimado: R\$ ${item.value.toStringAsFixed(2)}'),
                if (item.storeUrl.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => _openUrl(item.storeUrl),
                    child: Text(
                      item.storeUrl,
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Abrir link da loja'),
                          onPressed: () => _openUrl(item.storeUrl),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _copyLink(item.storeUrl),
                        icon: const Icon(Icons.copy),
                        tooltip: 'Copiar link',
                      ),
                    ],
                  ),
                ],
                if (widget.onDelete != null) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text('Excluir', style: TextStyle(color: Colors.red)),
                      onPressed: _confirmDelete,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
