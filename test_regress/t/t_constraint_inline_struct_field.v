// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Aditya Shevade
// SPDX-License-Identifier: CC0-1.0

// Struct field constraints under rand_mode gating. Inline randomize (any
// argument list) marks every member gated, and rand_mode(0) on a struct
// member gates it too, so the member reference lowers to a mode Cond; the
// field select must lift that gate above the select instead of crashing.

typedef struct {
  bit [3:0] tag;
} TagStruct;

typedef struct {
  TagStruct inner;
} MidStruct;

class Flat;
  rand TagStruct s;
  rand int n;
  constraint c { s.tag == 4'h5; }
endclass

class Nested;
  rand MidStruct m;
  rand int n;
  constraint c { m.inner.tag == 4'h5; }
endclass

module t;
  initial begin
    automatic Flat o = new;
    automatic Nested o2 = new;

    // Inline randomize of the sibling only: s keeps its preset value.
    o.s.tag = 4'h5;
    repeat (20) begin
      if (o.randomize(n) == 0) $stop;
      if (o.s.tag != 4'h5) $stop;
    end

    // Inline randomize including the struct: solver assigns the field.
    o.s.tag = 4'h0;
    repeat (20) begin
      if (o.randomize(s, n) == 0) $stop;
      if (o.s.tag != 4'h5) $stop;
    end

    // rand_mode(0) on the struct: preset value preserved, still passes.
    o.s.tag = 4'h5;
    o.s.rand_mode(0);
    repeat (20) begin
      if (o.randomize() == 0) $stop;
      if (o.s.tag != 4'h5) $stop;
    end

    // rand_mode back on: solver assigns the field again.
    o.s.tag = 4'h0;
    o.s.rand_mode(1);
    repeat (20) begin
      if (o.randomize() == 0) $stop;
      if (o.s.tag != 4'h5) $stop;
    end

    // Nested field under inline randomize of the sibling only.
    o2.m.inner.tag = 4'h5;
    repeat (20) begin
      if (o2.randomize(n) == 0) $stop;
      if (o2.m.inner.tag != 4'h5) $stop;
    end

    // Nested field under inline randomize including the struct.
    o2.m.inner.tag = 4'h0;
    repeat (20) begin
      if (o2.randomize(m, n) == 0) $stop;
      if (o2.m.inner.tag != 4'h5) $stop;
    end

    $write("*-* All Finished *-*\n");
    $finish;
  end
endmodule
