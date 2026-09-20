#!/usr/bin/env bash
set -euo pipefail

MODEL="srchmnmichael/Qwen3.8-Uncensored:q4_K_M"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
OLLAMA_URL="http://localhost:11434/api/version"

echo "=== 1/3 Ollama + demón de sistema ==="
if ! command -v ollama >/dev/null 2>&1; then
  sudo pacman -S --needed ollama
fi

# Habilitar el servicio para que arranque con el sistema (el paquete ya lo hace en Arch; redundancia inofensiva)
sudo systemctl enable ollama 2>/dev/null || true

# Matar cualquier "ollama serve" manual para que el puerto 11434 lo gobierne systemd
pkill -x ollama 2>/dev/null || true

if ! systemctl is-active --quiet ollama; then
  sudo systemctl start ollama
fi

reintentos=0
until curl -fsS "$OLLAMA_URL" >/dev/null 2>&1; do
  reintentos=$((reintentos+1))
  [ "$reintentos" -ge 15 ] && break
  sleep 2
done

if ! systemctl is-active --quiet ollama; then
  echo "ERROR: Ollama no quedó activo. Revisen: journalctl -u ollama"
  exit 1
fi
echo "Servicio ollama: active=$(systemctl is-active ollama) enabled=$(systemctl is-enabled ollama)"

echo "Comprobando modelo $MODEL ..."
ollama pull "$MODEL"

echo "=== 2/3 OpenCode ==="
if ! command -v opencode >/dev/null 2>&1; then
  sudo pacman -S --needed opencode
fi
echo "OpenCode: $(opencode --version)"

echo "=== 3/3 Configuración ==="
mkdir -p "$CONFIG_DIR"
cat > "$CONFIG_DIR/opencode.json" <<'JSON'
{
  "$schema": "https://opencode.ai/config.json",
  "providers": {
    "ollama": {
      "models": {
        "srchmnmichael/Qwen3.8-Uncensored:q4_K_M": {
          "limit": {
            "context": 32768,
            "output": 4096
          }
        }
      }
    }
  },
  "compaction": {
    "auto": true,
    "keep": { "tokens": 15000 },
    "buffer": 2000
  }
}
JSON
echo "Config escrita en: $CONFIG_DIR/opencode.json"

echo ""
echo "✅ Todo listo."
echo "   - Ollama corre como demón de sistema (arranca con el boot)."
echo "   - Verificar: systemctl status ollama  /  journalctl -u ollama"
