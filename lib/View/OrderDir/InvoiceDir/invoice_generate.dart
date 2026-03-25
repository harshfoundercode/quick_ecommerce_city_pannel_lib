import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/order_view_details_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/OrderDir/InvoiceDir/invoice_services.dart';


class InvoiceServiceBuildPdf {
  // ── Colours ────────────────────────────────────────────────────────────────
  static const _primary   = PdfColor.fromInt(0xff6CC51D);
  static const _green     = PdfColor.fromInt(0xFF059669);
  static const _lightBg   = PdfColor.fromInt(0xFFF4F6FA);
  static const _border    = PdfColor.fromInt(0xFFE5E7EB);
  static const _textDark  = PdfColor.fromInt(0xFF111827);
  static const _textMed   = PdfColor.fromInt(0xFF374151);
  static const _textLight = PdfColor.fromInt(0xFF6B7280);
  static const _textMuted = PdfColor.fromInt(0xFF9CA3AF);
  static const _blue      = PdfColor.fromInt(0xFF2563EB);
  static const _amber     = PdfColor.fromInt(0xFFD97706);
  static const _red       = PdfColor.fromInt(0xFFDC2626);
  static const _violet    = PdfColor.fromInt(0xFF7C3AED);
  static const _cyan      = PdfColor.fromInt(0xFF0891B2);
  static const _lightBlue = PdfColor.fromInt(0xFFFFFFFF);

  // ── Status helpers ─────────────────────────────────────────────────────────
  static String _statusLabel(int? s) => const {
    0:'Placed', 1:'Confirmed', 2:'Picked',
    3:'Out for Delivery', 4:'Completed',
    5:'Cancelled', 6:'Returned',
  }[s] ?? 'Unknown';

  static PdfColor _statusColor(int? s) => {
    0: _blue, 1: _violet, 2: _amber,
    3: _cyan, 4: _green, 5: _red,
    6: _textMuted,
  }[s] ?? _textMuted;

  static String _payLabel(int? s) => const {
    0:'Pending', 1:'Paid', 2:'Failed', 3:'Refunded',
  }[s] ?? 'Unknown';

  static PdfColor _payColor(int? s) => {
    0: _amber, 1: _green, 2: _red, 3: _violet,
  }[s] ?? _textMuted;

  static String _fmt(dynamic iso) {
    if (iso == null) return '/';
    try {
      return DateFormat('dd MMM yyyy, hh:mm a')
          .format(DateTime.parse(iso.toString()).toLocal());
    } catch (_) { return iso.toString(); }
  }

  // ── PDF builder ────────────────────────────────────────────────────────────

  static Future<Uint8List> _buildPdf(OrderViewDataModel model) async {
    final pdf     = pw.Document();
    final data    = model.data;
    final order   = data?.order;
    final items   = data?.items   ?? [];
    final payment = data?.payment;

    final sLabel = _statusLabel(order?.status);
    final sColor = _statusColor(order?.status);
    final pLabel = _payLabel(payment?.status);
    final pColor = _payColor(payment?.status);

    final subtotal = _amt(order?.totalAmount);
    final delivery = _amt(order?.deliveryCharge);
    final total    = _amt(order?.finalAmount);

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(18 * PdfPageFormat.mm),
      build: (_) => [
        _header(order),
        pw.SizedBox(height: 12),
        _metaStrip(order, sLabel, sColor),
        pw.SizedBox(height: 14),

        // ── Customer + Delivery ───────────────────────────────────────
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(child: _infoCard('Customer Details', [
              ('Name',    order?.customerName?.toString()  ?? 'N/n'),
              ('Phone',   order?.customerPhone?.toString() ?? 'N/n'),
              ('Address', _addrStr(order)),
            ])),
            pw.SizedBox(width: 10),
            pw.Expanded(child: _infoCard('Delivery Details', [
              ('Partner', order?.deliveryName?.toString()  ?? 'N/n'),
              ('Phone',   order?.deliveryPhone?.toString() ?? 'N/n'),
              ('Hub',     order?.hubName?.toString()       ?? 'N/n'),
            ])),
          ],
        ),
        pw.SizedBox(height: 16),

        // ── Items ─────────────────────────────────────────────────────
        _sectionTitle('Order Items'),
        pw.SizedBox(height: 6),
        _itemsTable(items),
        pw.SizedBox(height: 14),

