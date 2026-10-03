# Rede-Local
# Rede Local — Android + C++/JNI para AIDE

Aplicativo Android simples para diagnóstico da rede local. A interface consulta as APIs Android; a descoberta TCP e o teste de portas são executados em C++ via JNI. Projeto Gradle com `ndk-build`.

## Funcionalidades

- Mostra IPv4 local e prefixo, gateway padrão, servidores DNS e o estado de conectividade validado pelo Android.
- Descobre dispositivos respondendo a portas TCP comuns (80, 443, 22, 445, 554 e 8080).
- Testa o alcance de um IP local com `InetAddress.isReachable()`. O botão do gateway atualiza a rota e, se ping não responder, também tenta conexão TCP nas portas 53, 80, 443 e 8080.
- Testa portas TCP de um alvo dentro da sub-rede local, em intervalos de até 128 portas, usando até 16 conexões paralelas. Para alvos comuns, teste portas individuais como 53 (DNS), 80 (HTTP) ou 443 (HTTPS).
- Executa as operações de rede em segundo plano para não congelar a interface.

## Limites conhecidos

Não identifiquei uma função declarada sem implementação. Ainda assim, a descoberta é uma sondagem TCP de seis portas comuns, não uma listagem garantida de todos os dispositivos; hosts sem essas portas abertas ou atrás de firewall podem não aparecer. O ping usa a API Android `isReachable`, que é best-effort, e o estado de Internet vem da validação do próprio Android. A confirmação final das funções depende de executar o app no AIDE, com NDK instalado e em uma rede Wi-Fi/Ethernet real.

## Logo

O logo está integrado como ícone launcher em todas as densidades Android e também aparece no topo da tela. O arquivo mestre está em `assets/rede_local_logo.png`.

## Restrições de segurança

- Cada execução de teste exige marcar a confirmação de que a rede é própria ou autorizada.
- O app só aceita IPv4 privado (RFC1918; também link-local 169.254/16) dentro da sub-rede da conexão Wi-Fi/Ethernet ativa. VPNs e redes móveis não são alvos de varredura.
- Descoberta limitada a no máximo 254 endereços, usando o bloco /24 que contém o IP local quando a rede for maior.
- Testes TCP de portas limitados a 128 portas por execução. A descoberta envia conexões TCP apenas às portas comuns listadas acima.
- Dispositivos podem não aparecer se firewall, isolamento de clientes Wi-Fi ou configuração do host bloquear sondagens.
- Use somente em redes e dispositivos próprios ou com autorização explícita.

## Abrir no AIDE

1. Extraia o ZIP e abra a pasta `RedeLocalAIDE` (a pasta raiz com `settings.gradle`) como projeto Gradle Android.
2. O ZIP inclui `libredelocal.so` para `arm64-v8a` e `armeabi-v7a`, para que o app possa carregar o JNI mesmo se o AIDE não executar `ndk-build`. O código-fonte C++ e a configuração Gradle/NDK também continuam no projeto; instale/habilite o NDK r23.1.7779620 no AIDE para recompilar o código nativo. O wrapper Gradle 7.5.1 usa Java 11–18; se o AIDE usar Java 21, selecione Java 17/11 ou use a versão Gradle suportada pela instalação.
3. Abra/sincronize o projeto e compile/executar. Se o app continuar mostrando “Biblioteca C++ ausente”, use **Clean Project** e **Rebuild** e confirme que o APK contém `lib/arm64-v8a/libredelocal.so` ou `lib/armeabi-v7a/libredelocal.so`.
4. No primeiro uso, conecte o aparelho a Wi-Fi ou Ethernet e toque em **Atualizar informações**. Marque a confirmação de autorização para habilitar ping/descoberta/testes de portas.

O projeto também inclui `gradlew` e `gradlew.bat` para compilar fora do AIDE: `./gradlew assembleDebug` (requer Android SDK e NDK configurados).

## Diagnóstico se o app não iniciar

Se a interface abrir, mas descoberta/portas estiverem indisponíveis, confira se o APK contém `lib/arm64-v8a/libredelocal.so` ou `lib/armeabi-v7a/libredelocal.so` dentro de `lib/`. O ZIP agora já leva essas bibliotecas em `app/src/main/jniLibs/`. Se o app ainda fechar ao tocar no ícone, copie a mensagem de erro do AIDE/Logcat para identificar o crash específico.

## Estrutura principal

- `app/src/main/java/org/manus/redelocal/MainActivity.java` — interface, informações de rede e teste ping.
- `app/src/main/cpp/native-lib.cpp` — descoberta local e sondagem TCP em C++.
- `app/src/main/cpp/Android.mk` / `Application.mk` — build NDK.
- `app/src/main/jniLibs/<abi>/libredelocal.so` — bibliotecas JNI pré-compiladas para ARM64 e ARM32.
- `app/build.gradle`, `settings.gradle`, `build.gradle` — projeto Gradle.

## Referências Android

- [Integração Gradle com ndk-build](https://developer.android.com/studio/projects/gradle-external-native-builds)
- [LinkProperties: endereços, rotas e DNS](https://developer.android.com/reference/android/net/LinkProperties)
- [InetAddress.isReachable](https://developer.android.com/reference/java/net/InetAddress#isReachable(int))
