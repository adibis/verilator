// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Wilson Snyder
// SPDX-License-Identifier: CC0-1.0

class Item;
  int val;
endclass

// Scalar class handle compared in a constraint: '==' can't be represented
// as a bit-vector SMT literal, and shouldn't reference-compare either.
class C1;
  rand Item h;
  Item t2;
  constraint c { h == t2; }
  function new();
    h = new;
    t2 = new;
  endfunction
endclass

// Same shape, but an array of handles -- confirms the diagnostic fires
// regardless of whether the class-handle-typed operand is scalar or an
// array element.
class C2;
  rand Item h[2];
  Item t2[2];
  constraint c { h == t2; }
  function new();
    h[0] = new;
    h[1] = new;
    t2[0] = new;
    t2[1] = new;
  endfunction
endclass

// Same shape, but the class-handle operand is reached through a member
// select (holder.h) instead of directly -- confirms the diagnostic also
// covers a MemberSel-typed operand, not just VarRef/ArraySel.
class Holder;
  rand Item h;
endclass
class C3;
  rand Holder holder1;
  Holder holder2;
  constraint c { holder1.h == holder2.h; }
  function new();
    holder1 = new;
    holder1.h = new;
    holder2 = new;
    holder2.h = new;
  endfunction
endclass

module t;
  initial begin
    C1 obj1;
    C2 obj2;
    C3 obj3;
    obj1 = new;
    obj2 = new;
    obj3 = new;
    if (obj1.randomize() == 0) $stop;
    if (obj2.randomize() == 0) $stop;
    if (obj3.randomize() == 0) $stop;
  end
endmodule
