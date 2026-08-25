import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/chat_service.dart';
import '../providers/cart_provider.dart';
import '../utils/catalog.dart';
import '../widgets/interactive_3d_robot.dart';
import 'cart_screen.dart'; // Add this import

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Offset _pointerOffset = Offset.zero;

  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  bool _isSending = false; // Guard anti-duplicados: bloquea envíos mientras se procesa
  // Guarda las claves únicas de pedidos ya procesados para evitar agregar al carrito dos veces
  final Set<String> _processedCartKeys = {};

  final List<String> _quickSuggestions = [
    "¿Qué me recomiendas para un cumpleaños?",
    "Necesito una torta para una boda",
    "¿Cuál es la más vendida?",
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    setState(() {
      _messages.clear();
      final history = _chatService.history;
      
      if (history.isEmpty) {
        // Mensaje de bienvenida inicial
        _messages.add({
          "role": "assistant",
          "content": "¡Hola! Soy Yani. ¿En qué te puedo ayudar hoy?",
        });
      } else {
        // Cargar historial
        for (var msg in history) {
          _messages.add({
            "role": msg.role,
            "content": msg.content,
          });
        }
      }
    });
    _scrollToBottom();
  }

  void _startNewConversation() {
    _chatService.clearHistory();
    _loadHistory();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Nueva conversación iniciada"),
        backgroundColor: Color(0xFFF07070),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Procesa la respuesta de la IA: detecta el comando mágico y agrega al carrito
  void _processResponse(String rawResponse) {
    final regex = RegExp(
      r'\[ADD_CART:([^|]+)\|([^|]+)\|([^|]+)\|([^|]+)\|([^|]+)\|([^|]+)\|([^\]]+)\]',
    );
    final match = regex.firstMatch(rawResponse);

    final cleanMessage = rawResponse.replaceAll(regex, '').trim();

    setState(() {
      _messages.add({"role": "assistant", "content": cleanMessage});
      _isLoading = false;
    });

    if (match != null) {
      final nombreTorta = match.group(1)!.trim();
      final tamanio     = match.group(2)!.trim();
      final pisos       = int.tryParse(match.group(3)!.trim()) ?? 1;
      final relleno     = match.group(4)!.trim();
      final colorDeco   = match.group(5)!.trim();
      final mensaje     = match.group(6)!.trim();
      final precio      = double.tryParse(match.group(7)!.trim()) ?? 0.0;

      // ─── GUARD ANTI-DUPLICADOS ───────────────────────────────────────────
      final cartKey = "${nombreTorta}_${tamanio}_${pisos}_${relleno}_${precio}_${DateTime.now().millisecondsSinceEpoch ~/ 5000}";
      if (_processedCartKeys.contains(cartKey)) {
        _scrollToBottom();
        return;
      }
      _processedCartKeys.add(cartKey);
      // ─────────────────────────────────────────────────────────────────────

      final tortaData = TortasCatalog.findByName(nombreTorta);
      final imagen = tortaData?["imagen"] as String? ?? "";

      final cart = Provider.of<CartProvider>(context, listen: false);
      cart.addItem(
        {"nombre": nombreTorta, "imagen": imagen},
        tamanio,
        precio,
        relleno,
        pisos,
        10,
        colorDeco,
        mensaje,
        "",
      );

      _showCartSuccess(nombreTorta, tamanio, pisos, relleno, precio);
    }

    _scrollToBottom();
  }

  void _showCartSuccess(String nombre, String tamanio, int pisos, String relleno, double precio) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 4),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "¡Agregado al carrito!",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
            ),
            Text(
              "$nombre · $tamanio · $pisos ${pisos == 1 ? 'piso' : 'pisos'} · $relleno",
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Text(
              "Total: S/ ${precio.toStringAsFixed(0)}",
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading || _isSending) return;

    setState(() {
      _isSending = true;
      _messages.add({"role": "user", "content": text});
      _isLoading = true;
    });

    _textController.clear();
    _scrollToBottom();

    final rawResponse = await _chatService.sendMessage(text);
    _processResponse(rawResponse);

    setState(() => _isSending = false);
  }

  Widget _buildMessageContent(String content, bool isUser) {
    final regex = RegExp(r'\[ADD_CART:[^\]]+\]');
    final cleanText = content.replaceAll(regex, '').trim();

    final List<TextSpan> spans = [];
    final parts = cleanText.split('**');
    
    for (int i = 0; i < parts.length; i++) {
      final isBold = i % 2 == 1;
      spans.add(
        TextSpan(
          text: parts[i],
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isUser ? Colors.white : Colors.black87,
          ),
        ),
      );
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 14.5,
          height: 1.4,
          fontFamily: GoogleFonts.poppins().fontFamily,
        ),
        children: spans,
      ),
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        setState(() {
          _pointerOffset = event.position;
        });
      },
      child: Listener(
        onPointerMove: (event) {
          setState(() {
            _pointerOffset = event.position;
          });
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFFFF0F5),
          appBar: AppBar(
            backgroundColor: const Color(0xFFFFF0F5),
            elevation: 0,
            titleSpacing: 4,
            title: Row(
              children: [
                Interactive3DRobot(
                  size: 40,
                  globalPointerOffset: _pointerOffset,
                  isSpeaking: _isLoading,
                ),
                const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Yani AI",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                Text(
                  _isLoading ? "Escribiendo..." : "En línea ✨",
                  style: TextStyle(
                      fontSize: 11,
                      color: _isLoading
                          ? const Color(0xFFF07070)
                          : Colors.green.shade600),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Botón de Nueva Conversación
          IconButton(
            icon: const Icon(Iconsax.trash, color: Colors.black54, size: 22),
            tooltip: "Nueva conversación",
            onPressed: _startNewConversation,
          ),
          // Ícono de carrito con badge en el AppBar del chat
          Consumer<CartProvider>(
            builder: (context, cart, _) => Stack(
              children: [
                IconButton(
                  icon: const Icon(Iconsax.shopping_cart, color: Colors.black87),
                  onPressed: () {
                    // Usar MaterialPageRoute ya que no hay rutas nombradas definidas en main.dart
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CartScreen()),
                    );
                  },
                ),
                if (cart.totalItems > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF07070),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          "${cart.totalItems}",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Lista de mensajes
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              itemCount: _messages.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Yani AI Big Robot Header at the top
                  return Column(
                    children: [
                      const SizedBox(height: 20),
                      Interactive3DRobot(
                        size: 110,
                        globalPointerOffset: _pointerOffset,
                        isSpeaking: _isLoading,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Yani AI",
                        style: GoogleFonts.poppins(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFE56B8F),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Tu asistente virtual de repostería",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(height: 1, color: Color(0xFFFDDDE6)),
                      const SizedBox(height: 20),
                    ],
                  );
                }

                final msg = _messages[index - 1];
                final isUser = msg["role"] == "user";

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment:
                        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!isUser) ...[
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: Interactive3DRobot(
                            size: 28,
                            globalPointerOffset: _pointerOffset,
                            isSpeaking: false,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isUser
                                ? const Color(0xFFF07070)
                                : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(18),
                              topRight: const Radius.circular(18),
                              bottomLeft: Radius.circular(isUser ? 18 : 4),
                              bottomRight: Radius.circular(isUser ? 4 : 18),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              )
                            ],
                          ),
                          child: _buildMessageContent(msg["content"], isUser),
                        ),
                      ),
                    ],
                  ),
                ).animate().fade(duration: 300.ms).slideY(begin: 0.08);
              },
            ),
          ),

          // Indicador "Yani está escribiendo..."
          if (_isLoading)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 52, bottom: 8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 3))
                    ],
                  ),
                  child: const Text("✍🏻 escribiendo...",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontStyle: FontStyle.italic)),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fade(duration: 600.ms),
              ),
            ),

          // Sugerencias rápidas (solo al inicio)
          if (_messages.length == 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _quickSuggestions.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _sendMessage(_quickSuggestions[index]),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color:
                                  const Color(0xFFF07070).withOpacity(0.4)),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 4)
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _quickSuggestions[index],
                          style: const TextStyle(
                              color: Color(0xFFF07070),
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ).animate().fade(delay: (150 * index).ms).slideX(begin: 0.15);
                  },
                ),
              ),
            ),

          // Barra de texto de entrada
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, -4))
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0F5),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _textController,
                        style: const TextStyle(
                            color: Colors.black87, fontSize: 14),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          hintText: "Escríbeme algo...",
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 14),
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 10),
                        ),
                        onSubmitted: _sendMessage,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _sendMessage(_textController.text),
                    child: Container(
                      padding: const EdgeInsets.all(11),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF07070),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Iconsax.send_1,
                          color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    ),
    );
  }
}
