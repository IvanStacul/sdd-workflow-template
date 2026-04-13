# Reglas Generales del Proyecto

> Archivo generado por sdd-init. Estas reglas aplican SIEMPRE, en todas las fases
> y en interacciones fuera del flujo SDD.
> Puede quedar referenciado desde `AGENTS.md` según `agents_md_policy`.

## Commits

- Nunca agregar "Co-Autor" ni atribuciones de IA a los commits
- Usar solo conventional commits (feat:, fix:, refactor:, docs:, etc.) \
- No modificar historial git salvo pedido explícito.

## Interacción

- Al hacer una pregunta, DETENERSE y esperar la respuesta. Nunca continuar ni dar por sentadas las respuestas
- Nunca estar de acuerdo con afirmaciones del usuario sin verificarlas. Decir "dejame verificar" y revisar código/documentación primero
- Si el usuario se equivoca, explicar POR QUÉ con evidencia y sin sarcasmo
- Si te equivocaste, admitirlo con evidencia
- Siempre proponer alternativas con ventajas y desventajas cuando sea pertinente
- Validación incremental: presentar diseño, plan o propuesta y obtener aprobación antes de avanzar. No asumir aceptación implícita

## Verificación

- Verificar afirmaciones técnicas antes de hacerlas.
- Si hay incertidumbre, investigar primero.
- No inventar comportamientos, paths, comandos ni resultados o información de la que no se este seguro.
- Cuando una fase pida evidencia, producirla o reportar por que no se pudo.

## Código

- Seguir las convenciones existentes del proyecto (detectadas en `openspec/config.yaml`)
- No crear abstracciones innecesarias (consultar `_shared/abstraction-guide.md`)
- No modificar archivos que no estén relacionados con la tarea actual
- Preferir cambios pequeños y verificables sobre refactors masivos

## Workflow

- `.agents/` es la fuente de verdad del workflow.
- La interfaz pública es `/sdd:*`.
- `testing.strict_tdd` y `modules.model_routing` son opt-in.
- `modules.skill_registry` es parte de la base recomendada del workflow; si se apaga, debe hacerse de forma explícita y entendiendo que se pierde resolución automática de skills de proyecto.
