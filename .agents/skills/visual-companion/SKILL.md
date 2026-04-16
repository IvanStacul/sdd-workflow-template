---
name: visual-companion
description: "Acompañante visual basado en navegador para mostrar mockups, diagramas y opciones durante cualquier fase del workflow. Usar cuando el contenido se entiende mejor viéndolo que leyéndolo."
---

# Acompañante Visual

Acompañante visual basado en navegador para mostrar mockups, diagramas y opciones durante cualquier fase del workflow SDD (explore, design, o cualquier interacción que lo necesite).

## Context Load

Leer:

- `.agents/rules.md` para reglas generales del proyecto
- `.agents/personality.md` para tono y filosofía de comunicación

## Cuándo Usarlo

Decide por pregunta, no por sesión. La prueba es: **¿el usuario entendería esto mejor viéndolo que leyéndolo?**

**Usa el navegador** cuando el contenido en sí sea visual:

- **Mockups de UI** — wireframes, layouts, estructuras de navegación, diseños de componentes
- **Diagramas de arquitectura** — componentes del sistema, flujo de datos, mapas de relaciones
- **Comparaciones visuales lado a lado** — comparar dos layouts, dos esquemas de color, dos direcciones de diseño
- **Pulido de diseño** — cuando la pregunta trata sobre apariencia y sensación, espaciado o jerarquía visual
- **Relaciones espaciales** — máquinas de estados, diagramas de flujo, relaciones entre entidades representadas como diagramas

**Usa la terminal** cuando el contenido sea texto o tabular:

- **Preguntas de requisitos y alcance** — "¿qué significa X?", "¿qué funcionalidades están dentro del alcance?"
- **Opciones conceptuales A/B/C** — elegir entre enfoques descritos con palabras
- **Listas de compensaciones** — pros/contras, tablas comparativas
- **Decisiones técnicas** — diseño de API, modelado de datos, selección del enfoque de arquitectura
- **Preguntas de aclaración** — cualquier cosa cuya respuesta sean palabras, no una preferencia visual

Una pregunta *sobre* un tema de UI no es automáticamente una pregunta visual. "¿Qué tipo de asistente quieres?" es conceptual: usa la terminal. "¿Cuál de estos layouts de asistente se siente correcto?" es visual: usa el navegador.

## Ofrecer el acompañante

Cuando anticipes que las próximas preguntas implicarán contenido visual, ofrécelo una vez para obtener consentimiento:

> "Parte de lo que estamos trabajando podría ser más fácil de explicar si puedo mostrártelo en un navegador web. Puedo preparar mockups, diagramas, comparaciones y otros recursos visuales a medida que avanzamos. Esta función todavía es nueva y puede consumir muchos tokens. ¿Quieres probarla? (Requiere abrir una URL local)"

**Esta oferta DEBE ser su propio mensaje.** No la combines con preguntas de aclaración, resúmenes de contexto ni ningún otro contenido. Espera la respuesta del usuario antes de continuar. Si la rechaza, continúa solo en texto.

## Cómo Funciona

El servidor observa un directorio en busca de archivos HTML y sirve el más reciente al navegador. Escribes contenido HTML en `screen_dir`, el usuario lo ve en su navegador y puede hacer clic para seleccionar opciones. Las selecciones se registran en `state_dir/events`, que tú lees en tu siguiente turno.

**Fragmentos de contenido frente a documentos completos:** Si tu archivo HTML comienza con `<!DOCTYPE` o `<html`, el servidor lo sirve tal cual (solo inyecta el script auxiliar). En caso contrario, el servidor envuelve automáticamente tu contenido en la plantilla de marco, añadiendo la cabecera, el tema CSS, el indicador de selección y toda la infraestructura interactiva. **Escribe fragmentos de contenido por defecto.** Escribe documentos completos solo cuando necesites control total sobre la página.

## Iniciar una Sesión

