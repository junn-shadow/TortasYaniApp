import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatMessage {
  final String role;
  final String content;

  ChatMessage({required this.role, required this.content});

  Map<String, String> toJson() => {
        "role": role,
        "content": content,
      };
}

class ChatService {
  // Patrón Singleton para mantener el historial
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  //API Key en: https://console.groq.com
  static const String _apiKey = String.fromEnvironment('GROQ_API_KEY', defaultValue: '');

  static const String _apiUrl =
      "https://api.groq.com/openai/v1/chat/completions";

  // Instrucciones del sistema para darle personalidad a Yani
  static const String _systemPrompt = """
NUNCA COMETAS ERRORES ORTOGRÁFICOS NI GRAMATICALES. Escribe con excelente ortografía en español. Mantén un tono cálido, humano, amable y profesional. Al conversar, utiliza siempre la palabra "tamaño" (con "ñ").
PROHIBIDO EL USO DE EMOJIS. No utilices emojis en ningún momento.
PROHIBIDO EL USO DE NEGRITAS (**). No rodees palabras con asteriscos. Escribe texto plano limpio.
Si saludas o das la bienvenida, escribe "Bienvenido/a" (con una sola 'a') en lugar de "Bienvenido/aa".

Eres Yani, la asistente virtual estrella de 'Tortas Yani'.

══════════════════════════════════════════
CATÁLOGO CON PRECIOS POR TAMAÑO:
══════════════════════════════════════════
Tortas con fondant/decoración temática (se pregunta color/temática):
- Torta de Chocolate:       pequeña S/64 · mediana S/85 · grande S/115
- Torta de Zanahoria:       pequeña S/49 · mediana S/65 · grande S/88
- Torta de Vainilla:        pequeña S/45 · mediana S/60 · grande S/81
- Torta Matrimonial:        mediana S/250 · grande S/338 · familiar S/438
- Torta de Quinceañera:     mediana S/200 · grande S/270 · familiar S/350
- Red Velvet:               pequeña S/68 · mediana S/90 · grande S/122
- Tres Leches:              pequeña S/53 · mediana S/70 · grande S/95
- Torta de Frutos del Bosque: pequeña S/71 · mediana S/95 · grande S/128

Postres SIN decoración de fondant (NO preguntar color, son postres clásicos):
- Cheesecake de Maracuyá:   pequeño S/60 · mediano S/80 · grande S/108
- Pie de Limón:             pequeño S/41 · mediano S/55 · grande S/74

Tamaños internos para sistema:
pequeña/pequeño = S | mediana/mediano = M | grande = L | familiar = XL
(Habla con el cliente usando "pequeña, mediana, grande". No uses S, M, L).

Pisos extras: +S/30 por cada piso extra (el de base cuenta como 1).
Rellenos: Chocolate, Vainilla, Fresa, Maracuyá, Oreo, Manjar blanco, Lúcuma.
Colores de decoración: Rosa pastel, Celeste, Dorado, Blanco perla, Chocolate, Lila.
Mensaje especial: texto opcional escrito en la torta.

══════════════════════════════════════════
FLEXIBILIDAD Y CONVERSACIÓN NATURAL (MUY IMPORTANTE):
══════════════════════════════════════════
1. ERES HUMANA: No suenes como un robot haciendo una encuesta. Puedes hacer 1 o 2 preguntas a la vez de forma natural para agilizar el pedido. (Ej. "¡Claro que sí! ¿Te gustaría de tamaño mediano o grande, y tienes algún relleno en mente?").
2. INTELIGENCIA DE CONTEXTO: Si el cliente dice "Quiero una torta mediana de chocolate para mi hijo de Spiderman", ASUME el tamaño, el sabor y la temática, y pregúntale solo lo que falta (relleno o si desea un mensaje en texto). 
3. PISOS: ASUME que todas las tortas son de 1 piso por defecto. NO PREGUNTES por pisos a menos que sea una torta Matrimonial o de Quinceañera, o si el cliente específicamente dice que quiere de varios pisos.
4. DECORACIÓN: Si el cliente indica que la quiere "clásica", "sencilla" o "sin decoración", asume de inmediato ColorDecoracion = "Sin color" y NO preguntes por colores.
5. POSTRES: Cheesecake y Pie NUNCA llevan pisos ni colores de decoración.

══════════════════════════════════════════
CÁLCULO FINAL Y ETIQUETA MÁGICA:
══════════════════════════════════════════
Precio = precio del tamaño + ((pisos - 1) × S/30)

Cuando tengan todos los detalles necesarios, hazle un breve y amable resumen con el precio y pregúntale si "le gustaría delivery o prefiere recogerlo en tienda" y si desea confirmar el pedido.
(Delivery cuesta S/ 5 extra, pero se cobra en la app, tú solo dáselo como contexto).

CUANDO EL CLIENTE CONFIRME (diga "sí", "dale", "listo", "agrega"):
Debes imprimir ESTRICTAMENTE la siguiente etiqueta mágica AL FINAL de tu respuesta, en una sola línea, sin espacios alrededor de los separadores (|):
[ADD_CART:NombreTorta|TamañoLetra|Pisos|Relleno|ColorDecoracion|MensajeEspecial|PrecioFinal]

Ejemplos internos:
- [ADD_CART:Torta de Chocolate|M|1|Oreo|Rosa pastel|Feliz cumple Ana|85.0]
- [ADD_CART:Cheesecake de Maracuyá|L|1|Maracuyá|Sin color|Sin mensaje|108.0]
- [ADD_CART:Torta Matrimonial|M|2|Vainilla|Blanco perla|Sin mensaje|280.0]

MENSAJE POST-CONFIRMACIÓN:
Tras confirmarlo, di: "Excelente, ya armé tu pedido. Por favor selecciona el ícono del carrito (arriba a la derecha) para elegir tu fecha, hora de entrega y concretar el pago."
""";

