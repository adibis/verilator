// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Aditya Shevade
// SPDX-License-Identifier: CC0-1.0

class InnerR;
  rand bit [7:0] target[2];
  rand bit [7:0] scalarVal;
endclass

// Fixed-size class-handle array (lowers h[idx] to an AstArraySel).
class CFixed;
  rand int idx;
  rand InnerR h[2];
  rand bit [7:0] probe[2];
  constraint ci { idx inside {[0:1]}; }
  constraint c { probe == h[idx].target; }
  function new();
    h[0] = new;
    h[1] = new;
  endfunction
endclass

// Same rand-index-into-member-select shape, but the member itself is scalar.
class CFixedScalar;
  rand int idx;
  rand InnerR h[2];
  rand bit [7:0] probe;
  constraint ci { idx inside {[0:1]}; }
  constraint c { probe == h[idx].scalarVal; }
  function new();
    h[0] = new;
    h[1] = new;
  endfunction
endclass

// Queue of class handles (lowers h[idx] to an AstCMethodHard ARRAY_AT).
class CQueue;
  rand int idx;
  rand InnerR h[$];
  rand bit [7:0] probe;
  constraint ci { idx inside {[0:1]}; }
  constraint c { probe == h[idx].scalarVal; }
  function new();
    InnerR elemp;
    elemp = new;
    h.push_back(elemp);
    elemp = new;
    h.push_back(elemp);
  endfunction
endclass

module t;
  initial begin
    CFixed f;
    CFixedScalar fs;
    CQueue q;
    f = new;
    fs = new;
    q = new;
    void'(f.randomize());
    void'(fs.randomize());
    void'(q.randomize());
  end
endmodule