```bash
# Iniciar servidor con persistencia (los mockups se guardan en el proyecto)
scripts/start-server.sh --project-dir /path/to/project

# Devuelve: {"type":"server-started","port":52341,"url":"http://localhost:52341",
#            "screen_dir":"/path/to/project/.visual-companion/sessions/12345-1706000000/content",
#            "state_dir":"/path/to/project/.visual-companion/sessions/12345-1706000000/state"}
```

Guarda `screen_dir` y `state_dir` de la respuesta. Indica al usuario que abra la URL.

**Encontrar la información de conexión:** El servidor escribe su JSON de arranque en `$STATE_DIR/server-info`. Si iniciaste el servidor en segundo plano y no capturaste stdout, lee ese archivo para obtener la URL y el puerto. Cuando uses `--project-dir`, revisa `<project>/.visual-companion/sessions/` para encontrar el directorio de sesión.

**Nota:** Pasa la raíz del proyecto como `--project-dir` para que los mockups persistan en `.visual-companion/sessions/` y sobrevivan a reinicios del servidor. Sin ello, los archivos van a `/tmp` y se limpian. Recuérdale al usuario que añada `.visual-companion/` a `.gitignore` si todavía no está ahí.

**Iniciar el servidor por plataforma:**

**Claude Code (macOS / Linux):**
```bash
# El modo predeterminado funciona: el script envía el servidor a segundo plano por sí mismo
scripts/start-server.sh --project-dir /path/to/project
```

**Claude Code (Windows):**
```bash
# Windows detecta esto automáticamente y usa el modo en primer plano, que bloquea la llamada a la herramienta.
# Usa run_in_background: true en la llamada de la herramienta Bash para que el servidor sobreviva
# entre turnos de la conversación.
scripts/start-server.sh --project-dir /path/to/project
```
Al llamar a esto mediante la herramienta Bash, establece `run_in_background: true`. Después lee `$STATE_DIR/server-info` en el siguiente turno para obtener la URL y el puerto.

**Codex:**
```bash
# Codex elimina procesos en segundo plano. El script detecta automáticamente CODEX_CI y
# cambia al modo en primer plano. Ejecútalo normalmente; no se necesitan flags extra.
scripts/start-server.sh --project-dir /path/to/project
```

**Gemini CLI:**
```bash
# Usa --foreground y establece is_background: true en la llamada de tu herramienta shell
# para que el proceso sobreviva entre turnos
scripts/start-server.sh --project-dir /path/to/project --foreground
```

**Otros entornos:** El servidor debe seguir ejecutándose en segundo plano entre turnos de conversación. Si tu entorno elimina procesos desacoplados, usa `--foreground` e inicia el comando con el mecanismo de ejecución en segundo plano de tu plataforma.

Si la URL no es accesible desde tu navegador (algo común en configuraciones remotas o en contenedores), enlaza un host que no sea loopback:

```bash
scripts/start-server.sh \
  --project-dir /path/to/project \
  --host 0.0.0.0 \
  --url-host localhost
```

Usa `--url-host` para controlar qué nombre de host se imprime en el JSON de URL devuelto.

## El Bucle

1. **Comprueba que el servidor sigue activo**, luego **escribe HTML** en un archivo nuevo dentro de `screen_dir`:
  - Antes de cada escritura, comprueba que exista `$STATE_DIR/server-info`. Si no existe (o existe `$STATE_DIR/server-stopped`), el servidor se ha detenido: reinícialo con `start-server.sh` antes de continuar. El servidor sale automáticamente tras 30 minutos de inactividad.
  - Usa nombres de archivo semánticos: `platform.html`, `visual-style.html`, `layout.html`
  - **Nunca reutilices nombres de archivo**: cada pantalla recibe un archivo nuevo
  - Usa la herramienta Write; **nunca uses cat/heredoc** (mete ruido en la terminal)
  - El servidor sirve automáticamente el archivo más reciente

