# Impact Map - {Nombre del Change}

## Clasificacion

- **Nivel**: `obligatorio | recomendado | opcional`
- **Justificacion**: {por que aplica este nivel}
- **Dominio principal**: `{domain-principal}`

## Dominios Secundarios

| Dominio | Motivo | Status |
|---------|--------|--------|
| `{domain}` | {por que se revisa} | `secondary | watch-only | out-of-scope` |

## Referencias Tipadas

| target | target_type | relation | status | reason | tags |
|--------|-------------|----------|--------|--------|------|
| `{path-o-identificador}` | `domain | capability | spec | artifact | contract | flow | external-reference` | `depends-on | updates | consumes | emits | constrains | verified-by | excluded-after-review` | `primary | secondary | in-scope | out-of-scope | watch-only` | {contexto breve y verificable} | `tag-a, tag-b` |

## Contratos o Interfaces Afectadas

| Contrato | Tipo | Cambio esperado | Evidencia asociada |
|----------|------|-----------------|--------------------|
| `{target}` | `api | schema | template | workflow-interface | external-contract` | {que cambia o que se verifica} | {test, review o evidencia esperada} |

## Downstream Flows

| Flow | Disparador | Impacto esperado | Status |
|------|------------|------------------|--------|
| `{flow}` | {evento o fase} | {consecuencia aguas abajo} | `in-scope | watch-only | out-of-scope` |

## Edge Cases Cross-Domain

| Caso | Dominios o artefactos involucrados | Mitigacion o seguimiento |
|------|------------------------------------|--------------------------|
| {caso} | {dominios, contracts o artifacts} | {como se cubre o por que se observa} |

## Exclusiones Explicitas

| Target | Motivo | Fecha de revision |
|--------|--------|-------------------|
| `{target}` | {por que queda fuera} | `YYYY-MM-DD` |

## Evidencia Esperada para Verify

- {evidencia 1}
- {evidencia 2}

## Notas de Seguimiento

- Registrar relaciones relacionadas como nuevas filas o bullets breves, nunca copiando el contenido completo de otro artefacto.
- Deduplicar entradas por combinacion de `target` + `relation`.
- Si una referencia apunta a otro seguimiento, enlazar el `target` relacionado y resumir la razon del vínculo en una sola linea.