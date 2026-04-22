# Diseño - spec-2026-04-22-03-workflow-cross-domain-traceability

## Contexto

El template ya separa bien propuesta, spec, diseño, tareas, verify y archive, pero todavía no tiene una pieza estable que obligue a pensar el impacto cruzado de un change. El problema no es solo de contenido faltante: también es de persistencia. Si la referencia cruzada queda dispersa entre comentario conversacional, proposal o tasks, se vuelve difícil reutilizarla en `continue`, `verify` o `archive`.

Este change toca varias fases del workflow y además debe respetar dos restricciones fuertes:

- seguir siendo file-based en Markdown
- no reescribir artefactos existentes por la regla forward-only

## Objetivos / No-Objetivos

**Objetivos:**
- introducir una fuente de verdad reusable para impacto cruzado
- mantener el workflow simple para cambios locales y más riguroso para cambios cross-cutting
- hacer que `verify` pueda revisar evidencia concreta y no intuiciones sobre alcance
- permitir referencias en monorepo o multi-repo sin depender de herramientas externas
- evitar loops recursivos o mapas de impacto imposibles de mantener

**No-Objetivos:**
- construir un grafo automático desde código o desde una base de conocimiento externa
- imponer visualizaciones, Mermaid o dashboards para el mapa
- reabrir o reescribir changes archivados
- reemplazar proposal/spec/design/tasks con un mega-documento único

## Decisiones

### D-01: usar `impact-map.md` como artefacto separado y fuente de verdad

**Decisión**: el análisis de impacto cruzado vive en `openspec/changes/{change-name}/impact-map.md` y no como secciones obligatorias repartidas entre `proposal.md`, `spec.md`, `design.md` y `tasks.md`.

**Alternativas consideradas**:
1. Agregar una sección fija a `proposal.md` y otra a `spec.md` - menos archivos, pero duplica contenido y complica `continue` y `verify`.
2. Poner todo en `design.md` - funciona solo para changes con gate técnico y deja afuera cambios que no necesitan diseño formal.
3. Artefacto separado `impact-map.md` - un archivo más, pero centraliza la información y evita drift.

**Razón**: el análisis cruzado nace en propose, se refina en spec, puede disparar design, baja a tasks y se valida en verify. Un artefacto separado acompaña todo ese recorrido sin duplicar texto.

### D-02: referencias tipadas con expansión acotada

**Decisión**: cada referencia del mapa usa una estructura mínima tipada (`target`, `target_type`, `relation`, `status`, `reason`, `tags`) y el workflow deduplica por `target` + `relation`.

**Alternativas consideradas**:
1. Lista libre de bullets - rápida de escribir, pero difícil de verificar y propensa a drift.
2. Grafo totalmente formal con IDs y subgrafos - más expresivo, pero demasiado pesado para un workflow Markdown.
3. Registro tipado y deduplicado - suficiente para verify y ligero para editar a mano.

**Razón**: hace verificable el artefacto sin volverlo una mini base de datos. También corta el riesgo de loops porque la relación se registra como link y no como nesting recursivo.

### D-03: trigger matrix por riesgo y transversalidad

**Decisión**: el workflow clasifica el análisis como `obligatorio`, `recomendado` u `opcional`.

**Alternativas consideradas**:
1. Siempre obligatorio - maximiza cobertura, pero castiga cambios chicos y genera burocracia.
2. Siempre opcional - mantiene velocidad, pero no corrige el problema de omisiones.
3. Matriz por riesgo/scope - aumenta cobertura donde importa y mantiene fricción baja en fixes locales.

**Razón**: el problema aparece sobre todo en cambios cross-cutting o con contratos compartidos. La matriz pone la exigencia donde agrega valor operativo.

### D-04: `verify` valida cobertura por dominio o contrato, no solo cantidad total

**Decisión**: `verify` exige evidencia por dominio secundario o contrato in-scope y usa mínimos numéricos solo como red de seguridad.

**Alternativas consideradas**:
1. Pedir un mínimo fijo de edge cases para todos los cambios - simple, pero arbitrario.
2. Hacer una revisión puramente cualitativa - flexible, pero difícil de estandarizar.
3. Combinar cobertura por referencia con un mínimo razonable cuando hay múltiples cruces - equilibrio entre consistencia y criterio.

**Razón**: evita tanto el checkbox vacío como la discrecionalidad total. El objetivo es demostrar que los cruces importantes fueron pensados.

## Riesgos / Trade-offs

| Riesgo | Mitigación |
|--------|------------|
| Archivo adicional puede percibirse como overhead | Trigger matrix clara y source of truth única para evitar duplicación |
| Clasificación manual puede variar entre agentes | Definir criterios y ejemplos explícitos en la spec y en la skill |
| Verify puede volverse demasiado duro en repos sin mucha documentación | Permitir justificación explícita cuando una referencia no pueda inspeccionarse directamente |
| Referencias multi-repo pueden degradarse a texto poco útil | Exigir formato mínimo estable y razón operativa por cada referencia |

## Plan de Implementación / Migración

1. Extender la convención compartida para incluir `impact-map.md` como artefacto válido del change.
2. Agregar template Markdown del mapa con tabla o secciones mínimas y taxonomía de referencias.
3. Actualizar `sdd-propose` y `/sdd:new` para crear o clasificar el artefacto.
4. Actualizar `sdd-spec`, `sdd-design` y `sdd-tasks` para leer y refinar el mapa.
5. Actualizar `sdd-verify` y `sdd-archive` para revisar cobertura y propagar lecciones.
6. Documentar comportamiento en README y workflow-guide.
7. Mantener adopción forward-only: solo nuevos changes reciben el artefacto automáticamente.

## Preguntas Abiertas

- [ ] Definir si el template inicial de `impact-map.md` conviene más como secciones narrativas, tabla híbrida o ambos.