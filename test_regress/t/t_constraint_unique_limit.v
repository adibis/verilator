// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Wilson Snyder
// SPDX-License-Identifier: CC0-1.0

// Test that a unique{} constraint on an array-typed foreach slice is
// ignored when its size exceeds --constraint-unique-limit

class Grid;
  rand bit [4:0] grid[3][3];
  constraint c1 {foreach (grid[i, j]) grid[i][j] inside {[1 : 9]};}
  constraint c2 {foreach (grid[i]) unique {grid[i]};}
endclass

module t;
  initial begin
    Grid g;
    g = new;
    void'(g.randomize());

    $write("*-* All Finished *-*\n");
    $finish;
  end
endmodule
