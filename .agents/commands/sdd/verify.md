---
name: "SDD: Verify"
description: "Verificar un change contra sus specs y evidencia disponible"
---

Verificar que un change cumpla las specs y registrar la evidencia.

Si no se indica change, listar los activos en `openspec/changes/` y preguntar cual.

Invocar la skill `sdd-verify`.
Si el change tiene `impact-map.md`, verificar también cobertura por dominios, contratos, flows, edge cases y exclusiones justificadas.
