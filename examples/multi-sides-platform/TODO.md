# TODO

当前 sprint 聚焦 **P0 — Lean 形式化证明补全** 和 **P1 — Python 代码可执行化**。

---

## 当前 Sprint

### Lean：补全 `free_ride_when_strong_network_effects`

- [ ] 引入 mathlib 依赖到 `lakefile.lean`
- [ ] 在简化条件（pf = pl = 0）下写出 `pu*` 闭式解
- [ ] 证明 `β·γ > α → B > B* → pu* ≤ 0`
- [ ] 将 `Finset` / `Analysis` 中需要的引理单独抽到 `Lemmas.lean`

### Lean：补全 `free_ride_implies_saturation`

- [ ] 写出 `hQ_bound` 约束下的 Q 上游推导
- [ ] 证明 `pu ≤ 0 → Q = M`

### Python：提取可执行代码

- [ ] `src/model.py`：`build_model()` + `solve_and_output()` 从 `dev.md` 提取
- [ ] `src/scan.py`：`scan_parameter_range()` + CLI 入口
- [ ] `pyproject.toml`：添加 `console_scripts` 入口 `solve-model`

### 验证

- [ ] `pytest tests/` 通过
- [ ] `python -m src.model --params data/params.json` 输出 JSON
- [ ] `python -m src.scan --config data/scan.json` 输出表格 + JSON

---

## 待定

- 参数网格搜索（依赖 `scan.py` 可执行化）
- `docs/tutorial.md`
