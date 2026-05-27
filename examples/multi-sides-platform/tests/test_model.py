import json
import pytest
from src.model import build_model, solve_and_output

DEFAULT_PARAMS = {
    "A": 100, "B": 10, "alpha": 0.5, "beta": 0.8,
    "gamma": 0.6, "delta_f": 0.3, "delta_l": 0.2, "c": 2.0, "M": 1000,
}


def test_build_model():
    m = build_model(DEFAULT_PARAMS)
    assert hasattr(m, "Q")
    assert hasattr(m, "pu")
    assert hasattr(m, "N")
    assert hasattr(m, "pf")
    assert hasattr(m, "pl")
    assert hasattr(m, "demand_eq")
    assert hasattr(m, "entry_eq")
    assert hasattr(m, "foc_pf")
    assert hasattr(m, "foc_pl")
    assert hasattr(m, "foc_pu")


@pytest.mark.skipif(
    True, reason="需要 PATH 求解器环境才能运行"
)
def test_solve_default():
    sol = solve_and_output(DEFAULT_PARAMS, tee=False)
    assert sol["status"] == "ok"
    assert sol["Q"] > 0
    assert sol["N"] > 0


def test_solve_output_keys():
    sol = solve_and_output(DEFAULT_PARAMS, tee=False)
    expected_keys = {
        "status", "Q", "pu", "N", "pf", "pl",
        "platform_profit", "free_ride_achieved", "market_saturated",
    }
    assert expected_keys.issubset(sol.keys()), f"缺少键: {expected_keys - sol.keys()}"
    assert isinstance(sol["free_ride_achieved"], bool)
    assert isinstance(sol["market_saturated"], bool)


def test_build_model_with_custom_params():
    params = {**DEFAULT_PARAMS, "M": 500, "alpha": 1.0}
    m = build_model(params)
    assert m.Q.ub == 500
