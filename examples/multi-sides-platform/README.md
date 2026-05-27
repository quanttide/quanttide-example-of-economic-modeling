# 多边平台网络 — 结果交付型城际出行平台 MCP 模型

## 项目结构

```
├── docs/
│   ├── index.md            ← 文档入口
│   ├── modelling.md        ← 建模策略：为什么先外生 pl
│   ├── symbol-table.md     ← 符号的经济学直觉对照表
│   ├── dev.md              ← 模型推导 + Python 代码
│   └── consolution.md      ← 商业决策建议
├── src/
│   ├── __init__.py
│   ├── model.py            ← MCP 求解 Python 实现
│   └── scan.py             ← 参数扫描入口
├── src/lean/
│   ├── Model.lean          ← 模型定义（参数、变量、FOC、均衡）
│   ├── Theorems.lean       ← 均衡的基本性质
│   └── CriticalCondition.lean ← 盈利可行性条件
├── tests/
│   ├── __init__.py
│   └── test_model.py
├── data/
│   ├── params.json         ← 默认参数配置
│   └── scan.json           ← 扫描配置示例
├── pyproject.toml          ← Python 构建配置
├── lakefile.lean           ← Lean 构建配置
├── ROADMAP.md
└── README.md
```

## 快速入口

| 你想了解什么 | 去哪看 |
|-------------|--------|
| 每个符号是什么意思 | [`docs/symbol-table.md`](docs/symbol-table.md) |
| 为什么把入驻费设成固定的 | [`docs/modelling.md`](docs/modelling.md) |
| 完整的数学推导 + Python 代码 | [`docs/dev.md`](docs/dev.md) |
| 商业决策建议 | [`docs/consolution.md`](docs/consolution.md) |
| Lean 形式化的模型定义 | `src/lean/Model.lean` |
| 盈利可行性的 Lean 定理 | `src/lean/CriticalCondition.lean` |
