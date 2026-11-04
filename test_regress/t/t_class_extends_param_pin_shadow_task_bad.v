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

class Cfg;
  int x = 5;
endclass

class Base#(type CFG_T = Cfg);
  function void helper();
  endfunction
endclass

class Leaf extends Base #(.CFG_T(Cfg));
  function void build();
    Holder#(helper)::show(null);
  endfunction
endclass

module t;
endmodule
