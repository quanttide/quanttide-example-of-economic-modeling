import Lake
open Lake

package «multi-sides-platform» where
  version := "0.1.0"

@[default_target]
lean_lib «MultiSidesPlatform» where
  -- src dir is lean/ (default: .)
  srcDir := "."