        // ── Payment + Price ───────────────────────────────────────────
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(child: _payCard(payment, pLabel, pColor)),
            pw.SizedBox(width: 10),
            pw.Expanded(child: _priceSummary(subtotal, delivery, total)),
          ],
        ),
      ],
      footer: (_) => _footer(order?.orderNo?.toString() ?? ''),
    ));

    return pdf.save();
  }

  // ── Components ─────────────────────────────────────────────────────────────

  static pw.Widget _header(Order? order) => pw.Container(
    width: Sizes.screenWidth,
    padding: const pw.EdgeInsets.all(16),
    decoration: const pw.BoxDecoration(color: _primary),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text('Fasto',
              style: pw.TextStyle(color: PdfColors.white, fontSize: 20,
                  fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 3),
          pw.Text('City Admin Panel  |  Order Invoice',
              style: const pw.TextStyle(color: _lightBlue, fontSize: 9)),
        ]),
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
          pw.Text('INVOICE',
              style: pw.TextStyle(color: PdfColors.white, fontSize: 22,
                  fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 3),
          pw.Text('#${order?.orderNo ?? ''}',
              style: const pw.TextStyle(color: _lightBlue, fontSize: 9)),
        ]),
      ],
    ),
  );

  static pw.Widget _metaStrip(Order? order, String sLabel, PdfColor sColor) =>
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: pw.BoxDecoration(
            color: _lightBg, borderRadius: pw.BorderRadius.circular(6)),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _metaCell('ORDER DATE', _fmt(order?.createdAt)),
            _metaCell('UPDATED',    _fmt(order?.updatedAt)),
            _metaCell('PAYMENT',
                (order?.paymentMethod?.toString() ?? 'N/n').toUpperCase()),
            _metaCell('STATUS', sLabel, valueColor: sColor),
          ],
        ),
      );

  static pw.Widget _metaCell(String label, String value,
      {PdfColor? valueColor}) =>
      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(label, style: const pw.TextStyle(color: _textMuted, fontSize: 7)),
        pw.SizedBox(height: 3),
        pw.Text(value, style: pw.TextStyle(
            color: valueColor ?? _textDark, fontSize: 9,
            fontWeight: pw.FontWeight.bold)),
      ]);

  static pw.Widget _sectionTitle(String title) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(title, style: pw.TextStyle(
          color: _textDark, fontSize: 11, fontWeight: pw.FontWeight.bold)),
      pw.Container(width: 36, height: 2,
          margin: const pw.EdgeInsets.only(top: 3),
          decoration: const pw.BoxDecoration(color: _green)),
    ],
  );

  static pw.Widget _infoCard(String title, List<(String, String)> rows) =>
      pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          border: pw.Border.all(color: _border, width: 0.5),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: const pw.BoxDecoration(color: _primary),
              child: pw.Text(title, style: pw.TextStyle(
                  color: PdfColors.white, fontSize: 9,
                  fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 8),
            ...rows.map((r) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 5),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(width: 55,
                      child: pw.Text('${r.$1}:',
                          style: const pw.TextStyle(color: _textLight, fontSize: 8))),
                  pw.Expanded(child: pw.Text(r.$2, style: pw.TextStyle(
                      color: _textDark, fontSize: 8,
                      fontWeight: pw.FontWeight.bold))),
                ],
              ),
            )),
          ],
        ),
      );

  static pw.Widget _itemsTable(List<Items> items) {
    const hS = pw.TextStyle(color: PdfColors.white, fontSize: 9);
    final rS = pw.TextStyle(color: _textDark,  fontSize: 8.5);
    final mS = pw.TextStyle(color: _textLight, fontSize: 8.5);
    final bS = pw.TextStyle(color: _textDark,  fontSize: 8.5,
        fontWeight: pw.FontWeight.bold);

    return pw.Table(
      columnWidths: {
        0: const pw.FixedColumnWidth(22),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(1.3),
        3: const pw.FixedColumnWidth(30),
        4: const pw.FlexColumnWidth(1.3),
      },
      border: pw.TableBorder.all(color: _border, width: 0.3),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _primary),
          children: [
            _cell('#',            hS, pw.Alignment.center),
            _cell('Product',      hS, pw.Alignment.centerLeft),
            _cell('Unit Price',   hS, pw.Alignment.centerRight),
            _cell('Qty',          hS, pw.Alignment.center),
            _cell('Total',        hS, pw.Alignment.centerRight),
          ],
        ),
        ...List.generate(items.length, (i) {
          final item = items[i];
          return pw.TableRow(
            decoration: pw.BoxDecoration(
                color: i.isEven ? _lightBg : PdfColors.white),
            children: [
              _cell('${i + 1}',                          mS, pw.Alignment.center),
              _cell(item.productName?.toString() ?? 'N/n', rS, pw.Alignment.centerLeft),
              _cell('Rs.${item.price ?? 0}',             rS, pw.Alignment.centerRight),
              _cell('${item.qty ?? 0}',                  rS, pw.Alignment.center),
              _cell('Rs.${item.totalPrice ?? 0}',        bS, pw.Alignment.centerRight),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _cell(String t, pw.TextStyle s, pw.Alignment a) =>
      pw.Container(
        alignment: a,
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        child: pw.Text(t, style: s),
      );

  static pw.Widget _priceSummary(
      double subtotal, double delivery, double total) =>
      pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          border: pw.Border.all(color: _border, width: 0.5),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Text('Price Summary', style: pw.TextStyle(
                color: _primary, fontSize: 9, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            _priceRow('Subtotal',        'Rs. ${subtotal.toStringAsFixed(2)}', false),
            pw.SizedBox(height: 5),
            _priceRow('Delivery Charge', 'Rs. ${delivery.toStringAsFixed(2)}', false),
            pw.Divider(color: _border, thickness: 0.5),
            pw.SizedBox(height: 3),
            _priceRow('Total Amount',    'Rs. ${total.toStringAsFixed(2)}',    true),
          ],
        ),
      );

  static pw.Widget _priceRow(String label, String value, bool bold) =>
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(
              color: bold ? _textDark : _textLight,
              fontSize: bold ? 10 : 8.5,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(value, style: pw.TextStyle(
              color: bold ? _green : _textMed,
              fontSize: bold ? 11 : 8.5,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ],
      );

  static pw.Widget _payCard(
      Payment? payment, String pLabel, PdfColor pColor) =>
      pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: _lightBg,
          border: pw.Border.all(color: _border, width: 0.5),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Payment Info', style: pw.TextStyle(
                color: _primary, fontSize: 9, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            _payRow('TXN ID',
                payment?.transactionId?.toString() ?? 'N/n'),
            pw.SizedBox(height: 4),
            _payRow('Method',
                (payment?.paymentMethod?.toString() ?? 'N/n').toUpperCase()),
            pw.SizedBox(height: 4),
            _payRow('Amount', 'Rs. ${payment?.amount ?? 0}'),
            pw.SizedBox(height: 5),
            pw.Row(children: [
              pw.Text('Status: ',
                  style: const pw.TextStyle(color: _textLight, fontSize: 8)),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: pw.BoxDecoration(
                    color: pColor, borderRadius: pw.BorderRadius.circular(10)),
                child: pw.Text(pLabel, style: pw.TextStyle(
                    color: PdfColors.white, fontSize: 8,
                    fontWeight: pw.FontWeight.bold)),
              ),
            ]),
          ],
        ),
      );

  static pw.Widget _payRow(String label, String value) => pw.Row(children: [
    pw.SizedBox(width: 45, child: pw.Text('$label:',
        style: const pw.TextStyle(color: _textLight, fontSize: 8))),
    pw.Expanded(child: pw.Text(value, style: pw.TextStyle(
        color: _textDark, fontSize: 8, fontWeight: pw.FontWeight.bold))),
  ]);

  static pw.Widget _footer(String orderNo) => pw.Container(
    color: _primary,
    width: Sizes.screenWidth,
    padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 18),
    child: pw.Column(children: [
      pw.Text('Fasto City Panel  |  Generated automatically',
          style: const pw.TextStyle(color: PdfColors.white, fontSize: 8),
          textAlign: pw.TextAlign.center),
      pw.SizedBox(height: 3),
      pw.Text('Invoice for Order $orderNo  |  System-generated document',
          style: const pw.TextStyle(color: _lightBlue, fontSize: 7),
          textAlign: pw.TextAlign.center),
    ]),
  );

  // ── Helpers ────────────────────────────────────────────────────────────────

  static double _amt(dynamic v) =>
      double.tryParse(v?.toString() ?? '0') ?? 0.0;

  static String _addrStr(Order? order) =>
      [order?.address, order?.landmark, order?.pincode]
          .where((e) => e != null && e.toString().isNotEmpty)
          .map((e) => e.toString())
          .join(', ');
}

// ─── Drop-in button ───────────────────────────────────────────────────────────

class InvoiceDownloadButton extends StatefulWidget {
  final OrderViewDataModel model;
  const InvoiceDownloadButton({super.key, required this.model});

  @override
  State<InvoiceDownloadButton> createState() =>
      _InvoiceDownloadButtonState();
}

class _InvoiceDownloadButtonState extends State<InvoiceDownloadButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _loading
            ? null
            : () async {
          setState(() => _loading = true);
          final bytes = await InvoiceServiceBuildPdf._buildPdf(widget.model);
          await InvoiceService.saveAndOpen(
            context,
            bytes,
            "Invoice_${widget.model.data?.order?.orderNo}.pdf",);

          if (mounted) setState(() => _loading = false);
        },
        icon: _loading
            ? const SizedBox(
            width: 16, height: 16,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.picture_as_pdf_rounded,
            size: 18, color: Colors.white),
        label: Text(
          _loading ? 'Generating PDF...' : 'View Invoice',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorConst.primaryGreen,
          disabledBackgroundColor: ColorConst.primaryLightGreen,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
    );
  }
}