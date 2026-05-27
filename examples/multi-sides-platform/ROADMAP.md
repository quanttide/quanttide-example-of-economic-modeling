# ROADMAP

## P0 — 修复（2026-05 已完成）

- [x] `dev.md`: 补充 `derivative` 导入（`from pyomo.mpec import derivative`）
- [x] `dev.md`: 修正注释（`differentiate()` → `derivative()`）
- [x] `dev.md`: MCP 符号表对齐 PATH 标准（`F(x) ≤ 0` → `F(x) ≥ 0`）
- [x] `dev.md`: 参数扫描同时输出 JSON 和表格
- [x] `dev.md`: 求解失败时提前返回，不崩

## P1 — 模型代码健壮性

- [ ] 验证 `derivative()` 在目标 Pyomo 版本中与 `Expression` 对象的兼容性；不兼容则替换为解析导数（`∂π/∂pf = N·Q` 等）
- [ ] 单点求解也输出参数值（方便回放）
- [ ] `scan_parameter_range` 支持保存结果为文件（`--output results.json`）

## P2 — 文档与可维护性

- [ ] 重命名 `docs/dev.md` 为 `docs/model-mcp.md`（当前名称太泛）
- [ ] 补充各参数典型取值范围与物理含义对照表
- [ ] 添加"免费出行临界条件"的解析推导附录

## P3 — 工程集成

- [ ] Rust 产线集成：提供 `solve.py` 入口脚本（已有框架，需测试端到端）
- [ ] 扫描模式支持参数网格搜索（`param1 + param2` 组合扫描）
- [ ] 支持 JSON config 中传入 `solver_options`（容差、迭代上限等）
