/-
  免费出行临界条件
  ================
-/

import MultiSidesPlatform.Model

/-- 简化场景假设：δ_f = δ_l = 1。 -/
structure SimplificationAssumption (p : ModelParams) where
  h_unit_δ : p.δ_f = 1 ∧ p.δ_l = 1

/-- 临界条件定义（无容量约束，λ = 0，pf = pl = 0）：

    若 β·γ > α（网络效应强于价格敏感度）
    且 B 高于阈值 B* = (α·c) / (β·γ - α)，
    则存在均衡使得 pu* ≤ 0（免费出行）。

    注意：此为简化充分条件，假设：
    - λ = 0（市场未饱和）
    - pf = pl = 0（仅入驻费场景）
    - δ_f = δ_l = 1（归一化） -/
structure CriticalCondition (p : ModelParams) where
  h_network_strong : p.β * p.γ > p.α
  B_star           : ℝ := (p.α * p.c) / (p.β * p.γ - p.α)
  h_denom_pos      : p.β * p.γ - p.α > 0 := by
    nlinarith
  h_B_above        : p.B > B_star
  h_free_ride      : ∃ (eq : Equilibrium p), free_ride_achieved eq.vars

/-- 命题：在简化场景下，若 β·γ > α 且 B 充分大，则存在均衡使得 pu ≤ 0。 -/
theorem free_ride_when_strong_network_effects
    (p : ModelParams) (h_network : p.β * p.γ > p.α)
    (h_B_large : p.B > (p.α * p.c) / (p.β * p.γ - p.α)) :
    ∃ (eq : Equilibrium p), free_ride_achieved eq.vars := by
  have h_denom_pos : p.β * p.γ - p.α > 0 := by nlinarith
  have h_D_nonzero : D p ≠ 0 := hD_ne_zero p
  -- 待补：构造满足所有 Equilibrium 条件的 Vars
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
