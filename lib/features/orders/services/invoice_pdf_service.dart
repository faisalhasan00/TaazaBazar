import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../core/constants/app_constants.dart';
import '../../checkout/domain/order_model.dart';
import '../domain/customer_order.dart';

/// Service for generating professional, mathematically accurate, and clean
/// invoice PDF documents for TaazaBazar customer orders.
class InvoicePdfService {
  InvoicePdfService._();

  /// Generates a deterministic invoice number from the order ID.
  /// Format: INV-TB-{id} or INV-{id} without spaces/hashes.
  static String getInvoiceNumber(String orderId) {
    var cleanId = orderId.replaceAll('#', '').trim().replaceAll(RegExp(r'\s+'), '-');
    cleanId = cleanId.replaceAll(RegExp(r'^-+|-+$'), '');
    if (cleanId.startsWith('INV-')) {
      return cleanId;
    }
    return 'INV-$cleanId';
  }

  static String _formatDateTime(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[dt.month - 1];
    final hour12 = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    return '$day $month ${dt.year}, $hour12:$min $ampm';
  }

  /// Builds a PDF Document as raw bytes for a given CustomerOrder.
  static Future<Uint8List> generateInvoicePdf(CustomerOrder order) async {
    final pdf = pw.Document();

    // Use standard fonts provided by pdf package or font provider
    final fontRegular = await PdfGoogleFonts.plusJakartaSansRegular();
    final fontBold = await PdfGoogleFonts.plusJakartaSansBold();
    final fontSemiBold = await PdfGoogleFonts.plusJakartaSansSemiBold();

    final invoiceNumber = getInvoiceNumber(order.orderId);
    final formattedDate = _formatDateTime(order.orderDate);

    // Primary Brand Colors
    const primaryColor = PdfColor.fromInt(0xFF166534); // Emerald Dark Green
    const primaryLight = PdfColor.fromInt(0xFFDCFCE7); // Light Emerald
    const textDark = PdfColor.fromInt(0xFF0F172A); // Slate 900
    const textMuted = PdfColor.fromInt(0xFF64748B); // Slate 500
    const borderColor = PdfColor.fromInt(0xFFE2E8F0); // Slate 200
    const cardBg = PdfColor.fromInt(0xFFF8FAFC); // Slate 50

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ==========================================
              // 1. BRAND HEADER & INVOICE META
              // ==========================================
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        AppConstants.appName,
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 24,
                          color: primaryColor,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        AppConstants.appTagline,
                        style: pw.TextStyle(
                          font: fontRegular,
                          fontSize: 10,
                          color: textMuted,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Support: ${AppConstants.supportPhone}',
                        style: pw.TextStyle(
                          font: fontRegular,
                          fontSize: 9,
                          color: textMuted,
                        ),
                      ),
                      pw.Text(
                        'Email: ${AppConstants.supportEmail}',
                        style: pw.TextStyle(
                          font: fontRegular,
                          fontSize: 9,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: pw.BoxDecoration(
                      color: primaryLight,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'ORDER INVOICE',
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 12,
                            color: primaryColor,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          invoiceNumber,
                          style: pw.TextStyle(
                            font: fontSemiBold,
                            fontSize: 10,
                            color: textDark,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Order ID: ${order.orderId}',
                          style: pw.TextStyle(
                            font: fontRegular,
                            fontSize: 9,
                            color: textDark,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Date: $formattedDate',
                          style: pw.TextStyle(
                            font: fontRegular,
                            fontSize: 9,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 20),
              pw.Divider(color: borderColor, thickness: 1),
              pw.SizedBox(height: 14),

              // ==========================================
              // 2. BILL TO / DELIVERY DETAILS
              // ==========================================
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: cardBg,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  border: pw.Border.all(color: borderColor),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      flex: 6,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'DELIVERY DESTINATION',
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 9,
                              color: textMuted,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            order.deliveryAddress.isNotEmpty
                                ? order.deliveryAddress
                                : 'Address provided at checkout',
                            style: pw.TextStyle(
                              font: fontRegular,
                              fontSize: 10,
                              color: textDark,
                              lineSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 16),
                    pw.Expanded(
                      flex: 4,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'DELIVERY SLOT',
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 9,
                              color: textMuted,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            '${order.slotDate}\n${order.timeSlot}',
                            style: pw.TextStyle(
                              font: fontSemiBold,
                              fontSize: 10,
                              color: textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // ==========================================
              // 3. ITEM TABLE
              // ==========================================
              pw.Text(
                'ORDER ITEMS (${order.items.length})',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 11,
                  color: textDark,
                ),
              ),
              pw.SizedBox(height: 8),

              pw.Table(
                border: pw.TableBorder(
                  horizontalInside: pw.BorderSide(color: borderColor, width: 0.5),
                  bottom: pw.BorderSide(color: borderColor, width: 1),
                ),
                columnWidths: const {
                  0: pw.FlexColumnWidth(1),
                  1: pw.FlexColumnWidth(5),
                  2: pw.FlexColumnWidth(2),
                  3: pw.FlexColumnWidth(2),
                  4: pw.FlexColumnWidth(2),
                },
                children: [
                  // Table Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: cardBg,
                    ),
                    children: [
                      _buildTableCell('#', fontBold, isHeader: true),
                      _buildTableCell('Item Description', fontBold, isHeader: true),
                      _buildTableCell('Qty', fontBold, align: pw.TextAlign.center, isHeader: true),
                      _buildTableCell('Price', fontBold, align: pw.TextAlign.right, isHeader: true),
                      _buildTableCell('Total', fontBold, align: pw.TextAlign.right, isHeader: true),
                    ],
                  ),
                  // Items
                  ...order.items.asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final item = entry.value;
                    return pw.TableRow(
                      children: [
                        _buildTableCell('$index', fontRegular),
                        _buildTableCell(
                          '${item.product.name} (${item.product.unit})',
                          fontRegular,
                        ),
                        _buildTableCell(
                          '${item.quantity}',
                          fontRegular,
                          align: pw.TextAlign.center,
                        ),
                        _buildTableCell(
                          'INR ${item.product.price.toStringAsFixed(2)}',
                          fontRegular,
                          align: pw.TextAlign.right,
                        ),
                        _buildTableCell(
                          'INR ${item.subtotal.toStringAsFixed(2)}',
                          fontSemiBold,
                          align: pw.TextAlign.right,
                        ),
                      ],
                    );
                  }),
                ],
              ),

              pw.SizedBox(height: 16),

              // ==========================================
              // 4. BILLING SUMMARY & PAYMENT INFO
              // ==========================================
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  // Left side: Payment details & status box
                  pw.Expanded(
                    flex: 5,
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: cardBg,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                        border: pw.Border.all(color: borderColor),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'PAYMENT DETAILS',
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 9,
                              color: textMuted,
                            ),
                          ),
                          pw.SizedBox(height: 6),
                          _buildKeyValueRow('Method:', order.paymentMethod.title, fontRegular, fontSemiBold),
                          pw.SizedBox(height: 3),
                          _buildKeyValueRow(
                            'Status:',
                            order.paymentStatus.name.toUpperCase(),
                            fontRegular,
                            fontBold,
                            valueColor: _getPaymentStatusColor(order.paymentStatus),
                          ),
                          if (order.gatewayPaymentId != null && order.gatewayPaymentId!.isNotEmpty) ...[
                            pw.SizedBox(height: 3),
                            _buildKeyValueRow('Payment ID:', order.gatewayPaymentId!, fontRegular, fontRegular),
                          ],
                          if (order.refundStatus != null && order.refundStatus!.isNotEmpty) ...[
                            pw.SizedBox(height: 6),
                            pw.Divider(color: borderColor, thickness: 0.5),
                            pw.SizedBox(height: 4),
                            _buildKeyValueRow(
                              'Refund Status:',
                              order.refundStatus!.toUpperCase(),
                              fontRegular,
                              fontBold,
                              valueColor: const PdfColor.fromInt(0xFF9333EA),
                            ),
                            if (order.refundAmount != null) ...[
                              pw.SizedBox(height: 3),
                              _buildKeyValueRow(
                                'Refund Amount:',
                                'INR ${order.refundAmount!.toStringAsFixed(2)}',
                                fontRegular,
                                fontSemiBold,
                              ),
                            ],
                            if (order.refundId != null) ...[
                              pw.SizedBox(height: 3),
                              _buildKeyValueRow('Refund ID:', order.refundId!, fontRegular, fontRegular),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),

                  pw.SizedBox(width: 20),

                  // Right side: Financial Totals
                  pw.Expanded(
                    flex: 5,
                    child: pw.Column(
                      children: [
                        _buildSummaryLine('Item Subtotal', 'INR ${order.itemTotal.toStringAsFixed(2)}', fontRegular),
                        pw.SizedBox(height: 6),
                        _buildSummaryLine(
                          'Delivery Partner Fee',
                          order.deliveryFee == 0
                              ? 'FREE'
                              : 'INR ${order.deliveryFee.toStringAsFixed(2)}',
                          fontRegular,
                          isHighlight: order.deliveryFee == 0,
                        ),
                        if (order.discount > 0) ...[
                          pw.SizedBox(height: 6),
                          _buildSummaryLine(
                            'Coupon Discount',
                            '- INR ${order.discount.toStringAsFixed(2)}',
                            fontRegular,
                            isDiscount: true,
                          ),
                        ],
                        pw.SizedBox(height: 8),
                        pw.Divider(color: borderColor, thickness: 1),
                        pw.SizedBox(height: 6),
                        _buildSummaryLine(
                          'Grand Total',
                          'INR ${order.grandTotal.toStringAsFixed(2)}',
                          fontBold,
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.Spacer(),

              // ==========================================
              // 5. FOOTER & COMPLIANCE NOTES
              // ==========================================
              pw.Divider(color: borderColor, thickness: 0.5),
              pw.SizedBox(height: 6),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'This is an official computer-generated receipt for your order.',
                    style: pw.TextStyle(
                      font: fontRegular,
                      fontSize: 8,
                      color: textMuted,
                    ),
                  ),
                  pw.Text(
                    'TaazaBazar | Hyderabad, Telangana',
                    style: pw.TextStyle(
                      font: fontRegular,
                      fontSize: 8,
                      color: textMuted,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildTableCell(
    String text,
    pw.Font font, {
    pw.TextAlign align = pw.TextAlign.left,
    bool isHeader = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 7, horizontal: 6),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          font: font,
          fontSize: isHeader ? 9 : 8.5,
          color: isHeader
              ? const PdfColor.fromInt(0xFF475569)
              : const PdfColor.fromInt(0xFF0F172A),
        ),
      ),
    );
  }

  static pw.Widget _buildKeyValueRow(
    String label,
    String value,
    pw.Font labelFont,
    pw.Font valueFont, {
    PdfColor valueColor = const PdfColor.fromInt(0xFF0F172A),
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            font: labelFont,
            fontSize: 8.5,
            color: const PdfColor.fromInt(0xFF64748B),
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            font: valueFont,
            fontSize: 8.5,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSummaryLine(
    String label,
    String value,
    pw.Font font, {
    bool isDiscount = false,
    bool isHighlight = false,
    bool isTotal = false,
  }) {
    PdfColor color = const PdfColor.fromInt(0xFF0F172A);
    if (isDiscount) {
      color = const PdfColor.fromInt(0xFF166534);
    } else if (isHighlight) {
      color = const PdfColor.fromInt(0xFF166534);
    } else if (isTotal) {
      color = const PdfColor.fromInt(0xFF166534);
    }

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            font: font,
            fontSize: isTotal ? 11 : 9,
            color: isTotal
                ? const PdfColor.fromInt(0xFF0F172A)
                : const PdfColor.fromInt(0xFF64748B),
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            font: font,
            fontSize: isTotal ? 12 : 9,
            color: color,
          ),
        ),
      ],
    );
  }

  static PdfColor _getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return const PdfColor.fromInt(0xFF166534);
      case PaymentStatus.pending:
        return const PdfColor.fromInt(0xFFD97706);
      case PaymentStatus.failed:
        return const PdfColor.fromInt(0xFFDC2626);
      case PaymentStatus.refunded:
        return const PdfColor.fromInt(0xFF9333EA);
      case PaymentStatus.cancelled:
        return const PdfColor.fromInt(0xFF64748B);
    }
  }
}
