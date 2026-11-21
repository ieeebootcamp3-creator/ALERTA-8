# SPDX-FileCopyrightText: © 2026 Jesús Eduardo Martínez Tinajero
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

CLOCK_PERIOD_NS = 20
DEBOUNCE_CYCLES = 50_000  # 1 ms at 50 MHz

async def settle_inputs(dut):
    await ClockCycles(dut.clk, DEBOUNCE_CYCLES + 4)

@cocotb.test()
async def test_alerta8_arming_and_cancel(dut):
    """Checks reset, safe state, countdown arming, and cancel on empty seat."""
    cocotb.start_soon(Clock(dut.clk, CLOCK_PERIOD_NS, unit="ns").start())
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    await settle_inputs(dut)

    # Safe output is active when there is no countdown or latched alarm.
    assert int(dut.uo_out.value) & 0b0000_1111 == 0b0000_1000

    # Occupied seat, ignition off, door closed: no countdown yet.
    dut.ui_in.value = 0b0000_0001
    await settle_inputs(dut)
    assert int(dut.uo_out.value) & 0b0000_0100 == 0

    # Opening the driver's door starts the countdown.
    dut.ui_in.value = 0b0000_0101
    await settle_inputs(dut)
    assert int(dut.uo_out.value) & 0b0000_0100 != 0
    assert int(dut.uo_out.value) & 0b0000_0010 == 0

    # Emptying the seat cancels the pending warning and restores safe status.
    dut.ui_in.value = 0
    await settle_inputs(dut)
    assert int(dut.uo_out.value) & 0b0000_0101 == 0
    assert int(dut.uo_out.value) & 0b0000_1000 != 0
