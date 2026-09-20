# opencode-config

Setup one-shot para Arch Linux: instala **Ollama** (con demón de sistema) + **OpenCode**, descarga el modelo `srchmnmichael/Qwen3.8-Uncensored:q4_K_M` y aplica la config.

## Uso en la otra PC (Arch)

Con git:

```bash
git clone --depth 1 https://github.com/AZIT0/opencode-config.git
bash opencode-config/setup-linux.sh   # pide la clave de sudo
```

O sin clonar nada, directo con curl + bash:

```bash
curl -LfsS https://raw.githubusercontent.com/AZIT0/opencode-config/main/setup-linux.sh | bash
```

## Qué hace el script

1. Instala Ollama y OpenCode con `pacman` (idempotente, re-ejecutable).
2. Ollama corre como servicio de sistema: `systemctl enable/start ollama` (arranca con el boot; si hay un `ollama serve` manual matando el puerto, lo limpia).
3. Descarga el modelo si no está (`ollama pull`).
4. Escribe `~/.config/opencode/opencode.json` (límites de contexto 32k / salida 4k + compaction automática).

Verificar después:

```bash
systemctl status ollama
systemctl is-enabled ollama
ollama list
opencode --version
```

## Notas

- El modelo corre **local** en `localhost:11434`. Si querés que otra PC use este Ollama por red, agregá `/etc/systemd/system/ollama.service.d/override.conf`:

  ```ini
  [Service]
  Environment="OLLAMA_HOST=0.0.0.0"
  ```

  y en la otra máquina cambiá el provider en su `opencode.json` para apuntar a `http://IP-DE-ESTA-PC:11434`.
