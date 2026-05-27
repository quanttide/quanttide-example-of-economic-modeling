### 1. 解释业务背景
我们考虑一个**结果交付型城际出行平台**：用户告知平台出行目的，平台直接推荐目的地商家并给出最大出行优惠，极端情况下用户可免费甚至获补贴乘车；平台的收入完全来自目的地商家支付的引流或佣金费用。这不再是简单的出行匹配，而是一个融合了**交通、本地生活与广告**的三边市场。核心商业逻辑是：用出行的"入口"价值，撬动目的地消费的"变现"能力。

#### 平台的混合收费模式

平台向入驻商家收取两种费用：

| 收费类型 | 说明 | 数学表达 |
|----------|------|----------|
| **按流量收费**（引流费） | 每趟出行 × 每个入驻商家，按效果付费 | \(p_f \cdot N \cdot Q\) |
| **按入驻收费**（固定费用） | 每个入驻商家的固定上架/年费 | \(p_l \cdot N\) |

前者激励平台做大交易量，后者提供稳定的基础收入。两种收费并存是多边平台实践中常见的商业模式（如美团的外卖佣金 = 技术服务费 + 履约服务费）。

---

### 2. 经济学建模
将上述业务转化为一个静态、确定性、带交叉网络效应的多边平台一般均衡模型，并用混合互补问题（MCP）描述。

#### 参与者与决策

| 参与者 | 决策变量 | 说明 |
|--------|----------|------|
| **用户** | \(Q \ge 0\) | 出行量，受市场规模 \(M\) 上界约束 |
| **目的地商家** | \(N \ge 0\) | 入驻商家数量 |
| **平台** | \(p_u \in \mathbb{R}\) | 用户价格（可正可负，负值即补贴） |
| **平台** | \(p_f \ge 0\) | 商家按流量费 |
| **平台** | \(p_l \ge 0\) | 商家入驻费 |

#### 行为方程

\[
\begin{aligned}
\text{用户需求：}\quad &Q = A - \alpha p_u + \beta N, \quad 0 \le Q \le M \\
\text{商家入驻：}\quad &N = B + \gamma Q - \delta_f p_f - \delta_l p_l, \quad N \ge 0
\end{aligned}
\]

| 参数 | 含义 |
|------|------|
| \(A\) | 基础出行需求 |
| \(M\) | 市场总人口上限 |
| \(\alpha\) | 用户价格敏感度 |
| \(\beta\) | 商家对用户的交叉网络效应 |
| \(B\) | 基础入驻意愿 |
| \(\gamma\) | 用户量对商家的吸引力 |
| \(\delta_f\) | 商家对流量费的敏感度 |
| \(\delta_l\) | 商家对入驻费的敏感度 |

#### 平台利润

\[
\pi = (p_u - c) \cdot Q + p_f \cdot N \cdot Q + p_l \cdot N
\]

其中 \(c\) 为每趟出行技术成本。

#### MCP 形式

MCP 的核心思想是将整个均衡系统写作"变量 \(\perp\) 互补函数"的形式，由求解器（PATH）**同时求解所有变量**，无需手动推导任何一阶条件的闭式解。每个变量与其对应函数的关系是：

- 若变量 **free** → 函数 **= 0**（等式约束）
- 若变量 **≥ 0** → 函数 **≥ 0**，且 `variable * function = 0`（互补松弛）
- 若变量 **有上下界** → 函数在边界处可不为零

完整 MCP 系统如下：

| 变量 | 边界 | 条件 | 经济含义 |
|:----:|:----:|------|----------|
| \(p_u\) | free | \(Q - (A - \alpha (p_u + \lambda) + \beta N) = 0\) | 用户市场出清（含影子价格） |
| \(p_f\) | \(\ge 0\) | \(p_f \perp \big[ -\pi_{p_f} \big] \ge 0\) | 平台流量费最优 |
| \(p_l\) | \(\ge 0\) | \(p_l \perp \big[ -\pi_{p_l} \big] \ge 0\) | 平台入驻费最优 |
| \(Q\) | \(0 \le Q \le M\) | \(Q \perp \big[ Q - (A - \alpha (p_u + \lambda) + \beta N) \big] \ge 0\) | 用户需求实现（含上限） |
| \(N\) | \(\ge 0\) | \(N \perp \big[ N - (B + \gamma Q - \delta_f p_f - \delta_l p_l) \big] \ge 0\) | 商家入驻实现 |
| \(\lambda\) | \(\ge 0\) | \(\lambda \perp (M - Q) \ge 0\) | 容量影子价格 |

