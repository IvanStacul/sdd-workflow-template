# Guía de Abstracción

> Referencia compartida para skills que crean o modifican código: sdd-tasks (planifica archivos/funciones), sdd-design (diseña arquitectura), sdd-apply (implementa), sdd-verify (revisa).

## Principio

Abstraer solo cuando hay beneficio concreto, no por principio DRY preventivo.

## Cuándo SÍ extraer a Service / Helper

- La lógica se usa en **2+ lugares** Y es **idéntica** (no "parecida")
- La lógica de negocio crece dentro de un controlador/handler
- El controlador/handler supera ~80 líneas de lógica no-framework
- Hay orquestación de múltiples operaciones (guardar + subir imagen + notificar)
- La lógica necesita ser testeada de forma aislada

## Cuándo NO abstraer

- Función privada usada solo en un lugar → dejar inline
- "Podría" reutilizarse en el futuro → no abstraer preventivamente
- La abstracción requiere más líneas que el código original
- Solo se quiere "limpiar" por estética sin beneficio funcional
- El código es un CRUD simple sin lógica de negocio

## Patrones

**Controller → Service**: lógica de negocio compleja, 2+ contextos, orquestación de operaciones.

**Controller → función privada**: lógica auxiliar, un solo controlador, mejora legibilidad del método principal.

**Inline**: 5-15 líneas directas, un solo lugar, lectura secuencial más clara que indirección.

## Anti-patrones

| Anti-patrón | Alternativa |
|-------------|-------------|
| Service de 1 método usado en 1 lugar | Inline o función privada |
| Helper "util" genérico que crece sin cohesión | Módulos con responsabilidad clara |
| Repository pattern sobre un ORM que ya lo provee | Usar el ORM directamente |
| Abstraer "por si acaso" | YAGNI — extraer cuando se necesite |
