#!/usr/bin/env python3
"""
MCP 模型定义与求解
结果交付型城际出行平台（混合收费 + 市场规模上限）
"""
import json
import sys
from pyomo.environ import *
from pyomo.mpec import Complementarity, complements, derivative
from pyomo.opt import SolverStatus


def build_model(params):
    """根据参数构建 MCP 模型"""
    A       = params.get("A", 100)
    M       = params.get("M", 1000)
    B       = params.get("B", 10)
    alpha   = params.get("alpha", 0.5)
    beta    = params.get("beta", 0.8)
    gamma   = params.get("gamma", 0.6)
    delta_f = params.get("delta_f", 0.3)
    delta_l = params.get("delta_l", 0.2)
    c       = params.get("c", 2.0)

    m = ConcreteModel()

    m.Q  = Var(domain=NonNegativeReals, bounds=(0, M), initialize=50)
    m.pu = Var(domain=Reals,            initialize=5)
    m.N  = Var(domain=NonNegativeReals, initialize=30)
    m.pf = Var(domain=NonNegativeReals, initialize=5)
    m.pl = Var(domain=NonNegativeReals, initialize=3)

    m.profit = Expression(
        expr=(m.pu - c) * m.Q + m.pf * m.N * m.Q + m.pl * m.N
    )

    m.demand_eq = Complementarity(
        expr=complements(m.pu, m.Q - (A - alpha * m.pu + beta * m.N))
    )

    m.entry_eq = Complementarity(
        expr=complements(
            m.N,
            m.N - (B + gamma * m.Q - delta_f * m.pf - delta_l * m.pl)
        )
    )

    m.foc_pf = Complementarity(
        expr=complements(m.pf, -derivative(m.profit, m.pf))
    )

    m.foc_pl = Complementarity(
        expr=complements(m.pl, -derivative(m.profit, m.pl))
    )

    m.foc_pu = Complementarity(
        expr=complements(m.pu, derivative(m.profit, m.pu))
    )

    return m


def solve_and_output(params, solver="path", tee=False):
    """求解模型并返回结果字典"""
    model = build_model(params)
    opt = SolverFactory(solver)
    results = opt.solve(model, tee=tee)

    if results.solver.status != SolverStatus.ok:
        return {"status": str(results.solver.status), "error": "求解失败"}

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


def solve_from_file(path, tee=False):
    """从 JSON 文件读取参数并求解"""
    with open(path) as f:
        data = json.load(f)
    params = data if isinstance(data, dict) and "params" not in data else data.get("params", {})
    return solve_and_output(params, tee=tee)


def main():
    """CLI 入口"""
    if len(sys.argv) > 1:
        sol = solve_from_file(sys.argv[1])
    else:
        params = {
            "A": 100, "B": 10, "alpha": 0.5, "beta": 0.8,
            "gamma": 0.6, "delta_f": 0.3, "delta_l": 0.2, "c": 2.0, "M": 1000,
        }
        sol = solve_and_output(params, tee=False)
    print(json.dumps(sol, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
