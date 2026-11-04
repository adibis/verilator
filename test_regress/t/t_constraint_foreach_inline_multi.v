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

class Cube;
  rand bit [3:0] cube[2][2][2];
endclass

module t;

  initial begin
    automatic Grid g = new;
    automatic GridArg ga = new;
    automatic Cube cu = new;
    bit [3:0] sarr[2][2];
    int std_result;

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

    // Three loop variables -- the third also sits mid-list under the header
    repeat (20) begin
      if (!bit'(cu.randomize() with {foreach (cube[i, j, k]) cube[i][j][k] inside {[2:7]};}))
        $stop;
      for (int i = 0; i < 2; i++)
        for (int j = 0; j < 2; j++)
          for (int k = 0; k < 2; k++)
            if (!(cu.cube[i][j][k] inside {[2:7]})) $stop;
    end

    // std::randomize() with{} goes through the same capture path
    repeat (20) begin
      std_result = std::randomize(
          sarr) with {foreach (sarr[i, j]) sarr[i][j] inside {[3:5]};};
      if (std_result != 1) $stop;
      for (int i = 0; i < 2; i++)
        for (int j = 0; j < 2; j++) if (!(sarr[i][j] inside {[3:5]})) $stop;
    end

    $write("*-* All Finished *-*\n");
    $finish;
  end

endmodule
