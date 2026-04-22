# Propuesta - trazabilidad cruzada entre dominios y artefactos

## Por qué

El workflow SDD actual obliga a documentar propuesta, spec, diseño y tareas, pero no obliga a explicitar los impactos cruzados entre dominios, módulos, specs y artefactos relacionados. Eso deja demasiado espacio para que un cambio se piense como si viviera aislado en su dominio principal y hace que edge cases, contratos implícitos o efectos aguas abajo aparezcan tarde.

## Qué Cambia

- Crear una capability nueva del workflow para registrar análisis de impacto cruzado como artefacto file-based reutilizable.
- Introducir un `impact-map.md` por change cuando el alcance o el riesgo lo ameriten, con dominios afectados, contratos, flujos downstream, edge cases interdominio y exclusiones justificadas.
- Definir criterios explícitos de uso obligatorio, recomendado u opcional para evitar tanto omisiones como sobre-documentación.
- Integrar el artefacto con `/sdd:new`, `/sdd:propose`, `/sdd:continue`, `/sdd:verify` y `/sdd:archive` sin romper la regla forward-only.
- Incorporar una taxonomía de referencias y un mecanismo anti-loop para evitar recorridos infinitos o mapas recursivos inmanejables.

## Capabilities

### Nuevas
- `cross-reference-analysis`: práctica operativa del workflow para identificar, clasificar y verificar impactos cruzados entre dominios, capabilities, contratos y artefactos relacionados.

### Modificadas
- Ninguna. La mejora se modela como capability nueva del workflow y se integra después en skills, templates y documentación operativa.

## Alcance

### Dentro
- Artefacto nuevo `impact-map.md` dentro del change como fuente de verdad del análisis cruzado.
- Estructura mínima obligatoria para dominios, referencias, contratos, flujos downstream, edge cases y exclusiones.
- Matriz de uso obligatorio/recomendado/opcional según tamaño, riesgo y cantidad de dominios o contratos implicados.
- Reglas de integración con `propose`, `spec`, `design`, `tasks`, `continue`, `verify` y `archive`.
- Compatibilidad con monorepo, multi-repo y referencias opcionales a capas externas de conocimiento sin dependencia obligatoria.
- Mecanismo de clasificación por tipo de referencia y tags para evitar loops infinitos o duplicación recursiva.

### Fuera
- Generación automática de grafos visuales o dependencias a herramientas externas como Obsidian, Engram o bases vectoriales.
- Reescritura retroactiva de changes archivados o activos existentes.
- Descubrimiento automático de impactos desde código o repositorios remotos.
- Validaciones cuantitativas rígidas que premien cantidad de referencias por encima de calidad y justificación.

## Análisis cruzado

- **Clasificación**: `obligatorio`
- **Justificación**: el change modifica templates del workflow, contratos compartidos de la interfaz `/sdd:*` y cruza `propose`, `spec`, `design`, `tasks`, `verify` y `archive`.
- **Artefacto fuente de verdad**: `impact-map.md`

## Impacto
- **Código**: `.agents/orchestrator.md`, `.agents/skills/_shared/openspec-convention.md`, skills `sdd-propose`, `sdd-spec`, `sdd-design`, `sdd-tasks`, `sdd-verify`, `sdd-archive`, assets de templates y documentación operativa.
- **APIs**: la interfaz pública `/sdd:new`, `/sdd:propose`, `/sdd:continue`, `/sdd:verify` y `/sdd:archive` adquiere una expectativa nueva sobre evidencia de impacto cruzado.
- **Dependencias**: sin dependencias externas nuevas.
- **Datos**: sin schemas; solo artefactos Markdown nuevos dentro de `openspec/changes/`.

## Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| El artefacto se vuelve burocrático y la gente lo completa mecánicamente | Media | Alto | Definir triggers claros y exigir justificación útil, no listas largas vacías |
| Duplicar información entre `proposal.md`, `spec.md` y `impact-map.md` genera drift | Media | Alto | Hacer de `impact-map.md` la fuente de verdad y usar resúmenes breves en otros artefactos |
| Un modelo de referencias demasiado libre produce loops o mapas inmanejables | Media | Alto | Usar relaciones tipadas, deduplicación por target y expansión acotada |
| El verify falla por reglas arbitrarias y no por evidencia real | Baja | Medio | Combinar mínimos razonables con criterios cualitativos por dominio o contrato |

## Plan de Rollback

Revert del change y eliminación de la nueva plantilla/skill wiring. Como el cambio es forward-only y solo afecta artefactos nuevos del workflow, deshacerlo no requiere migrar ni reescribir changes anteriores.