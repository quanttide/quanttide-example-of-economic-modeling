/-
  免费出行临界条件
  =================

  平台通过向商家收取入驻费 pl 来交叉补贴用户。
  当 pl 足够高时，平台可设定 pu ≤ 0（免费出行）。

  简化假设：
  - pf = 0（不收取流量费）
  - δ_f = δ_l = 1（价格敏感度归一化）
  - λ = 0（未触及容量上限，Q < M）
  - βγ ≠ 1（分母非零）
  - pl 视为外生参数（简化分析，非联合优化）
-/

import MultiSidesPlatform.Model

/-- 简化参数假设 -/
structure SimplificationAssumption (p : ModelParams) where
  h_unit_δ : p.δ_f = 1 ∧ p.δ_l = 1

/-- 免费出行临界条件

    给定 pl 时，平台最优定价：
    pu*(pl) = (A + β·B + α·c - (β + γ·α)·pl) / (2α)

    令 pu*(pl) ≤ 0 解得：
    pl ≥ (A + β·B + α·c) / (β + γ·α)

    即入驻费需足够高，平台才能用商家收入补贴用户出行。 -/
structure CriticalCondition (p : ModelParams) (pl : ℝ) where
  pl_star        : ℝ := (p.A + p.β * p.B + p.α * p.c) / (p.β + p.γ * p.α)
  h_pl_above     : pl ≥ pl_star
  h_network_ok   : p.β + p.γ * p.α ≠ 0
  h_free_ride    : ∃ (eq : Equilibrium p), free_ride_achieved eq.vars

/-- 命题：当入驻费 pl 足够高时，存在均衡使得 pu ≤ 0。

    设定 pf = 0, δ_f = δ_l = 1, λ = 0，
    pl 需满足：pl ≥ (A + β·B + α·c) / (β + γ·α)

    注意：此为 pl 外生给定时的局部最优，非联合优化（pu, pl）的结果。 -/
theorem free_ride_when_listing_fee_sufficient
    (p : ModelParams) (pl : ℝ) (h_pl_high : pl ≥ (p.A + p.β * p.B + p.α * p.c) / (p.β + p.γ * p.α))
    (h_denom_ok : p.β + p.γ * p.α ≠ 0) :
    ∃ (eq : Equilibrium p), free_ride_achieved eq.vars := by
  -- 构造满足 Equilibrium 条件的 Vars：
  -- 1. 由 ∂π/∂pu = 0 得 pu*(pl) 表达式
  -- 2. 由 pl ≥ pl* 得 pu* ≤ 0
  -- 3. 将 pu*, pl 代入行为方程得 Q, N
  -- 4. 设定 λ = 0（未饱和），验证所有 Equilibrium 约束
  sorry

/-- 推论：免费出行且基础需求足够大时，市场饱和（Q = M）。 -/
theorem free_ride_implies_saturation
    (p : ModelParams) (eq : Equilibrium p)
    (h_free : free_ride_achieved eq.vars)
    (h_demand_strong : p.A + p.β * eq.vars.N ≥ p.M + p.α * (eq.vars.pu + eq.vars.λ)) :
    market_saturated p eq.vars := by
  have hQ_eq := eq.h_demand
  have h_upper := eq.h_Q_upper
  have hQ_ge_M : p.M ≤ eq.vars.Q := by
    linarith
  have hQ_eq_M : eq.vars.Q = p.M := by
    nlinarith
  exact hQ_eq_M
