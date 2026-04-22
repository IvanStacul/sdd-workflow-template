# Cross-Reference Analysis

**Namespace**: -

## Purpose

Definir una práctica consistente del workflow SDD para mapear impactos cruzados entre dominios, capabilities, contratos y artefactos relacionados antes de especificar o implementar un cambio. La capacidad busca que cada change se piense como parte de un sistema y no como una isla documental.

## Requirements

### Requirement: XREF-01 - Artefacto file-based de impacto cruzado

El workflow MUST soportar un artefacto `impact-map.md` dentro de `openspec/changes/{change-name}/` como fuente de verdad del análisis de impacto cruzado cuando la práctica sea obligatoria o recomendada.

El artefacto MUST ser Markdown puro y MUST funcionar sin depender de una base de conocimiento externa. MAY incluir referencias opcionales a herramientas o capas externas, pero dichas referencias MUST ser complementarias y nunca un prerequisito.

El `impact-map.md` MUST registrar como mínimo:

- dominio principal afectado
- dominios secundarios relacionados
- capabilities, specs o artefactos relacionados
- contratos o interfaces afectadas
- procesos o flujos downstream potencialmente impactados
- edge cases detectados por interacción entre dominios
- exclusiones explícitas con razón
- evidencia esperada para verify

Cada referencia MUST poder apuntar tanto a paths locales de un monorepo como a identificadores de otros repositorios usando un formato file-based simple (por ejemplo `repo:path`, `repo@ref:path` o `path` local).

#### Scenario: Change cross-cutting crea mapa de impacto

- GIVEN un change nuevo que introduce una práctica del workflow con impacto en `propose`, `spec`, `verify` y `archive`
- WHEN `/sdd:new` o `/sdd:propose` inicia la documentación del change
- THEN el change contiene `impact-map.md` con dominio principal, dominios secundarios, referencias, contratos, edge cases y exclusiones iniciales

#### Scenario: Referencia multi-repo sin dependencia externa

- GIVEN un change que afecta un contrato documentado en otro repositorio
- WHEN el analista registra la referencia en `impact-map.md`
- THEN la referencia queda guardada como identificador Markdown o path textual dentro del change, sin requerir sincronización con herramientas externas

### Requirement: XREF-02 - Matriz de uso obligatorio, recomendado u opcional

El workflow MUST clasificar el análisis de impacto cruzado como `obligatorio`, `recomendado` u `opcional` por change.

La clasificación MUST ser `obligatorio` cuando ocurra al menos una de estas condiciones:

- el change crea o modifica comportamiento en dos o más dominios o capabilities relacionadas
- el change introduce o modifica un contrato compartido, una plantilla del workflow o una integración entre fases
- el change tiene riesgo funcional alto o cross-cutting aunque la implementación viva en pocos archivos

La clasificación SHOULD ser `recomendado` cuando el change sea principalmente local pero tenga downstream flows, navegación entre artefactos o dependencias que convenga revisar explícitamente.

La clasificación MAY ser `opcional` solo para cambios acotados y localizados, como correcciones textuales, ajustes editoriales o fixes sin contratos ni efectos aguas abajo. Cuando el análisis sea omitido, el workflow MUST registrar una justificación breve.

#### Scenario: Nuevo flujo cross-domain es obligatorio

- GIVEN una propuesta que afecta inventario, ventas y reportes
- WHEN el workflow evalúa el criterio de uso
- THEN el análisis queda marcado como `obligatorio`

#### Scenario: Fix local queda como opcional

- GIVEN un patch de redacción en una guía sin cambios de comportamiento
- WHEN el workflow evalúa el criterio de uso
- THEN el análisis puede omitirse y queda registrada la razón de esa omisión

### Requirement: XREF-03 - Integración operativa con fases y comandos del workflow

`/sdd:new` y `/sdd:propose` MUST crear o actualizar `impact-map.md` cuando la clasificación sea `obligatorio` o `recomendado`, y MUST dejar al menos el resumen de clasificación cuando sea `opcional`.

`/sdd:continue` MUST releer el `impact-map.md` existente antes de decidir la siguiente fase y MUST continuar actualizando el mismo artefacto en lugar de reemplazarlo.

`sdd-spec`, `sdd-design` y `sdd-tasks` MUST usar el `impact-map.md` para:

- validar que la spec cubra dominios y contratos impactados
- decidir si el change necesita `design.md`
- convertir impactos cross-domain en tareas verificables, especialmente cuando hay contratos o downstream flows

Las fases MAY resumir hallazgos en sus propios artefactos, pero `impact-map.md` MUST seguir siendo la fuente de verdad del análisis cruzado.

#### Scenario: Propuesta crea mapa y spec lo refina

- GIVEN un change nuevo clasificado como `obligatorio`
- WHEN se ejecutan `sdd-propose` y luego `sdd-spec`
- THEN `proposal.md` resume el alcance y `impact-map.md` concentra las referencias cruzadas refinadas para que la spec no tenga que reinventarlas

#### Scenario: Continue retoma el mismo mapa

- GIVEN un change activo con `impact-map.md` y `state.md`
- WHEN el usuario ejecuta `/sdd:continue`
- THEN la fase siguiente relee el mapa existente, agrega nueva evidencia si aparece y no crea un artefacto paralelo duplicado

### Requirement: XREF-04 - Referencias tipadas, deduplicadas y acotadas

