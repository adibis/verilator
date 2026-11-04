// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Aditya Shevade
// SPDX-License-Identifier: CC0-1.0

// Rand-indexed rand arrays of structs. A rand index into a struct array
// cannot stay a symbolic SMT select (struct arrays are flattened to
// per-element solver variables), so it lowers to a mux over the elements;
// nested field access threads the element name through each struct level.

typedef struct {
  bit [3:0] tag;
} TagStruct;

typedef struct {
  TagStruct inner;
} MidStruct;

typedef struct {
  MidStruct mid;
} OuterStruct;

typedef struct {
  bit [3:0] verylongfieldname;
} LongFieldStruct;

typedef struct {
  TagStruct arr[4];
} HasArr;

class InlineStruct;
  rand int idx;
  rand TagStruct arr[4];
  rand MidStruct marr[4];
  constraint c_idx { idx inside {[0:3]}; }
endclass

class RandIndex1Level;
  rand int idx;
  rand TagStruct arr[4];
  constraint c_idx { idx inside {[0:3]}; }
  constraint c { arr[idx].tag == 4'h5; }
endclass

class RandIndex2Level;
  rand int idx;
  rand MidStruct arr[4];
  constraint c_idx { idx inside {[0:3]}; }
  constraint c { arr[idx].inner.tag == 4'h5; }
endclass

class ConstIndex2Level;
  rand MidStruct arr[4];
  constraint c { arr[2].inner.tag == 4'h5; }
endclass

class ConstIndex3Level;
  rand OuterStruct arr[4];
  constraint c { arr[1].mid.inner.tag == 4'h5; }
endclass

class MemberRooted;
  rand int idx;
  rand HasArr s;
  constraint c_idx { idx inside {[0:3]}; }
  constraint c { s.arr[idx].tag == 4'h5; }
endclass

class NonZeroBase;
  rand int idx;
  rand TagStruct arr[1:4];
  constraint c_idx { idx inside {[1:4]}; }
  constraint c { arr[idx].tag == 4'h5; }
endclass

class OutOfRangeSat;
  rand int idx;
  rand TagStruct arr[3];
  constraint c { idx == 3; arr[idx].tag == 0; }
endclass

class OutOfRangeUnsat;
  rand int idx;
  rand TagStruct arr[3];
  constraint c { idx == 3; arr[idx].tag == 4'h5; }
endclass

class TwoElem;
  rand int idx;
  rand TagStruct arr[2];
  constraint c_idx { idx inside {[0:1]}; }
  constraint c { arr[idx].tag == 4'h5; }
endclass

class SixteenElem;
  rand int idx;
  rand TagStruct arr[16];
  constraint c_idx { idx inside {[0:15]}; }
  constraint c { arr[idx].tag == 4'h5; }
endclass

class LongFieldName;
  rand int idx;
  rand LongFieldStruct arr[4];
  constraint c_idx { idx inside {[0:3]}; }
  constraint c { arr[idx].verylongfieldname == 4'h5; }
endclass

class OneElem;
  rand int idx;
  rand TagStruct arr[1];
  constraint c_idx { idx == 0; }
  constraint c { arr[idx].tag == 4'h5; }
endclass

class MemberMultidim;
  rand int idx;
  rand HasArr m[2];
  constraint c_idx { idx inside {[0:1]}; }
  constraint c { m[idx].arr[2].tag == 4'h5; }
endclass

class MultidimOuterRand;
  rand int idx;
  rand TagStruct arr[2][3];
  constraint c_idx { idx inside {[0:2]}; }
  constraint c { arr[1][idx].tag == 4'h5; }
endclass

class IfGuarded;
  rand bit cond;
  rand int idx;
  rand TagStruct arr[4];
  constraint c_idx { idx inside {[0:3]}; }
  constraint c { if (cond) arr[idx].tag == 4'h5; }
endclass

module t;

  initial begin
    automatic RandIndex1Level o1 = new;
    automatic RandIndex2Level o2 = new;
    automatic ConstIndex2Level o3 = new;
    automatic ConstIndex3Level o4 = new;
    automatic MemberRooted o5 = new;
    automatic NonZeroBase o6 = new;
    automatic OutOfRangeSat o7 = new;
    automatic OutOfRangeUnsat o8 = new;
    automatic IfGuarded o9 = new;
    automatic MultidimOuterRand o10 = new;
    automatic TwoElem o11 = new;
    automatic SixteenElem o12 = new;
    automatic OneElem o13 = new;
    automatic MemberMultidim o14 = new;
    automatic InlineStruct o15 = new;
    automatic LongFieldName o16 = new;

    repeat (20) begin
      if (!bit'(o1.randomize())) $stop;
      if (!(o1.idx inside {[0:3]})) $stop;
      if (o1.arr[o1.idx].tag != 4'h5) $stop;
    end

    repeat (20) begin
      if (!bit'(o2.randomize())) $stop;
      if (!(o2.idx inside {[0:3]})) $stop;
      if (o2.arr[o2.idx].inner.tag != 4'h5) $stop;
    end

    repeat (20) begin
      if (!bit'(o3.randomize())) $stop;
      if (o3.arr[2].inner.tag != 4'h5) $stop;
    end

    repeat (20) begin
      if (!bit'(o4.randomize())) $stop;
      if (o4.arr[1].mid.inner.tag != 4'h5) $stop;
    end

    repeat (20) begin
      if (!bit'(o5.randomize())) $stop;
      if (!(o5.idx inside {[0:3]})) $stop;
      if (o5.s.arr[o5.idx].tag != 4'h5) $stop;
    end

    repeat (20) begin
      if (!bit'(o6.randomize())) $stop;
      if (!(o6.idx inside {[1:4]})) $stop;
      if (o6.arr[o6.idx].tag != 4'h5) $stop;
    end

    // Out-of-range index reads the field default (IEEE 1800-2023 7.4.2)
    if (!bit'(o7.randomize())) $stop;
    if (o7.idx != 3) $stop;

    // ... so a nonzero match out of range is unsatisfiable
    if (bit'(o8.randomize())) $stop;

    repeat (20) begin
      if (!bit'(o9.randomize())) $stop;
      if (o9.cond && o9.arr[o9.idx].tag != 4'h5) $stop;
    end

    repeat (20) begin
      if (!bit'(o10.randomize())) $stop;
      if (!(o10.idx inside {[0:2]})) $stop;
      if (o10.arr[1][o10.idx].tag != 4'h5) $stop;
    end

    repeat (20) begin
      if (!bit'(o11.randomize())) $stop;
      if (!(o11.idx inside {[0:1]})) $stop;
      if (o11.arr[o11.idx].tag != 4'h5) $stop;
    end

    repeat (20) begin
      if (!bit'(o12.randomize())) $stop;
      if (!(o12.idx inside {[0:15]})) $stop;
      if (o12.arr[o12.idx].tag != 4'h5) $stop;
    end

    repeat (20) begin
      if (!bit'(o13.randomize())) $stop;
      if (o13.arr[0].tag != 4'h5) $stop;
    end

    repeat (20) begin
      if (!bit'(o14.randomize())) $stop;
      if (!(o14.idx inside {[0:1]})) $stop;
      if (o14.m[o14.idx].arr[2].tag != 4'h5) $stop;
    end

    repeat (20) begin
      if (!bit'(o15.randomize() with {arr[idx].tag == 4'h5;})) $stop;
      if (o15.arr[o15.idx].tag != 4'h5) $stop;
      if (!bit'(o15.randomize() with {marr[idx].inner.tag == 4'h6;})) $stop;
      if (o15.marr[o15.idx].inner.tag != 4'h6) $stop;
    end

    repeat (20) begin
      if (!bit'(o16.randomize())) $stop;
      if (!(o16.idx inside {[0:3]})) $stop;
      if (o16.arr[o16.idx].verylongfieldname != 4'h5) $stop;
    end

    $write("*-* All Finished *-*\n");
    $finish;
  end

endmodule
