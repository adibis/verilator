// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Aditya Shevade
// SPDX-License-Identifier: CC0-1.0

class Holder#(type T = int);
  static function void show(T val);
    $display("holder");
  endfunction
endclass

class B#(type T = int);
endclass

class Leaf#(type P = B) extends P;
  function void build();
    Holder#(Nope)::show(null);
  endfunction
endclass

module t;
  initial begin
    automatic Leaf l = new;
    l.build();
  end
endmodule
