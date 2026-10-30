import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';

/// Autenticação opcional: o cardápio continua acessível sem configurar Firebase.
/// Ative os provedores Email/Senha e Google no Console Firebase.
class DeliveryAuth extends ChangeNotifier {
  DeliveryAuth._();
  static final DeliveryAuth instance = DeliveryAuth._();

  bool available = false;
  bool loading = false;
  String? configurationError;
  User? user;
  StreamSubscription<User?>? _subscription;
  bool _googleInitialized = false;

  Future<void> initialize() async {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      available = true;
      user = FirebaseAuth.instance.currentUser;
      _subscription = FirebaseAuth.instance.authStateChanges().listen((value) {
        user = value;
        notifyListeners();
      });
    } catch (_) {
      available = false;
      configurationError = 'Autenticação indisponível neste dispositivo.';
    }
    notifyListeners();
  }

  Future<void> signInEmail(String email, String password) => _run(() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.trim(), password: password,
    );
  });

  Future<void> signUp(String name, String email, String password) => _run(() async {
    final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email.trim(), password: password,
    );
    await credential.user?.updateDisplayName(name.trim());
    user = FirebaseAuth.instance.currentUser;
    notifyListeners();
  });

  Future<void> resetPassword(String email) => _run(() async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
  });

  Future<void> signInGoogle() => _run(() async {
    if (!_googleInitialized) {
      await GoogleSignIn.instance.initialize();
      _googleInitialized = true;
    }
    final account = await GoogleSignIn.instance.authenticate();
    final googleAuth = account.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null) {
      throw StateError('O Google não retornou um token de identificação.');
    }
    await FirebaseAuth.instance.signInWithCredential(
      GoogleAuthProvider.credential(idToken: idToken),
    );
  });

  Future<void> signOut() => _run(() async {
    await FirebaseAuth.instance.signOut();
    if (_googleInitialized) {
      try { await GoogleSignIn.instance.signOut(); } catch (_) {/* Firebase já saiu. */}
    }
    user = null;
    notifyListeners();
  });

  Future<void> _run(Future<void> Function() action) async {
    if (!available) {
      throw StateError('Não foi possível acessar o serviço de contas. Tente novamente mais tarde.');
    }
    loading = true;
    notifyListeners();
    try { await action(); } finally { loading = false; notifyListeners(); }
  }

  @override
  void dispose() { _subscription?.cancel(); super.dispose(); }
}