2. **Indícale al usuario qué debe esperar y termina tu turno:**
  - Recuérdale la URL (en cada paso, no solo en el primero)
  - Da un breve resumen en texto de lo que aparece en pantalla (por ejemplo, "Mostrando 3 opciones de layout para la página de inicio")
  - Pídele que responda en la terminal: "Échale un vistazo y dime qué te parece. Haz clic para seleccionar una opción si quieres."

3. **En tu siguiente turno**, después de que el usuario responda en la terminal:
  - Lee `$STATE_DIR/events` si existe; esto contiene las interacciones del usuario en el navegador (clics, selecciones) como líneas JSON
  - Combínalo con el texto del usuario en la terminal para obtener la imagen completa
  - El mensaje en la terminal es la retroalimentación principal; `state_dir/events` aporta datos estructurados de interacción

4. **Itera o avanza**: si la retroalimentación cambia la pantalla actual, escribe un archivo nuevo (por ejemplo, `layout-v2.html`). Avanza a la siguiente pregunta solo cuando el paso actual esté validado.

5. **Descarga al volver a la terminal**: cuando el siguiente paso no necesite el navegador (por ejemplo, una pregunta de aclaración o una discusión de compensaciones), envía una pantalla de espera para limpiar el contenido obsoleto:

   ```html
   <!-- filename: waiting.html (or waiting-2.html, etc.) -->
   <div style="display:flex;align-items:center;justify-content:center;min-height:60vh">
     <p class="subtitle">Continuando en la terminal...</p>
   </div>
   ```

  Esto evita que el usuario se quede mirando una elección ya resuelta mientras la conversación ya avanzó. Cuando surja la siguiente pregunta visual, envía un nuevo archivo de contenido como de costumbre.

6. Repite hasta terminar.

## Escribir Fragmentos de Contenido

Escribe solo el contenido que va dentro de la página. El servidor lo envuelve automáticamente en la plantilla de marco (cabecera, CSS del tema, indicador de selección y toda la infraestructura interactiva).

**Ejemplo mínimo:**

```html
<h2>¿Qué layout funciona mejor?</h2>
<p class="subtitle">Ten en cuenta la legibilidad y la jerarquía visual</p>

<div class="options">
  <div class="option" data-choice="a" onclick="toggleSelect(this)">
    <div class="letter">A</div>
    <div class="content">
      <h3>Columna Única</h3>
      <p>Experiencia de lectura limpia y enfocada</p>
    </div>
  </div>
  <div class="option" data-choice="b" onclick="toggleSelect(this)">
    <div class="letter">B</div>
    <div class="content">
      <h3>Dos Columnas</h3>
      <p>Navegación lateral con contenido principal</p>
    </div>
  </div>
</div>
```

Eso es todo. No hace falta `<html>`, ni CSS, ni etiquetas `<script>`. El servidor proporciona todo eso.

## Clases CSS Disponibles

La plantilla de marco proporciona estas clases CSS para tu contenido:

### Opciones (elecciones A/B/C)

```html
<div class="options">
  <div class="option" data-choice="a" onclick="toggleSelect(this)">
    <div class="letter">A</div>
    <div class="content">
      <h3>Title</h3>
      <p>Description</p>
    </div>
  </div>
</div>
```

**Selección múltiple:** Añade `data-multiselect` al contenedor para permitir que los usuarios seleccionen varias opciones. Cada clic alterna el elemento. La barra indicadora muestra la cantidad.

```html
<div class="options" data-multiselect>
  <!-- mismo marcado de opción: los usuarios pueden seleccionar o deseleccionar varias -->
</div>
```

### Tarjetas (diseños visuales)

```html
<div class="cards">
  <div class="card" data-choice="design1" onclick="toggleSelect(this)">
    <div class="card-image"><!-- mockup content --></div>
    <div class="card-body">
      <h3>Nombre</h3>
      <p>Descripción</p>
    </div>
  </div>
</div>
```

