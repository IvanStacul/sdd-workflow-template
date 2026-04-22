# Ejemplo - Impact Map Obligatorio

## Contexto

- **Tipo de change**: cambio cross-domain
- **Clasificación**: `obligatorio`
- **Motivo**: modifica contrato compartido entre `inventory`, `sales` y `reports`

## Fragmento de `impact-map.md`

```markdown
# Impact Map - sync-inventory-sales-reporting

## Clasificacion

- **Nivel**: `obligatorio`
- **Justificacion**: el change modifica un contrato compartido y downstream flows entre tres dominios
- **Dominio principal**: `inventory`

## Dominios Secundarios

| Dominio | Motivo | Status |
|---------|--------|--------|
| `sales` | consume el stock reservado | `secondary` |
| `reports` | recalcula métricas con el nuevo estado | `secondary` |

## Referencias Tipadas

| target | target_type | relation | status | reason | tags |
|--------|-------------|----------|--------|--------|------|
| `openspec/specs/009-warehouse-management/spec.md` | `spec` | `updates` | `in-scope` | cambia el contrato de reserva | `shared-contract, verify-critical` |
| `openspec/specs/006-sales/spec.md` | `spec` | `consumes` | `in-scope` | el checkout usa el nuevo estado | `cross-domain` |
| `reports-service:profitability` | `external-reference` | `depends-on` | `watch-only` | requiere revisar impacto aguas abajo | `downstream` |

## Contratos o Interfaces Afectadas

| Contrato | Tipo | Cambio esperado | Evidencia asociada |
|----------|------|-----------------|--------------------|
| `StockReservationStatus` | `schema` | agrega estado `committed` | spec delta + verify estático |

## Downstream Flows

| Flow | Disparador | Impacto esperado | Status |
|------|------------|------------------|--------|
| `checkout -> reserve-stock -> reporting` | cierre de venta | mantiene consistencia entre venta y reporte | `in-scope` |

## Exclusiones Explicitas

| Target | Motivo | Fecha de revision |
|--------|--------|-------------------|
| `legacy-batch-export` | no consume el contrato nuevo | `2026-04-22` |
```

## Que muestra este ejemplo

- El mapa es obligatorio cuando el cambio cruza dominios y contratos compartidos.
- `verify` debe revisar cobertura sobre el contrato, el flow downstream y la exclusión explícita.
- `archive` puede propagar la lección si el patrón resulta reusable para futuros changes.