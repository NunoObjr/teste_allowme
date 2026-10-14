# AllowMe Bridge (teste_allowme)

Aplicativo de exemplo em **Flutter** que integra o **SDK nativo da AllowMe** (Android e iOS) — plataforma brasileira de prevenção a fraude e biometria facial — usando **Platform Channels**. O Dart apenas dispara as operações; toda a lógica de biometria e coleta contextual roda no código nativo.

> Projeto de estudo/teste técnico. Não é um produto da AllowMe.

## O que o app faz

A tela principal expõe botões que chamam, via `MethodChannel`, as operações do SDK:

| Método do canal | Operação |
| --- | --- |
| `setup` | Inicializa o SDK |
| `start` | Inicia a análise contextual |
| `collect` | Coleta os dados contextuais do dispositivo |
| `addPerson` | Cadastra uma pessoa para a análise |
| `biometry` | Abre o fluxo de captura biométrica |

O resultado da biometria volta ao Flutter por uma chamada reversa (`didReceiveBiometry`), exibida na tela. O app também solicita as permissões necessárias em tempo de execução (`permission_handler`).

## Conceitos técnicos

**Platform Channels.** Comunicação bidirecional entre Dart e código nativo por um canal nomeado (`br.com.samples.allowme/sdk`):

```
Flutter (Dart) ──invokeMethod('collect')──► Kotlin / Swift ──► AllowMe SDK
              ◄──didReceiveBiometry(result)──
```

**Implementação nativa por plataforma.**

- **Android:** `MainActivity.kt` (Kotlin) registra o `MethodCallHandler` e usa os callbacks `SetupCallback`, `CollectCallback`, `StartCallback` e `AddPersonCallback`. O SDK vem do repositório Maven da AllowMe, com variantes `release` e `debug` (*stage*).
- **iOS:** `AppDelegate.swift` (Swift) implementa `AllowMeBiometryDelegate` e devolve o resultado ao Dart pelo canal; o SDK é adicionado via CocoaPods.

**Callbacks assíncronos → `Future`.** Cada chamada ao SDK é assíncrona; o resultado é devolvido ao `Future` do Dart com `result.success`/`result.error`.

## Estrutura

```
lib/main.dart                     # UI e chamadas ao MethodChannel
android/app/src/main/kotlin/...   # MainActivity.kt — integração com o SDK Android
ios/Runner/AppDelegate.swift      # integração com o SDK iOS
```

## Como executar

Pré-requisitos: Flutter, Android Studio/Xcode e **credenciais de testes fornecidas pela AllowMe**.

```bash
flutter pub get
flutter run
```

> **Segurança:** a chave de API do SDK **não deve ficar versionada no código**. Mantenha-a fora do repositório (variáveis de build, `local.properties`, xcconfig ignorado pelo Git) e revogue/rotacione qualquer chave que já tenha sido commitada.

## Stack

Flutter · Dart · Kotlin · Swift · `permission_handler` · AllowMe SDK
