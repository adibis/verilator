// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Aditya Shevade
// SPDX-License-Identifier: CC0-1.0

// Bare inherited class parameters used as another parameterized class's type
// or value pins (the uvm_config_db#(CFG_T) idiom). The pins resolve to the
// binding taken from the enclosing class's extends pins, or the default when
// unbound, at any depth of the extends chain.

typedef struct packed {
  bit [7:0]  x;
} tag8_t;

typedef struct packed {
  bit [15:0] y;
} tag16_t;

typedef bit [15:0] my16_t;

class Cfg;
  int x = 5;
endclass

class Other;
  int y = 6;
endclass

class Holder#(type T = int);
  static function int bits();
    return $bits(T);
  endfunction
endclass

class CHolder#(type T = Cfg);
  static function int show(T val);
    return 1;
  endfunction
endclass

class VCounter#(int N = 0);
  static function int get();
    return N;
  endfunction
endclass

class CBase#(type CFG_T = Cfg);
endclass

class CLeaf extends CBase #(.CFG_T(Cfg));
  function int check();
    Cfg cfg = new;
    if (CHolder#(CFG_T)::show(cfg) != 1) return 0;
    return 1;
  endfunction
endclass

class Base#(type CFG_T = tag8_t, type U = int, int N = 3, type L = tag8_t);
endclass

class Leaf1 extends Base #(.CFG_T(tag16_t), .N(7));
  function int check();
    if (Holder#(CFG_T)::bits() != 16) return 0;
    if (VCounter#(N)::get() != 7) return 0;
    if (Holder#(U)::bits() != 32) return 0;
    return 1;
  endfunction
endclass

class PBase#(type A = int, int M = 0);
endclass

class LeafPos extends PBase #(tag16_t, 9);
  function int check();
    if (Holder#(A)::bits() != 16) return 0;
    if (VCounter#(M)::get() != 9) return 0;
    return 1;
  endfunction
endclass

class Mid extends Base #(.CFG_T(tag16_t));
endclass

class Leaf3 extends Mid;
  function int check();
    if (Holder#(CFG_T)::bits() != 16) return 0;
    return 1;
  endfunction
endclass

class Mid2#(type Q = int);
endclass

class Leaf4 extends Mid2;
  function int check();
    if (Holder#(Q)::bits() != 32) return 0;
    return 1;
  endfunction
endclass

class BaseD#(type A = int, type B = A);
endclass

class Leaf6 extends BaseD #(.A(tag16_t));
  function int check();
    if (Holder#(B)::bits() != 16) return 0;
    return 1;
  endfunction
endclass

class BaseT#(type C = my16_t);
endclass

class Leaf7a extends BaseT;
  function int check();
    if (Holder#(C)::bits() != 16) return 0;
    return 1;
  endfunction
endclass

class BaseT2#(type C = my16_t);
endclass

class Leaf7b extends BaseT2 #(.C(my16_t));
  function int check();
    if (Holder#(C)::bits() != 16) return 0;
    return 1;
  endfunction
endclass

class LeafP#(type L = int) extends Base #(.CFG_T(L));
  function int check();
    if (Holder#(CFG_T)::bits() != 16) return 0;
    return 1;
  endfunction
endclass

class BaseL#(int K = 3);
  localparam int M = 5;
endclass

class Leaf8 extends BaseL;
  function int check();
    if (VCounter#(M)::get() != 5) return 0;
    return 1;
  endfunction
endclass

class MidPT#(type Z = int, type T = tag8_t) extends Base #(.CFG_T(T));
  function int check();
    if (Holder#(CFG_T)::bits() != 16) return 0;
    return 1;
  endfunction
endclass

class LeafPT extends MidPT #(.T(tag16_t));
  function int check();
    if (Holder#(CFG_T)::bits() != 16) return 0;
    return 1;
  endfunction
endclass

class HasDot;
  localparam int P = 11;
endclass

class LeafDot extends Base;
  function int check();
    if (VCounter#(HasDot::P)::get() != 11) return 0;
    return 1;
  endfunction
endclass

class LeafEmpty extends Base #(.CFG_T());
  function int check();
    if (Holder#(CFG_T)::bits() != 8) return 0;
    return 1;
  endfunction
endclass

typedef Base Base_t;

class LeafTdef extends Base_t #(.CFG_T(tag16_t));
  function int check();
    if (Holder#(CFG_T)::bits() != 16) return 0;
    return 1;
  endfunction
endclass

class BaseV#(int N = 3, int M = 5);
endclass

class LeafV extends BaseV #(.N(7));
  function int check();
    if (VCounter#(M)::get() != 5) return 0;
    return 1;
  endfunction
endclass

class BaseD2#(type A = int, type B = A, type Z = int);
endclass

class Leaf6b extends BaseD2 #(.Z(int));
  function int check();
    if (Holder#(B)::bits() != 32) return 0;
    return 1;
  endfunction
endclass

class BI#(type PI = tag8_t);
endclass

class MidI#(int MI = 0) extends BI;
endclass

class LeafIB extends MidI #(.MI(1));
  function int check();
    if (Holder#(PI)::bits() != 8) return 0;
    return 1;
  endfunction
endclass

class ReaderFirst extends OwnerLater;
  function int check();
    if (Holder#(A)::bits() != 16) return 0;
    return 1;
  endfunction
endclass

class BaseR#(type U = tag8_t, type A = U);
endclass

class OwnerLater extends BaseR #(.U(tag16_t));
endclass

module submod #(int W = 0);
  initial begin
    if (W != 3) $stop;
  end
endmodule

module t;
  parameter int P = 3;
  submod #(.W(P)) u_sub ();
  initial begin
    automatic CLeaf l0 = new;
    automatic Leaf1 l1 = new;
    automatic LeafPos lp = new;
    automatic Leaf3 l3 = new;
    automatic Leaf4 l4 = new;
    automatic Leaf6 l6 = new;
    automatic Leaf7a l7a = new;
    automatic Leaf7b l7b = new;
    automatic LeafP #(.L(tag16_t)) lP = new;
    automatic Leaf8 l8 = new;
    automatic LeafPT lPT = new;
    automatic LeafDot lD = new;
    automatic LeafEmpty lE = new;
    automatic LeafTdef lT = new;
    automatic LeafV lV = new;
    automatic Leaf6b l6b = new;
    automatic LeafIB lIB = new;
    automatic ReaderFirst lRF = new;
    automatic MidPT #(.T(tag16_t)) mPT = new;
    if (l0.check() == 0) $stop;
    if (l1.check() == 0) $stop;
    if (lp.check() == 0) $stop;
    if (l3.check() == 0) $stop;
    if (l4.check() == 0) $stop;
    if (l6.check() == 0) $stop;
    if (l7a.check() == 0) $stop;
    if (l7b.check() == 0) $stop;
    if (lP.check() == 0) $stop;
    if (l8.check() == 0) $stop;
    if (lPT.check() == 0) $stop;
    if (lD.check() == 0) $stop;
    if (lE.check() == 0) $stop;
    if (lT.check() == 0) $stop;
    if (lV.check() == 0) $stop;
    if (l6b.check() == 0) $stop;
    if (lIB.check() == 0) $stop;
    if (lRF.check() == 0) $stop;
    if (mPT.check() == 0) $stop;
    $write("*-* All Finished *-*\n");
    $finish;
  end
endmodule
