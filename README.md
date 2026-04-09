# SDD Workflow Template

Template de flujo **Spec-Driven Development** para proyectos con agentes de IA.

## ¿Qué es?

Un sistema de especificaciones y documentación basado en archivos Markdown que guía el desarrollo con agentes de IA. Todo vive en el repo — no hay base de datos externa.

## Estructura

```
.agents/
├── skills/
│   ├── _shared/              ← Convenciones compartidas (no es una skill)
│   ├── sdd-init/             ← Inicializar el flujo en un proyecto
│   ├── sdd-explore/          ← Investigar antes de proponer
│   ├── sdd-propose/          ← Crear propuesta de cambio
│   ├── sdd-spec/             ← Escribir especificaciones
│   ├── sdd-design/           ← Diseño técnico
│   ├── sdd-tasks/            ← Plan de tareas
│   ├── sdd-apply/            ← Implementar
│   ├── sdd-verify/           ← Verificar vs specs
│   ├── sdd-archive/          ← Archivar + retro + mejora continua
│   ├── sdd-patch/            ← Cambios pequeños documentados
│   └── domain-brief/         ← Descripción funcional del dominio
└── commands/
    └── opsx/                 ← Comandos del usuario (/opsx:init, etc.)

openspec/                     ← Estructura de specs (generada por sdd-init)
├── config.yaml
├── specs/                    ← Fuente de verdad
└── changes/                  ← Changes activos + archive
```

## Flujo

```
explore (opcional) → propose → spec → design (opcional) → tasks → apply → verify → archive
                                                                              ↓
                                                                      retro + mejora continua
```

Para cambios pequeños: `patch` (todo en uno, sin flujo completo).

## Instalación

1. Copiar `.agents/` a la raíz de tu proyecto
2. Ejecutar `/opsx:init` en tu agente de IA
3. El init detecta tu stack, crea `openspec/config.yaml`, y configura todo

## Mirror a otros editores

```bash
bash .agents/skills/sdd-init/scripts/mirror-agents.sh cursor claude
```

## Principios

- **Specs como fuente de verdad** — el código implementa lo que dicen las specs
- **Documentación como archivos** — todo es Markdown, todo va al repo
- **Mejora continua** — cada archive genera una retro que puede mejorar el flujo
- **Forward-only** — cambios a templates solo afectan artefactos nuevos
- **Trazabilidad** — cada decisión, archivo, y bug queda registrado
