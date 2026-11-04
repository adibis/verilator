// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Aditya Shevade
// SPDX-License-Identifier: CC0-1.0

// Multi-index foreach inside an inline randomize() with{} block. The second
// loop variable must stay local to the generated with-function, not be
// captured as a by-value argument from the outer scope.

class Grid;
  rand bit [4:0] grid[3][3];

  function void all_in_range();
    for (int r = 0; r < 3; r++) begin
      for (int c = 0; c < 3; c++) begin
        if (!(grid[r][c] inside {[1:9]})) $stop;
      end
    end
  endfunction
endclass

class GridArg;
  rand bit [4:0] grid[3][3];
  rand int x;

  function void all_in_range();
    for (int r = 0; r < 3; r++) begin
      for (int c = 0; c < 3; c++) begin
        if (!(grid[r][c] inside {[1:9]})) $stop;
      end
    end
  endfunction
endclass

module t;

  initial begin
    automatic Grid g = new;
    automatic GridArg ga = new;

    // Filed shape: multi-index foreach, inline with, no randomize argument
    repeat (20) begin
      if (!bit'(g.randomize() with {foreach (grid[i, j]) grid[i][j] inside {[1:9]};}))
        $stop;
      g.all_in_range();
    end

    // Same shape with randomize() arguments (grid must be randomized too,
    // else the range check on its all-zero initial value is unsatisfiable)
    repeat (20) begin
      if (!bit'(ga.randomize(x, grid) with {foreach (grid[i, j]) grid[i][j] inside {[1:9]};}))
        $stop;
      ga.all_in_range();
    end

    // Single-index inline with (control: worked before the fix)
    repeat (20) begin
      if (!bit'(g.randomize() with {foreach (grid[i]) grid[i][0] inside {[1:9]};}))
        $stop;
      if (!(g.grid[0][0] inside {[1:9]})) $stop;
    end

    $write("*-* All Finished *-*\n");
    $finish;
  end

endmodule
