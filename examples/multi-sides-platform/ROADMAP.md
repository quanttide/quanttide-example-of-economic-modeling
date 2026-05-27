# ROADMAP

## P0 — 模型验证与证明补全

- [ ] 补齐 Lean 定理的 `nlinarith`/`positivity` 证明（mathlib 编译完成后）
- [ ] 证明 `Equilibrium.exists`：对合法参数构造均衡解
- [ ] 证明 `Equilibrium.unique`：均衡解在给定参数下唯一
- [ ] 将 Lean 模型公理同步到 `docs/model-mcp.md`
- [ ] 参数敏感性分析：扫描各参数，确认模型行为符合经济直觉

## P1 — 模型代码健壮性

- [ ] `model.py` + `scan.py` 已提取为可执行 Python 包（基础版本）
- [ ] 验证 `derivative()` 与 `Expression` 的版本兼容性
- [ ] 单点求解输出参数值
- [ ] `scan_parameter_range` 支持保存结果到文件

## P2 — 文档与可维护性

- [ ] 补充参数典型取值范围与物理含义对照表
- [ ] 添加 `docs/tutorial.md`：端到端从参数配置到求解

## P3 — 扫描与配置增强

- [ ] 扫描模式支持参数网格搜索
- [ ] 支持 JSON config 传入 `solver_options`