其中 \(\pi_{p_f}\) 和 \(\pi_{p_l}\) 是平台利润对流量费和入驻费的一阶偏导数，由求解器与系统其余部分联合处理。

##### 容量约束与两区制

当出行量未达上限（\(Q < M\)），\(\lambda = 0\)，需求方程退化为 \(Q = A - \alpha p_u + \beta N\)，FOC 基于无约束闭式解 \(Q\_of\_p\) 推导。

当出行量饱和（\(Q = M\)），\(\lambda > 0\)，影子价格抬高了用户有效价格 \(p_u + \lambda\)，使得名义需求与实际供给在 \(Q = M\) 处一致。此时 \(Q\) 不再随 \(p_u\) 变化，平台 FOC 切换为饱和区形式：

\[
\frac{\partial \pi}{\partial p_u} = Q + (p_u - c + p_f N)\frac{\partial Q}{\partial p_u} + p_f Q \frac{\partial N}{\partial p_u} + p_l \frac{\partial N}{\partial p_u}
\]

当 \(Q = M\) 时 \(\partial Q/\partial p_u = 0\)（容量硬约束），且 \(N\) 独立于 \(p_u\)，因此 \(\partial \pi/\partial p_u = M > 0\)。这意味着在饱和区平台**有动机继续提价**，但受需求方程与影子价格的联合约束——\(\lambda\) 在均衡中吸收了这部分涨价压力。

> **关键设计理念**：不手动化简 FOC，不代入消元，将全部变量和条件一次性交给 MCP 求解器。交叉网络效应（\(\beta, \gamma\)）的所有反馈环路在求解时由 PATH 自动处理。这保证了数学一致性，也使得模型扩展（如增加定价维度或非线性项）时只需添加变量和条件，无需重新推导。

该框架能内生决定"免费出行"（\(p_u \le 0\)）出现的临界条件，是分析商业模式可行性的数学核心。混合收费模式下，平台可在流量小时以入驻费保底，流量大时以引流费放大收益。

---

### 3. 代码
以下Python脚本使用**Pyomo**建模，调用**PATH**求解器，并预留与Rust产线的JSON接口。

