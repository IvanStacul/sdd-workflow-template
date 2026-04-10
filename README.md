# SDD Workflow Template

Template de flujo **Spec-Driven Development** para proyectos con agentes de IA.

## ¿Qué es?

Un sistema de especificaciones, documentación y coordinación de agentes de IA basado en archivos Markdown. Todo vive en el repo — no hay base de datos externa ni CLI propietario.

## Estructura

```
.agents/
├── orchestrator.md           ← Protocolo de coordinación (siempre activo)
├── personality.md            ← Personalidad y tono del agente
├── rules.md                  ← Reglas generales del proyecto
├── skills/
│   ├── _shared/              ← Convenciones compartidas (no es una skill)
│   │   ├── phase-common.md
│   │   ├── openspec-convention.md
│   │   ├── abstraction-guide.md
│   │   └── skill-resolver.md
│   ├── sdd-init/             ← Inicializar el flujo
│   ├── sdd-explore/          ← Investigar antes de proponer
│   ├── sdd-propose/          ← Crear propuesta de cambio
│   ├── sdd-spec/             ← Escribir especificaciones
│   ├── sdd-design/           ← Diseño técnico
│   ├── sdd-tasks/            ← Plan de tareas
│   ├── sdd-apply/            ← Implementar
│   ├── sdd-verify/           ← Verificar vs specs
│   ├── sdd-archive/          ← Archivar + retro + mejora continua
│   ├── sdd-patch/            ← Cambios pequeños documentados
│   ├── sdd-onboard/          ← Tutorial interactivo
│   └── domain-brief/         ← Descripción funcional del dominio
└── commands/
    └── opsx/                 ← Comandos del usuario

openspec/                     ← Generado por sdd-init
├── config.yaml               ← Config + modelos + overrides
├── specs/                    ← Fuente de verdad
└── changes/                  ← Changes activos + archive
```

## Modos de ejecución

| Modo | Soporte de subagentes | Cómo funciona |
|------|----------------------|---------------|
| **multi-agente** | Sí (Claude Code, etc.) | Cada fase se delega a un subagente con modelo asignado |
| **secuencial** | No (Cursor, Copilot, etc.) | El orquestador ejecuta cada fase en la misma conversación |

Ambos modos producen el mismo resultado — los artefactos son idénticos.

## Flujo

```
explore (opcional) → propose → spec → design (opcional) → tasks → apply → verify → archive
                                                                                    ↓
                                                                              retro + mejora
                                                                              continua
```

Para cambios pequeños: `patch` (todo en uno, sin flujo completo).

## Comandos

| Comando | Uso |
|---------|-----|
| `/opsx:init` | Inicializar el flujo en el proyecto |
| `/opsx:onboard` | Tutorial interactivo |
| `/opsx:new <nombre>` | Crear change completo (propose → tasks) |
| `/opsx:continue` | Continuar change pendiente |
| `/opsx:ff` | Fast-forward todas las fases sin pausa |
| `/opsx:explore <tema>` | Investigar antes de proponer |
| `/opsx:apply` | Implementar tareas |
| `/opsx:archive` | Archivar con retro obligatoria |
| `/opsx:patch` | Cambio pequeño documentado |
| `/opsx:domain-brief` | Regenerar descripción funcional |

## Instalación

1. Copiar `.agents/` a la raíz de tu proyecto
2. Ejecutar `/opsx:init`
3. El init detecta tu stack, crea config, y configura todo

### Mirror a otros editores

```bash
bash .agents/skills/sdd-init/scripts/mirror-agents.sh cursor claude
```

## Skills de proyecto

Las skills SDD coexisten con skills de tecnología/framework. Si tenés una skill `laravel` o `react`, el orquestador las detecta y las inyecta automáticamente a las fases que tocan código.

Debe verificarse que las skills de proyecto sigan las convenciones de la carpeta `_shared` para ser compatibles con el flujo SDD. Puede suceder que una skill tenga características que no encajen con el flujo, ya sea que no siga convenciones o que su enfoque sea muy diferente — en ese caso, el orquestador puede presentar una propuesta de cambio para adaptar la skill al flujo, adaptar el flujo a la skill (cuando una skill presente características que puedan mejorar el flujo), o simplemente no usarla.


```
.agents/skills/
├── sdd-apply/          ← Skill del flujo (cómo implementar)
├── laravel/            ← Skill de proyecto (convenciones de Laravel)
└── react/              ← Skill de proyecto (convenciones de React)
```

## Principios

- **Specs como fuente de verdad** — el código implementa lo que dicen las specs
- **Todo es Markdown** — archivos en el repo, sin base de datos externa
- **Agnóstico al editor** — funciona con cualquier agente de IA
- **Mejora continua** — cada archive genera retro que puede mejorar el flujo
- **Forward-only** — cambios a templates solo afectan artefactos nuevos
- **Trazabilidad** — decisiones, archivos, y bugs quedan registrados en state.md
- **Coexistencia** — skills de flujo + skills de proyecto sin conflicto
