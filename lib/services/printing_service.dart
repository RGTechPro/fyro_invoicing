import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';

class PrintingService {
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  // Print customer copy only
  static Future<void> printCustomerCopy(Order order,
      {bool showPreview = false}) async {
    final pdf = await _generateInvoicePdf(order, copyType: 'CUSTOMER');

    if (showPreview) {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Invoice_${order.orderId}_Customer.pdf',
        format: PdfPageFormat.roll80,
      );
    } else {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Invoice_${order.orderId}_Customer.pdf',
        format: PdfPageFormat.roll80,
      );
    }
  }

  // Print store copy only
  static Future<void> printStoreCopy(Order order,
      {bool showPreview = false}) async {
    final pdf = await _generateInvoicePdf(order, copyType: 'STORE');

    if (showPreview) {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Invoice_${order.orderId}_Store.pdf',
        format: PdfPageFormat.roll80,
      );
    } else {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Invoice_${order.orderId}_Store.pdf',
        format: PdfPageFormat.roll80,
      );
    }
  }

  // Print both copies (for compatibility - prints one after another)
  static Future<void> printBothCopies(Order order,
      {bool showPreview = false}) async {
    if (showPreview) {
      // For preview, show customer copy
      await printCustomerCopy(order, showPreview: true);
    } else {
      // Print customer copy first
      await printCustomerCopy(order);
      // Wait a moment before printing store copy
      await Future.delayed(const Duration(milliseconds: 500));
      // Print store copy
      await printStoreCopy(order);
    }
  }

  // Generate PDF for thermal printer
  static Future<pw.Document> _generateInvoicePdf(Order order,
      {required String copyType}) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(8),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header - Brand Name
              pw.Center(
                child: pw.Text(
                  'BIRYANI BY FLAME',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 4),

              // Tagline or address (optional)
              pw.Center(
                child: pw.Text(
                  'Authentic Biryani Experience',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'Flame-Cooked Perfection',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ),
              pw.SizedBox(height: 8),

              // Divider
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 4),

              // Copy type
              pw.Center(
                child: pw.Text(
                  '--- $copyType COPY ---',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 8),

              // Order details
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Order ID:', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text(
                    order.orderId,
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 2),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Date:', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text(
                    _dateFormat.format(order.createdAt),
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),

              if (order.customerName != null &&
                  order.customerName!.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Customer:',
                        style: const pw.TextStyle(fontSize: 10)),
                    pw.Text(
                      order.customerName!,
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ],

              pw.SizedBox(height: 8),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 4),

              // Items header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    flex: 5,
                    child: pw.Text(
                      'Item',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text(
                      'Qty',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      'Amount',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Divider(thickness: 0.5),

              // Items list
              ...order.items.map((item) {
                return pw.Column(
                  children: [
                    pw.SizedBox(height: 4),
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          flex: 5,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                item.menuItemName,
                                style: const pw.TextStyle(fontSize: 9),
                              ),
                              pw.Text(
                                item.getServingSizeDisplay(),
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  color: PdfColors.grey700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(
                            '${item.quantity}',
                            style: const pw.TextStyle(fontSize: 9),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            'Rs ${item.totalPrice.toStringAsFixed(2)}',
                            style: const pw.TextStyle(fontSize: 9),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                  ],
                );
              }),

              pw.Divider(thickness: 0.5),
              pw.SizedBox(height: 4),

              // Subtotal (base price)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Subtotal:', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text(
                    'Rs ${order.totalBaseAmount.toStringAsFixed(2)}',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
              pw.SizedBox(height: 2),

              // GST (5%)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('GST (5%):', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text(
                    'Rs ${order.totalGst.toStringAsFixed(2)}',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),

              pw.Divider(thickness: 1),
              pw.SizedBox(height: 4),

              // Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL:',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Rs ${order.totalAmount.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 8),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 8),

              // Footer
              pw.Center(
                child: pw.Text(
                  'Thank you for your order!',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  'Visit us again!',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ),

              if (order.notes != null && order.notes!.isNotEmpty) ...[
                pw.SizedBox(height: 8),
                pw.Text(
                  'Notes: ${order.notes}',
                  style: pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey700,
                  ),
                ),
              ],

              pw.SizedBox(height: 12),

              // GST disclaimer
              pw.Center(
                child: pw.Text(
                  'All prices are inclusive of GST',
                  style: pw.TextStyle(
                    fontSize: 7,
                    color: PdfColors.grey600,
                  ),
                ),
              ),

              pw.SizedBox(height: 16),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  // Share or export PDF (uses customer copy for sharing)
  static Future<void> sharePdf(Order order) async {
    final pdf = await _generateInvoicePdf(order, copyType: 'CUSTOMER');
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Invoice_${order.orderId}.pdf',
    );
  }
}
