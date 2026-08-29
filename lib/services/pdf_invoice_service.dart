import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfInvoiceService {
  static Future<void> generateAndPrintInvoice({
    required bool isFactura,
    required String numComprobante,
    required String orderId,
    required String clienteName,
    required String docNumber,
    required String direccion,
    required double totalAmount,
    required String fecha,
  }) async {
    final pdf = pw.Document();

    final tipoDoc = isFactura ? 'FACTURA' : 'BOLETA';
    final labelDoc = isFactura ? 'RUC' : 'DNI';
    
    // Simulate some items for the invoice
    final double opGravadas = totalAmount / 1.18;
    final double igv = totalAmount - opGravadas;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // HEADER
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Tortas Yani', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#F07070'))),
                      pw.SizedBox(height: 5),
                      pw.Text('Plaza Túpac Amaru, Wanchaq, Cusco'),
                      pw.Text('Teléfono: +51 919 576 034'),
                      pw.Text('Email: ventas@tortasyani.com'),
                    ],
                  ),
                  pw.Container(
                    width: 250,
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.black, width: 1.5),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text('RUC: 20123456789', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                        pw.SizedBox(height: 5),
                        pw.Text('$tipoDoc DE VENTA ELECTRÓNICA', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                        pw.SizedBox(height: 5),
                        pw.Text(numComprobante, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14, color: PdfColor.fromHex('#F07070'))),
                      ],
                    ),
                  )
                ],
              ),
              
              pw.SizedBox(height: 30),

              // CLIENT INFO
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Señor(es): $clienteName'),
                      pw.Text('$labelDoc: $docNumber'),
                      pw.Text('Dirección: $direccion'),
                    ]
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Fecha de Emisión: $fecha'),
                      pw.Text('Moneda: Soles (PEN)'),
                    ]
                  )
                ]
              ),

              pw.SizedBox(height: 20),

              // TABLE HEADER
              pw.Container(
                color: PdfColor.fromHex('#f8fafc'),
                padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                child: pw.Row(
                  children: [
                    pw.Expanded(flex: 1, child: pw.Text('CANT.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(flex: 5, child: pw.Text('DESCRIPCIÓN', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(flex: 2, child: pw.Text('P. UNIT.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(flex: 2, child: pw.Text('IMPORTE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                  ]
                )
              ),
              
              // TABLE ROW (Item)
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(flex: 1, child: pw.Text('1.00')),
                    pw.Expanded(flex: 5, child: pw.Text('Pastel / Torta Especial (Según Orden $orderId)')),
                    pw.Expanded(flex: 2, child: pw.Text('S/ ${opGravadas.toStringAsFixed(2)}')),
                    pw.Expanded(flex: 2, child: pw.Text('S/ ${opGravadas.toStringAsFixed(2)}', textAlign: pw.TextAlign.right)),
                  ]
                )
              ),

              pw.SizedBox(height: 30),

              // TOTALS
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 200,
                    child: pw.Column(
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Op. Gravadas:'),
                            pw.Text('S/ ${opGravadas.toStringAsFixed(2)}')
                          ]
                        ),
                        pw.SizedBox(height: 5),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('IGV (18%):'),
                            pw.Text('S/ ${igv.toStringAsFixed(2)}')
                          ]
                        ),
                        pw.SizedBox(height: 10),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          color: PdfColor.fromHex('#f1f5f9'),
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('IMPORTE TOTAL:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                              pw.Text('S/ ${totalAmount.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
                            ]
                          )
                        )
                      ]
                    )
                  )
                ]
              ),

              pw.Spacer(),
              
              // FOOTER
              pw.Center(
                child: pw.Text(
                  'Representación impresa de la $tipoDoc ELECTRÓNICA.\nAutorizado mediante resolución de SUNAT. Consulte su comprobante en sunat.gob.pe',
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)
                )
              )
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: '$numComprobante.pdf',
    );
  }
}
