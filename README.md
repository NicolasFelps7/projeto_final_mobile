# 🍔 67 Delivery — Flutter 2.0

**App Android de demonstração acadêmica**, com identidade visual exclusiva e logo `67 DELIVERY` em `assets/images/logo.png`. Implementa **SplashScreen → HomeScreen** automaticamente, conforme a atividade da professora Andreza Quintas. Projeto e repositório sugerido: `projeto_final_mobile`.

## Funcionalidades implementadas

- Splash Screen animada, com logo e navegação automática para a Home após 2,8 s.
- Home com banner, identidade visual, busca por nome/categoria/descrição, categorias e filtros por preço/avaliação.
- **25 itens** em Burgers, Pizzas, Churrasco, Açaí, Milk-shakes, Sorvetes, Tortas, Japonesa e Bebidas.
- **Fotografias reais** de alimentos carregadas da Unsplash (internet necessária); há imagens locais de fallback quando a conexão falhar. Alguns itens da mesma categoria usam uma foto ilustrativa da categoria, não uma foto do prato exato.
- Detalhes do item, seleção de quantidade, favoritos, sacola e cupom BEMVINDO20.
- Histórico de **pedidos demonstrativos**, sem pagamentos/cobranças/entregas reais.
- Favoritos, sacola e histórico demonstrativo armazenados localmente no tablet, mesmo após fechar o aplicativo.
- Localização ao vivo do **tablet Android**, com GPS, permissões, atualização contínua em primeiro plano, conversão de coordenadas para endereço quando o sistema suportar e botão de pausar/retomar.
- Tela de login/cadastro com **e-mail e senha**, redefinição de senha, **Google Sign-In** e logout. **Requer configurar seu Firebase para usar contas reais**. A Home funciona sem login, como exigido pela atividade.

## Como executar no tablet Android (Windows + VS Code)

Pré-requisitos: Flutter instalado (`flutter doctor` sem problemas críticos para Android), Android SDK, VS Code com extensão Flutter e tablet com Depuração USB ativada.

1. Abra esta pasta `projeto_final_mobile` no VS Code.
2. No terminal do VS Code, execute:

```powershell
flutter create . --platforms=android --project-name=projeto_final_mobile
flutter pub get
flutter devices
flutter run
```

O primeiro comando gera os arquivos padrão do projeto Android na primeira utilização. O arquivo `android/app/src/main/AndroidManifest.xml` **já está incluído**, com permissões de GPS e internet, e deve ser mantido.

**Não precisa emulador nem script `.bat`.** Basta conectar o tablet por USB, autorizar a depuração e selecionar o dispositivo em `flutter devices` ou pelo VS Code.

### Ativar login/cadastro/Google

Leia **[FIREBASE_SETUP.md](FIREBASE_SETUP.md)**. Sem essa etapa, o aplicativo **mostra a interface de cadastro, mas informa corretamente que autenticação precisa ser configurada**. Ninguém consegue autenticar sem um projeto Firebase válido.

### GPS ao vivo

Ao abrir a Home, o Android solicita permissão de localização. Aceite **Permitir durante o uso do app**; a barra superior mostrará o endereço aproximado e o status GPS AO VIVO. Toque no cabeçalho para ver detalhes, coordenadas, atualizar ou pausar. O GPS não rastreia localização em segundo plano. Se o GPS estiver desligado ou a permissão negada, a interface indica como resolver. O endereço depende do serviço de geocodificação do Android e pode não estar disponível sem conexão.

### Limitações importantes

Este é um **protótipo acadêmico interativo**, não um marketplace operacional. Restaurantes, preços, avaliações, cupons, tempos e pedidos são valores ilustrativos; não há pagamento online, pedidos enviados a comércios ou localização de entregadores. As fotos são fotografias reais, mas ilustrativas dos pratos, não de refeições preparadas por restaurantes cadastrados.

## Estrutura

```text
projeto_final_mobile/
├── android/app/src/main/AndroidManifest.xml   # GPS + internet
├── assets/images/logo.png                      # logo 67 Delivery
├── assets/images/                           # imagens offline de fallback
├── lib/main.dart                             # Splash + Home + cardápio + sacola
├── lib/auth_service.dart                     # Firebase + login/cadastro/Google
├── lib/firebase_options.dart                 # substituído pelo flutterfire configure
├── lib/live_location.dart                    # GPS + geocodificação
├── pubspec.yaml
├── FIREBASE_SETUP.md
└── README.md
```

## Fontes das fotografias

Fotos reais servidas pela [Unsplash](https://unsplash.com/license), sob [Unsplash License](https://unsplash.com/license). Exemplos: hambúrguer `photo-1568901346375-23c9450c58cd`, pizza `photo-1574071318508-1cdbab80d002`, sushi `photo-1579871494447-9811cf80d66c`, churrasco `photo-1544025162-d76694265947`, açaí `photo-1627308594190-a057cd4bfac8`, milk-shake `photo-1551782450-40537687757d`, sorvete `photo-1778996525701-2cb205f5953c`, torta `photo-1565958011703-44f9829ba187`. Imagens podem ser carregadas em resolução adaptada pelo servidor. Não vendemos nem redistribuímos coleções de imagens.

## Entrega da atividade

Crie no GitHub um repositório **`projeto_final_mobile`** e envie todos os arquivos da pasta. O enunciado exige principalmente `main.dart`, Splash, Home, logo em assets, navegação e funcionamento no dispositivo. **Faça um teste no seu tablet antes de entregar**.


## Erros do widget_test.dart / VS Code

Se aparecerem erros no teste padrão do Flutter, veja [CORRECAO_ERROS_VSCODE.md](CORRECAO_ERROS_VSCODE.md). Esta versão já traz o teste corrigido e `flutter_test` configurado.
