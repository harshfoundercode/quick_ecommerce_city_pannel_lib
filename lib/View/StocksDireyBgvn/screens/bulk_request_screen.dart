import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stock_provider.dart';
import '../models/models.dart';
import '../widgets/app_header.dart';

class BulkRequestScreen extends StatefulWidget {
  const BulkRequestScreen({super.key});

  @override
  State<BulkRequestScreen> createState() => _BulkRequestScreenState();
}

class _BulkRequestScreenState extends State<BulkRequestScreen> {
  final Map<String, TextEditingController> _qtyControllers = {};
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    for (var c in _qtyControllers.values) c.dispose();
    _noteController.dispose();
    super.dispose();
  }

  TextEditingController _getController(String variantId) {
    _qtyControllers[variantId] ??= TextEditingController(text: '0');
    return _qtyControllers[variantId]!;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StockProvider>();
    final selectedProducts = provider.selectedProducts;

    return Column(
      children: [
        const AppHeader(
          title: 'Bulk Stock Update',
          subtitle: 'Select products from Stock Overview first',
        ),
        if (selectedProducts.isEmpty)
          _buildEmptyState()
        else
          Expanded(
            child: Column(
              children: [
                // Header bar
                _buildSelectionHeader(context, provider, selectedProducts),
                // Product-Variant list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: selectedProducts.length,
                    itemBuilder: (_, i) => _buildProductCard(selectedProducts[i]),
                  ),
                ),
                // Note + Submit
                _buildSubmitSection(context, provider, selectedProducts),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A35),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.add_shopping_cart, color: Color(0xFF3D5AFE), size: 36),
            ),
            const SizedBox(height: 20),
            const Text(
              'Koi product select nahi hai',
              style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Stock Overview mein products select karein\nphir yahan bulk update karein',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionHeader(
      BuildContext context, StockProvider provider, List<Product> selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF3D5AFE).withOpacity(0.1),
        border: Border(bottom: BorderSide(color: const Color(0xFF3D5AFE).withOpacity(0.2))),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: const Color(0xFF3D5AFE), size: 18),
          const SizedBox(width: 8),
          Text(
            '${selected.length} product(s) selected',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: provider.clearSelection,
            icon: const Icon(Icons.close, size: 16),
            label: const Text('Clear All'),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF12122A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D5AFE).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.inventory_2, color: Color(0xFF3D5AFE), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    product.name,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF1E1E40)),
          // Variants
          ...product.variants.map((v) => _buildVariantRow(product, v)),
        ],
      ),
    );
  }

  Widget _buildVariantRow(Product product, ProductVariant variant) {
    final controller = _getController(variant.id);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(variant.name,
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
                Text('SKU: ${variant.sku}',
                    style: const TextStyle(color: Colors.white38, fontSize: 11)),
                const SizedBox(height: 2),
                _stockBadge(variant.availableStock),
              ],
            ),
          ),
          // Quantity stepper
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A35),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _stepBtn(Icons.remove, () {
                  final val = int.tryParse(controller.text) ?? 0;
                  if (val > 0) setState(() => controller.text = '${val - 1}');
                }),
                SizedBox(
                  width: 50,
                  child: TextField(
                    controller: controller,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (v) => setState(() {}),
                  ),
                ),
                _stepBtn(Icons.add, () {
                  final val = int.tryParse(controller.text) ?? 0;
                  setState(() => controller.text = '${val + 1}');
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFF3D5AFE).withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF3D5AFE), size: 16),
      ),
    );
  }

  Widget _stockBadge(int qty) {
    Color color;
    String label;
    if (qty <= 0) {
      color = Colors.red;
      label = 'Out of Stock';
    } else if (qty <= 10) {
      color = Colors.orange;
      label = 'Low: $qty';
    } else {
      color = Colors.green;
      label = 'In Stock: $qty';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildSubmitSection(
      BuildContext context, StockProvider provider, List<Product> selectedProducts) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F22),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      child: Column(
        children: [
          TextField(
            controller: _noteController,
            style: const TextStyle(color: Colors.white),
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Note add karein (optional)...',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: const Color(0xFF1A1A35),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              prefixIcon: const Icon(Icons.note_alt_outlined, color: Colors.white38),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _submitRequest(context, provider, selectedProducts),
              icon: const Icon(Icons.send),
              label: const Text('Send Stock Request', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3D5AFE),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitRequest(
      BuildContext context, StockProvider provider, List<Product> selectedProducts) {
    final items = <StockRequestItem>[];
    for (final product in selectedProducts) {
      for (final variant in product.variants) {
        final qty = int.tryParse(_qtyControllers[variant.id]?.text ?? '0') ?? 0;
        if (qty > 0) {
          items.add(StockRequestItem(
            productId: product.id,
            productName: product.name,
            variantId: variant.id,
            variantName: variant.name,
            quantityRequested: qty,
          ));
        }
      }
    }

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Koi bhi variant mein quantity add nahi ki!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    provider.submitBulkRequest(items: items, note: _noteController.text.trim());
    _noteController.clear();
    _qtyControllers.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✓ ${items.length} items ka stock request submit hua!'),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }
}