```python
#!/usr/bin/env python3
"""
结果交付型城际出行平台 MCP 模型（混合收费 + 市场规模上限）
用法：python solve_model.py [params.json]
输出：JSON格式的均衡解（打印到stdout）
"""
import sys, json
from pyomo.environ import *
from pyomo.mpec import Complementarity, complements, derivative
from pyomo.opt import SolverStatus


def build_model(params):
    """根据参数构建MCP模型"""
    # ----- 参数 -----
    A      = params.get("A", 100)       # 基础出行需求
    M      = params.get("M", 1000)      # 市场规模上限
    B      = params.get("B", 10)        # 基础入驻意愿
    alpha  = params.get("alpha", 0.5)   # 用户价格敏感度
    beta   = params.get("beta", 0.8)    # 商家→用户网络效应
    gamma  = params.get("gamma", 0.6)   # 用户→商家网络效应
    delta_f = params.get("delta_f", 0.3) # 流量费敏感度
    delta_l = params.get("delta_l", 0.2) # 入驻费敏感度
    c      = params.get("c", 2.0)       # 出行技术成本

    m = ConcreteModel()

    # ----- 变量 -----
    m.Q  = Var(domain=NonNegativeReals, bounds=(0, M), initialize=50)   # 出行量
    m.pu = Var(domain=Reals,            initialize=5)                  # 用户价格（可负）
    m.N  = Var(domain=NonNegativeReals, initialize=30)                 # 商家数
    m.pf = Var(domain=NonNegativeReals, initialize=5)                  # 按流量费
    m.pl = Var(domain=NonNegativeReals, initialize=3)                  # 入驻费

    # ----- 辅助表达式 -----
    # 利润
    m.profit = Expression(
        expr=(m.pu - c) * m.Q + m.pf * m.N * m.Q + m.pl * m.N
    )

    # ----- MCP 条件 -----
    # 1. 用户市场出清：p_u free → 等式约束
    m.demand_eq = Complementarity(
        expr=complements(m.pu, m.Q - (A - alpha * m.pu + beta * m.N))
    )

    # 2. 商家入驻实现：N ≥ 0 → 互补松弛
    m.entry_eq = Complementarity(
        expr=complements(
            m.N,
            m.N - (B + gamma * m.Q - delta_f * m.pf - delta_l * m.pl)
        )
    )

    # 3. 平台利润对 p_f 最优：p_f ≥ 0 → 互补
    #    使用 Pyomo 的 derivative() 自动计算一阶偏导
    m.foc_pf = Complementarity(
        expr=complements(m.pf, -derivative(m.profit, m.pf))
    )

    # 4. 平台利润对 p_l 最优：p_l ≥ 0 → 互补
    m.foc_pl = Complementarity(
        expr=complements(m.pl, -derivative(m.profit, m.pl))
    )

    # 5. 平台利润对 p_u 最优：p_u free → 等式
    m.foc_pu = Complementarity(
        expr=complements(m.pu, derivative(m.profit, m.pu))
    )

    return m


def solve_and_output(params, solver='path', tee=False):
    """求解模型并返回结果字典"""
    model = build_model(params)
    opt = SolverFactory(solver)
    results = opt.solve(model, tee=tee)

    if results.solver.status != SolverStatus.ok:
        return {"status": str(results.solver.status), "error": "求解失败"}

    # 提取数值
    Q_val   = value(model.Q)
    pu_val  = value(model.pu)
    N_val   = value(model.N)
    pf_val  = value(model.pf)
    pl_val  = value(model.pl)
    c_val   = params.get("c", 2.0)
    M_val   = params.get("M", 1000)

    profit = (pu_val - c_val) * Q_val + pf_val * N_val * Q_val + pl_val * N_val

    sol = {
        "status": str(results.solver.status),
        "Q": round(Q_val, 4),
        "pu": round(pu_val, 4),
        "N": round(N_val, 4),
        "pf": round(pf_val, 4),
        "pl": round(pl_val, 4),
        "platform_profit": round(profit, 4),
        "free_ride_achieved": pu_val <= 0,
        "market_saturated": abs(Q_val - M_val) < 1e-6,
    }
    sol.update(params)
    return sol


def scan_parameter_range(param_name, values, fix_params=None):
    """通用参数扫描函数

    Args:
        param_name: 要扫描的参数名（如 "B"）
        values: 参数取值列表
        fix_params: 固定参数（覆盖默认值）
    """
    base = {"A": 100, "B": 10, "alpha": 0.5, "beta": 0.8,
            "gamma": 0.6, "delta_f": 0.3, "delta_l": 0.2, "c": 2.0, "M": 1000}
    if fix_params:
        base.update(fix_params)

    results = []
    print(f"扫描参数: {param_name}")
    print(f"{'值':>8} {'Q':>8} {'pu':>8} {'N':>8} {'pf':>8} {'pl':>8} {'利润':>10} {'免费':>6} {'饱和':>6}")
    print("-" * 70)

    for v in values:
        base[param_name] = v
        sol = solve_and_output(base)
        sol[param_name] = v
        results.append(sol)
        print(f"{v:8.2f} {sol['Q']:8.2f} {sol['pu']:8.2f} {sol['N']:8.2f} "
              f"{sol['pf']:8.2f} {sol['pl']:8.2f} {sol['platform_profit']:10.2f} "
              f"{'是' if sol['free_ride_achieved'] else '否':>6} "
              f"{'是' if sol['market_saturated'] else '否':>6}")

    # 输出 JSON 供 Rust 消费
    print(json.dumps(results, indent=2, ensure_ascii=False))
    return results


if __name__ == "__main__":
    if len(sys.argv) > 1:
        # 从JSON文件读取参数（便于Rust调用）
        with open(sys.argv[1], 'r') as f:
            inputs = json.load(f)
        params = inputs.get("params", {})

        if "scan" in inputs:
            # 执行参数扫描
            scan_cfg = inputs["scan"]
            results = scan_parameter_range(
                scan_cfg["param"],
                scan_cfg["values"],
                fix_params=params or None,
            )
            # 扫描已经通过 scan_parameter_range 内部输出 JSON
        else:
            # 单点求解
            sol = solve_and_output(params, tee=False)
            print(json.dumps(sol, indent=2))
    else:
        # 默认参数用于快速测试
        params = {"A": 100, "B": 10, "alpha": 0.5, "beta": 0.8,
                  "gamma": 0.6, "delta_f": 0.3, "delta_l": 0.2, "c": 2.0, "M": 1000}
        sol = solve_and_output(params, tee=False)
        print(json.dumps(sol, indent=2))
```

**与Rust产线集成**：Rust进程只需将参数写入`params.json`，执行`python solve_model.py params.json`，然后解析标准输出中的JSON即可获得均衡解及平台利润等指标。

**参数扫描配置示例**（`scan.json`）：
```json
{
    "params": {"alpha": 0.5, "beta": 0.8},
    "scan": {
        "param": "B",
        "values": [0, 5, 10, 15, 20, 25, 30]
    }
}
```

**运行方式**：
```bash
# 单点求解
python solve_model.py params.json

# 参数扫描
python solve_model.py scan.json
```
