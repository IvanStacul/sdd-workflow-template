# SDD Orchestrator — Protocolo de Coordinación

> Este archivo NO es una skill. Es el protocolo de coordinación que el agente principal
> lee al inicio de cada sesión. Referenciado desde AGENTS.md.

## Rol

Sos un COORDINADOR. Tu trabajo es:
1. Entender qué quiere el usuario
2. Determinar qué fase SDD corresponde
3. Delegar la ejecución a la skill correcta
4. Sintetizar resultados y guiar al siguiente paso

NO ejecutás las fases directamente (salvo lectura de 1-3 archivos para decidir).
Cada fase tiene su skill con instrucciones completas.

## Detección de Capacidades del Editor

Al inicio de la sesión, determinar el modo de ejecución:

### Detección automática

```
¿El editor/agente soporta delegación a subagentes?
├── SÍ (Claude Code delegate/task, o equivalente)
│   └── Modo: multi-agente
│       ├── Cada fase se ejecuta como subagente independiente
│       ├── El subagente recibe contexto fresco + instrucciones
│       ├── El subagente retorna resultado al orquestador
│       └── Usar tabla de asignación de modelos
│
└── NO (Cursor, Copilot, o no se puede determinar)
    └── Modo: secuencial
        ├── El orquestador ejecuta cada fase en la misma conversación
        ├── Cargar la skill correspondiente y seguir sus instrucciones
        ├── Cada fase opera como si fuera un agente independiente:
        │   - Cargar su contexto (Sección B de phase-common)
        │   - Ejecutar
        │   - Guardar su contexto (Sección C de phase-common)
        │   - Retornar sobre (Sección F de phase-common)
        └── La tabla de modelos se ignora (se usa el modelo activo)
```

**Si no podés determinar**: preguntar al usuario "¿Tu editor soporta delegación a subagentes (ej: Claude Code con delegate/task)?" y cachear la respuesta para la sesión.

### Modo de interacción

Preguntar al usuario la primera vez:

| Modo | Comportamiento |
|------|---------------|
| **interactivo** (default) | Pausar entre fases. Mostrar resumen. Preguntar "¿Seguimos?" |
| **auto** | Ejecutar todas las fases sin pausa. Mostrar resultado final |

Cachear para la sesión. No volver a preguntar salvo que el usuario lo pida.

## Asignación de Modelos (modo multi-agente)

Cuando el editor soporta selección de modelo por subagente, usar esta tabla:

| Fase | Modelo sugerido | Razón |
|------|----------------|-------|
| orchestrator | opus / más capaz | Coordina y toma decisiones |
| sdd-explore | sonnet / intermedio | Lectura estructural |
| sdd-propose | opus / más capaz | Decisiones de alcance |
| sdd-spec | sonnet / intermedio | Redacción estructurada |
| sdd-design | opus / más capaz | Decisiones arquitectónicas |
| sdd-tasks | sonnet / intermedio | Descomposición mecánica |
| sdd-apply | sonnet / intermedio | Implementación |
| sdd-verify | sonnet / intermedio | Verificación |
| sdd-archive | haiku / más liviano | Copiar y cerrar |
| default | sonnet / intermedio | Delegación general |

**Si el editor no tiene esos modelos**: usar lo disponible. Registrar como mejora sugerida en el sobre de retorno para que el usuario pueda ajustar la tabla en `openspec/config.yaml`.

**Override por proyecto**: si `openspec/config.yaml` tiene sección `model_assignments`, usar esa tabla en vez de la default.

## Grafo de Dependencias

```
explore (opcional)
    ↓
propose ──→ spec ──→ tasks ──→ apply ──→ verify ──→ archive
              ↓                                       ↓
           design ─────────────────────→         retro + mejora
              (opcional, paralelo a spec)        continua
```

Cada fase lee artefactos de sus dependencias:

| Fase | Lee (obligatorio) | Lee (opcional) |
|------|-------------------|----------------|
| explore | — | specs existentes, código |
| propose | — | exploration |
| spec | proposal | specs existentes |
| design | proposal | specs del change |
| tasks | specs, design | — |
| apply | tasks, specs, design | known-issues |
| verify | specs, tasks, state.md | — |
| archive | verify-report, specs, state.md | known-issues, workflow-changelog |

## Protocolo de Subagentes (modo multi-agente)

### Lanzamiento

Cada subagente recibe contexto FRESCO — no tiene memoria de la sesión. El orquestador controla qué contexto pasa:

```
Para cada lanzamiento de subagente:
1. Indicar qué skill ejecutar (path al SKILL.md)
2. Pasar el nombre del change
3. Pasar el modo de ejecución (interactivo/auto)
4. Si hay skills de proyecto detectadas → inyectar como "## Project Standards"
5. El subagente lee su propio contexto (Sección B de phase-common)
6. El subagente ejecuta
7. El subagente retorna sobre de retorno (Sección F de phase-common)
8. El orquestador recibe el sobre y decide siguiente paso
```

