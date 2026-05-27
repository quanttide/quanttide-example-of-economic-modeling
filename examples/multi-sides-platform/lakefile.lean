import Lake
open System Lake DSL

package «multi-sides-platform» where version := v!"0.1.0"

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git"

lean_lib Model where srcDir := "src/lean"
