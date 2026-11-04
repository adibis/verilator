// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Aditya Shevade
// SPDX-License-Identifier: CC0-1.0

// Rand-index shapes over struct arrays beyond a single 1-D index: each must
// fail with a clean diagnostic, never a crash or a silent solve failure.

typedef struct {
  bit [3:0] tag;
} TagStruct;

typedef struct {
  TagStruct sub[3];
} HasSubArr;

typedef struct {
  TagStruct inner;
} MidStruct;

class MultidimInnerRand;
  rand int idx;
  rand TagStruct arr[2][3];
  constraint c_idx { idx inside {[0:1]}; }
  constraint c { arr[idx][2].tag == 4'h5; }
endclass

class TwoRandIndices;
  rand int i;
  rand int j;
  rand HasSubArr arr[2];
  constraint c_idx { i inside {[0:1]}; j inside {[0:2]}; }
  constraint c { arr[i].sub[j].tag == 4'h5; }
endclass

class QueueNestedConst;
  rand MidStruct q[$];
  constraint c_size { q.size() == 4; }
  constraint c { q[1].inner.tag == 4'h6; }
endclass

class QueueNestedRand;
  rand int idx;
  rand MidStruct q[$];
  constraint c_size { q.size() == 4; }
  constraint c_idx { idx inside {[0:3]}; }
  constraint c { q[idx].inner.tag == 4'h5; }
endclass

class AssocNestedConst;
  rand MidStruct a[int];
  constraint c_size { a.size() == 4; }
  constraint c { a[1].inner.tag == 4'h6; }
endclass

module t;

  initial begin
    automatic MultidimInnerRand o2 = new;
    automatic TwoRandIndices o3 = new;
    automatic QueueNestedConst o4 = new;
    automatic QueueNestedRand o5 = new;
    automatic AssocNestedConst o6 = new;
    if (!bit'(o2.randomize())) $stop;
    if (!bit'(o3.randomize())) $stop;
    if (!bit'(o4.randomize())) $stop;
    if (!bit'(o5.randomize())) $stop;
    if (!bit'(o6.randomize())) $stop;
    $write("*-* All Finished *-*\n");
    $finish;
  end

endmodule
