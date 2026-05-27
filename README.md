# 量潮经济建模实验室

quanttide-example-of-economic-modeling

多边平台经济建模示例项目，基于混合互补问题（MCP）框架分析平台经济中的交叉网络效应与定价策略。

## 项目结构

```
├── README.md
├── CHANGELOG.md
├── .gitignore
├── examples/
│   └── multi-sides-platform/       # 多边平台经济模型
│       ├── README.md
│       └── docs/
│           └── dev.md              # 模型文档 + Python 实现
└── .agents/
    └── skills/
        └── devops-release/
            └── SKILL.md            # DevOps 发布技能
```

## 模型概述

当前包含一个**结果交付型城际出行平台**的 MCP 模型：

- **用户**：基于效用决定出行并前往平台推荐商家
- **商家**：决定是否入驻平台
- **平台**：同时决定用户价格 \(p_u\) 和商家引流费 \(p_b\) 以最大化利润

技术栈：Python (Pyomo + PATH Solver)，预留 JSON 接口与 Rust 产线集成。

## 快速开始

```bash
# 安装依赖
pip install pyomo

# 运行默认参数
python examples/multi-sides-platform/docs/solve_model.py

# 从 JSON 文件传入参数
python examples/multi-sides-platform/docs/solve_model.py params.json
```

## 许可

Apache 2.0
