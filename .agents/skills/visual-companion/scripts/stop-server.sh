#!/usr/bin/env bash
# Detiene el servidor del acompañante visual y limpia
# Uso: stop-server.sh <session_dir>
#
# Mata el proceso del servidor. Solo elimina el directorio de sesión si está
# bajo /tmp (efímero). Los directorios persistentes (.visual-companion/) se
# conservan para que los mockups puedan revisarse más tarde.

SESSION_DIR="$1"

if [[ -z "$SESSION_DIR" ]]; then
  echo '{"error": "Uso: stop-server.sh <session_dir>"}'
  exit 1
fi

STATE_DIR="${SESSION_DIR}/state"
PID_FILE="${STATE_DIR}/server.pid"

if [[ -f "$PID_FILE" ]]; then
  pid=$(cat "$PID_FILE")

  # Intentar detener con elegancia; si sigue vivo, recurrir a la fuerza
  kill "$pid" 2>/dev/null || true

  # Esperar un cierre elegante (hasta ~2 s)
  for i in {1..20}; do
    if ! kill -0 "$pid" 2>/dev/null; then
      break
    fi
    sleep 0.1
  done

  # Si sigue ejecutándose, escalar a SIGKILL
  if kill -0 "$pid" 2>/dev/null; then
    kill -9 "$pid" 2>/dev/null || true

    # Darle a SIGKILL un momento para surtir efecto
    sleep 0.1
  fi

  if kill -0 "$pid" 2>/dev/null; then
    echo '{"status": "failed", "error": "el proceso sigue en ejecución"}'
    exit 1
  fi

  rm -f "$PID_FILE" "${STATE_DIR}/server.log"

  # Solo eliminar directorios efímeros de /tmp
  if [[ "$SESSION_DIR" == /tmp/* ]]; then
    rm -rf "$SESSION_DIR"
  fi

  echo '{"status": "stopped"}'
else
  echo '{"status": "not_running"}'
fi