### Contenedor de mockup

```html
<div class="mockup">
  <div class="mockup-header">Vista previa: Layout del panel</div>
  <div class="mockup-body"><!-- tu HTML de mockup --></div>
</div>
```

### Vista dividida (lado a lado)

```html
<div class="split">
  <div class="mockup"><!-- izquierda --></div>
  <div class="mockup"><!-- derecha --></div>
</div>
```

### Pros/Contras

```html
<div class="pros-cons">
  <div class="pros"><h4>Pros</h4><ul><li>Beneficio</li></ul></div>
  <div class="cons"><h4>Contras</h4><ul><li>Desventaja</li></ul></div>
</div>
```

### Elementos de mockup (bloques de construcción de wireframes)

```html
<div class="mock-nav">Logo | Inicio | Acerca de | Contacto</div>
<div style="display: flex;">
  <div class="mock-sidebar">Navegación</div>
  <div class="mock-content">Área de contenido principal</div>
</div>
<button class="mock-button">Botón de Acción</button>
<input class="mock-input" placeholder="Campo de entrada">
<div class="placeholder">Área de marcador de posición</div>
```

### Tipografía y secciones

- `h2` — título de página
- `h3` — encabezado de sección
- `.subtitle` — texto secundario bajo el título
- `.section` — bloque de contenido con margen inferior
- `.label` — texto de etiqueta pequeño en mayúsculas

## Formato de Eventos del Navegador

Cuando el usuario hace clic en opciones del navegador, sus interacciones se registran en `$STATE_DIR/events` (un objeto JSON por línea). El archivo se limpia automáticamente cuando envías una pantalla nueva.

```jsonl
{"type":"click","choice":"a","text":"Option A - Simple Layout","timestamp":1706000101}
{"type":"click","choice":"c","text":"Option C - Complex Grid","timestamp":1706000108}
{"type":"click","choice":"b","text":"Option B - Hybrid","timestamp":1706000115}
```

El flujo completo de eventos muestra la ruta de exploración del usuario: puede hacer clic en varias opciones antes de decidirse. El último evento `choice` suele ser la selección final, pero el patrón de clics puede revelar dudas o preferencias sobre las que merece la pena preguntar.

Si `$STATE_DIR/events` no existe, el usuario no interactuó con el navegador: usa solo su texto en la terminal.

## Consejos de Diseño

- **Ajusta la fidelidad a la pregunta** — wireframes para layout, pulido para preguntas sobre pulido
- **Explica la pregunta en cada página** — "¿Qué layout se siente más profesional?" y no solo "Elige uno"
- **Itera antes de avanzar** — si la retroalimentación cambia la pantalla actual, escribe una versión nueva
- **Máximo 2-4 opciones** por pantalla
- **Usa contenido real cuando importe** — para un portafolio de fotografía, usa imágenes reales (Unsplash). El contenido de marcador de posición oculta problemas de diseño.
- **Mantén los mockups simples** — céntrate en layout y estructura, no en diseño perfecto al píxel

## Nombres de Archivo

- Usa nombres semánticos: `platform.html`, `visual-style.html`, `layout.html`
- Nunca reutilices nombres de archivo: cada pantalla debe ser un archivo nuevo
- Para iteraciones: añade un sufijo de versión como `layout-v2.html`, `layout-v3.html`
- El servidor sirve el archivo más reciente según la hora de modificación

## Limpieza

```bash
scripts/stop-server.sh $SESSION_DIR
```

Si la sesión usó `--project-dir`, los archivos de mockup persisten en `.visual-companion/sessions/` para referencia posterior. Solo las sesiones en `/tmp` se eliminan al detenerse.

## Referencia

- Plantilla de marco (referencia CSS): `scripts/frame-template.html`
- Script auxiliar (lado del cliente): `scripts/helper.js`
