---
name: sdd-propose
description: >
  Crear una propuesta formal de cambio con motivación, alcance, y capabilities afectadas.
  Trigger: Cuando se inicia un nuevo change o se ejecuta /opsx:propose.
metadata:
  version: "1.0"
---

## Purpose

Crear la propuesta que establece POR QUÉ y QUÉ cambia. Es el contrato entre la idea y las specs. Todo lo que viene después se basa en este documento.

Sos un EJECUTOR — escribí la propuesta directamente. NO lances subagentes.

## What You Receive

- Nombre del change
- Descripción del cambio deseado (del usuario o de una exploración previa)

## What to Do

### Step 1: Cargar contexto

Seguir **Sección B** de `_shared/phase-common.md`.

Además leer:
- `openspec/changes/{change-name}/exploration.md` (si existe)
- `openspec/specs/` — listar specs existentes para identificar capabilities afectadas
- `docs/domain-brief.md` (si existe) — entender el dominio

### Step 2: Crear directorio del change

```
openspec/changes/{prefix}-{change-name}/
```

Donde `{prefix}` sigue la convención de `_shared/openspec-convention.md`:
- `spec-YYYY-MM-DD-NN-slug` para changes completos
- Determinar NN contando directorios existentes con la misma fecha

### Step 3: Crear state.md

Inicializar `state.md` en el directorio del change usando el formato de `_shared/openspec-convention.md`.

### Step 4: Escribir proposal.md

```markdown
# Propuesta — {nombre descriptivo}

## Por qué

{1-3 frases sobre el problema u oportunidad. ¿Qué problema resuelve? ¿Por qué ahora?}

## Qué Cambia

{Lista de cambios concretos. Ser específico sobre nuevas capabilities,
modificaciones, o eliminaciones. Marcar breaking changes con **BREAKING**.}

- {cambio 1}
- {cambio 2}

## Capabilities

### Nuevas
{Capabilities que se introducen. Cada una se convierte en una nueva spec.
Usar kebab-case. Cada entrada = un archivo specs/{name}/spec.md}

- `{nombre}`: {descripción breve}

### Modificadas
{Capabilities existentes cuyas SPECS cambian. Solo listar si cambia
el comportamiento a nivel spec, no detalles de implementación.
Cada entrada necesita un delta spec.}

- `{nombre-existente}`: {qué requisito cambia}

## Alcance

### Dentro
- {funcionalidad incluida}

### Fuera
- {funcionalidad excluida} — {motivo}

## Impacto

- **Código**: {módulos/archivos afectados}
- **APIs**: {endpoints que cambian, si aplica}
- **Dependencias**: {nuevas deps o cambios}
- **Datos**: {migraciones, cambios de schema}

## Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|-------------|---------|------------|

## Plan de Rollback

{Cómo revertir si algo sale mal. Puede ser "revert del commit" para
cambios simples, o un plan detallado para migraciones.}
```

### Step 5: Persistir

Seguir **Sección C** de `_shared/phase-common.md`.

### Step 6: Retornar resumen

```markdown
## Propuesta Creada

**Change**: {change-name}
**Directorio**: openspec/changes/{full-name}/

### Capabilities
- Nuevas: {N} → {lista}
- Modificadas: {N} → {lista}

### Siguiente paso
Ejecutar sdd-spec para escribir las especificaciones, o sdd-design si se necesita definir arquitectura primero.
```

## Rules

- La sección Capabilities es CRÍTICA — es el contrato entre proposal y specs
- Investigar specs existentes ANTES de listar capabilities modificadas
- NO incluir detalles de implementación — eso va en design
- Incluir SIEMPRE Plan de Rollback, aunque sea simple
- Alcance Fuera es tan importante como Alcance Dentro — previene scope creep
- Si el cambio es demasiado grande, RECOMENDAR dividirlo en múltiples changes
- Sobre de retorno según **Sección F** de `_shared/phase-common.md`
- Aplicar reglas de `openspec/config.yaml` sección `rules.proposal` si existen
