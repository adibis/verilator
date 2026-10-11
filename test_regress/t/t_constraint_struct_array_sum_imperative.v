// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Aditya Shevade
// SPDX-License-Identifier: CC0-1.0

// verilog_format: off
`define stop $stop
`define checkd(gotv,expv) do if ((gotv) !== (expv)) begin $write("%%Error: %s:%0d:  got=%0d exp=%0d\n", `__FILE__,`__LINE__, (gotv), (expv)); `stop; end while(0);
// The reduction total is pinned by its own constraint, so it can't be the
// signal checked for genuine variation -- track one element's value
// instead, which the solver is still free to distribute differently
// across solves as long as the pinned total still holds.
`define track_varies(signal, prevvar, variedvar) \
  if (longint'(signal) != (prevvar)) variedvar = 1; \
  prevvar = longint'(signal);
// verilog_format: on

// sum()/product()/and() with (item.field) on a dynamically-sized array of
// structs, sized imperatively (new[]) rather than by a solver-visible
// size() constraint -- exercises two independent bugs in the same
// reduction path, without needing the separate, unrelated pre-resize
// sizing-guard fix that a solver-visible size() constraint would require:
//
// 1. The reduction's own dtype was resolved from the array's element type
//    (the whole struct) instead of the with-clause expression's type (the
//    selected field), giving a 1-bit placeholder width instead of the
//    field's real width -- an SMT sort mismatch, always.
// 2. A struct-member access inside the with-clause sets a bounds-check
//    condition meant for one out-of-loop access; left alone it leaked out
//    of the reduction's own visit and wrapped the whole accumulated
//    result in a stale post-loop check, discarding the real value.

class Batch;
  typedef struct {
    rand int val;
  } cmd_s;
  rand cmd_s items[];
  function new();
    items = new[4];
  endfunction
  constraint c_sum {items.sum() with (item.val) == 20;}
endclass

class BatchProduct;
  typedef struct {
    rand int val;
  } cmd_s;
  rand cmd_s items[];
  function new();
    items = new[3];
  endfunction
  constraint c_each {foreach (items[i]) items[i].val inside {[1:4]};}
  constraint c_product {items.product() with (item.val) == 24;}
endclass

class BatchAnd;
  typedef struct {
    rand int val;
  } cmd_s;
  rand cmd_s items[];
  function new();
    items = new[3];
  endfunction
  constraint c_each {foreach (items[i]) items[i].val inside {[10:15]};}
  constraint c_and {items.and() with (item.val) == 8;}
endclass

module t;
  initial begin
    /* verilator lint_off IMPLICITSTATIC */
    Batch b = new;
    BatchProduct bp = new;
    BatchAnd ba = new;
    /* verilator lint_on IMPLICITSTATIC */
    int ok;
    int sum;
    int product;
    int bitand_;
    longint prevBVal, prevBpVal, prevBaVal;
    bit bValVaried, bpValVaried, baValVaried;

    // Seed prev* with one real solve first: a sentinel no real result could
    // equal would make the loop's first comparison always "vary" trivially,
    // without the loop below ever having tested anything.
    void'(b.randomize());
    void'(bp.randomize());
    void'(ba.randomize());
    prevBVal = longint'(b.items[0].val);
    prevBpVal = longint'(bp.items[0].val);
    prevBaVal = longint'(ba.items[0].val);
    repeat (20) begin
      ok = b.randomize();
      `checkd(ok, 1);
      `checkd(b.items.size(), 4);
      sum = 0;
      foreach (b.items[i]) sum += b.items[i].val;
      `checkd(sum, 20);
      `track_varies(b.items[0].val, prevBVal, bValVaried)

      ok = bp.randomize();
      `checkd(ok, 1);
      `checkd(bp.items.size(), 3);
      product = 1;
      foreach (bp.items[i]) product *= bp.items[i].val;
      `checkd(product, 24);
      `track_varies(bp.items[0].val, prevBpVal, bpValVaried)

      ok = ba.randomize();
      `checkd(ok, 1);
      `checkd(ba.items.size(), 3);
      bitand_ = '1;
      foreach (ba.items[i]) bitand_ &= ba.items[i].val;
      `checkd(bitand_, 8);
      `track_varies(ba.items[0].val, prevBaVal, baValVaried)
    end
    if (!bValVaried || !bpValVaried || !baValVaried) `stop;

    $write("*-* All Finished *-*\n");
    $finish;
  end
endmodule
