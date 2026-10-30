# Habilitar contas reais e login com Google no 67 Delivery

O aplicativo **abre sem Firebase**, porque a entrega acadêmica exige Splash → Home automaticamente. **O cadastro, login com e-mail e Google só passam a funcionar depois que você conecta seu próprio projeto Firebase.** Nenhuma chave, conta ou credencial é fornecida de forma fictícia.

## 1. Criar Firebase

1. Acesse https://console.firebase.google.com/ e crie um projeto (ex.: `delivery67-tcc`).
2. Em **Authentication → Sign-in method**, ative **Email/Password** e **Google**, e selecione o e-mail de suporte do projeto.
3. Em Configurações do projeto, adicione um aplicativo Android. O identificador do pacote deve ser o mesmo do Android criado pelo Flutter (normalmente `com.example.projeto_final_mobile` se você não o alterou).

## 2. Conectar ao Flutter

Instale Firebase CLI e FlutterFire CLI conforme https://firebase.google.com/docs/flutter/setup. Na pasta do projeto, execute:

```powershell
flutter create . --platforms=android --project-name=projeto_final_mobile
flutter pub get
firebase login
dart pub global activate flutterfire_cli
flutterfire configure --platforms=android
```

`flutterfire configure` substitui `lib/firebase_options.dart` (que neste pacote começa como um placeholder seguro). Confirme que foram gerados os arquivos Android necessários e que o aplicativo Android escolhido é o correto.

## 3. Habilitar o Google no tablet

- Gere o fingerprint **SHA-1 e SHA-256** da assinatura de debug do Android. Você pode executar `cd android` e `./gradlew signingReport` em ambientes Unix, ou no Windows `cd android` e `./gradlew.bat signingReport`; outra opção é utilizar `keytool`.
- Cadastre SHA-1 e SHA-256 em **Firebase Console → Configurações do projeto → Seus apps → Android → Adicionar impressão digital**.
- Confira Google habilitado em Authentication. Se necessário, baixe novamente o `google-services.json` e coloque-o em `android/app/google-services.json`.
- Reexecute `flutterfire configure --platforms=android` após mudar os certificados, verifique se o plugin Google Services está configurado e faça `flutter clean`, `flutter pub get`, `flutter run`.

## 4. Testar

Abra **Início → ENTRAR** ou **Perfil → Entrar ou criar uma conta**.

1. Crie uma conta com nome/e-mail/senha (mínimo 6 caracteres).
2. Saia e entre com o mesmo e-mail e senha.
3. Use **Esqueci minha senha** para testar o e-mail de recuperação.
4. Teste o botão **Entrar com Google** no tablet com Google Play Services e conta Google configurada.

Se ocorrer `ApiException: 10` ou `DEVELOPER_ERROR`, revise o SHA-1, o package name e o `google-services.json`; o Google Sign-In requer correspondência entre assinatura e aplicativo.

## Privacidade e escopo

- Firebase Authentication gerencia a sessão e a senha. Não salvamos senhas em SharedPreferences.
- O 67 Delivery **não implementa pagamentos reais**, restaurantes comerciais nem despacho de entregadores; os pedidos são simulados e armazenados no próprio tablet.
- O GPS funciona somente em primeiro plano; o endereço é obtido do serviço do Android e não é enviado a um backend do 67 Delivery.
