#!/usr/bin/env bash
# Inicia el servidor del acompañante visual y devuelve la información de conexión
# Uso: start-server.sh [--project-dir <path>] [--host <bind-host>] [--url-host <display-host>] [--foreground] [--background]
#
# Inicia el servidor en un puerto alto aleatorio y devuelve JSON con la URL.
# Cada sesión obtiene su propio directorio para evitar conflictos.
#
# Opciones:
#   --project-dir <path>  Almacena los archivos de sesión en <path>/.visual-companion/sessions/
#                         en lugar de /tmp. Los archivos persisten después de detener el servidor.
#   --host <bind-host>    Host/interfaz a la que enlazarse (predeterminado: 127.0.0.1).
#                         Usa 0.0.0.0 en entornos remotos o en contenedores.
#   --url-host <host>     Nombre de host mostrado en el JSON de URL devuelto.
#   --foreground          Ejecuta el servidor en la terminal actual (sin segundo plano).
#   --background          Fuerza el modo en segundo plano (anula el primer plano automático de Codex).

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Analizar argumentos
PROJECT_DIR=""
FOREGROUND="false"
FORCE_BACKGROUND="false"
BIND_HOST="127.0.0.1"
URL_HOST=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --project-dir)
      PROJECT_DIR="$2"
      shift 2
      ;;
    --host)
      BIND_HOST="$2"
      shift 2
      ;;
    --url-host)
      URL_HOST="$2"
      shift 2
      ;;
    --foreground|--no-daemon)
      FOREGROUND="true"
      shift
      ;;
    --background|--daemon)
      FORCE_BACKGROUND="true"
      shift
      ;;
    *)
      echo "{\"error\": \"Argumento desconocido: $1\"}"
      exit 1
      ;;
  esac
done

if [[ -z "$URL_HOST" ]]; then
  if [[ "$BIND_HOST" == "127.0.0.1" || "$BIND_HOST" == "localhost" ]]; then
    URL_HOST="localhost"
  else
    URL_HOST="$BIND_HOST"
  fi
fi

# Algunos entornos eliminan procesos desacoplados o en segundo plano. Cambia automáticamente a primer plano cuando se detecte.
if [[ -n "${CODEX_CI:-}" && "$FOREGROUND" != "true" && "$FORCE_BACKGROUND" != "true" ]]; then
  FOREGROUND="true"
fi

# Windows/Git Bash elimina procesos en segundo plano lanzados con nohup. Cambia automáticamente a primer plano cuando se detecte.
if [[ "$FOREGROUND" != "true" && "$FORCE_BACKGROUND" != "true" ]]; then
  case "${OSTYPE:-}" in
    msys*|cygwin*|mingw*) FOREGROUND="true" ;;
  esac
  if [[ -n "${MSYSTEM:-}" ]]; then
    FOREGROUND="true"
  fi
fi

# Generar un directorio de sesión único
SESSION_ID="$$-$(date +%s)"

if [[ -n "$PROJECT_DIR" ]]; then
  SESSION_DIR="${PROJECT_DIR}/.visual-companion/sessions/${SESSION_ID}"
else
  SESSION_DIR="/tmp/visual-companion-${SESSION_ID}"
fi

STATE_DIR="${SESSION_DIR}/state"
PID_FILE="${STATE_DIR}/server.pid"
LOG_FILE="${STATE_DIR}/server.log"

# Crear un directorio de sesión nuevo con directorios hermanos para contenido y estado
mkdir -p "${SESSION_DIR}/content" "$STATE_DIR"

# Matar cualquier servidor existente
if [[ -f "$PID_FILE" ]]; then
  old_pid=$(cat "$PID_FILE")
  kill "$old_pid" 2>/dev/null
  rm -f "$PID_FILE"
fi

cd "$SCRIPT_DIR"

# Resolver el PID del harness (abuelo de este script).
# $PPID es el shell efímero que el harness creó para ejecutarnos: muere
# cuando este script termina. El propio harness es el padre de $PPID.
OWNER_PID="$(ps -o ppid= -p "$PPID" 2>/dev/null | tr -d ' ')"
if [[ -z "$OWNER_PID" || "$OWNER_PID" == "1" ]]; then
  OWNER_PID="$PPID"
fi

# Modo en primer plano para entornos que eliminan procesos desacoplados o en segundo plano.
if [[ "$FOREGROUND" == "true" ]]; then
  echo "$$" > "$PID_FILE"
  env BRAINSTORM_DIR="$SESSION_DIR" BRAINSTORM_HOST="$BIND_HOST" BRAINSTORM_URL_HOST="$URL_HOST" BRAINSTORM_OWNER_PID="$OWNER_PID" node server.cjs
  exit $?
fi

# Iniciar el servidor, capturando la salida en el archivo de log
# Usa nohup para sobrevivir al cierre del shell; disown para quitarlo de la tabla de trabajos
nohup env BRAINSTORM_DIR="$SESSION_DIR" BRAINSTORM_HOST="$BIND_HOST" BRAINSTORM_URL_HOST="$URL_HOST" BRAINSTORM_OWNER_PID="$OWNER_PID" node server.cjs > "$LOG_FILE" 2>&1 &
SERVER_PID=$!
disown "$SERVER_PID" 2>/dev/null
echo "$SERVER_PID" > "$PID_FILE"

# Esperar el mensaje server-started (revisando el archivo de log)
for i in {1..50}; do
  if grep -q "server-started" "$LOG_FILE" 2>/dev/null; then
    # Verificar que el servidor siga vivo tras una ventana breve (detecta eliminadores de procesos)
    alive="true"
    for _ in {1..20}; do
      if ! kill -0 "$SERVER_PID" 2>/dev/null; then
        alive="false"
        break
      fi
      sleep 0.1
    done
    if [[ "$alive" != "true" ]]; then
      echo "{\"error\": \"El servidor arrancó pero fue terminado. Reintenta en una terminal persistente con: $SCRIPT_DIR/start-server.sh${PROJECT_DIR:+ --project-dir $PROJECT_DIR} --host $BIND_HOST --url-host $URL_HOST --foreground\"}"
      exit 1
    fi
    grep "server-started" "$LOG_FILE" | head -1
    exit 0
  fi
  sleep 0.1
done

# Tiempo agotado: el servidor no arrancó
echo '{"error": "El servidor no consiguió arrancar en 5 segundos"}'
exit 1