String friendlyAuthError(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-email': return 'Digite um e-mail válido.';
      case 'email-already-in-use': return 'Este e-mail já possui uma conta.';
      case 'weak-password': return 'A senha precisa ter pelo menos 6 caracteres.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found': return 'E-mail ou senha incorretos.';
      case 'network-request-failed': return 'Sem internet. Tente novamente.';
      case 'too-many-requests': return 'Muitas tentativas. Aguarde e tente novamente.';
      case 'operation-not-allowed': return 'Este método de login não está disponível agora.';
      case 'account-exists-with-different-credential': return 'Já existe outra forma de login para este e-mail.';
    }
    return error.message ?? 'Não foi possível realizar o login.';
  }
  final message = error.toString();
  if (message.contains('canceled') || message.contains('cancelled')) return 'Login cancelado.';
  return message.replaceFirst('Bad state: ', '').replaceFirst('Exception: ', '');
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _signup = false;
  bool _obscure = true;
  bool _busy = false;
  String? _error;
  static const orange = Color(0xFFF34E2D);
  static const ink = Color(0xFF24222A);

  @override
  void dispose() {
    _name.dispose(); _email.dispose(); _password.dispose(); super.dispose();
  }

  Future<void> _submit(Future<void> Function() action, {bool close = true}) async {
    if (_busy) return;
    setState(() { _busy = true; _error = null; });
    try {
      await action();
      if (!mounted) return;
      if (close) {
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Enviamos instruções de recuperação para seu e-mail.'),
        ));
      }
    } catch (error) {
      if (mounted) setState(() => _error = friendlyAuthError(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
    labelText: label, prefixIcon: Icon(icon, color: orange),
    filled: true, fillColor: const Color(0xFFF7F4F1),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 13),
  );

  @override
  Widget build(BuildContext context) {
    final auth = DeliveryAuth.instance;
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      appBar: AppBar(backgroundColor: Colors.transparent, leading: IconButton(
        onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded),
      )),
      body: SafeArea(child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(26, 5, 26, 30), child: Form(
          key: _form,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Center(child: Image.asset('assets/images/logo.png', width: 92, height: 92)),
            const SizedBox(height: 21),
            Text(_signup ? 'Crie sua conta' : 'Que bom te ver!',
              textAlign: TextAlign.center, style: const TextStyle(fontSize: 29, fontWeight: FontWeight.w900, color: ink)),
            const SizedBox(height: 8),
            Text(_signup ? 'Entre para o time dos apaixonados por comida.' : 'Seu próximo pedido delicioso começa aqui.',
              textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF85818A), fontSize: 14)),
            const SizedBox(height: 26),
            if (_signup) ...[
              TextFormField(controller: _name, textCapitalization: TextCapitalization.words,
                decoration: _dec('Seu nome', Icons.person_outline_rounded),
                validator: (v) => (v ?? '').trim().length < 2 ? 'Informe seu nome.' : null),
              const SizedBox(height: 12),
            ],
            TextFormField(controller: _email, keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email], decoration: _dec('E-mail', Icons.alternate_email_rounded),
              validator: (v) => RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch((v ?? '').trim()) ? null : 'Informe um e-mail válido.'),
            const SizedBox(height: 12),
            TextFormField(controller: _password, obscureText: _obscure,
              autofillHints: [_signup ? AutofillHints.newPassword : AutofillHints.password],
              decoration: _dec('Senha', Icons.lock_outline_rounded).copyWith(
                suffixIcon: IconButton(onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined))),
              validator: (v) => (v ?? '').length < 6 ? 'Use no mínimo 6 caracteres.' : null),
            if (!_signup) ...[
              Align(alignment: Alignment.centerRight, child: TextButton(
                onPressed: _busy ? null : () {
                  if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(_email.text.trim())) {
                    setState(() => _error = 'Digite seu e-mail para recuperar a senha.'); return;
                  }
                  _submit(() => auth.resetPassword(_email.text), close: false);
                }, child: const Text('Esqueci minha senha', style: TextStyle(color: orange)))),
            ] else const SizedBox(height: 18),
            if (_error != null) ...[
              Container(padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFFFE9E5), borderRadius: BorderRadius.circular(10)),
                child: Text(_error!, style: const TextStyle(color: Color(0xFF9D291D), fontSize: 12))),
              const SizedBox(height: 12),
            ],
            SizedBox(height: 54, child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              onPressed: _busy ? null : () {
                if (!_form.currentState!.validate()) return;
                _submit(() => _signup
                  ? auth.signUp(_name.text, _email.text, _password.text)
                  : auth.signInEmail(_email.text, _password.text));
              }, child: _busy ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(_signup ? 'Criar minha conta' : 'Entrar', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            )),
            const SizedBox(height: 18),
            const Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('ou continue com', style: TextStyle(color: Color(0xFF89858A)))), Expanded(child: Divider())]),
            const SizedBox(height: 16),
            SizedBox(height: 53, child: OutlinedButton.icon(
              onPressed: _busy ? null : () => _submit(auth.signInGoogle),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFE5E0DA)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              icon: const SizedBox(width: 24, height: 24, child: CustomPaint(painter: GoogleGMark())),
              label: const Text('Entrar com Google', style: TextStyle(color: ink, fontWeight: FontWeight.w700)),
            )),
            const SizedBox(height: 22),
            TextButton(onPressed: _busy ? null : () {
              setState(() { _signup = !_signup; _error = null; _form.currentState?.reset(); });
            }, child: Text(_signup ? 'Já tem uma conta? Fazer login' : 'Não tem uma conta? Cadastre-se',
              style: const TextStyle(color: orange, fontWeight: FontWeight.w800))),
            TextButton(onPressed: () => Navigator.of(context).pop(),
              child: const Text('Continuar explorando sem login', style: TextStyle(color: Color(0xFF89858A)))),
          ]),
        )),
      ))),
    );
  }
}


/// Marca G colorida com gradiente (versão vetorial do botão), sem fonte externa.
/// Não altera a autenticação OAuth, que depende de credenciais Google/Firebase.
class GoogleGMark extends CustomPainter {
  const GoogleGMark();

  @override
  void paint(Canvas canvas, Size size) {
    final shortest = size.shortestSide;
    final center = Offset(size.width / 2, size.height / 2);
    final circle = Rect.fromCircle(center: center, radius: shortest * .39);
    final stroke = shortest * .19;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt
      ..shader = const SweepGradient(
        startAngle: -1.57, endAngle: 4.71,
        colors: [Color(0xFF4285F4), Color(0xFF34A853),
          Color(0xFFFBBC05), Color(0xFFEA4335), Color(0xFF4285F4)],
        stops: [0, .25, .49, .75, 1],
      ).createShader(circle);
    // G aberto à direita, com barra azul central.
    canvas.drawArc(circle, .68, 5.40, false, paint);
    final blue = Paint()..color = const Color(0xFF4285F4)..strokeWidth = stroke;
    canvas.drawLine(Offset(center.dx + shortest * .02, center.dy + shortest * .015),
      Offset(center.dx + shortest * .46, center.dy + shortest * .015), blue);
  }

  @override bool shouldRepaint(covariant GoogleGMark oldDelegate) => false;
}
