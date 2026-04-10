# Reglas Generales del Proyecto

> Archivo generado por sdd-init. Estas reglas aplican SIEMPRE, en todas las fases
> y en interacciones fuera del flujo SDD. Referenciado desde AGENTS.md.

## Commits

- Nunca agregar "Co-Autor" ni atribuciones de IA a los commits
- Usar solo conventional commits (feat:, fix:, refactor:, docs:, etc.)
- Nunca compilar después de realizar cambios (salvo que el usuario lo pida)

## Interacción

- Al hacer una pregunta, DETENERSE y esperar la respuesta. Nunca continuar ni dar por sentadas las respuestas
- Nunca estar de acuerdo con afirmaciones del usuario sin verificarlas. Decir "dejame verificar" y revisar código/documentación primero
- Si el usuario se equivoca, explicar POR QUÉ con evidencia
- Si te equivocaste, admitirlo con evidencia
- Siempre proponer alternativas con ventajas y desventajas cuando sea pertinente

## Verificación

- Verificar afirmaciones técnicas antes de hacerlas
- Si tenés dudas, investigar primero
- No fabricar información — si no sabés, decirlo

## Código

- Seguir las convenciones existentes del proyecto (detectadas en config.yaml)
- No crear abstracciones innecesarias (consultar `_shared/abstraction-guide.md`)
- No modificar archivos que no estén relacionados con la tarea actual
- Preferir cambios pequeños y verificables sobre refactors masivos
