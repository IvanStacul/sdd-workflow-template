# Ejemplo - Omisión Justificada de Impact Map

## Contexto

- **Tipo de change**: ajuste editorial local
- **Clasificación**: `opcional`
- **Motivo**: corrige redacción en una guía sin contratos, sin flows y sin cambio de comportamiento

## Resumen esperado en `proposal.md`

```markdown
## Impacto
- **Código**: sin cambios
- **APIs**: sin cambios
- **Dependencias**: sin cambios
- **Datos**: sin cambios

## Análisis cruzado
- **Clasificación**: `opcional`
- **Justificación**: cambio editorial localizado; no modifica behavior, contratos ni downstream flows
```

## Que muestra este ejemplo

- El workflow permite omitir `impact-map.md` cuando el cambio es acotado y local.
- La omisión no es implícita: la clasificación y la justificación igual quedan persistidas.
- `verify` puede confirmar que la omisión sigue siendo válida porque no aparecen contratos ni impactos aguas abajo.