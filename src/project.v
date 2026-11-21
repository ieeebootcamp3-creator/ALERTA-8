/*
 * ALERTA-8: recordatorio digital para asiento infantil.
 * Copyright (c) 2026 Jesús Eduardo Martínez Tinajero
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_ieeebootcamp3_creator_alerta8 (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

  // El diseño presupone el reloj de 50 MHz configurado en src/config.json.
  // El aviso se activa 30 s después de detectar la secuencia de salida.
  localparam integer CLOCK_HZ          = 50000000;
  localparam integer ALERT_DELAY_SEC   = 30;
  localparam integer DEBOUNCE_CYCLES   = CLOCK_HZ / 1000; // 1 ms
  localparam integer ALERT_CYCLES      = CLOCK_HZ * ALERT_DELAY_SEC;
  localparam integer DB_WIDTH          = $clog2(DEBOUNCE_CYCLES + 1);
  localparam integer TIMER_WIDTH       = $clog2(ALERT_CYCLES + 1);

  // Entradas dedicadas (ui_in):
  // ui[0] = asiento infantil ocupado, nivel alto
  // ui[1] = encendido del vehículo activo, nivel alto
  // ui[2] = puerta del conductor abierta, nivel alto
  // ui[3] = botón de silencio, nivel alto mientras se presiona
  reg [3:0] sync_meta;
  reg [3:0] sync_input;
  reg [3:0] input_stable;
  reg [DB_WIDTH-1:0] debounce_count [0:3];
  integer i;

  // Sincronización y filtro de rebote para sensores y botón.
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      sync_meta     <= 4'b0000;
      sync_input    <= 4'b0000;
      input_stable  <= 4'b0000;
      for (i = 0; i < 4; i = i + 1)
        debounce_count[i] <= {DB_WIDTH{1'b0}};
    end else begin
      sync_meta  <= ui_in[3:0];
      sync_input <= sync_meta;
      for (i = 0; i < 4; i = i + 1) begin
        if (sync_input[i] == input_stable[i]) begin
          debounce_count[i] <= {DB_WIDTH{1'b0}};
        end else if (debounce_count[i] >= DEBOUNCE_CYCLES - 1) begin
          input_stable[i] <= sync_input[i];
          debounce_count[i] <= {DB_WIDTH{1'b0}};
        end else begin
          debounce_count[i] <= debounce_count[i] + 1'b1;
        end
      end
    end
  end

  wire seat_occupied   = input_stable[0];
  wire ignition_on     = input_stable[1];
  wire driver_door_open = input_stable[2];
  wire silence_pressed = input_stable[3];
  wire start_sequence  = seat_occupied && !ignition_on && driver_door_open;

  reg timer_active;
  reg alarm_latched;
  reg silence_latched;
  reg [TIMER_WIDTH-1:0] timer_count;

  // Una vez iniciada, la cuenta sigue aunque se cierre la puerta.
  // La alarma queda enclavada hasta que el asiento queda desocupado.
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      timer_active   <= 1'b0;
      alarm_latched  <= 1'b0;
      silence_latched <= 1'b0;
      timer_count    <= {TIMER_WIDTH{1'b0}};
    end else if (!seat_occupied) begin
      timer_active   <= 1'b0;
      alarm_latched  <= 1'b0;
      silence_latched <= 1'b0;
      timer_count    <= {TIMER_WIDTH{1'b0}};
    end else begin
      if (!timer_active && !alarm_latched && start_sequence) begin
        timer_active <= 1'b1;
        timer_count  <= {TIMER_WIDTH{1'b0}};
      end else if (timer_active && !alarm_latched) begin
        if (timer_count >= ALERT_CYCLES - 1) begin
          timer_active  <= 1'b0;
          alarm_latched <= 1'b1;
        end else begin
          timer_count <= timer_count + 1'b1;
        end
      end

      // Silenciar solo apaga el buzzer. El LED rojo permanece encendido
      // hasta que el sensor indique que el asiento quedó desocupado.
      if (alarm_latched && silence_pressed)
        silence_latched <= 1'b1;
    end
  end

  // uo[0] buzzer; uo[1] LED rojo; uo[2] LED ámbar; uo[3] LED verde.
  // uo[4] alarma enclavada; uo[5] estado asiento; uo[6] encendido;
  // uo[7] puerta del conductor. Los estados de sensores ayudan a depurar.
  assign uo_out[0] = alarm_latched && !silence_latched;
  assign uo_out[1] = alarm_latched;
  assign uo_out[2] = timer_active;
  assign uo_out[3] = !timer_active && !alarm_latched;
  assign uo_out[4] = alarm_latched;
  assign uo_out[5] = seat_occupied;
  assign uo_out[6] = ignition_on;
  assign uo_out[7] = driver_door_open;

  // No se usan pines bidireccionales en esta versión.
  assign uio_out = 8'b0;
  assign uio_oe  = 8'b0;

  // ena siempre está activo cuando el bloque está seleccionado; uio_in no se usa.
  wire _unused = &{ena, ui_in[7:4], uio_in, 1'b0};

endmodule

`default_nettype wire
