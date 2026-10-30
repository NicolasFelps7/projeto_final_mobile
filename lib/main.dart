import 'dart:math' as math;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'auth_service.dart';
import 'live_location.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 67 DELIVERY — Projeto final mobile
// Atividade: Splash Screen + Home Screen
// Aplicativo demonstrativo, sem pagamentos nem entregas reais.

const Color kOrange = Color(0xFFF34E2D);
const Color kOrangeLight = Color(0xFFFFE7DD);
const Color kInk = Color(0xFF222027);
const Color kMuted = Color(0xFF88858A);
const Color kCanvas = Color(0xFFFAF8F5);
const Color kGold = Color(0xFFFFC65D);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await DeliveryAuth.instance.initialize();
  runApp(const Delivery67App());
}

class Delivery67App extends StatelessWidget {
  const Delivery67App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '67 Delivery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: kCanvas,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kOrange,
          primary: kOrange,
          surface: Colors.white,
        ),
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 29,
            height: 1.14,
            fontWeight: FontWeight.w900,
            color: kInk,
            letterSpacing: -0.8,
          ),
          headlineSmall: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: kInk,
            letterSpacing: -0.4,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: kInk,
          ),
          bodyMedium: TextStyle(fontSize: 14, color: kInk),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// -----------------------------------------------------------------------------
