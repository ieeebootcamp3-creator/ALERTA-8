# ALERTA-8 — Recordatorio digital para asiento infantil

ALERTA-8 es un proyecto educativo de Tiny Tapeout que detecta una secuencia de salida del vehículo con un asiento infantil ocupado y activa una alerta después de 30 segundos. La alarma puede silenciarse con un botón, pero la indicación roja permanece hasta que el asiento queda libre.

## Señales

| Pin | Nombre | Función |
|---|---|---|
| `ui[0]` | `SEAT_OCCUPIED` | Nivel alto cuando el asiento está ocupado |
| `ui[1]` | `IGNITION_ON` | Nivel alto cuando el encendido está activo |
| `ui[2]` | `DRIVER_DOOR_OPEN` | Nivel alto cuando se abre la puerta del conductor |
| `ui[3]` | `SILENCE_BUTTON` | Nivel alto mientras se presiona para silenciar |
| `uo[0]` | `BUZZER` | Activa el buzzer durante una alarma no silenciada |
| `uo[1]` | `ALARM_RED_LED` | LED rojo mientras la alarma siga enclavada |
| `uo[2]` | `COUNTDOWN_AMBER_LED` | LED ámbar durante la cuenta de 30 segundos |
| `uo[3]` | `SAFE_GREEN_LED` | Estado sin cuenta pendiente ni alarma |
| `uo[4]`–`uo[7]` | Estado | Alarma, asiento, encendido y puerta |

Las entradas son digitales y se sincronizan y filtran para reducir rebotes. Los sensores, el buzzer y los LEDs son componentes externos; el chip solo aporta la lógica de control. Consulta [la ficha del proyecto](docs/info.md) para el comportamiento y las limitaciones.

> ALERTA-8 es un prototipo académico y no sustituye equipo automotriz certificado ni un sistema comercial de seguridad infantil.

## Uso en Tiny Tapeout

El módulo superior es `tt_um_ieeebootcamp3_creator_alerta8`. La fuente Verilog se encuentra en `src/project.v`; la configuración de Tiny Tapeout está en `info.yaml` y las pruebas en `test/`.
