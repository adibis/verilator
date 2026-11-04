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

class Base#(type A = U, type U = A, type Z = int);
endclass

class Leaf extends Base #(.Z(int));
  function void build();
    Holder#(A)::show(null);
  endfunction
endclass

module t;
endmodule
