import 'package:flutter/material.dart';
import '../../services/pdf_invoice_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

class AdminInvoicesScreen extends StatefulWidget {
  const AdminInvoicesScreen({super.key});

  @override
  State<AdminInvoicesScreen> createState() => _AdminInvoicesScreenState();
}

class _AdminInvoicesScreenState extends State<AdminInvoicesScreen> {
  List<Map<String, dynamic>> _invoices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('tortasyani_invoices_local');
    if (data != null) {
      final List<dynamic> parsed = jsonDecode(data);
      _invoices = parsed.map((e) => e as Map<String, dynamic>).toList();
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveInvoices() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tortasyani_invoices_local', jsonEncode(_invoices));
  }

  void _showInvoiceModal() {
    final _formKey = GlobalKey<FormState>();
    String tipo = 'Boleta';
    String docNumber = '';
    String name = '';
    String address = '';
    double total = 50.00;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return AlertDialog(
              title: const Text('Emitir Comprobante (Simulador)'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: tipo,
                        decoration: const InputDecoration(labelText: 'Tipo de Comprobante'),
                        items: const [
                          DropdownMenuItem(value: 'Boleta', child: Text('Boleta (DNI)')),
                          DropdownMenuItem(value: 'Factura', child: Text('Factura (RUC)')),
                        ],
                        onChanged: (val) => setStateModal(() => tipo = val!),
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: tipo == 'Factura' ? 'RUC' : 'DNI'),
                        keyboardType: TextInputType.number,
                        validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                        onChanged: (val) => docNumber = val,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Nombre / Razón Social'),
                        validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                        onChanged: (val) => name = val,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Dirección (Opcional)'),
                        onChanged: (val) => address = val,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Monto Total (S/)'),
                        keyboardType: TextInputType.number,
                        initialValue: total.toString(),
                        onChanged: (val) => total = double.tryParse(val) ?? 0.0,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pop(context);
                      
                      final isFactura = tipo == 'Factura';
                      final prefix = isFactura ? 'F001' : 'B001';
                      final correlativo = Random().nextInt(900000) + 100000;
                      final numeroComprobante = '$prefix-$correlativo';
                      final orderId = 'ORD-${Random().nextInt(9000) + 1000}';
                      final fecha = DateTime.now().toString().substring(0, 16);

                      final newInvoice = {
                        'numeroComprobante': numeroComprobante,
                        'orderId': orderId,
                        'cliente': name,
                        'documentoCliente': docNumber,
                        'direccionCliente': address.isEmpty ? 'Plaza Túpac Amaru, Wanchaq, Cusco' : address,
                        'tipo': tipo,
                        'fechaEmision': fecha,
                        'montoTotal': total,
                        'estadoSunat': 'Aceptado',
                      };

                      setState(() {
                        _invoices.insert(0, newInvoice);
                      });
                      await _saveInvoices();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✅ Comprobante simulado localmente con éxito.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF07070)),
                  child: const Text('Emitir SUNAT', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Comprobantes SUNAT (Demo)', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showInvoiceModal,
        backgroundColor: const Color(0xFFF07070),
        icon: const Icon(Icons.receipt_long, color: Colors.white),
        label: const Text('Emitir Boleta/Factura', style: TextStyle(color: Colors.white)),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFF07070)))
        : _invoices.isEmpty 
          ? const Center(child: Text('No hay comprobantes simulados aún.'))
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _invoices.length,
              itemBuilder: (context, index) {
                final inv = _invoices[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(inv['numeroComprobante'], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF07070))),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Cliente: ${inv['cliente']}'),
                        Text('Fecha: ${inv['fechaEmision']}'),
                        Text('Estado: ${inv['estadoSunat']}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('S/ ${inv['montoTotal'].toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 5),
                        InkWell(
                          onTap: () {
                            PdfInvoiceService.generateAndPrintInvoice(
                              isFactura: inv['tipo'] == 'Factura',
                              numComprobante: inv['numeroComprobante'],
                              orderId: inv['orderId'],
                              clienteName: inv['cliente'],
                              docNumber: inv['documentoCliente'],
                              direccion: inv['direccionCliente'],
                              totalAmount: inv['montoTotal'],
                              fecha: inv['fechaEmision'],
                            );
                          },
                          child: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