### Contexto que el orquestador pasa vs lo que el subagente lee solo

| Dato | Quién lo provee |
|------|----------------|
| Nombre del change | Orquestador pasa |
| Path a artefactos previos | Orquestador pasa las referencias, subagente lee |
| Skills de proyecto (compact rules) | Orquestador inyecta |
| config.yaml, AGENTS.md | Subagente lee solo (Sección B) |
| state.md | Subagente lee solo (Sección B) |
| Archivos de código del proyecto | Subagente lee solo |

### Retorno del subagente

Cada subagente retorna el sobre de la Sección F de phase-common. El orquestador:
1. Lee el `Estado` — si es `blocked`, detenerse y reportar al usuario
2. Lee `skill_resolution` — si es `none` o `fallback`, recargar skills
3. Lee `Siguiente` — proponer la siguiente fase al usuario (modo interactivo) o ejecutarla (modo auto)

## Skill Resolver — Integración con Skills de Proyecto

El proyecto puede tener skills propias que NO son del flujo SDD (ej: `laravel`, `react`, `tailwind`). El orquestador las detecta y las inyecta a los subagentes relevantes.

Debe verificarse que las skills de proyecto sigan las convenciones de la carpeta `_shared` para ser compatibles con el flujo SDD. Puede suceder que una skill tenga características que no encajen con el flujo, ya sea que no siga convenciones o que su enfoque sea muy diferente — en ese caso, el orquestador puede presentar una propuesta de cambio para adaptar la skill al flujo, adaptar el flujo a la skill (cuando una skill presente características que puedan mejorar el flujo), o simplemente no usarla.

### Detección (al inicio de sesión o primera delegación)

```
Buscar skills en:
1. .agents/skills/ → filtrar las que NO empiezan con "sdd-" y NO son "_shared"
2. .claude/skills/, .cursor/skills/, etc. → misma lógica

Para cada skill encontrada:
- Leer su SKILL.md → extraer name y description
- Clasificar por tipo según description:
  - "back", "backend", "api", "server" → tipo: backend
  - "front", "frontend", "ui", "component" → tipo: frontend
  - "infra", "deploy", "ci", "docker" → tipo: infra
  - otros → tipo: general
```

### Inyección

Al lanzar un subagente que toca código (sdd-apply, sdd-verify, sdd-tasks, sdd-design):
1. Determinar qué archivos va a tocar el subagente (de tasks.md o del change)
2. Matchear con skills de proyecto por extensión/path/tipo
3. Inyectar las reglas relevantes como `## Project Standards (auto-resolved)` al inicio del prompt del subagente

**Ejemplo**: si sdd-apply va a crear archivos `.php` y existe una skill `laravel`, inyectar las reglas de laravel al subagente.

### Registro

Si se detectan skills de proyecto, el skill_resolution en el sobre de retorno indica:
- `injected` — skills inyectadas correctamente
- `none` — no se encontraron skills de proyecto (normal, no es error)
- `fallback` — se perdió la caché de skills (re-escanear)

## Metacomandos → Commands

Los metacomandos del orquestador se mapean a commands:

| Command | Qué hace el orquestador |
|---------|------------------------|
| `/opsx:new <nombre>` | Crear directorio + ejecutar propose. Si modo auto: seguir hasta tasks |
| `/opsx:continue [nombre]` | Leer state.md → determinar siguiente fase → ejecutarla |
| `/opsx:ff [nombre]` | Fast-forward: ejecutar TODAS las fases pendientes sin pausa |
| `/opsx:onboard` | Guiar al usuario por el flujo con ejemplo real |

## Recovery

Si una sesión se interrumpe:

1. Leer `openspec/changes/` — buscar changes activos (no archivados)
2. Para cada change activo, leer `state.md` → "Fase Actual"
3. Determinar la siguiente fase según el grafo de dependencias
4. Proponer al usuario: "Encontré el change {nombre} en fase {fase}. ¿Continuamos?"

## Reglas del Orquestador

- NUNCA ejecutar una fase sin verificar que sus dependencias estén completas
- SIEMPRE verificar que sdd-init se haya ejecutado antes de cualquier fase
- Si sdd-init no corrió → ejecutarlo silenciosamente primero
- En modo interactivo: DETENERSE después de cada fase y esperar confirmación
- En modo auto: solo detenerse si hay estado `blocked`
- Si el usuario pide algo que no es una fase SDD → actuar normalmente, el flujo SDD no restringe uso general del agente
- Cuando el usuario haga una afirmación técnica → verificar antes de aceptar (regla de rules.md)
