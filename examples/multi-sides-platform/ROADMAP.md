# ROADMAP

## P0 — 理论模型验证

### Lean 形式化验证

- [x] 搭建 `src/lean/` 结构，`Model.lean` 定义参数/变量/均衡公理
- [x] `Theorems.lean`：需求单调性、交叉网络效应、零入驻引理
- [x] `CriticalCondition.lean`：免费出行临界条件骨架
- [ ] **补全 `free_ride_when_strong_network_effects` 证明**（需 mathlib 实分析）
- [ ] **补全 `free_ride_implies_saturation` 证明**
- [ ] 证明 `Equilibrium.exists`：对任意合法参数，均衡解存在
- [ ] 证明 `Equilibrium.unique`：均衡解在给定参数下唯一
- [ ] 将完整的模型公理与 Lean 定理同步到 `docs/model-mcp.md`

### 数值验证

- [ ] 推导混合收费模式下"免费出行"临界条件的闭式解，与数值解交叉验证
- [ ] 验证交叉网络效应（β, γ）在极端取值下的均衡存在性与唯一性
- [ ] 检验 **MCP 与等效优化问题**（如平台利润最大化 + 用户/商家反应函数代入）是否给出相同均衡
- [ ] 参数敏感性分析：逐一扫描各参数，确认模型行为符合经济直觉（如 α↑ → Q↓ 等）

## P1 — 模型代码健壮性

- [ ] 提取 `model.py` 和 `scan.py` 从 `docs/dev.md` 为可执行 Python 包
- [ ] 添加 `pyproject.toml` 入口脚本（`console_scripts`）
- [ ] 验证 `derivative()` 在目标 Pyomo 版本中与 `Expression` 对象的兼容性；不兼容则替换为解析导数
- [ ] 单点求解输出参数值（方便回放）
- [ ] `scan_parameter_range` 支持保存结果为文件

## P2 — 文档与可维护性

- [ ] 补充各参数典型取值范围与物理含义对照表
- [ ] 添加"免费出行临界条件"的解析推导附录
- [ ] 添加 `docs/tutorial.md`：端到端从参数配置到求解

## P3 — 扫描与配置增强

- [ ] 扫描模式支持参数网格搜索（`param1 + param2` 组合扫描）
- [ ] 支持 JSON config 中传入 `solver_options`（容差、迭代上限等）