El workflow MUST registrar cada referencia cruzada como una entrada tipada con, como mínimo, `target`, `target_type`, `relation`, `status`, `reason` y `tags`.

`target_type` MUST distinguir al menos entre `domain`, `capability`, `spec`, `artifact`, `contract`, `flow` y `external-reference`.

`relation` MUST distinguir la naturaleza del vínculo (por ejemplo `depends-on`, `updates`, `consumes`, `emits`, `constrains`, `verified-by`, `excluded-after-review`).

`status` MUST distinguir al menos `primary`, `secondary`, `in-scope`, `out-of-scope` y `watch-only`.

Para evitar loops infinitos, el workflow MUST deduplicar entradas por combinación de `target` + `relation` y MUST referenciar nodos relacionados mediante nuevas filas o bullets, no mediante anidado recursivo del contenido completo de otros artefactos. Si una referencia remite a otra relación relevante, el mapa SHOULD registrar el link y la razón de seguimiento, no copiar cadenas infinitas de contexto.

#### Scenario: Dos specs se referencian mutuamente

- GIVEN una capability A impacta a B y B ya referencia a A
- WHEN el mapa registra el cruce
- THEN el artefacto conserva una referencia tipada por cada relación relevante y evita expandir el contenido en bucle

#### Scenario: Mismo contrato aparece desde dos flujos

- GIVEN un contrato compartido es impactado tanto por una integración de propuesta como por verify
- WHEN el mapa actualiza sus referencias
- THEN la entrada se deduplica por target y relación, y solo agrega evidencia o tags complementarios

### Requirement: XREF-05 - Verificación de cobertura cruzada

`/sdd:verify` MUST revisar la evidencia de impacto cruzado cuando el change esté clasificado como `obligatorio` o `recomendado`.

La verificación MUST confirmar al menos:

- que el dominio principal y los dominios secundarios fueron listados o descartados con justificación
- que cada contrato, capability o flujo downstream in-scope tiene cobertura en spec, design, tasks o evidencia equivalente
- que existe al menos un edge case interdominio por cada dominio secundario in-scope o una justificación explícita de por qué no surge un edge case nuevo
- que si el mapa tiene dos o más referencias secundarias in-scope, existen al menos dos edge cases intermodulares o justificaciones equivalentes que cubran la interacción
- que las exclusiones están justificadas y no contradicen el resto de los artefactos del change

Si falta cobertura suficiente, `verify` MUST devolver hallazgo o bloqueo explícito en lugar de aprobar el change silenciosamente.

#### Scenario: Verify aprueba mapa consistente

- GIVEN un change obligatorio con dos dominios secundarios, contratos listados y edge cases justificados
- WHEN `/sdd:verify` revisa proposal, spec, design, tasks y `impact-map.md`
- THEN el reporte confirma cobertura cruzada suficiente

#### Scenario: Verify detecta dominio omitido

- GIVEN el mapa lista ventas como downstream flow pero no existe coverage en spec, tasks ni exclusiones justificadas
- WHEN `/sdd:verify` ejecuta la revisión
- THEN el change no queda aprobado y el hallazgo explicita la brecha de impacto cruzado

### Requirement: XREF-06 - Adopción forward-only y propagación de aprendizaje

La incorporación del `impact-map.md` MUST respetar la regla forward-only: solo aplica automáticamente a changes nuevos creados después de adoptarse la mejora.

Los changes activos previos MAY adoptar el artefacto manualmente, pero el workflow MUST NOT reescribir ni exigir retroactivamente `impact-map.md` a changes archivados.

Cuando `verify` o `archive` descubran que un impacto cruzado omitido produjo una lección reusable o un bug del workflow, `archive` MUST propagar el aprendizaje a `docs/known-issues.md` y/o `docs/workflow-changelog.md` según corresponda.

#### Scenario: Mejora nueva no reescribe historial

- GIVEN un change archivado antes de incorporar esta capability
- WHEN se adopta la nueva práctica de impacto cruzado
- THEN el archive histórico permanece intacto y solo los changes nuevos reciben la plantilla automáticamente

#### Scenario: Hallazgo de verify se propaga al workflow

- GIVEN un change detecta durante verify que faltó revisar un contrato downstream relevante
- WHEN el change se archiva con una lección generalizable
- THEN `docs/known-issues.md` o `docs/workflow-changelog.md` registran la mejora aplicable para futuros changes

## Edge Cases

| Caso | Comportamiento Esperado | Req Relacionado |
|------|-------------------------|-----------------|
| Change single-domain con contrato externo opcional | El mapa puede quedar como recomendado u opcional, pero la justificación de clasificación debe quedar escrita | XREF-02 |
| Referencia a spec consolidada y delta del mismo change | El mapa debe distinguir ambos targets sin duplicar contenido completo | XREF-04 |
| Dominio secundario revisado y descartado | Debe quedar como exclusión explícita con razón y fecha de revisión | XREF-01, XREF-05 |
| Monorepo con múltiples módulos pero una sola capability nueva | El mapa registra módulos o artefactos como flows/contracts sin forzar specs extra | XREF-01, XREF-04 |
| Multi-repo sin acceso al repo dependiente | La referencia se mantiene textual y verify valida la justificación disponible, no una inspección imposible | XREF-01, XREF-05 |
| Un mismo target cambia de `watch-only` a `in-scope` durante el change | El mapa actualiza el status manteniendo trazabilidad de la decisión | XREF-04 |