import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/trip_model.dart';
import '../utils/helpers.dart';

class PdfService {
  static Future<void> exportTripsReport({
    required String title,
    required List<Trip> trips,
    required Map<int, String> vehicleNames,
    required Map<int, String> customerNames,
  }) async {
    final doc = pw.Document();

    double totalFreight = 0, totalExpense = 0;
    for (final t in trips) {
      totalFreight += t.freightAmount;
      totalExpense += t.totalExpenses;
    }
    final totalProfit = totalFreight - totalExpense;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('AH Transport Gujranwala', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.Text(title, style: const pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 10),
            pw.Divider(),
          ],
        ),
        build: (context) => [
          pw.Table.fromTextArray(
            headers: ['Trip #', 'Date', 'Vehicle', 'Customer', 'Freight', 'Expenses', 'Profit'],
            data: trips
                .map((t) => [
                      t.tripNumber,
                      Helpers.formatDate(t.date),
                      vehicleNames[t.vehicleId] ?? '-',
                      customerNames[t.customerId] ?? '-',
                      Helpers.formatCurrency(t.freightAmount),
                      Helpers.formatCurrency(t.totalExpenses),
                      Helpers.formatCurrency(t.profit),
                    ])
                .toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellAlignment: pw.Alignment.centerLeft,
          ),
          pw.SizedBox(height: 16),
          pw.Divider(),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Total Trips: ${trips.length}'),
              pw.Text('Total Freight: ${Helpers.formatCurrency(totalFreight)}'),
            ],
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Total Expenses: ${Helpers.formatCurrency(totalExpense)}'),
              pw.Text(
                'Net Profit: ${Helpers.formatCurrency(totalProfit)}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
          pw.SizedBox(height: 40),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(children: [pw.Text('_________________'), pw.Text('Prepared By')]),
              pw.Column(children: [pw.Text('_________________'), pw.Text('Signature')]),
            ],
          ),
        ],
      ),
    );

    await Printing.sharePdf(bytes: await doc.save(), filename: 'AH_Transport_Report.pdf');
  }
}