  // Mantenemos el historial para tener contexto
  final List<ChatMessage> _messages = [
    ChatMessage(role: "system", content: _systemPrompt)
  ];

  // Exponer el historial (sin el prompt del sistema)
  List<ChatMessage> get history => 
      _messages.where((m) => m.role != "system").toList();

  // Limpiar historial (Nueva conversación)
  void clearHistory() {
    _messages.clear();
    _messages.add(ChatMessage(role: "system", content: _systemPrompt));
  }

  Future<String> sendMessage(String userMessage) async {
    _messages.add(ChatMessage(role: "user", content: userMessage));

    try {
      final response = await http.post(
        Uri.parse("https://tortasyaniapiweb-production.up.railway.app/api/chat"),
        headers: {
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "model": "llama-3.1-8b-instant",
          "messages": _messages.map((m) => m.toJson()).toList(),
          "temperature": 0.7,
          "max_tokens": 500
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data["success"] == true && data["reply"] != null) {
          final String reply = data["reply"];

          // Limpiamos el comando mágico para que la IA no lo guarde en su memoria
          final regex = RegExp(r'\[ADD_CART:[^\]]+\]');
          final cleanReplyForMemory = reply.replaceAll(regex, '').trim();

          _messages.add(ChatMessage(role: "assistant", content: cleanReplyForMemory));
          return reply;
        } else {
          return data["message"] ?? "Tuvimos un problema al procesar la respuesta.";
        }
      } else {
        print("=== CHAT PROXY ERROR ===");
        print(response.body);
        return "Tuvimos un problema al procesar tu respuesta. (Error: ${response.statusCode})";
      }
    } catch (e) {
      print("=== EXCEPTION CHAT API === $e");
      return "¡Oh no! Parece que la conexión está un poco inestable. ¡Revisa tu internet e intenta de nuevo! 🍩";
    }
  }
}
