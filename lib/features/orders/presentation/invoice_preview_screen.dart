import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import '../domain/customer_order.dart';
import '../services/invoice_pdf_service.dart';

/// Full-screen or modal screen for previewing, printing, and sharing the order invoice PDF.
class InvoicePreviewScreen extends StatelessWidget {
  final CustomerOrder order;

  const InvoicePreviewScreen({
    super.key,
    required this.order,
  });

  static Future<void> show(BuildContext context, CustomerOrder order) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvoicePreviewScreen(order: order),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final invoiceNumber = InvoicePdfService.getInvoiceNumber(order.orderId);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Invoice',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            Text(
              invoiceNumber,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF166534),
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: 'Share Invoice',
            icon: const Icon(Icons.share_outlined, color: Color(0xFF166534)),
            onPressed: () async {
              try {
                final pdfBytes = await InvoicePdfService.generateInvoicePdf(order);
                await Printing.sharePdf(
                  bytes: pdfBytes,
                  filename: '$invoiceNumber.pdf',
                );
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Could not share invoice: $e'),
                      backgroundColor: const Color(0xFFDC2626),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => InvoicePdfService.generateInvoicePdf(order),
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        allowPrinting: true,
        allowSharing: true,
        pdfFileName: '$invoiceNumber.pdf',
        previewPageMargin: const EdgeInsets.all(16),
        loadingWidget: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: Color(0xFF166534),
              ),
              const SizedBox(height: 12),
              Text(
                'Generating Invoice PDF...',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        onError: (context, error) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFDC2626),
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  'Unable to render invoice',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
