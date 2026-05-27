# 多边平台经济模型

## 一句话讲清这个项目在做什么

一个**结果交付型城际出行平台**的 MCP 均衡模型——平台向商家收入驻费，用这笔钱补贴用户出行。模型回答的核心问题是：**免费出行在什么条件下是可持续的？**

---

## 三句话讲清模型逻辑

```
         你（用户）          商家
            ↘              ↗
        付票价（可负）    交入驻费
            ↓           ↑
            ﹊﹊ 平 台 ﹊﹊
```

1. **用户**想要便宜甚至免费的出行（\(Q = A - \alpha p_u + \beta N\)）
2. **商家**想要更多客流（\(N = B + \gamma Q - \delta_f p_f - \delta_l p_l\)）
3. **平台**当中间人——向商家收入驻费，用这笔钱补贴用户（\(\pi = \underbrace{(p_u - c)Q}_{\text{客运收入}} + \underbrace{p_f N Q}_{\text{流量费}} + \underbrace{p_l N}_{\text{入驻费}}\)）

---

## 核心直觉：免费出行何时出现？

关键条件：

> **网络效应的滚雪球速度（βγ）> 用户对价格的敏感度（α）**

用大白话解释：

- 你因为补贴少花了钱 → 吸引了更多客流 → 吸引了更多商家入驻 → 商家交了更多入驻费 → 平台赚回了补贴你的钱
- 如果这个循环跑得通（βγ > α），免费出行就是可持续的
- 如果跑不通（βγ ≤ α），补贴一个用户的成本超过了它能带来的商家收入，平台不该免费

具体门槛：入驻费 \(p_l\) 需足够高，超过临界值 \(p_l^* = \dfrac{A + \beta B + \alpha c}{\beta + \gamma\alpha}\)。

---

## 项目结构

```
docs/
├── index.md              ← 你在这里
├── modelling.md          ← 建模策略：为什么先外生 pl
├── symbol-table.md       ← 所有符号的经济学直觉对照表
└── dev.md                ← 完整的模型推导 + Python 代码

src/lean/
├── Model.lean            ← 模型定义（参数、变量、FOC、均衡）
├── CriticalCondition.lean ← 免费出行临界条件
└── Theorems.lean         ← 均衡的基本性质
```

## 快速入口

| 你想了解什么 | 去哪看 |
|-------------|--------|
| 每个符号是什么意思 | [`symbol-table.md`](symbol-table.md) |
| 为什么把入驻费设成固定的 | [`modelling.md`](modelling.md) |
| 完整的数学推导 + Python 代码 | [`dev.md`](dev.md) |
| Lean 形式化的模型定义 | `src/lean/Model.lean` |
| 免费出行临界条件的 Lean 定理 | `src/lean/CriticalCondition.lean` |
