# opencode-config

Setup one-shot para Arch Linux: instala **Ollama** (con demón de sistema) + **OpenCode**, descarga el modelo `srchmnmichael/Qwen3.8-Uncensored:q4_K_M` y aplica la config.

## Uso

```bash
git clone --depth 1 git@github.com:AZIT0/opencode-config.git
bash opencode-config/setup-linux.sh   # pide la clave de sudo
```

O desde cero en cualquier PC con Arch:

```bash
mkdir -p /tmp/oc && cd /tmp/oc
curl -LfsS https://raw.githubusercontent.com/AZIT0/opencode-config/main/setup-linux.sh -o setup-linux.sh
bash setup-linux.sh
```

## Qué hace el script

1. Instala Ollama y OpenCode con `pacman` (idempotente).
2. Arranca Ollama como servicio de sistema (`systemctl enable/start ollama`), listo para arrancar con el boot.
3. Descarga el modelo si no está (`ollama pull`).
4. Escribe `~/.config/opencode/opencode.json` (límites de contexto 32k / salida 4k + compaction automática).

Verificar después:

```bash
systemctl status ollama
ollama list
opencode --version
```

## Notas

- El modelo corre **local** en `localhost:11434`. Si querés que otro PC use este Ollama por red, agregá en `/etc/systemd/system/ollama.service.d/override.conf`:

  ```ini
  [Service]
  Environment="OLLAMA_HOST=0.0.0.0"
  ```

  y cambiá el `baseURL` del provider en el `opencode.json` de la otra máquina.
