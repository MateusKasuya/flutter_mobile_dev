#!/usr/bin/env bash
#
# Roda os testes do projeto. Não há CI: este script é o "botão" manual.
#
# Uso:
#   ./testar.sh            analyze + testes de unidade/widget (rápido, sem device)
#   ./testar.sh device     o acima + integration tests em emulador/aparelho
#   ./testar.sh homolog    E2E real contra homologação (pede as credenciais)
#   ./testar.sh tudo       tudo acima
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

case "$MODO" in
  rapido)  rapido ;;
  device)  rapido; device_tests ;;
  homolog) homolog ;;
  tudo)    rapido; device_tests; homolog ;;
  *)
    vermelho "modo desconhecido: $MODO (use: device | homolog | tudo, ou nada)"
    exit 1
    ;;
esac

verde ""
verde "✓ concluído"
