// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Wilson Snyder
// SPDX-License-Identifier: CC0-1.0

// A nonzero-based table needs its index rebased before expansion; without
// that support the compile fails loudly instead of reading the wrong element.
class C1;
  rand bit [7:0] r;
  bit [7:0] pool[1:16];
  constraint c { pool[r] == 8'h77; }
endclass

// Same rejection for a negative-based table.
class C2;
  rand byte r;
  bit [7:0] pool[-4:11];
  constraint c { pool[r] == 8'h77; }
endclass

module t;
  initial begin
    C1 obj1;
    C2 obj2;
    obj1 = new;
    obj2 = new;
    if (obj1.randomize() == 0) $stop;
    if (obj2.randomize() == 0) $stop;
  end
endmodule
