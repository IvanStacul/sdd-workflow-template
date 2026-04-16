---
name: system-overview
description: "Generar una descripción funcional narrativa y completa del sistema a partir de las specs vigentes, con nivel de detalle configurable. Usar cuando el usuario ejecuta /sdd:system-overview o necesita un documento de análisis funcional del sistema."
metadata:
  version: "1.0"
---

## Purpose

Generar `docs/system-overview.md`: un documento narrativo que describe el sistema completo desde la perspectiva de un analista funcional. Explica QUÉ hace el sistema, cómo se comporta y qué reglas lo gobiernan, sin detalles de implementación técnica.

Este documento complementa al `domain-brief` (que es un resumen ejecutivo de alto nivel). El system-overview es más profundo: describe entidades, flujos, reglas de negocio y relaciones en prosa narrativa.

Se regenera completo en cada corrida leyendo las specs vigentes.

Sos un EJECUTOR. NO lances subagentes.

## Inputs

- Specs consolidadas en `openspec/specs/`.
- Nivel de detalle elegido por el usuario: `intermedio` o `detallado`.

## Niveles de detalle

El documento tiene dos niveles. El usuario elige uno al invocar el comando.

| Nivel | Qué incluye | Extensión típica |
|-------|-------------|------------------|
| **Intermedio** | Entidades principales, flujos operativos, reglas de negocio clave, relaciones entre subsistemas. Prosa narrativa sin enumerar cada edge case ni cada requerimiento individual. | 150–300 líneas |
| **Detallado** | Todo lo del intermedio + edge cases, validaciones, restricciones, escenarios especiales, reglas de cálculo exactas, condiciones de error y comportamientos condicionales extraídos de las specs. | 300–600 líneas |

Si el usuario no especifica nivel, preguntar antes de generar. No asumir.

Para un resumen ejecutivo de alto nivel (sin entidades ni reglas), usar `/sdd:domain-brief` en vez de esta skill.

## Tono y estilo

El documento debe leerse como si lo hubiera escrito un **analista funcional senior** documentando el sistema para:

- Dar contexto global a un nuevo integrante técnico o no técnico con conocimiento del negocio.
- Servir como insumo para planificación (roadmap, priorización).
- Proveer contexto completo a un agente de IA que necesita entender el sistema.

### Reglas de redacción

- **Narrativo, no telegráfico.** Usar párrafos con oraciones completas, no listas de bullets interminables. Las listas se usan para enumerar opciones o valores concretos, no como estructura principal.
- **Funcional, no técnico.** Decir "cada variante lleva su propio SKU y código de barras", no "la tabla `variants` tiene columnas `sku` y `barcode`". No mencionar tablas, columnas, endpoints, componentes React ni frameworks.
- **Preciso sin ser árido.** Usar vocabulario del dominio (tenant, variante, lista de precios, sesión de caja) pero explicar cada concepto cuando aparece por primera vez.
- **Estructura por subsistemas.** Organizar el documento agrupando por áreas funcionales del negocio, no por specs individuales. Varias specs pueden alimentar la misma sección.
- **Relaciones explícitas.** Cuando un subsistema depende de otro, decirlo en contexto ("El precio de venta se resuelve consultando las listas de precios activas del catálogo").
- **Voz activa, tercera persona.** "El sistema calcula...", "El cajero abre...", "Cada tenant tiene...".

### Nivel intermedio vs detallado — criterio de corte

En nivel **intermedio**, describir la regla general y el caso feliz. Omitir:

- Validaciones de borde (ej: "si el SKU ya existe dentro del mismo tenant, se rechaza").
- Enumeraciones exhaustivas (ej: listar todos los motivos de movimiento de stock).
- Escenarios de error o condiciones negativas (ej: "no se puede cerrar una caja que ya está cerrada").
- Fórmulas paso a paso (resumir el resultado, no cada paso).

En nivel **detallado**, incluir todo lo anterior. Cada regla de negocio documentada en las specs debe tener representación en el documento. Usar sub-encabezados adicionales para organizar la densidad sin perder legibilidad.

## Context Load

Leer:

1. `openspec/config.yaml`
2. `.agents/rules.md` para reglas generales del proyecto
3. `.agents/personality.md` para tono y filosofía de comunicación
4. Si `openspec/config.yaml` define `communication.compression`, leer `.agents/skills/caveman/SKILL.md` para las reglas operativas de cada nivel
5. Todas las specs vigentes dentro de `openspec/specs/`

Si no hay specs consolidadas, retornar `blocked`.

## Steps

### Step 1: Relevar y agrupar capabilities

Leer todas las specs consolidadas. Extraer:

- Entidades principales y sus atributos funcionales (no técnicos).
- Reglas de negocio y restricciones.
- Flujos operativos (cómo se usa el sistema).
- Relaciones entre subsistemas.

Agrupar las specs en **subsistemas funcionales** coherentes. Un subsistema puede agrupar varias specs si comparten dominio (ej: "Inventario y stock" puede incluir almacenes, movimientos y conteos). No forzar agrupaciones artificiales — si una spec merece su propia sección, darle una.

### Step 2: Determinar nivel de detalle

Si el usuario especificó el nivel, usarlo. Si no, preguntar y detenerse hasta recibir respuesta.

### Step 3: Redactar usando el template

Tomar como base `assets/system-overview.template.md`.

Escribir cada sección en prosa narrativa siguiendo las reglas de tono y el nivel de detalle elegido. Respetar la estructura del template pero adaptar las secciones internas según lo que las specs contengan realmente.

**Reglas de contenido:**

- NO mencionar nombres de specs, números de requerimientos (FR-01, RN-03) ni IDs de artefactos. El documento debe leerse sin conocer la estructura de OpenSpec.
- SÍ referenciar al final de cada sección del subsistema qué specs lo alimentan, como nota de trazabilidad discreta (ej: `Basado en: 003-catalog, 004-products`).
- NO incluir elementos planificados que no tengan spec vigente. Solo documentar lo que las specs definen hoy.
- SÍ mencionar brevemente al final del documento las áreas conocidas como planificadas si están referenciadas en las specs existentes (ej: "Clientes" mencionado como futuro en la spec de ventas), separadas claramente como horizonte futuro.

### Step 4: Escribir el documento

Crear o sobrescribir `docs/system-overview.md`.

El documento se regenera completo en cada corrida; no es incremental.

Incluir al inicio del documento:

- Indicación de que es generado automáticamente.
- Fecha de generación.
- Nivel de detalle usado.

## Persistence

Escribir:

- `docs/system-overview.md`

## Return Envelope

```yaml
status: success | blocked
summary: ""
artifacts:
  - docs/system-overview.md
next: "ninguno"
risks:
  - ""
skill_resolution: disabled | direct
```

## Rules

- No incluir detalles de implementación técnica (tablas, columnas, endpoints, componentes).
- No inventar funcionalidad que no esté en las specs vigentes.
- Mantener trazabilidad discreta a las specs fuente por sección.
- Respetar estrictamente el nivel de detalle elegido.
- Si el usuario no especificó nivel, preguntar y detenerse.
- El documento reemplaza al anterior completo en cada generación.
- Escribir en español.

## Optional Modules

- No hay módulos obligatorios.