// SPLASH SCREEN
// -----------------------------------------------------------------------------

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1050),
    );
    _fade = CurvedAnimation(parent: _animation, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animation, curve: Curves.easeOutCubic));
    _animation.forward();

    Future.delayed(const Duration(milliseconds: 2800), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionDuration: const Duration(milliseconds: 550),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: kOrange,
        body: Stack(
          children: [
            const Positioned.fill(child: CustomPaint(painter: SplashArt())),
            SafeArea(
              child: Center(
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 156,
                          height: 156,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(45),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x350C0710),
                                blurRadius: 32,
                                offset: Offset(0, 16),
                              ),
                            ],
                          ),
                          child: Image.asset('assets/images/logo.png'),
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          '67 Delivery',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 37,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.5,
                          ),
                        ),
                        const SizedBox(height: 9),
                        const Text(
                          'O sabor chega até você.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFFFEDE6),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 38,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'PREPARANDO UMA EXPERIÊNCIA DELICIOSA',
                      style: TextStyle(
                        color: const Color(0xCCFFFFFF),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SplashArt extends CustomPainter {
  const SplashArt();

  @override
  void paint(Canvas canvas, Size size) {
    final orangePaint = Paint()..color = const Color(0xFFFF6A42);
    final creamPaint = Paint()..color = const Color(0x22FFFFFF);
    canvas.drawCircle(Offset(size.width + 55, -10), 195, orangePaint);
    canvas.drawCircle(Offset(-90, size.height * 0.82), 180, creamPaint);
    canvas.drawCircle(
      Offset(size.width * 0.96, size.height * 0.66),
      74,
      creamPaint,
    );
    final ring = Paint()
      ..color = const Color(0x20FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(Offset(size.width + 28, size.height * 0.31), 86, ring);
    for (var i = 0; i < 7; i++) {
      canvas.drawCircle(
        Offset(
          (i * 77.0 + 35) % math.max(1.0, size.width),
          (i * 181.0 + 69) % math.max(1.0, size.height),
        ),
        i.isEven ? 4 : 2,
        creamPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SplashArt oldDelegate) => false;
}

// -----------------------------------------------------------------------------
// MENU DE DEMONSTRAÇÃO (DADOS LOCAIS / SEM BACKEND)
// -----------------------------------------------------------------------------

class Food {
  const Food({
    required this.id,
    required this.name,
    required this.restaurant,
    required this.description,
    required this.category,
    required this.photo,
    required this.price,
    required this.rating,
    required this.minutes,
    this.isPopular = false,
  });

  final String id;
  final String name;
  final String restaurant;
  final String description;
  final String category;
  final String photo;
  final double price;
  final double rating;
  final int minutes;
  final bool isPopular;

  /// Fotografias de alimentos (Unsplash). Precisa de internet para carregar.
  String get realPhoto => foodPhotos[id] ?? foodPhotos[category] ?? foodPhotos['Burgers']!;
}

// Fotos reais: servidas pela Unsplash (internet). As imagens locais são fallback.
const Map<String, String> foodPhotos = {
  'Burgers': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=820&q=80',
  'smash': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=820&q=80',
  'bacon': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=820&q=80',
  'chicken': 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?auto=format&fit=crop&w=820&q=80',
  'Pizzas': 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?auto=format&fit=crop&w=820&q=80',
  'Japonesa': 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?auto=format&fit=crop&w=820&q=80',
  'Churrasco': 'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=820&q=80',
  'Açaí': 'https://images.unsplash.com/photo-1627308594190-a057cd4bfac8?auto=format&fit=crop&w=820&q=80',
  'Milk-shakes': 'https://images.unsplash.com/photo-1551782450-40537687757d?auto=format&fit=crop&w=820&q=80',
  'shake_oreo': 'https://images.unsplash.com/photo-1638176066390-d1a2b56cc99c?auto=format&fit=crop&w=820&q=80',
  'Sorvetes': 'https://images.unsplash.com/photo-1778996525701-2cb205f5953c?auto=format&fit=crop&w=820&q=80',
  'sundae': 'https://images.unsplash.com/photo-1551024506-0bccd828d307?auto=format&fit=crop&w=820&q=80',
  'Tortas': 'https://images.unsplash.com/photo-1565958011703-44f9829ba187?auto=format&fit=crop&w=820&q=80',
  'brownie': 'https://images.unsplash.com/photo-1551024506-0bccd828d307?auto=format&fit=crop&w=820&q=80',
  'fries': 'https://images.unsplash.com/photo-1721137565555-64a77c9cd009?auto=format&fit=crop&w=820&q=80',
  'refrigerante': 'https://images.unsplash.com/photo-1773188243488-702914547143?auto=format&fit=crop&w=820&q=80',
  'suco': 'https://images.unsplash.com/photo-1613478223719-2ab802602423?auto=format&fit=crop&w=820&q=80',
  'shake_morango': 'https://images.unsplash.com/photo-1686638745403-d21193f16b2f?auto=format&fit=crop&w=820&q=80',
  'torta_morango': 'https://images.unsplash.com/photo-1558541382-ab8c2c503a56?auto=format&fit=crop&w=820&q=80',
  'torta_choco': 'https://images.unsplash.com/photo-1564844536308-75c540dbf14e?auto=format&fit=crop&w=820&q=80',
  'Bebidas': 'https://images.unsplash.com/photo-1773188243488-702914547143?auto=format&fit=crop&w=820&q=80',
};

const List<Food> foods = [
  Food(id: 'smash', name: 'Smash 67', restaurant: '67 Burger Club',
    description: 'Pão brioche, hambúrguer suculento, cheddar e molho especial.', category: 'Burgers', photo: 'assets/images/smash.jpg',
    price: 29.90, rating: 4.9, minutes: 25, isPopular: true),
  Food(id: 'bacon', name: 'Duplo Bacon', restaurant: '67 Burger Club',
    description: 'Dois hambúrgueres, cheddar, bacon crocante e barbecue.', category: 'Burgers', photo: 'assets/images/bacon.jpg',
    price: 38.90, rating: 4.9, minutes: 30, isPopular: true),
  Food(id: 'chicken', name: 'Chicken Crispy', restaurant: '67 Burger Club',
    description: 'Frango crocante, alface, maionese temperada e brioche.', category: 'Burgers', photo: 'assets/images/smash.jpg',
    price: 31.90, rating: 4.8, minutes: 27, isPopular: false),
  Food(id: 'fries', name: 'Batata Supreme', restaurant: '67 Burger Club',
    description: 'Batata dourada com cheddar e bacon crocante.', category: 'Burgers', photo: 'assets/images/fries.jpg',
    price: 21.90, rating: 4.8, minutes: 20, isPopular: false),
  Food(id: 'margherita', name: 'Pizza Margherita', restaurant: 'Forno 67',
    description: 'Massa artesanal, muçarela fresca, tomate e manjericão.', category: 'Pizzas', photo: 'assets/images/margherita.jpg',
    price: 49.90, rating: 4.9, minutes: 38, isPopular: true),
  Food(id: 'pepperoni', name: 'Pizza Pepperoni', restaurant: 'Forno 67',
    description: 'Muito queijo, pepperoni e massa crocante.', category: 'Pizzas', photo: 'assets/images/pepperoni.jpg',
    price: 54.90, rating: 4.8, minutes: 40, isPopular: false),
  Food(id: 'quatro_queijos', name: 'Pizza 4 Queijos', restaurant: 'Forno 67',
    description: 'Muçarela, provolone, parmesão e gorgonzola.', category: 'Pizzas', photo: 'assets/images/margherita.jpg',
    price: 56.90, rating: 4.8, minutes: 39, isPopular: false),
  Food(id: 'sushi', name: 'Combinado Salmão', restaurant: 'Sushi Mood',
    description: 'Uramakis, niguiris de salmão e shoyu.', category: 'Japonesa', photo: 'assets/images/sushi.jpg',
    price: 46.90, rating: 4.9, minutes: 35, isPopular: true),
  Food(id: 'hotroll', name: 'Hot Roll Especial', restaurant: 'Sushi Mood',
    description: 'Rolinhos quentes com salmão e cream cheese.', category: 'Japonesa', photo: 'assets/images/hotroll.jpg',
    price: 34.90, rating: 4.8, minutes: 32, isPopular: false),
  Food(id: 'picanha', name: 'Picanha na Brasa', restaurant: 'Brasa 67',
    description: 'Picanha grelhada, farofa, vinagrete e acompanhamentos.', category: 'Churrasco', photo: 'assets/images/bacon.jpg',
    price: 67.90, rating: 4.9, minutes: 42, isPopular: true),
  Food(id: 'costela', name: 'Costela BBQ', restaurant: 'Brasa 67',
    description: 'Costela ao molho barbecue, macia e suculenta.', category: 'Churrasco', photo: 'assets/images/bacon.jpg',
    price: 59.90, rating: 4.8, minutes: 40, isPopular: false),
  Food(id: 'espetinho', name: 'Combo Espetinhos', restaurant: 'Brasa 67',
    description: 'Três espetinhos com arroz, farofa e vinagrete.', category: 'Churrasco', photo: 'assets/images/fries.jpg',
    price: 39.90, rating: 4.7, minutes: 34, isPopular: false),
  Food(id: 'acai_500', name: 'Açaí 500 ml', restaurant: 'Açaí 67',
    description: 'Açaí cremoso com banana, granola e leite em pó.', category: 'Açaí', photo: 'assets/images/brownie.jpg',
    price: 24.90, rating: 4.9, minutes: 18, isPopular: true),
  Food(id: 'acai_700', name: 'Açaí Turbo 700 ml', restaurant: 'Açaí 67',
    description: 'Açaí com morango, banana, granola e leite condensado.', category: 'Açaí', photo: 'assets/images/brownie.jpg',
    price: 32.90, rating: 4.9, minutes: 18, isPopular: false),
  Food(id: 'acai_copo', name: 'Açaí Copo Especial', restaurant: 'Açaí 67',
    description: 'Açaí gelado em camadas com frutas e granola.', category: 'Açaí', photo: 'assets/images/brownie.jpg',
    price: 19.90, rating: 4.8, minutes: 15, isPopular: false),
  Food(id: 'shake_chocolate', name: 'Milk-shake Chocolate', restaurant: 'Shake House 67',
    description: 'Chocolate cremoso, chantilly e calda.', category: 'Milk-shakes', photo: 'assets/images/soda.jpg',
    price: 22.90, rating: 4.9, minutes: 15, isPopular: true),
  Food(id: 'shake_oreo', name: 'Milk-shake Oreo', restaurant: 'Shake House 67',
    description: 'Baunilha cremosa, biscoitos de chocolate e chantilly.', category: 'Milk-shakes', photo: 'assets/images/soda.jpg',
    price: 25.90, rating: 4.8, minutes: 16, isPopular: false),
  Food(id: 'shake_morango', name: 'Milk-shake Morango', restaurant: 'Shake House 67',
    description: 'Sorvete de creme batido com morangos.', category: 'Milk-shakes', photo: 'assets/images/soda.jpg',
    price: 23.90, rating: 4.8, minutes: 15, isPopular: false),
  Food(id: 'sorvete', name: 'Sorvete 3 Bolas', restaurant: 'Doce 67',
    description: 'Três bolas de sorvete e calda especial.', category: 'Sorvetes', photo: 'assets/images/brownie.jpg',
    price: 17.90, rating: 4.8, minutes: 12, isPopular: true),
  Food(id: 'sundae', name: 'Sundae Caramelo', restaurant: 'Doce 67',
    description: 'Sorvete de creme, caramelo e crocantes.', category: 'Sorvetes', photo: 'assets/images/brownie.jpg',
    price: 16.90, rating: 4.9, minutes: 12, isPopular: false),
  Food(id: 'torta_morango', name: 'Torta de Morango', restaurant: 'Doce 67',
    description: 'Massa delicada, creme leve e frutas frescas.', category: 'Tortas', photo: 'assets/images/brownie.jpg',
    price: 19.90, rating: 4.9, minutes: 15, isPopular: true),
  Food(id: 'torta_choco', name: 'Torta Chocolate', restaurant: 'Doce 67',
    description: 'Chocolate intenso com cobertura cremosa.', category: 'Tortas', photo: 'assets/images/brownie.jpg',
    price: 21.90, rating: 4.9, minutes: 15, isPopular: false),
  Food(id: 'brownie', name: 'Brownie com Sorvete', restaurant: 'Doce 67',
    description: 'Brownie quentinho com sorvete e calda.', category: 'Tortas', photo: 'assets/images/brownie.jpg',
    price: 23.90, rating: 4.8, minutes: 17, isPopular: false),
  Food(id: 'refrigerante', name: 'Refrigerante Lata', restaurant: '67 Drinks',
    description: 'Lata gelada de 350 ml para acompanhar seu pedido.', category: 'Bebidas', photo: 'assets/images/soda.jpg',
    price: 7.90, rating: 4.6, minutes: 10, isPopular: false),
  Food(id: 'suco', name: 'Suco Natural', restaurant: '67 Drinks',
    description: 'Suco de fruta preparado na hora.', category: 'Bebidas', photo: 'assets/images/soda.jpg',
    price: 13.90, rating: 4.8, minutes: 12, isPopular: false),
];


// Opções de cardápio e valores ilustrativos, sem restaurantes integrados.
class Addon {
  const Addon(this.name, this.price);
  final String name;
  final double price;
}

const Map<String, List<Addon>> addOnMenu = {
  'Burgers': [Addon('Cheddar extra', 4.50), Addon('Bacon crocante', 5.90), Addon('Ovo', 3.50), Addon('Molho especial', 2.50)],
  'Pizzas': [Addon('Borda de catupiry', 9.90), Addon('Borda de cheddar', 8.90), Addon('Queijo extra', 6.90), Addon('Azeitonas', 3.00)],
  'Churrasco': [Addon('Farofa extra', 4.50), Addon('Vinagrete', 3.50), Addon('Arroz extra', 6.90), Addon('Batata frita', 9.90)],
  'Açaí': [Addon('Leite em pó', 3.00), Addon('Leite condensado', 3.00), Addon('Granola', 2.50), Addon('Morango', 4.50), Addon('Banana', 2.50), Addon('Nutella', 7.00), Addon('Paçoca', 2.50)],
  'Milk-shakes': [Addon('Chantilly extra', 3.50), Addon('Oreo', 4.00), Addon('Calda chocolate', 2.50)],
  'Sorvetes': [Addon('Calda de chocolate', 2.50), Addon('Granulado', 2.00), Addon('Morango', 4.50)],
  'Tortas': [Addon('Bola de sorvete', 6.90), Addon('Chantilly', 3.50), Addon('Calda extra', 2.50)],
  'Japonesa': [Addon('Cream cheese', 3.50), Addon('Shoyu extra', 2.00), Addon('Gengibre', 2.50)],
  'Bebidas': [Addon('Gelo extra', 0.00), Addon('Limão', 1.50)],
};

class CartItem {
  CartItem({required this.food, required this.quantity, required this.addons, this.halfPizzaId, this.note = ''});
  final Food food;
  int quantity;
  final List<Addon> addons;
  final String? halfPizzaId;
  final String note;

  Food? get halfPizza => halfPizzaId == null ? null : foods.where((f) => f.id == halfPizzaId).firstOrNull;
  double get basePrice => halfPizza == null ? food.price : (food.price + halfPizza!.price) / 2;
  double get unitPrice => basePrice + addons.fold<double>(0, (sum, a) => sum + a.price);
  double get total => unitPrice * quantity;
  String get detail => [
    if (halfPizza != null) 'Meia ${food.name.replaceFirst('Pizza ', '')} / meia ${halfPizza!.name.replaceFirst('Pizza ', '')}',
    if (addons.isNotEmpty) addons.map((a) => a.name).join(', '),
    if (note.trim().isNotEmpty) 'Obs.: ${note.trim()}',
  ].join(' • ');
  String get key => '${food.id}|${halfPizzaId ?? ''}|${(addons.map((a) => a.name).toList()..sort()).join(',')}|${note.trim()}';

  Map<String, dynamic> toJson() => {
    'id': food.id, 'quantity': quantity, 'addons': addons.map((a) => a.name).toList(),
    'halfPizzaId': halfPizzaId, 'note': note,
  };
  static CartItem? fromJson(Map<String, dynamic> json) {
    final food = foods.where((f) => f.id == json['id']).firstOrNull;
    if (food == null) return null;
    final names = (json['addons'] as List<dynamic>? ?? []).map((e) => e.toString()).toSet();
    final addons = (addOnMenu[food.category] ?? []).where((a) => names.contains(a.name)).toList();
    final half = json['halfPizzaId'] as String?;
    return CartItem(food: food, quantity: math.min(99, math.max(1, (json['quantity'] as num? ?? 1).toInt())),
      addons: addons, halfPizzaId: foods.any((f) => f.id == half && f.category == 'Pizzas') ? half : null,
      note: ((json['note'] as String? ?? '').length > 200)
        ? (json['note'] as String).substring(0, 200) : (json['note'] as String? ?? ''));
  }
}

class Coupon {
  const Coupon(this.code, this.title, this.description);
  final String code;
  final String title;
  final String description;
}

const coupons = <Coupon>[
  Coupon('BEMVINDO20', '20% OFF', '20% de desconto nos produtos, até R\$ 25'),
  Coupon('FOME10', 'R\$ 10 OFF', 'R\$ 10 de desconto acima de R\$ 50 em produtos'),
  Coupon('DOCE15', '15% doces', '15% em açaí, sorvetes, milk-shakes e tortas'),
  Coupon('FRETEGRATIS', 'Entrega grátis', 'Retira o frete ilustrativo'),
];

class OrderDemo {
  const OrderDemo({
    required this.number,
    required this.summary,
    required this.total,
    required this.time,
    this.payment = 'Não informado',
    this.coupon,
  });

  final String payment;
  final String? coupon;
  final String number;
  final String summary;
  final double total;
  final DateTime time;
}

String reais(double value) =>
    'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';

// -----------------------------------------------------------------------------
// HOME SCREEN + FUNCIONALIDADES LOCAIS
// -----------------------------------------------------------------------------

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _search = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<CartItem> _bag = [];
  final Set<String> _favorites = {'smash', 'margherita'};
  final List<OrderDemo> _orders = [];
  final LiveLocation _liveLocation = LiveLocation();
  final SharedPreferencesAsync _storage = SharedPreferencesAsync();

  String _category = 'Todos';
  String _sort = 'Destaques';
  String _query = '';
  String? _couponCode;
  String? _selectedStore;
  int _tab = 0;

  int get _bagCount => _bag.fold(0, (sum, item) => sum + item.quantity);
  double get _subtotal => _bag.fold<double>(0, (sum, item) => sum + item.total);
  double get _deliveryFee => _bag.isEmpty || _subtotal >= 75 || _couponCode == 'FRETEGRATIS' ? 0.0 : 5.90;
  double get _discount {
    switch (_couponCode) {
      case 'BEMVINDO20': return math.min(25.0, _subtotal * .20);
      case 'FOME10': return _subtotal >= 50 ? 10.0 : 0.0;
      case 'DOCE15': return _bag.where((e) => const ['Açaí', 'Sorvetes', 'Milk-shakes', 'Tortas']
        .contains(e.food.category)).fold<double>(0, (a, e) => a + e.total) * .15;
      default: return 0;
    }
  }
  double get _total => math.max(0.0, _subtotal - _discount) + _deliveryFee;

  List<Food> get _filtered {
    final term = _query.trim().toLowerCase();
    final list = foods.where((food) {
      final matchesCategory =
          (_category == 'Todos' || food.category == _category) &&
          (_selectedStore == null || food.restaurant == _selectedStore);
      final matchesSearch = term.isEmpty ||
          food.name.toLowerCase().contains(term) ||
          food.restaurant.toLowerCase().contains(term) ||
          food.category.toLowerCase().contains(term) ||
          food.description.toLowerCase().contains(term);
      return matchesCategory && matchesSearch;
    }).toList();

    if (_sort == 'Menor preço') {
      list.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sort == 'Melhor avaliação') {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    DeliveryAuth.instance.addListener(_refreshAuth);
    _liveLocation.addListener(_refreshLocation);
    _restoreLocalData();
    // Solicita permissão apenas com a Home já visível.
    WidgetsBinding.instance.addPostFrameCallback((_) => _liveLocation.start());
  }

  void _refreshAuth() { if (mounted) setState(() {}); }
  void _refreshLocation() { if (mounted) setState(() {}); }

  Future<void> _restoreLocalData() async {
    try {
      final favorites = await _storage.getStringList('favorite_foods');
      final bagJson = await _storage.getString('current_bag_v3');
      final ordersJson = await _storage.getString('history_orders');
      if (!mounted) return;
      setState(() {
        if (favorites != null) {
          _favorites..clear()..addAll(favorites.where((id) => foods.any((f) => f.id == id)));
        }
        if (bagJson != null) {
          final saved = jsonDecode(bagJson) as List<dynamic>;
          _bag..clear()..addAll(saved
              .map((e) => CartItem.fromJson(Map<String, dynamic>.from(e as Map)))
              .whereType<CartItem>());
        }
        if (ordersJson != null) {
          final records = jsonDecode(ordersJson) as List<dynamic>;
          _orders..clear()..addAll(records.map((e) {
            final o = Map<String, dynamic>.from(e as Map);
            return OrderDemo(number: o['number'] as String, summary: o['summary'] as String,
              total: (o['total'] as num).toDouble(), time: DateTime.parse(o['time'] as String),
              payment: (o['payment'] as String?) ?? 'Não informado', coupon: o['coupon'] as String?);
          }));
        }
      });
    } catch (_) { /* Não deixa dados antigos/corrompidos impedirem a abertura. */ }
  }

  Future<void> _saveLocalData() async {
    try {
      await _storage.setStringList('favorite_foods', _favorites.toList());
      await _storage.setString('current_bag_v3', jsonEncode(_bag.map((i) => i.toJson()).toList()));
      await _storage.setString('history_orders', jsonEncode(_orders.map((o) => {
        'number': o.number, 'summary': o.summary, 'total': o.total,
        'time': o.time.toIso8601String(), 'payment': o.payment, 'coupon': o.coupon,
      }).toList()));
    } catch (_) { /* Armazenamento não é indispensável para navegação. */ }
  }

  void _openAuth() {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AuthPage()));
  }

  @override
  void dispose() {
    DeliveryAuth.instance.removeListener(_refreshAuth);
    _liveLocation.removeListener(_refreshLocation);
    _liveLocation.dispose();
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: kInk,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      );
  }

  void _add(Food food, int quantity, {List<Addon> addons = const [], String? halfPizzaId, String note = ''}) {
    final newItem = CartItem(food: food, quantity: quantity, addons: addons, halfPizzaId: halfPizzaId, note: note);
    final old = _bag.where((i) => i.key == newItem.key).firstOrNull;
    setState(() {
      if (old != null) { old.quantity += quantity; } else { _bag.add(newItem); }
    });
    _saveLocalData();
    _toast('$quantity × ${food.name} adicionado à sacola');
  }

  void _favorite(Food food) {
    setState(() {
      if (!_favorites.add(food.id)) _favorites.remove(food.id);
    });
    _saveLocalData();
  }

  void _showAddress() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) => AnimatedBuilder(
        animation: _liveLocation,
        builder: (_, __) => SafeArea(top: false, child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Sua localização ao vivo', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 7),
              const Text('Utilizamos somente o GPS deste tablet durante o uso do aplicativo.',
                style: TextStyle(color: kMuted, height: 1.4)),
              const SizedBox(height: 20),
              Row(children: [
                Icon(_liveLocation.active ? Icons.gps_fixed_rounded : Icons.gps_off_rounded,
                  color: _liveLocation.active ? Colors.green : kOrange, size: 29),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_liveLocation.address, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(height: 5),
                  Text(_liveLocation.detail, style: const TextStyle(color: kMuted, fontSize: 12)),
                ])),
              ]),
              if (_liveLocation.error != null) ...[
                const SizedBox(height: 12),
                Text(_liveLocation.error!, style: const TextStyle(color: kOrange, fontSize: 12)),
              ],
              const SizedBox(height: 18),
              SizedBox(width: double.infinity, child: FilledButton.icon(
                onPressed: _liveLocation.loading ? null : () async {
                  if (_liveLocation.active) {
                    await _liveLocation.stop();
                  } else {
                    await _liveLocation.start();
                  }
                },
                icon: Icon(_liveLocation.active ? Icons.pause_circle_outline : Icons.my_location_rounded),
                label: Text(_liveLocation.active ? 'Pausar GPS' : 'Atualizar com GPS'),
              )),
              TextButton.icon(onPressed: Geolocator.openAppSettings,
                icon: const Icon(Icons.settings_outlined),
                label: const Text('Configurações de localização')),
            ],
          ),
        )),
      ),
    );
  }

  void _showSort() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Organizar cardápio', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            for (final item in ['Destaques', 'Menor preço', 'Melhor avaliação'])
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item),
                trailing: _sort == item ? const Icon(Icons.check_circle, color: kOrange) : null,
                onTap: () {
                  setState(() => _sort = item);
                  Navigator.pop(sheetContext);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showProduct(Food food) {
    int quantity = 1;
    String? halfPizzaId;
    bool halfAndHalf = false;
    final selectedAddons = <String>{};
    final noteController = TextEditingController();
    final available = addOnMenu[food.category] ?? <Addon>[];
    double unitPrice() {
      final other = foods.where((f) => f.id == halfPizzaId).firstOrNull;
      final base = halfAndHalf && other != null ? (food.price + other.price) / 2 : food.price;
      return base + available.where((a) => selectedAddons.contains(a.name)).fold<double>(0, (sum, a) => sum + a.price);
    }
    showModalBottomSheet<void>(
      context: context, isScrollControlled: true, showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, updateModal) => SafeArea(top: false,
          child: FractionallySizedBox(heightFactor: .89,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 6, 20,
                math.max(12.0, MediaQuery.of(sheetContext).viewInsets.bottom + 12.0)),
              child: Column(children: [
                Expanded(child: ListView(children: [
                  ClipRRect(borderRadius: BorderRadius.circular(22),
                    child: _foodPhoto(food, width: double.infinity, height: 215)),
                  const SizedBox(height: 17),
                  Text(food.restaurant.toUpperCase(),
                    style: const TextStyle(color: kOrange, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                  const SizedBox(height: 7),
                  Text(food.name, style: const TextStyle(color: kInk, fontSize: 26, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 7),
                  Text(food.description, style: const TextStyle(color: kMuted, height: 1.5)),
                  const SizedBox(height: 12),
                  Wrap(spacing: 15, runSpacing: 6, children: [
                    _detailChip(Icons.star_rounded, '${food.rating.toStringAsFixed(1)} avaliação'),
                    _detailChip(Icons.schedule_rounded, '${food.minutes}–${food.minutes + 10} min'),
                    _detailChip(Icons.storefront_outlined, food.restaurant),
                  ]),
                  const SizedBox(height: 18),
                  const Text('Detalhes do produto', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 5),
                  Text('Preparado conforme o cardápio ilustrativo. Ingredientes: ${food.description} Consulte o estabelecimento em caso de alergias ou restrições.',
                    style: const TextStyle(color: kMuted, fontSize: 12, height: 1.5)),
                  if (food.category == 'Pizzas') ...[
                    const SizedBox(height: 17),
                    SwitchListTile.adaptive(contentPadding: EdgeInsets.zero, activeTrackColor: kOrange,
                      title: const Text('Pizza meio a meio', style: TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: const Text('Cada metade com um sabor. Valor médio dos dois sabores.'),
                      value: halfAndHalf, onChanged: (v) => updateModal(() {
                        halfAndHalf = v;
                        halfPizzaId = v ? foods.firstWhere((f) => f.category == 'Pizzas' && f.id != food.id).id : null;
                      })),
                    if (halfAndHalf) ...[
                      const Text('Escolha o sabor da segunda metade', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      for (final pizza in foods.where((f) => f.category == 'Pizzas' && f.id != food.id))
                        ListTile(contentPadding: EdgeInsets.zero,
                          title: Text(pizza.name), subtitle: Text(reais(pizza.price)),
                          trailing: Icon(halfPizzaId == pizza.id
                            ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                            color: kOrange),
                          onTap: () => updateModal(() => halfPizzaId = pizza.id)),
                    ],
                  ],
                  if (available.isNotEmpty) ...[
                    const SizedBox(height: 19),
                    Text(food.category == 'Açaí' ? 'Monte seu açaí' : 'Personalize seu pedido',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 3),
                    const Text('Adicione os complementos que desejar', style: TextStyle(color: kMuted, fontSize: 12)),
                    const SizedBox(height: 9),
                    for (final add in available)
                      CheckboxListTile(contentPadding: EdgeInsets.zero,
                        title: Text(add.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        subtitle: Text(add.price == 0 ? 'Grátis' : '+ ${reais(add.price)}',
                          style: const TextStyle(color: kOrange, fontSize: 12)),
                        activeColor: kOrange,
                        value: selectedAddons.contains(add.name),
                        onChanged: (yes) => updateModal(() {
                          if (yes == true) { selectedAddons.add(add.name); }
                          else { selectedAddons.remove(add.name); }
                        })),
                  ],
                  const SizedBox(height: 15),
                  TextField(controller: noteController, maxLength: 150, maxLines: 2,
                    decoration: InputDecoration(labelText: 'Alguma observação?',
                      hintText: 'Ex.: sem cebola, molho separado',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
                  const Text('Preços, composição e disponibilidade são exemplos deste projeto.',
                    style: TextStyle(color: kMuted, fontSize: 11)),
                  const SizedBox(height: 10),
                ])),
                const SizedBox(height: 8),
                Row(children: [
                  _quantityButton(Icons.remove, () { if (quantity > 1) updateModal(() => quantity--); }),
                  SizedBox(width: 44, child: Text('$quantity', textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18))),
                  _quantityButton(Icons.add, () => updateModal(() => quantity++)),
                  const SizedBox(width: 12),
                  Expanded(child: SizedBox(height: 52, child: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: kOrange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                    onPressed: () {
                      final addons = available.where((a) => selectedAddons.contains(a.name)).toList();
                      final note = noteController.text.trim();
                      Navigator.pop(sheetContext);
                      _add(food, quantity, addons: addons,
                        halfPizzaId: halfAndHalf ? halfPizzaId : null, note: note);
                    },
                    icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                    label: FittedBox(child: Text('Adicionar ${reais(unitPrice() * quantity)}',
                      style: const TextStyle(fontWeight: FontWeight.w900))),
                  ))),
                ]),
              ]),
            ),
          )),
      ),
    ).whenComplete(noteController.dispose);
  }

  Widget _detailChip(IconData icon, String text) => Row(mainAxisSize: MainAxisSize.min,
    children: [Icon(icon, size: 16, color: kOrange), const SizedBox(width: 4),
      Text(text, style: const TextStyle(fontSize: 12, color: kMuted))]);

  Widget _foodPhoto(Food food, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    return Image.network(
      food.realPhoto,
      width: width, height: height, fit: fit,
      // Fotos reais enquanto online; fallback local garante funcionamento offline.
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : SizedBox(width: width, height: height, child: Stack(fit: StackFit.expand, children: [
              Image.asset(food.photo, fit: fit),
              const Center(child: CircularProgressIndicator(strokeWidth: 2, color: kOrange)),
            ])),
      errorBuilder: (_, __, ___) => Image.asset(food.photo,
        width: width, height: height, fit: fit),
    );
  }

  Widget _quantityButton(IconData icon, VoidCallback onTap) => Material(
        color: kOrangeLight,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: SizedBox(width: 38, height: 38, child: Icon(icon, color: kOrange, size: 19)),
        ),
      );

  void _showBag() {
    showModalBottomSheet<void>(context: context, isScrollControlled: true,
      showDragHandle: true, backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, updateModal) => SafeArea(top: false,
          child: FractionallySizedBox(heightFactor: .83,
            child: Padding(padding: const EdgeInsets.fromLTRB(22, 5, 22, 18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Sua sacola', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26)),
                const SizedBox(height: 4),
                Text('$_bagCount itens • Personalizados do seu jeito', style: const TextStyle(color: kMuted)),
                const SizedBox(height: 13),
                Expanded(child: _bag.isEmpty
                  ? const Center(child: Text('Sua sacola está vazia.'))
                  : ListView(children: [
                    for (final item in List<CartItem>.from(_bag))
                      _bagLine(item, () {
                        setState(() { if (item.quantity <= 1) { _bag.remove(item); } else { item.quantity--; } });
                        updateModal(() {}); _saveLocalData();
                      }, () {
                        setState(() => item.quantity++);
                        updateModal(() {}); _saveLocalData();
                      }),
                  ])),
                const Divider(height: 17),
                OutlinedButton.icon(onPressed: () async {
                  await _showCoupons();
                  if (sheetContext.mounted) updateModal(() {});
                }, icon: const Icon(Icons.local_offer_outlined),
                  label: Text(_couponCode == null ? 'Adicionar cupom' : 'Cupom $_couponCode aplicado')),
                const SizedBox(height: 8),
                _totalLine('Produtos', reais(_subtotal)),
                const SizedBox(height: 6),
                _totalLine('Entrega ilustrativa', _deliveryFee == 0 ? 'Grátis' : reais(_deliveryFee)),
                if (_couponCode != null) ...[
                  const SizedBox(height: 6),
                  _totalLine('Desconto $_couponCode', '− ${reais(_discount)}', color: Colors.green.shade700),
                ],
                const SizedBox(height: 9),
                _totalLine('Total', reais(_total), bold: true),
                const SizedBox(height: 13),
                SizedBox(height: 52, width: double.infinity, child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: kOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  onPressed: _bag.isEmpty ? null : () {
                    Navigator.pop(sheetContext);
                    _openCheckout();
                  },
                  child: const Text('Continuar para pagamento', style: TextStyle(fontWeight: FontWeight.w800)),
                )),
                const SizedBox(height: 7),
                const Center(child: Text('Checkout fictício: nenhuma cobrança é realizada.',
                  style: TextStyle(color: kMuted, fontSize: 11))),
              ]),
            ),
          )),
      ),
    );
  }

  Widget _bagLine(CartItem item, VoidCallback minus, VoidCallback plus) => Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ClipRRect(borderRadius: BorderRadius.circular(14),
        child: _foodPhoto(item.food, width: 76, height: 76)),
      const SizedBox(width: 11),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(item.food.name, style: const TextStyle(fontWeight: FontWeight.w800)),
        if (item.detail.isNotEmpty) Text(item.detail,
          style: const TextStyle(fontSize: 11, color: kMuted, height: 1.4), maxLines: 3),
        const SizedBox(height: 5),
        Text(reais(item.total), style: const TextStyle(color: kOrange, fontWeight: FontWeight.w800)),
        const SizedBox(height: 7),
        Row(children: [
          _quantityButton(Icons.remove, minus),
          SizedBox(width: 32, child: Text('${item.quantity}', textAlign: TextAlign.center)),
          _quantityButton(Icons.add, plus),
        ]),
      ])),
    ]),
  );

  Future<void> _showCoupons() async {
    final codeController = TextEditingController();
    await showModalBottomSheet<void>(context: context, isScrollControlled: true,
      showDragHandle: true, backgroundColor: Colors.white,
      builder: (sheet) => SafeArea(top: false, child: Padding(
        padding: EdgeInsets.fromLTRB(22, 4, 22, MediaQuery.of(sheet).viewInsets.bottom + 26),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Cupons 67', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24)),
          const SizedBox(height: 6),
          const Text('Promoções simuladas para testar sua sacola', style: TextStyle(color: kMuted)),
          const SizedBox(height: 13),
          for (final c in coupons)
            ListTile(contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.local_offer_outlined, color: kOrange),
              title: Text(c.code, style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text('${c.title} • ${c.description}'),
              trailing: const Icon(Icons.add_circle_outline, color: kOrange),
              onTap: () {
                if (_selectCoupon(c.code)) Navigator.pop(sheet);
              }),
          if (_couponCode != null)
            TextButton.icon(onPressed: () { setState(() => _couponCode = null); Navigator.pop(sheet); },
              icon: const Icon(Icons.close_rounded), label: const Text('Remover cupom')),
          const SizedBox(height: 9),
          Row(children: [
            Expanded(child: TextField(controller: codeController, textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(labelText: 'Digite seu cupom', border: OutlineInputBorder()))),
            const SizedBox(width: 8),
            FilledButton(onPressed: () {
              if (_selectCoupon(codeController.text)) Navigator.pop(sheet);
            }, child: const Text('Aplicar')),
          ]),
        ])),
      )),
    );
    codeController.dispose();
  }

  bool _selectCoupon(String input) {
    final code = input.trim().toUpperCase();
    if (!coupons.any((c) => c.code == code)) {
      _toast('Cupom não encontrado. Confira os códigos disponíveis.');
      return false;
    }
    if (code == 'FOME10' && _subtotal < 50) {
      _toast('FOME10 exige R\$ 50 em produtos.');
      return false;
    }
    if (code == 'DOCE15' && !_bag.any((i) => const ['Açaí','Sorvetes','Milk-shakes','Tortas']
      .contains(i.food.category))) {
      _toast('DOCE15 é válido apenas para sobremesas e açaí.');
      return false;
    }
    setState(() => _couponCode = code);
    _toast('Cupom $code aplicado!');
    return true;
  }

  Future<void> _openCheckout() async {
    if (_bag.isEmpty) return;
    final result = await Navigator.push<String>(context,
      MaterialPageRoute(builder: (_) => DeliveryCheckout(
        items: List<CartItem>.from(_bag), subtotal: _subtotal,
        discount: _discount, delivery: _deliveryFee, total: _total,
        coupon: _couponCode, address: _liveLocation.address)));
    if (!mounted || result == null) return;
    final summary = _bag.map((e) => '${e.quantity}× ${e.food.name}${e.halfPizza != null ? ' (meio a meio)' : ''}${e.addons.isNotEmpty ? ' + extras' : ''}').join(', ');
    final number = (_orders.length + 1).toString().padLeft(3, '0');
    setState(() {
      _orders.insert(0, OrderDemo(number: '#$number', summary: summary,
        total: _total, time: DateTime.now(), payment: result, coupon: _couponCode));
      _bag.clear();
      _couponCode = null;
      _tab = 2;
    });
    _saveLocalData();
    _showSuccess(number);
  }

  Widget _totalLine(String label, String value, {bool bold = false, Color? color}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(
          color: bold ? kInk : kMuted,
          fontSize: bold ? 17 : 14,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w400)),
      Text(value, style: TextStyle(
          color: color ?? kInk,
          fontSize: bold ? 20 : 14,
          fontWeight: FontWeight.w800)),
    ]);
  }

  void _showSuccess(String number) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Pedido simulado! 🎉'),
        content: Text('Seu pedido $number aparece na aba Pedidos. Este aplicativo é uma demonstração e não realiza entregas ou cobranças.'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Ver meus pedidos'),
          ),
        ],
      ),
    );
  }

  void _applyCoupon() {
    if (_bag.isEmpty) {
      _toast('Escolha seus produtos e depois aplique o cupom na sacola.');
      return;
    }
    _selectCoupon('BEMVINDO20');
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: kCanvas,
        body: SafeArea(
          bottom: false,
          child: switch (_tab) {
            0 => _discovery(),
            1 => _favoritesPage(),
            2 => _ordersPage(),
            _ => _profilePage(),
          },
        ),
        bottomNavigationBar: _bottomNav(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: _bagCount == 0 ? null : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: _showBag,
              style: FilledButton.styleFrom(
                backgroundColor: kInk,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                elevation: 5,
              ),
              child: Row(children: [
                const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 21),
                const SizedBox(width: 10),
                Text('Ver sacola ($_bagCount)',
                    style: const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w800)),
                const Spacer(),
                Text(reais(_total),
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                const SizedBox(width: 3),
                const Icon(Icons.chevron_right, color: Colors.white),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomNav() {
    final items = [
      (Icons.home_rounded, Icons.home_outlined, 'Início'),
      (Icons.favorite_rounded, Icons.favorite_border_rounded, 'Favoritos'),
      (Icons.receipt_long_rounded, Icons.receipt_long_outlined, 'Pedidos'),
      (Icons.person_rounded, Icons.person_outline_rounded, 'Perfil'),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF0EDEB))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(11, 8, 11, 9),
          child: Row(
            children: List.generate(items.length, (index) {
              final selected = _tab == index;
              final item = items[index];
              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => setState(() => _tab = index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(selected ? item.$1 : item.$2,
                            color: selected ? kOrange : kMuted, size: 24),
                        const SizedBox(height: 4),
                        Text(item.$3, style: TextStyle(
                          fontSize: 11, fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                          color: selected ? kOrange : kMuted,
                        )),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _discovery() {
    final visible = _filtered;
    return ListView(
      controller: _scroll,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 115),
      children: [
        _header(),
        const SizedBox(height: 17),
        Row(children: [
          Image.asset('assets/images/logo.png', width: 33, height: 33),
          const SizedBox(width: 8),
          const Text('67', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: kOrange)),
          const SizedBox(width: 5),
          const Text('DELIVERY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2, color: kInk)),
          const Spacer(),
          if (DeliveryAuth.instance.user == null)
            TextButton(onPressed: _openAuth, child: const Text('ENTRAR', style: TextStyle(fontWeight: FontWeight.w900, color: kOrange))),
        ]),
        const SizedBox(height: 17),
        RichText(
          text: const TextSpan(
            style: TextStyle(color: kInk, fontSize: 31, fontWeight: FontWeight.w900, height: 1.13, letterSpacing: -0.95),
            children: [
              TextSpan(text: 'Bateu aquela fome?\n'),
              TextSpan(text: 'o 67 resolve', style: TextStyle(color: kOrange)),
              TextSpan(text: '.'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _searchBox(),
        const SizedBox(height: 23),
        _promo(),
        const SizedBox(height: 26),
        _section('Lojas do 67', 'Ver todas', () => setState(() => _selectedStore = null)),
        const SizedBox(height: 12),
        _stores(),
        const SizedBox(height: 9),
        if (_selectedStore != null) Padding(padding: const EdgeInsets.only(top: 5),
          child: ActionChip(label: Text('$_selectedStore  ×'),
            onPressed: () => setState(() => _selectedStore = null))),
        const SizedBox(height: 23),
        _section('O que você deseja?', 'Ver tudo', () {
          setState(() { _category = 'Todos'; _selectedStore = null; _query = ''; _search.clear(); });
        }),
        const SizedBox(height: 15),
        _categories(),
        const SizedBox(height: 31),
        _section('Favoritos da galera', 'Filtrar', _showSort),
        const SizedBox(height: 16),
        if (visible.isEmpty) _empty('Nenhum prato encontrado', 'Experimente outro termo ou categoria.')
        else SizedBox(
          height: 289,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: math.min(5, visible.length),
            separatorBuilder: (_, __) => const SizedBox(width: 13),
            itemBuilder: (_, index) => _featuredCard(visible[index]),
          ),
        ),
        const SizedBox(height: 29),
        _section('Nosso cardápio', '${visible.length} opções', null),
        const SizedBox(height: 14),
        for (final food in visible) ...[
          _foodRow(food),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 10),
        const Center(child: Text('67 Delivery • Feito com sabor e carinho',
            style: TextStyle(fontSize: 11, color: kMuted))),
      ],
    );
  }

  Widget _header() => Row(children: [
    Material(color: Colors.white, borderRadius: BorderRadius.circular(16),
      child: InkWell(borderRadius: BorderRadius.circular(16), onTap: _showAddress,
        child: const SizedBox(width: 46, height: 46,
          child: Icon(Icons.location_on_rounded, color: kOrange, size: 25)))),
    const SizedBox(width: 11),
    Expanded(child: InkWell(onTap: _showAddress,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(_liveLocation.active ? 'GPS AO VIVO' : 'LOCALIZAÇÃO',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: kMuted, letterSpacing: 1.2)),
          if (_liveLocation.active) ...[
            const SizedBox(width: 5),
            Container(width: 7, height: 7, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
          ],
        ]),
        const SizedBox(height: 4),
        Row(children: [
          Flexible(child: Text(_liveLocation.address, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: kInk))),
          const Icon(Icons.keyboard_arrow_down_rounded, color: kOrange, size: 18),
        ]),
      ]))),
    const SizedBox(width: 7),
    InkWell(borderRadius: BorderRadius.circular(15), onTap: _openAuth,
      child: Container(width: 45, height: 45, padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: DeliveryAuth.instance.user == null
          ? const Icon(Icons.person_outline_rounded, color: kInk, size: 24)
          : const Icon(Icons.verified_user_rounded, color: kOrange, size: 22))),
  ]);

  Widget _searchBox() => Row(children: [
    Expanded(child: Container(
      height: 56,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17)),
      child: TextField(
        controller: _search,
        onChanged: (value) => setState(() => _query = value),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Pratos, restaurantes...',
          hintStyle: const TextStyle(color: kMuted, fontSize: 13),
          prefixIcon: const Icon(Icons.search_rounded, color: kOrange, size: 24),
          suffixIcon: _query.isEmpty ? null : IconButton(
            tooltip: 'Limpar busca',
            icon: const Icon(Icons.close_rounded, size: 19),
            onPressed: () => setState(() { _query = ''; _search.clear(); }),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    )),
    const SizedBox(width: 11),
    Material(
      color: kOrange,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: _showSort,
        borderRadius: BorderRadius.circular(17),
        child: const SizedBox(width: 56, height: 56,
            child: Icon(Icons.tune_rounded, color: Colors.white, size: 24)),
      ),
    ),
  ]);

  Widget _promo() => Container(
    height: 183,
    clipBehavior: Clip.hardEdge,
    decoration: BoxDecoration(
      color: kInk,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Stack(children: [
      Positioned(right: -66, top: -95, child: Container(
        height: 290, width: 290,
        decoration: const BoxDecoration(color: Color(0xFF343039), shape: BoxShape.circle),
      )),
      Positioned(right: -44, bottom: -74, child: Container(
        height: 220, width: 220,
        decoration: const BoxDecoration(color: Color(0x3DF34E2D), shape: BoxShape.circle),
      )),
      Positioned(right: -36, top: -5,
          child: ClipOval(child: _foodPhoto(foods.first, width: 218, height: 195, fit: BoxFit.cover))),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 10, 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(color: kGold, borderRadius: BorderRadius.circular(7)),
            child: const Text('PRIMEIRA PEDIDA',
                style: TextStyle(fontSize: 9, letterSpacing: .8, color: kInk, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 10),
          const Text('20% OFF', style: TextStyle(
              fontSize: 35, color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: -1.7)),
          const Text('O seu primeiro pedido\ncom mais sabor.',
              style: TextStyle(color: Color(0xFFEBE5E5), height: 1.35, fontSize: 12)),
          const Spacer(),
          GestureDetector(
            onTap: _applyCoupon,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(_couponCode == 'BEMVINDO20' ? 'CUPOM ATIVO' : 'APROVEITAR AGORA',
                  style: const TextStyle(color: kGold, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: .4)),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_rounded, color: kGold, size: 15),
            ]),
          ),
        ]),
      ),
    ]),
  );

  Widget _section(String title, String trailing, VoidCallback? tap) => Row(children: [
    Expanded(child: Text(title, style: const TextStyle(
      fontSize: 20, color: kInk, fontWeight: FontWeight.w900, letterSpacing: -.6,
    ))),
    if (tap == null)
      Text(trailing, style: const TextStyle(color: kMuted, fontSize: 12))
    else
      TextButton(onPressed: tap, child: Text(trailing,
          style: const TextStyle(color: kOrange, fontWeight: FontWeight.w800, fontSize: 12))),
  ]);

  Widget _stores() {
    final names = foods.map((e) => e.restaurant).toSet().toList();
    return SizedBox(height: 132, child: ListView.separated(
      scrollDirection: Axis.horizontal, itemCount: names.length,
      separatorBuilder: (_, __) => const SizedBox(width: 11),
      itemBuilder: (_, idx) {
        final name = names[idx];
        final sample = foods.firstWhere((e) => e.restaurant == name);
        final chosen = _selectedStore == name;
        return InkWell(borderRadius: BorderRadius.circular(17), onTap: () => setState(() {
          _selectedStore = chosen ? null : name;
          _category = 'Todos';
        }), child: Container(width: 144, padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17),
            border: Border.all(color: chosen ? kOrange : const Color(0xFFEFEAE4), width: chosen ? 2 : 1)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(borderRadius: BorderRadius.circular(10),
              child: _foodPhoto(sample, height: 69, width: double.infinity)),
            const SizedBox(height: 7),
            Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
            const Text('LOJA DEMONSTRATIVA', style: TextStyle(fontSize: 9, color: kMuted)),
          ]),
        ));
      },
    ));
  }

  Widget _categories() {
    const items = [
      ('Todos', Icons.apps_rounded),
      ('Burgers', Icons.lunch_dining_rounded),
      ('Pizzas', Icons.local_pizza_rounded),
      ('Churrasco', Icons.outdoor_grill_rounded),
      ('Açaí', Icons.ramen_dining_rounded),
      ('Milk-shakes', Icons.blender_outlined),
      ('Sorvetes', Icons.icecream_outlined),
      ('Tortas', Icons.cake_rounded),
      ('Japonesa', Icons.set_meal_outlined),
      ('Bebidas', Icons.local_drink_rounded),
    ];
    return SizedBox(
      height: 49,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final item = items[index];
          final selected = _category == item.$1;
          return Material(
            color: selected ? kOrange : Colors.white,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => setState(() => _category = item.$1),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(item.$2, size: 19, color: selected ? Colors.white : kOrange),
                  const SizedBox(width: 7),
                  Text(item.$1,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                          color: selected ? Colors.white : kInk)),
                ]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _featuredCard(Food food) => Container(
    width: 220,
    clipBehavior: Clip.hardEdge,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [BoxShadow(color: Color(0x0B242424), blurRadius: 15, offset: Offset(0, 5))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Stack(children: [
        InkWell(onTap: () => _showProduct(food),
          child: _foodPhoto(food, width: 220, height: 139, fit: BoxFit.cover)),
        Positioned(top: 10, left: 10, child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.star_rounded, size: 14, color: Color(0xFFE8A52A)),
            Text(food.rating.toStringAsFixed(1),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
          ]),
        )),
        Positioned(top: 8, right: 8, child: _heartButton(food)),
      ]),
      Expanded(child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(food.restaurant, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: kMuted)),
          const SizedBox(height: 5),
          InkWell(onTap: () => _showProduct(food), child: Text(food.name,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: kInk))),
          const SizedBox(height: 5),
          Row(children: [
            const Icon(Icons.timer_outlined, size: 13, color: kMuted),
            const SizedBox(width: 4),
            Text('${food.minutes}–${food.minutes + 10} min',
                style: const TextStyle(fontSize: 11, color: kMuted)),
          ]),
          const Spacer(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(reais(food.price),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: kInk)),
            Material(
              color: kOrange,
              borderRadius: BorderRadius.circular(11),
              child: InkWell(
                borderRadius: BorderRadius.circular(11),
                onTap: () => _showProduct(food),
                child: const SizedBox(width: 33, height: 33,
                    child: Icon(Icons.add_rounded, color: Colors.white, size: 20)),
              ),
            ),
          ]),
        ]),
      )),
    ]),
  );

  Widget _heartButton(Food food) {
    final liked = _favorites.contains(food.id);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        onTap: () => _favorite(food),
        borderRadius: BorderRadius.circular(100),
        child: SizedBox(width: 33, height: 33,
            child: Icon(liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: liked ? kOrange : kInk, size: 18)),
      ),
    );
  }

  Widget _foodRow(Food food) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(19),
    child: InkWell(
      onTap: () => _showProduct(food),
      borderRadius: BorderRadius.circular(19),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: _foodPhoto(food, width: 103, height: 101, fit: BoxFit.cover),
          ),
          const SizedBox(width: 13),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(food.restaurant, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: kMuted, fontSize: 11)),
            const SizedBox(height: 4),
            Text(food.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: kInk)),
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.star_rounded, size: 14, color: Color(0xFFE8A52A)),
              Text(' ${food.rating.toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              const SizedBox(width: 9),
              const Icon(Icons.access_time, color: kMuted, size: 13),
              Text(' ${food.minutes} min',
                  style: const TextStyle(fontSize: 11, color: kMuted)),
            ]),
            const SizedBox(height: 9),
            Text(reais(food.price),
                style: const TextStyle(fontSize: 16, color: kOrange, fontWeight: FontWeight.w900)),
          ])),
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _heartButton(food),
            const SizedBox(height: 28),
            Material(
              color: kOrangeLight,
              borderRadius: BorderRadius.circular(11),
              child: InkWell(
                onTap: () => _showProduct(food),
                borderRadius: BorderRadius.circular(11),
                child: const SizedBox(width: 34, height: 34,
                    child: Icon(Icons.add_rounded, color: kOrange)),
              ),
            ),
          ]),
        ]),
      ),
    ),
  );

  Widget _pageIntro(String kicker, String title, String subtitle) => Padding(
    padding: const EdgeInsets.only(bottom: 28),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(kicker.toUpperCase(),
          style: const TextStyle(color: kOrange, fontWeight: FontWeight.w900, letterSpacing: 1.3, fontSize: 12)),
      const SizedBox(height: 10),
      Text(title, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: kInk)),
      const SizedBox(height: 7),
      Text(subtitle, style: const TextStyle(fontSize: 14, color: kMuted)),
    ]),
  );

  Widget _favoritesPage() {
    final liked = foods.where((food) => _favorites.contains(food.id)).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 115),
      children: [
        _pageIntro('Sua seleção', 'Meus favoritos ❤️',
            'Os pratos que conquistaram seu coração.'),
        if (liked.isEmpty)
          _empty('Nenhum favorito ainda', 'Toque no coração dos pratos para salvá-los.'),
        for (final food in liked) ...[
          _foodRow(food),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _ordersPage() => ListView(
    padding: const EdgeInsets.fromLTRB(20, 30, 20, 115),
    children: [
      _pageIntro('Acompanhe tudo', 'Meus pedidos',
          'Histórico dos pedidos feitos nesta demonstração.'),
      if (_orders.isEmpty)
        _empty('Ainda não há pedidos',
            'Escolha algo delicioso na Home e finalize uma simulação.'),
      for (final order in _orders) ...[
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(19)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Pedido ${order.number}',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
              const Text('SIMULADO',
                  style: TextStyle(color: kOrange, fontSize: 10, fontWeight: FontWeight.w900)),
            ]),
            const SizedBox(height: 9),
            Text(order.summary, style: const TextStyle(color: kMuted, height: 1.4)),
            const SizedBox(height: 6),
            Text('Pagamento: ${order.payment}${order.coupon == null ? '' : ' • Cupom: ${order.coupon}'}',
              style: const TextStyle(fontSize: 12, color: kMuted)),
            const SizedBox(height: 12),
            Text(reais(order.total),
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: kOrange)),
          ]),
        ),
        const SizedBox(height: 12),
      ],
    ],
  );

  Widget _profilePage() => ListView(
    padding: const EdgeInsets.fromLTRB(20, 30, 20, 115),
    children: [
      _pageIntro('Bem-vindo ao 67', 'Meu perfil', 'O seu cantinho dentro do app.'),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Row(children: [
          Image.asset('assets/images/logo.png', width: 58, height: 58),
          const SizedBox(width: 15),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(DeliveryAuth.instance.user?.displayName?.isNotEmpty == true
                ? DeliveryAuth.instance.user!.displayName!
                : (DeliveryAuth.instance.user?.email ?? 'Visitante 67'),
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(DeliveryAuth.instance.user?.email ?? 'Explore sem login ou crie sua conta',
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: kMuted, fontSize: 12)),
          ])),
        ]),
      ),
      const SizedBox(height: 23),
      if (DeliveryAuth.instance.user == null)
        _profileAction(Icons.login_rounded, 'Entrar ou criar uma conta', _openAuth)
      else
        _profileAction(Icons.logout_rounded, 'Sair da conta', () async {
          try { await DeliveryAuth.instance.signOut(); _toast('Você saiu da sua conta.'); }
          catch (e) { _toast(friendlyAuthError(e)); }
        }),
      _profileAction(Icons.my_location_rounded, 'GPS em tempo real', _showAddress),
      _profileAction(Icons.location_on_outlined, 'Meu endereço atual', _showAddress),
      _profileAction(Icons.receipt_long_outlined, 'Histórico de pedidos', () => setState(() => _tab = 2)),
      _profileAction(Icons.favorite_border_rounded, 'Meus favoritos', () => setState(() => _tab = 1)),
      _profileAction(Icons.info_outline_rounded, 'Sobre o aplicativo', () {
        showAboutDialog(
          context: context,
          applicationName: '67 Delivery',
          applicationVersion: '3.0.0',
          applicationIcon: Image.asset('assets/images/logo.png', height: 52, width: 52),
          children: [const Text('Projeto acadêmico Flutter. Fotografias reais de alimentos fornecidas pela Unsplash. Restaurantes, preços, cupons e pedidos são demonstrações. GPS usa o tablet e login requer Firebase.')],
        );
      }),
      const SizedBox(height: 25),
      const Center(child: Text('67 DELIVERY  •  VERSÃO 3.0.0',
          style: TextStyle(color: kMuted, letterSpacing: 1, fontWeight: FontWeight.w700, fontSize: 11))),
    ],
  );

  Widget _profileAction(IconData icon, String text, VoidCallback onTap) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(children: [
            Icon(icon, color: kOrange),
            const SizedBox(width: 13),
            Expanded(child: Text(text,
                style: const TextStyle(fontWeight: FontWeight.w700))),
            const Icon(Icons.chevron_right_rounded, color: kMuted),
          ]),
        ),
      ),
    ),
  );

  Widget _empty(String title, String subtitle) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 45, horizontal: 20),
    child: Center(child: Column(children: [
      Container(
        height: 85, width: 85,
        decoration: const BoxDecoration(color: kOrangeLight, shape: BoxShape.circle),
        child: const Icon(Icons.fastfood_outlined, size: 37, color: kOrange),
      ),
      const SizedBox(height: 18),
      Text(title, textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      Text(subtitle, textAlign: TextAlign.center,
          style: const TextStyle(color: kMuted, height: 1.5)),
    ])),
  );
}


