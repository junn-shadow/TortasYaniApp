import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _messageCtrl = TextEditingController();
  String _subject = 'Duda o Consulta';

  bool _isSubmitting = false;
  bool _showSuccess = false;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _showSuccess = true;
          _nameCtrl.clear();
          _emailCtrl.clear();
          _messageCtrl.clear();
        });

        // Hide success message after 5 seconds
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() => _showSuccess = false);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text("Contáctanos", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Envíanos un mensaje",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4A4A),
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "Completa el formulario y te responderemos en breve.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            
            if (_showSuccess)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFF065F46)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: const Text(
                        "¡Gracias por escribirnos! Hemos guardado tu mensaje.",
                        style: TextStyle(color: Color(0xFF065F46)),
                      ),
                    ),
                  ],
                ),
              ),

            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Nombre Completo", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      hintText: "Ej. Juan Pérez",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    validator: (val) {
                      if (val == null || val.trim().length < 3) return "Mínimo 3 letras";
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  const Text("Correo Electrónico", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "juan@correo.com",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    validator: (val) {
                      if (val == null || !val.contains("@")) return "Ingresa un correo válido";
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  const Text("Asunto", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  DropdownButtonFormField<String>(
                    value: _subject,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: "Cotización para Evento", child: Text("Cotización para Evento")),
                      DropdownMenuItem(value: "Pedido Personalizado", child: Text("Pedido Personalizado")),
                      DropdownMenuItem(value: "Duda o Consulta", child: Text("Duda o Consulta")),
                      DropdownMenuItem(value: "Otro", child: Text("Otro")),
                    ],
                    onChanged: (val) => setState(() => _subject = val!),
                  ),
                  const SizedBox(height: 15),

                  const Text("Mensaje", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _messageCtrl,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: "Escribe tu mensaje aquí...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    validator: (val) {
                      if (val == null || val.trim().length < 10) return "Mínimo 10 caracteres";
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF07070),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              "Enviar Mensaje",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
