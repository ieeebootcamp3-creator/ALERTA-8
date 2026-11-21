## Cómo funciona

ALERTA-8 es un controlador digital de recordatorio para una instalación educativa de monitoreo de asiento infantil. Recibe señales digitales externas de ocupación del asiento, encendido del vehículo y puerta del conductor. Cuando detecta asiento ocupado, encendido apagado y puerta del conductor abierta, inicia una cuenta de 30 segundos. La cuenta continúa aunque la puerta se cierre. Si el asiento se desocupa antes de terminar, cancela el aviso. Si la cuenta termina mientras el asiento sigue ocupado, activa el buzzer y el LED rojo. El botón de silencio apaga el buzzer, pero el LED rojo permanece activo hasta que el asiento queda desocupado.

Las cuatro entradas pasan por sincronizadores y un filtro digital de 1 ms para reducir rebotes. La lógica usa el reloj de 50 MHz declarado en `info.yaml`. Las entradas y salidas son niveles digitales; el circuito integrado no incluye sensores analógicos, buzzer ni LEDs.

## Cómo probarlo

Conecta las señales digitales a `ui[0]`–`ui[3]` según el pinout de `info.yaml`. En simulación, el test automatizado comprueba el estado seguro, el inicio de la cuenta y su cancelación al desocuparse el asiento. Para observar la alarma completa, mantén `SEAT_OCCUPIED=1`, `IGNITION_ON=0` y abre `DRIVER_DOOR_OPEN`; después de 30 segundos deben activarse `BUZZER` y `ALARM_RED_LED`. Activar `SILENCE_BUTTON` silencia solo el buzzer. Al poner `SEAT_OCCUPIED=0`, la alarma se borra y el controlador vuelve al estado seguro.

## Hardware externo

Para una demostración se requieren sensores que entreguen niveles lógicos compatibles con la plataforma, un botón momentáneo, un buzzer y LEDs externos con sus resistencias limitadoras y una etapa de manejo apropiada para la corriente requerida. No conectes cargas directamente a los pines del chip si exceden sus límites eléctricos. Este prototipo académico no sustituye un sistema certificado de seguridad infantil ni un monitor comercial para automóvil.
