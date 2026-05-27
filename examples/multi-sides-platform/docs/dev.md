### 1. 解释业务背景
我们考虑一个**结果交付型城际出行平台**：用户告知平台出行目的，平台直接推荐目的地商家并给出最大出行优惠，极端情况下用户可免费甚至获补贴乘车；平台的收入完全来自目的地商家支付的引流或佣金费用。这不再是简单的出行匹配，而是一个融合了**交通、本地生活与广告**的三边市场。核心商业逻辑是：用出行的“入口”价值，撬动目的地消费的“变现”能力。

### 2. 经济学建模
将上述业务转化为一个静态、确定性、带交叉网络效应的多边平台一般均衡模型，并用混合互补问题（MCP）描述。

- **参与者与决策**
  - **用户**：基于效用决定是否从A城出行至B城并前往平台推荐商家。出行量 \(Q \ge 0\)。
  - **目的地商家**：决定是否入驻平台，入驻数量 \(N \ge 0\)。
  - **平台**：同时决定向用户收取的价格 \(p_u\)（可正可负）和向商家收取的引流费 \(p_b\)，以最大化自身利润。

- **行为方程**
  用户需求：\(Q = A - \alpha p_u + \beta N\) （\(A\):基础需求，\(\alpha\):价格敏感度，\(\beta\):商家对用户的交叉网络效应）
  商家入驻：\(N = B + \gamma Q - \delta p_b\) （\(B\):基础入驻意愿，\(\gamma\):用户量对商家的吸引，\(\delta\):付费敏感度）

- **平台利润与最优条件**
  平台利润：\(\pi = (p_u - c) \cdot Q + p_b \cdot N \cdot Q\)，其中 \(c\) 为每趟出行技术成本。
  平台选择 \(p_u\) 和 \(p_b\) 最大化 \(\pi\)，对应一阶条件（当内点解时）：
  \(\frac{\partial \pi}{\partial p_u} = 0 \;\Longrightarrow\; Q - \alpha(p_u - c + p_b N) = 0\)
  \(\frac{\partial \pi}{\partial p_b} = 0 \;\Longrightarrow\; Q(N - \delta p_b) = 0\)

- **MCP 形式**（变量与互补函数）
  | 变量 | 边界 | 互补关系 |
  |------|------|----------|
  | \(p_u\) | free | \(p_u \perp \big[ Q - (A - \alpha p_u + \beta N) \big] = 0\) |
  | \(N\)   | \(\ge 0\) | \(N \perp \big[ N - (B + \gamma Q - \delta p_b) \big] = 0\) |
  | \(Q\)   | \(\ge 0\) | \(Q \perp \big[ Q - \alpha(p_u - c + p_b N) \big] = 0\) |
  | \(p_b\) | free | \(p_b \perp \big[ N - \delta p_b \big] = 0\) |

该框架能内生决定“免费出行”（\(p_u \le 0\)）出现的临界条件，是分析商业模式可行性的数学核心。

### 3. 代码
以下Python脚本使用**Pyomo**建模，调用**PATH**求解器，并预留与Rust产线的JSON接口。

```python
#!/usr/bin/env python3
"""
结果交付型城际出行平台 MCP 模型
用法：python solve_model.py [params.json]
输出：JSON格式的均衡解（打印到stdout）
"""
import sys, json
from pyomo.environ import *
from pyomo.mpec import Complementarity, complements

def build_model(params):
    """根据参数构建MCP模型"""
    # ----- 参数 -----
    A     = params.get("A", 100)
    B     = params.get("B", 10)
    alpha = params.get("alpha", 0.5)
    beta  = params.get("beta", 0.8)
    gamma = params.get("gamma", 0.6)
    delta = params.get("delta", 0.3)
    c     = params.get("c", 2.0)

    m = ConcreteModel()

    # ----- 变量 -----
    m.Q  = Var(domain=NonNegativeReals, initialize=50)   # 出行量
    m.pu = Var(domain=Reals,          initialize=5)     # 用户价格（可负）
    m.N  = Var(domain=NonNegativeReals, initialize=30)   # 商家数
    m.pb = Var(domain=Reals,          initialize=8)     # 商家引流费

    # ----- MCP 条件 -----
    # 1. 用户需求实现
    m.demand_eq = Complementarity(
        expr=complements(m.pu, m.Q - (A - alpha * m.pu + beta * m.N))
    )
    # 2. 商家入驻实现
    m.entry_eq = Complementarity(
        expr=complements(m.N, m.N - (B + gamma * m.Q - delta * m.pb))
    )
    # 3. 平台利润对pu的一阶条件
    m.foc_pu = Complementarity(
        expr=complements(m.Q, m.Q - alpha * (m.pu - c + m.pb * m.N))
    )
    # 4. 平台利润对pb的一阶条件
    m.foc_pb = Complementarity(
        expr=complements(m.pb, m.N - delta * m.pb)
    )
    return m

def solve_and_output(params, solver='path', tee=False):
    """求解模型并返回结果字典"""
    model = build_model(params)
    opt = SolverFactory(solver)
    results = opt.solve(model, tee=tee)

    # 提取数值
    Q_val   = value(model.Q)
    pu_val  = value(model.pu)
    N_val   = value(model.N)
    pb_val  = value(model.pb)
    c_val   = params.get("c", 2.0)

    profit = (pu_val - c_val) * Q_val + pb_val * N_val * Q_val
    return {
        "status": str(results.solver.status),
        "Q": round(Q_val, 4),
        "pu": round(pu_val, 4),
        "N": round(N_val, 4),
        "pb": round(pb_val, 4),
        "platform_profit": round(profit, 4),
        "free_ride_achieved": pu_val <= 0
    }

def scan_parameter_r(r_values):
    """示例：扫描商家利润率r对均衡的影响（r影响基础商家意愿B）"""
    results = []
    for r in r_values:
        params = {"A":100, "B":r*0.5, "alpha":0.5, "beta":0.8,
                  "gamma":0.6, "delta":0.3, "c":2.0}
        sol = solve_and_output(params)
        sol["r"] = r
        results.append(sol)
        print(f"r={r:3d}, pu={sol['pu']:+.2f}, profit={sol['platform_profit']:.2f}, free={sol['free_ride_achieved']}")
    return results

if __name__ == "__main__":
    if len(sys.argv) > 1:
        # 从JSON文件读取参数（便于Rust调用）
        with open(sys.argv[1], 'r') as f:
            inputs = json.load(f)
        params = inputs.get("params", {})
    else:
        # 默认参数用于快速测试
        params = {"A":100, "B":10, "alpha":0.5, "beta":0.8,
                  "gamma":0.6, "delta":0.3, "c":2.0}

    sol = solve_and_output(params, tee=False)
    # 将结果以JSON字符串形式输出到stdout，供Rust产线捕获
    print(json.dumps(sol, indent=2))
```

**与Rust产线集成**：Rust进程只需将参数写入`params.json`，执行`python solve_model.py params.json`，然后解析标准输出中的JSON即可获得均衡解及平台利润等指标。参数扫描（如寻找免费拐点）可直接在Python脚本内完成，或由Rust循环调用并聚合结果。