// CHECKOUT DIDÁTICO: sem PIX emitido, dados bancários, cobranças ou envio a lojas.
class DeliveryCheckout extends StatefulWidget {
  const DeliveryCheckout({super.key, required this.items, required this.subtotal,
    required this.discount, required this.delivery, required this.total,
    required this.address, this.coupon});
  final List<CartItem> items;
  final double subtotal, discount, delivery, total;
  final String address;
  final String? coupon;
  @override State<DeliveryCheckout> createState() => _DeliveryCheckoutState();
}

class _DeliveryCheckoutState extends State<DeliveryCheckout> {
  String _method = 'Pix';
  final _change = TextEditingController();
  @override void dispose() { _change.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Finalizar pedido', style: TextStyle(fontWeight: FontWeight.w900)),
      backgroundColor: kCanvas),
    backgroundColor: kCanvas,
    body: SafeArea(child: Column(children: [
      Expanded(child: ListView(padding: const EdgeInsets.all(20), children: [
        Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(
          color: kOrangeLight, borderRadius: BorderRadius.circular(16)),
          child: const Row(children: [Icon(Icons.info_outline, color: kOrange), SizedBox(width: 10),
            Expanded(child: Text('Pagamento de demonstração. Não informe dados reais: nenhuma cobrança será realizada.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)))])),
        const SizedBox(height: 22),
        const Text('Entrega', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 19)),
        const SizedBox(height: 7),
        Row(children: [const Icon(Icons.location_on_outlined, color: kOrange),
          const SizedBox(width: 8), Expanded(child: Text(widget.address,
            style: const TextStyle(color: kMuted)))]),
        const SizedBox(height: 18),
        const Text('Resumo do seu pedido', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 19)),
        const SizedBox(height: 9),
        for (final line in widget.items) Padding(padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${line.quantity}×', style: const TextStyle(color: kOrange, fontWeight: FontWeight.w900)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(line.food.name, style: const TextStyle(fontWeight: FontWeight.w800)),
              if (line.detail.isNotEmpty) Text(line.detail, style: const TextStyle(fontSize: 11, color: kMuted)),
            ])),
            Text(reais(line.total), style: const TextStyle(fontWeight: FontWeight.w800)),
          ])),
        const Divider(height: 26),
        _line('Produtos', widget.subtotal),
        _line('Frete simulado', widget.delivery),
        if (widget.coupon != null) _line('Cupom ${widget.coupon}', -widget.discount),
        _line('Total', widget.total, strong: true),
        const SizedBox(height: 22),
        const Text('Forma de pagamento', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 19)),
        const SizedBox(height: 7),
        for (final method in ['Pix', 'Cartão de crédito', 'Cartão de débito', 'Dinheiro'])
          Card(color: Colors.white, elevation: 0, child: ListTile(
            title: Text(method), subtitle: Text(switch (method) {
              'Pix' => 'Aprovação simulada, sem QR Code real',
              'Cartão de crédito' => 'Simulação, sem solicitar número de cartão',
              'Cartão de débito' => 'Simulação, sem dados bancários',
              _ => 'Pagamento fictício na entrega',
            }),
            trailing: Icon(_method == method ? Icons.radio_button_checked_rounded
              : Icons.radio_button_unchecked_rounded, color: kOrange),
            onTap: () => setState(() => _method = method),
          )),
        if (_method == 'Dinheiro') ...[
          const SizedBox(height: 10),
          TextField(controller: _change, keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Troco para quanto? (opcional)',
              hintText: 'Ex.: 100,00', border: OutlineInputBorder())),
        ],
        const SizedBox(height: 10),
      ])),
      Padding(padding: const EdgeInsets.fromLTRB(20, 7, 20, 18),
        child: SizedBox(width: double.infinity, height: 56, child: FilledButton.icon(
          icon: const Icon(Icons.check_circle_outline),
          style: FilledButton.styleFrom(backgroundColor: kOrange,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          label: Text('Confirmar simulação • ${reais(widget.total)}',
            style: const TextStyle(fontWeight: FontWeight.w900)),
          onPressed: () {
            if (_method == 'Dinheiro' && _change.text.trim().isNotEmpty) {
              final value = double.tryParse(_change.text.replaceAll('.', '').replaceAll(',', '.'));
              if (value == null || value < widget.total) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Informe um valor válido para o troco.')));
                return;
              }
            }
            Navigator.pop(context, _method);
          },
        )),
      ),
    ])),
  );

  Widget _line(String name, double amount, {bool strong = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(name, style: TextStyle(fontSize: strong ? 18 : 14,
        fontWeight: strong ? FontWeight.w800 : FontWeight.w500)),
      Text('${amount < 0 ? '− ' : ''}${reais(amount.abs())}',
        style: TextStyle(fontWeight: FontWeight.w900, fontSize: strong ? 21 : 14,
          color: strong ? kOrange : kInk)),
    ]),
  );
}
