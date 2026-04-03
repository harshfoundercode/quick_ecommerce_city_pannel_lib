import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/CityStocksRedefinedDir/demo_data.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/CityStocksRedefinedDir/models.dart';


// ─────────────────────────────────────────────
//  REQUEST MODAL  (bulk send to admin)
// ─────────────────────────────────────────────
class RequestModal extends StatefulWidget {
  final List<CartItem> cart;
  final VoidCallback onSent;

  const RequestModal({super.key, required this.cart, required this.onSent});

  @override
  State<RequestModal> createState() => _RequestModalState();
}

class _RequestModalState extends State<RequestModal> {
  RequestPriority _priority = RequestPriority.normal;
  final _noteCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() { _noteCtrl.dispose(); super.dispose(); }

  void _send() async {
    if (widget.cart.isEmpty) return;
    setState(() => _sending = true);
    await Future.delayed(const Duration(milliseconds: 800));

    final newReq = StockRequest(
      id: 'REQ-2025-00${demoRequests.length + 1}',
      date: DateTime.now(),
      status: RequestStatus.pending,
      priority: _priority,
      items: widget.cart.map((c) => RequestItem(
        name: '${c.productName} ${c.variantLabel}',
        qty: c.qty,
      )).toList(),
      note: _noteCtrl.text.trim(),
    );
    demoRequests.insert(0, newReq);

    if (mounted) {
      Navigator.pop(context);
      widget.onSent();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('${newReq.id} sent to admin!',
              style: const TextStyle(fontWeight: FontWeight.w700)),
          ]),
          backgroundColor: ColorConst.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ColorConst.cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 38, height: 4,
              decoration: BoxDecoration(
                color: ColorConst.borderColor,
                borderRadius: BorderRadius.circular(2)),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Row(
              children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: ColorConst.primaryExtraLightGreen,
                    borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.send_rounded, size: 18, color: ColorConst.primaryGreen),
                ),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Send Restock Request',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: ColorConst.kTextHead)),
                  Text('${widget.cart.length} item${widget.cart.length > 1 ? 's' : ''} · Bulk request to admin',
                    style: const TextStyle(fontSize: 12, color: ColorConst.textSecondary)),
                ]),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                      color: ColorConst.containerGrey,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: ColorConst.borderColor)),
                    child: const Icon(Icons.close, size: 16, color: ColorConst.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: ColorConst.borderColor),

          // Body
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary
                  const Text('Request Summary',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: ColorConst.kTextHead)),
                  const SizedBox(height: 10),
                  ...widget.cart.map((item) => _ModalCartRow(item: item)),

                  const SizedBox(height: 18),
                  const Divider(color: ColorConst.borderColor),
                  const SizedBox(height: 14),

                  // Priority
                  const Text('Priority',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: ColorConst.kTextHead)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _PriorityOption(
                        label: 'Normal', icon: Icons.info_outline_rounded,
                        selected: _priority == RequestPriority.normal,
                        selectedBg: const Color(0xFFEFF6FF),
                        selectedBorder: const Color(0xFF93C5FD),
                        selectedTextColor: const Color(0xFF1D4ED8),
                        onTap: () => setState(() => _priority = RequestPriority.normal),
                      )),
                      const SizedBox(width: 8),
                      Expanded(child: _PriorityOption(
                        label: 'Urgent', icon: Icons.priority_high_rounded,
                        selected: _priority == RequestPriority.urgent,
                        selectedBg: ColorConst.criticalYellowLight,
                        selectedBorder: const Color(0xFFFDE68A),
                        selectedTextColor: ColorConst.criticalYellowLightText,
                        onTap: () => setState(() => _priority = RequestPriority.urgent),
                      )),
                      const SizedBox(width: 8),
                      Expanded(child: _PriorityOption(
                        label: 'Critical', icon: Icons.warning_rounded,
                        selected: _priority == RequestPriority.critical,
                        selectedBg: ColorConst.criticalRedLight,
                        selectedBorder: const Color(0xFFFECACA),
                        selectedTextColor: ColorConst.criticalRed,
                        onTap: () => setState(() => _priority = RequestPriority.critical),
                      )),
                    ],
                  ),

                  const SizedBox(height: 16),
                  // Note
                  const Text('Note for Admin (optional)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: ColorConst.kTextHead)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteCtrl,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 13, color: ColorConst.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'e.g. Festive season approaching, IPL peak demand...',
                      hintStyle: const TextStyle(fontSize: 13, color: ColorConst.textSecondary),
                      filled: true,
                      fillColor: ColorConst.containerGrey2,
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: ColorConst.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: ColorConst.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: ColorConst.primaryLightGreen, width: 1.5),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  // Send button
                  SizedBox(
                    width: double.infinity,
                    child: Material(
                      color: ColorConst.primaryGreen,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: _sending ? null : _send,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: _sending
                              ? const Center(child: SizedBox(
                                  width: 22, height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)))
                              : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  const Icon(Icons.send_rounded, size: 17, color: Colors.white),
                                  const SizedBox(width: 8),
                                  const Text('Send Request to Admin',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                                ]),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModalCartRow extends StatelessWidget {
  final CartItem item;
  const _ModalCartRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: ColorConst.containerGrey2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColorConst.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.productName,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: ColorConst.kTextHead)),
              const SizedBox(height: 2),
              Text(item.variantLabel,
                style: const TextStyle(fontSize: 11, color: ColorConst.textSecondary)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: ColorConst.primaryExtraLightGreen,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Text('×${item.qty}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: ColorConst.primaryGreen)),
          ),
        ],
      ),
    );
  }
}

class _PriorityOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color selectedBg, selectedBorder, selectedTextColor;
  final VoidCallback onTap;
  const _PriorityOption({
    required this.label, required this.icon,
    required this.selected, required this.selectedBg,
    required this.selectedBorder, required this.selectedTextColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? selectedBg : ColorConst.containerGrey,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? selectedBorder : ColorConst.borderColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18,
              color: selected ? selectedTextColor : ColorConst.textSecondary),
            const SizedBox(height: 4),
            Text(label,
              style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w800,
                color: selected ? selectedTextColor : ColorConst.textSecondary,
              )),
          ],
        ),
      ),
    );
  }
}
