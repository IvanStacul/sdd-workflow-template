# Strict TDD - Módulo Opcional de Verify

Este archivo solo se carga si `testing.strict_tdd: true`.

## Objetivo

Agregar controles extra para verificar que la implementación no se salto el flujo de tests primero.

## Chequeos mínimos

- Los requirements cambiados deben tener tests relacionados.
- La evidencia runtime no puede faltar para cambios de comportamiento.
- Si hay implementación sin tests asociados, reportar al menos `WARNING`.

## Reglas

- No convertir automaticamente ausencia de evidencia en `PASS`.
- Si el cambio no puede probarse con el runner actual, reportarlo.
