#!/usr/bin/env python3
"""
参数扫描 CLI
"""
import json
import sys

from .model import solve_and_output


def scan_parameter_range(param_name, values, fix_params=None):
    """通用参数扫描函数"""
    base = {
        "A": 100, "B": 10, "alpha": 0.5, "beta": 0.8,
        "gamma": 0.6, "delta_f": 0.3, "delta_l": 0.2, "c": 2.0, "M": 1000,
    }
    if fix_params:
        base.update(fix_params)

    results = []
    print(f"扫描参数: {param_name}")
    header = f"{'值':>8} {'Q':>8} {'pu':>8} {'N':>8} {'pf':>8} {'pl':>8} {'利润':>10} {'免费':>6} {'饱和':>6}"
    print(header)
    print("-" * len(header))

    for v in values:
        base[param_name] = v
        sol = solve_and_output(base)
        sol[param_name] = v
        results.append(sol)
        print(
            f"{v:8.2f} {sol['Q']:8.2f} {sol['pu']:8.2f} {sol['N']:8.2f} "
            f"{sol['pf']:8.2f} {sol['pl']:8.2f} {sol['platform_profit']:10.2f} "
            f"{'是' if sol['free_ride_achieved'] else '否':>6} "
            f"{'是' if sol['market_saturated'] else '否':>6}"
        )

    print()
    print(json.dumps(results, indent=2, ensure_ascii=False))
    return results


def main():
    if len(sys.argv) < 2:
        print("用法: solve-scan <scan.json>", file=sys.stderr)
        sys.exit(1)

    with open(sys.argv[1]) as f:
        inputs = json.load(f)

    params = inputs.get("params", {})
    scan_cfg = inputs["scan"]

    scan_parameter_range(
        scan_cfg["param"],
        scan_cfg["values"],
        fix_params=params or None,
    )


if __name__ == "__main__":
    main()
