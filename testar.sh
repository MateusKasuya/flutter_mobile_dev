#!/usr/bin/env bash
#
# Roda os testes do projeto. Não há CI: este script é o "botão" manual.
#
# Uso:
#   ./testar.sh            analyze + testes de unidade/widget (rápido, sem device)
#   ./testar.sh device     o acima + integration tests em emulador/aparelho
#   ./testar.sh homolog    E2E real contra homologação (pede as credenciais)
#   ./testar.sh testlab    integration tests em aparelhos do Firebase Test Lab
#   ./testar.sh tudo       rápido + device + homolog
#
# O 2º argumento força um device específico, ex. o simulador iOS:
#   ./testar.sh device 212A55AD-7896-4281-8623-9F53611C4767
#
# No modo device, se nenhum aparelho estiver conectado o script sobe o
# primeiro emulador Android disponível e espera o boot terminar.

set -euo pipefail
cd "$(dirname "$0")"

MODO="${1:-rapido}"
DEVICE_ARG="${2:-}"

ADB="$HOME/Library/Android/sdk/platform-tools/adb"
EMULATOR="$HOME/Library/Android/sdk/emulator/emulator"

vermelho() { printf '\033[31m%s\033[0m\n' "$*"; }
verde()    { printf '\033[32m%s\033[0m\n' "$*"; }
titulo()   { printf '\n\033[1m== %s ==\033[0m\n' "$*"; }

rapido() {
  titulo "flutter analyze"
  flutter analyze
  titulo "testes de unidade/widget (test/)"
  flutter test
}

# Define DEVICE: usa o 2º argumento se veio, senão o primeiro Android
# conectado, senão sobe um emulador e espera o boot.
garantir_device() {
  if [[ -n "$DEVICE_ARG" ]]; then
    DEVICE="$DEVICE_ARG"
    return
  fi

  DEVICE="$("$ADB" devices | awk 'NR>1 && $2=="device" {print $1; exit}')"
  if [[ -n "$DEVICE" ]]; then
    return
  fi

  local avd
  avd="$("$EMULATOR" -list-avds | head -1)"
  if [[ -z "$avd" ]]; then
    vermelho "Nenhum device conectado e nenhum AVD criado."
    vermelho "Crie um em Android Studio > Device Manager e rode de novo."
    exit 1
  fi

  titulo "subindo o emulador $avd (primeira vez demora ~1 min)"
  "$EMULATOR" -avd "$avd" >/dev/null 2>&1 &
  "$ADB" wait-for-device
  until [[ "$("$ADB" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" == "1" ]]; do
    sleep 2
  done
  DEVICE="$("$ADB" devices | awk 'NR>1 && $2=="device" {print $1; exit}')"
}

device_tests() {
  garantir_device
  titulo "integration tests em $DEVICE"
  # Roda os 3 arquivos de integration_test/; o E2E de homologação se
  # auto-pula quando não recebe credenciais por dart-define.
  flutter test integration_test -d "$DEVICE"
}

homolog() {
  garantir_device
  # Credenciais por variável de ambiente (E2E_CPF=... ./testar.sh homolog)
  # ou digitadas na hora — nunca ficam gravadas em arquivo nem no histórico
  # do git. read -s não ecoa a senha no terminal.
  local cpf="${E2E_CPF:-}" senha="${E2E_SENHA:-}" placa="${E2E_PLACA:-}"
  [[ -z "$cpf" ]] && read -r -p "CPF de homologação: " cpf
  [[ -z "$senha" ]] && { read -r -s -p "Senha: " senha; echo; }
  [[ -z "$placa" ]] && read -r -p "Placa para busca (opcional, Enter pula): " placa

  titulo "E2E contra homologação em $DEVICE"
  flutter test integration_test/e2e_homolog_test.dart -d "$DEVICE" \
    --dart-define=E2E_CPF="$cpf" \
    --dart-define=E2E_SENHA="$senha" \
    ${placa:+--dart-define=E2E_PLACA="$placa"}
}

testlab() {
  command -v gcloud >/dev/null 2>&1 || {
    vermelho "gcloud não instalado: brew install --cask google-cloud-sdk"
    exit 1
  }

  # Confirma conta/projeto ANTES de qualquer coisa — evita enviar os testes
  # para um projeto gcloud de outro contexto por engano.
  local projeto conta resposta
  projeto="$(gcloud config get-value project 2>/dev/null || true)"
  conta="$(gcloud config get-value account 2>/dev/null || true)"
  if [[ -z "$projeto" || "$projeto" == "(unset)" ]]; then
    vermelho "Nenhum projeto gcloud configurado."
    vermelho "Rode: gcloud auth login && gcloud config set project <ID_DO_PROJETO_FIREBASE>"
    exit 1
  fi
  titulo "Firebase Test Lab"
  echo "conta:   $conta"
  echo "projeto: $projeto"
  read -r -p "Enviar os testes para ESTE projeto? [s/N] " resposta
  [[ "$resposta" == "s" || "$resposta" == "S" ]] || { vermelho "abortado"; exit 1; }

  # O gradlew não acha o Java sozinho; usa o JDK embutido do Android Studio.
  export JAVA_HOME="${JAVA_HOME:-/Applications/Android Studio.app/Contents/jbr/Contents/Home}"
  local alvo
  alvo="$(pwd)/integration_test/all_tests.dart"

  titulo "build dos APKs (app + instrumentação)"
  (cd android && ./gradlew app:assembleDebug -Ptarget="$alvo" app:assembleDebugAndroidTest)

  # Matriz de aparelhos. Sobrescreva com a variável TESTLAB_DEVICES, ex.:
  #   TESTLAB_DEVICES="--device model=a15,version=34 --device model=husky,version=34" ./testar.sh testlab
  # Modelos disponíveis: gcloud firebase test android models list
  local devices="${TESTLAB_DEVICES:---device model=MediumPhone.arm,version=34,locale=pt_BR,orientation=portrait}"

  titulo "enviando para o Test Lab (resultado também no console do Firebase)"
  # $devices sem aspas de propósito: contém múltiplas flags --device.
  gcloud firebase test android run \
    --type instrumentation \
    --app build/app/outputs/apk/debug/app-debug.apk \
    --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk \
    $devices \
    --timeout 10m
}

case "$MODO" in
  rapido)  rapido ;;
  device)  rapido; device_tests ;;
  homolog) homolog ;;
  testlab) testlab ;;
  tudo)    rapido; device_tests; homolog ;;
  *)
    vermelho "modo desconhecido: $MODO (use: device | homolog | testlab | tudo, ou nada)"
    exit 1
    ;;
esac

verde ""
verde "✓ concluído"
