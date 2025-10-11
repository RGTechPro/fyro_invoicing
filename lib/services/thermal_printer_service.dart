import 'package:intl/intl.dart';
import '../models/order.dart';
import 'dart:html' as html;
import 'dart:js' as js;

class ThermalPrinterService {
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  /// Print receipt on thermal printer (58mm width)
  /// This creates a simple HTML page optimized for thermal printers
  static void printReceipt(Order order, {required bool isCustomerCopy}) {
    final String receiptHtml = _generateReceiptHtml(order, isCustomerCopy);
    
    // Create a blob with the HTML content
    final blob = html.Blob([receiptHtml], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);
    
    // Create a new window for printing
    final printWindow = html.window.open(url, 'Print Receipt', 'width=300,height=600');
    
    // Use JS interop to call print after a delay
    js.context.callMethod('setTimeout', [
      () {
        js.context['printWindow'] = printWindow;
        js.context.callMethod('eval', ['printWindow.print(); printWindow.close();']);
      },
      500
    ]);
    
    // Clean up the URL after a delay
    js.context.callMethod('setTimeout', [
      () => html.Url.revokeObjectUrl(url),
      2000
    ]);
  }

  /// Generate HTML optimized for 58mm thermal printer
  static String _generateReceiptHtml(Order order, bool isCustomerCopy) {
    final copyType = isCustomerCopy ? 'CUSTOMER' : 'STORE';
    
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Receipt - Order ${order.orderId}</title>
  <style>
    @page {
      size: 58mm auto;
      margin: 0mm;
    }
    
    @media print {
      body {
        width: 58mm;
        margin: 0;
        padding: 2mm;
      }
    }
    
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }
    
    body {
      font-family: 'Courier New', monospace;
      font-size: 11px;
      line-height: 1.3;
      width: 58mm;
      max-width: 58mm;
      padding: 2mm;
      background: white;
      color: black;
    }
    
    .center {
      text-align: center;
    }
    
    .bold {
      font-weight: bold;
    }
    
    .large {
      font-size: 14px;
    }
    
    .divider {
      border-top: 1px dashed #000;
      margin: 3mm 0;
    }
    
    .line {
      display: flex;
      justify-content: space-between;
      margin: 1mm 0;
    }
    
    .item-line {
      margin: 2mm 0;
    }
    
    .small {
      font-size: 9px;
    }
    
    .total {
      font-size: 13px;
      font-weight: bold;
      margin: 2mm 0;
    }
    
    .header {
      margin-bottom: 3mm;
    }
    
    .footer {
      margin-top: 3mm;
      text-align: center;
    }
  </style>
</head>
<body>
  <!-- Header -->
  <div class="header center">
    <div class="bold large">BIRYANI BY FLAME</div>
    <div class="small">Authentic Biryani Experience</div>
    <div class="small">Flame-Cooked Perfection</div>
  </div>
  
  <div class="divider"></div>
  
  <!-- Copy Type -->
  <div class="center bold">--- $copyType COPY ---</div>
  <div class="divider"></div>
  
  <!-- Order Details -->
  <div class="line">
    <span>Order ID:</span>
    <span class="bold">${order.orderId}</span>
  </div>
  <div class="line">
    <span>Date:</span>
    <span>${_dateFormat.format(order.createdAt)}</span>
  </div>
  ${order.customerName != null && order.customerName!.isNotEmpty ? '''
  <div class="line">
    <span>Customer:</span>
    <span>${order.customerName}</span>
  </div>
  ''' : ''}
  
  <div class="divider"></div>
  
  <!-- Items Header -->
  <div class="line bold">
    <span style="flex: 3;">Item</span>
    <span style="flex: 1; text-align: center;">Qty</span>
    <span style="flex: 2; text-align: right;">Amount</span>
  </div>
  <div class="divider"></div>
  
  <!-- Items List -->
  ${order.items.map((item) => '''
  <div class="item-line">
    <div class="line">
      <span style="flex: 3;">${item.menuItemName}</span>
      <span style="flex: 1; text-align: center;">${item.quantity}</span>
      <span style="flex: 2; text-align: right;">Rs ${item.totalPrice.toStringAsFixed(2)}</span>
    </div>
    <div class="small" style="margin-left: 2mm;">${item.getServingSizeDisplay()}</div>
  </div>
  ''').join('')}
  
  <div class="divider"></div>
  
  <!-- Subtotal -->
  <div class="line">
    <span>Subtotal:</span>
    <span>Rs ${order.totalBaseAmount.toStringAsFixed(2)}</span>
  </div>
  
  <!-- GST -->
  <div class="line">
    <span>GST (5%):</span>
    <span>Rs ${order.totalGst.toStringAsFixed(2)}</span>
  </div>
  
  <div class="divider"></div>
  
  <!-- Total -->
  <div class="line total">
    <span>TOTAL:</span>
    <span>Rs ${order.totalAmount.toStringAsFixed(2)}</span>
  </div>
  
  <div class="divider"></div>
  
  <!-- Footer -->
  <div class="footer">
    <div class="bold">Thank you for your order!</div>
    <div class="small">Visit us again!</div>
    ${order.notes != null && order.notes!.isNotEmpty ? '''
    <div class="divider"></div>
    <div class="small">Notes: ${order.notes}</div>
    ''' : ''}
    <div class="divider"></div>
    <div class="small">All prices are inclusive of GST</div>
  </div>
  
  <div style="height: 10mm;"></div>
</body>
</html>
    ''';
  }

  /// Preview receipt in browser (for testing)
  static void previewReceipt(Order order, {required bool isCustomerCopy}) {
    final String receiptHtml = _generateReceiptHtml(order, isCustomerCopy);
    
    // Create a blob and open in new tab
    final blob = html.Blob([receiptHtml], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, 'Preview Receipt', 'width=400,height=800');
    
    // Clean up the URL after a delay
    js.context.callMethod('setTimeout', [
      () => html.Url.revokeObjectUrl(url),
      5000
    ]);
  }
}
