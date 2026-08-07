/// =================================================
/// 🎂 CATÁLOGO CENTRALIZADO DE TORTAS YANI
/// Usado por HomeScreen y ChatScreen (Yani AI)
/// =================================================
class TortasCatalog {
  static List<Map<String, dynamic>> tortas = [
    {
      "nombre": "Torta de Chocolate",
      "categoria": "Tortas Especiales",
      "precio": 85.0,
      "imagen":
          "https://res.cloudinary.com/ddfzttgyr/image/upload/v1774234559/torta_de_chocolate_wv8mi7.png",
      "rating": 4.9,
      "resenas": 124,
      "badge": "Popular",
      "descripcion":
          "Deliciosa torta de chocolate con capas de bizcocho húmedo y ganache.",
      "ingredientes": ["Chocolate", "Harina", "Huevos", "Mantequilla", "Azúcar"],
      "tamanios": ["S", "M", "L"],
    },
    {
      "nombre": "Cheesecake de Maracuyá",
      "categoria": "Cheesecake y Pyes",
      "precio": 80.0,
      "imagen":
          "https://res.cloudinary.com/ddfzttgyr/image/upload/v1774234883/Cheesecake_de_Maracuy%C3%A1_knhn3w.png",
      "rating": 4.9,
      "resenas": 110,
      "badge": "Popular",
      "descripcion": "Refrescante cheesecake con coulis de maracuyá tropical.",
      "ingredientes": ["Maracuyá", "Queso crema", "Galletas", "Crema", "Azúcar"],
      "tamanios": ["S", "M", "L"],
    },
    {
      "nombre": "Torta de Zanahoria",
      "categoria": "Tortas",
      "precio": 65.0,
      "imagen":
          "https://res.cloudinary.com/ddfzttgyr/image/upload/v1774234868/Torta_de_Zanahoriaa_ury5wh.png",
      "rating": 4.7,
      "resenas": 76,
      "badge": "Favorito",
      "descripcion":
          "Esponjosa torta de zanahoria con frosting de queso crema y nueces.",
      "ingredientes": ["Zanahoria", "Harina", "Huevos", "Nueces", "Queso crema"],
      "tamanios": ["S", "M", "L"],
    },
    {
      "nombre": "Torta de Vainilla",
      "categoria": "Tortas",
      "precio": 60.0,
      "imagen":
          "https://res.cloudinary.com/ddfzttgyr/image/upload/v1774234876/torta_de_vainilla_vgcfkf.png",
      "rating": 4.6,
      "resenas": 89,
      "badge": "",
      "descripcion":
          "Clásica torta de vainilla con crema suave y decoración elegante.",
      "ingredientes": ["Vainilla", "Harina", "Huevos", "Mantequilla", "Leche"],
      "tamanios": ["S", "M", "L"],
    },
    {
      "nombre": "Torta Matrimonial",
      "categoria": "Matrimoniales",
      "precio": 250.0,
      "imagen":
          "https://res.cloudinary.com/ddfzttgyr/image/upload/v1774234891/Torta_Matrimonial_qhxegx.png",
      "rating": 5.0,
      "resenas": 45,
      "badge": "Premium",
      "descripcion":
          "Elegante torta matrimonial de varios pisos decorada a medida.",
      "ingredientes": ["Vainilla", "Fondant", "Crema", "Flores", "Perlas"],
      "tamanios": ["M", "L", "XL"],
    },
    {
      "nombre": "Torta de Quinceañera",
      "categoria": "Quinceañeros",
      "precio": 200.0,
      "imagen":
          "https://res.cloudinary.com/ddfzttgyr/image/upload/v1774234897/Torta_de_Quincea%C3%B1era_evxzmp.png",
      "rating": 4.8,
      "resenas": 62,
      "badge": "Especial",
      "descripcion":
          "Torta especial para quinceañeras con decoración rosa y detalles dorados.",
      "ingredientes": [
        "Vainilla",
        "Fondant rosa",
        "Crema",
        "Flores",
        "Brillantina"
      ],
      "tamanios": ["M", "L", "XL"],
    },
    {
      "nombre": "Pie de Limón",
      "categoria": "Cheesecake y Pyes",
      "precio": 55.0,
      "imagen":
          "https://res.cloudinary.com/ddfzttgyr/image/upload/v1774234905/Pie_de_Lim%C3%B3n_plhcyw.png",
      "rating": 4.7,
      "resenas": 83,
      "badge": "",
      "descripcion": "Clásico pie de limón con merengue tostado y base crocante.",
      "ingredientes": ["Limón", "Huevos", "Azúcar", "Galletas", "Mantequilla"],
      "tamanios": ["S", "M", "L"],
    },
    {
      "nombre": "Red Velvet",
      "categoria": "Tortas Especiales",
      "precio": 90.0,
      "imagen":
          "https://res.cloudinary.com/ddfzttgyr/image/upload/v1774234910/Red_Velvet_da5fqq.png",
      "rating": 4.9,
      "resenas": 137,
      "badge": "Top",
      "descripcion":
          "Irresistible red velvet con frosting de queso crema y color rojo intenso.",
      "ingredientes": [
        "Cacao",
        "Colorante rojo",
        "Queso crema",
        "Harina",
        "Buttermilk"
      ],
      "tamanios": ["S", "M", "L"],
    },
    {
      "nombre": "Tres Leches",
      "categoria": "Tortas",
      "precio": 70.0,
      "imagen":
          "https://res.cloudinary.com/ddfzttgyr/image/upload/v1774234917/Tres_Leches_d8lm11.png",
      "rating": 4.8,
      "resenas": 91,
      "badge": "Nuevo",
      "descripcion":
          "Esponjoso bizcocho empapado en tres tipos de leche con crema chantilly.",
      "ingredientes": [
        "Leche condensada",
        "Leche evaporada",
        "Crema",
        "Huevos",
        "Harina"
      ],
      "tamanios": ["S", "M", "L"],
    },
    {
      "nombre": "Torta de Frutos del Bosque",
      "categoria": "Tortas Especiales",
      "precio": 95.0,
      "imagen":
          "https://res.cloudinary.com/ddfzttgyr/image/upload/v1774234923/Torta_de_Frutos_del_Bosque_sfpmtk.png",
      "rating": 4.8,
      "resenas": 72,
      "badge": "Nuevo",
      "descripcion":
          "Exquisita torta con mix de frutos del bosque frescos y crema.",
      "ingredientes": [
        "Frutos del bosque",
        "Crema",
        "Harina",
        "Huevos",
        "Azúcar"
      ],
      "tamanios": ["S", "M", "L"],
    },
  ];

  /// Busca una torta por nombre (sin importar mayúsculas/minúsculas)
  static Map<String, dynamic>? findByName(String nombre) {
    final lower = nombre.toLowerCase().trim();
    try {
      return tortas.firstWhere(
        (t) => (t["nombre"] as String).toLowerCase().contains(lower),
      );
    } catch (_) {
      return null;
    }
  }

  /// Calcula el precio final según el tamaño elegido
  static double calcularPrecio(Map<String, dynamic> torta, String tamanio) {
    final base = (torta["precio"] as double);
    switch (tamanio.toUpperCase()) {
      case "S":
        return base * 0.75;
      case "L":
        return base * 1.35;
      case "XL":
        return base * 1.75;
      default: // M
        return base;
    }
  }
}
