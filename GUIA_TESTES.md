# Guia de testes no tablet — 67 Delivery

Valide no tablet Android (não foi possível executar o app neste ambiente, pois não há Flutter SDK instalado aqui).

## Checklist da atividade

- [ ] `flutter pub get` conclui sem erro.
- [ ] `flutter devices` reconhece seu tablet.
- [ ] Splash laranja com a logo 67 Delivery aparece.
- [ ] Após cerca de 2,8 segundos, entra automaticamente na Home.
- [ ] Logo, slogan, banner e cardápio aparecem corretamente.
- [ ] Fotos reais dos alimentos são carregadas com Wi-Fi/dados móveis.
- [ ] Categorias mostram resultados de churrasco, açaí, milk-shake, sorvete, torta etc.
- [ ] Busca filtra produtos e o botão Filtrar organiza o cardápio.
- [ ] Favoritar e desfavoritar funciona e permanece após fechar/reabrir o app.
- [ ] A sacola aumenta/diminui quantidade, atualiza total e aplica desconto.
- [ ] Finalizar pedido demonstrativo cria entrada no histórico local, sem cobrar nem enviar a restaurante.
- [ ] Ao autorizar a permissão do Android, o GPS exibe a posição atual e o endereço quando disponível.
- [ ] Mover o tablet atualiza as coordenadas e, quando apropriado, o endereço.
- [ ] Pausar GPS interrompe as atualizações e retomar reinicia.
- [ ] Negar a permissão ou desligar GPS mostra mensagem adequada.
- [ ] A tela Entrar/Cadastrar abre e oferece as opções e-mail, Google e recuperação de senha.
- [ ] **Após configurar Firebase**, criar conta, autenticar, recuperar senha e entrar com Google funcionam.
- [ ] O repositório GitHub está com o nome `projeto_final_mobile`, contém `lib/main.dart` e a pasta `assets`.

## Se as fotos não carregarem

As fotografias são solicitadas à Unsplash. Verifique a internet do tablet. Sem conexão, o app usa imagens locais de fallback (ilustrações).

## Se login Google falhar

Verifique Firebase Authentication → Google habilitado, package name, certificado SHA-1/SHA-256, `flutterfire configure` e conexão do tablet a uma conta Google. Veja `FIREBASE_SETUP.md`.

## Se o GPS não funcionar

Ative Localização do tablet e permita o acesso durante o uso. No app, toque no endereço → Atualizar com GPS. Em ambientes internos o sinal pode ser lento ou impreciso.
