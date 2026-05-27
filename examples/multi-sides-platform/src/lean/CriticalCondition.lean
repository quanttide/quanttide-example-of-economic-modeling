/-
  免费出行临界条件
  ================
  推导"免费出行"（pu ≤ 0）出现的参数临界条件。

  数学目标：找出 (α, β, γ, c, B, ...) 在何种组合下
  平台最优定价 pu* ≤ 0，即平台选择补贴用户而非收费。
-/

import MultiSidesPlatform.Model
open Real

/-- 简化场景假设：流量费和入驻费敏感性归一化（δ_f = δ_l = 1）。 -/
structure SimplificationAssumption (p : ModelParams) where
  h_unit_δ : p.δ_f = 1 ∧ p.δ_l = 1

/-- 临界条件定义：

    假设 δ_f = δ_l = 1, pf = pl = 0（仅入驻费场景）。
    若 β·γ > α（网络效应强于价格敏感度）
    且 B 高于阈值 B* = (α·c) / (β·γ - α)，
    则存在均衡使得 pu* ≤ 0（免费出行）。 -/
structure CriticalCondition (p : ModelParams) where
  h_network_strong : p.β * p.γ > p.α
  B_star           : ℝ := (p.α * p.c) / (p.β * p.γ - p.α)
  h_denom_pos      : p.β * p.γ - p.α > 0 := by
    nlinarith
  h_B_above        : p.B > B_star
  h_free_ride      : ∃ (eq : Equilibrium p), free_ride_achieved eq.vars

/-- 命题：在简化场景（pf = pl = 0, δ_f = δ_l = 1）下，
    若 β·γ > α 且 B 充分大，则存在均衡使得 pu ≤ 0。 -/
theorem free_ride_when_strong_network_effects
    (p : ModelParams) (h_network : p.β * p.γ > p.α)
    (h_B_large : p.B > (p.α * p.c) / (p.β * p.γ - p.α)) :
    ∃ (eq : Equilibrium p), free_ride_achieved eq.vars := by
  have h_denom_pos : p.β * p.γ - p.α > 0 := by nlinarith
  have h_D_nonzero : D p ≠ 0 := by
    intro hzero
    have : p.β * p.γ = 1 := by linarith
    have h_contra : p.β * p.γ ≤ p.α := by
      nlinarith
    nlinarith
  -- 证明思路：
  -- 1. 设 pf = pl = 0（简化），利润 π(pu) = (pu - c)·Q_of_p(pu, 0, 0)
  -- 2. Q_of_p(pu,0,0) = (A + β·B - α·pu) / (1 - β·γ)
  -- 3. ∂π/∂pu = 0 → pu* 闭式
  -- 4. 代入条件证明 pu* ≤ 0
  -- 完整证明需解析展开 π 并求根，待补
  sorry

/-- 推论：当免费出行时，若基础需求 A 与网络效应 β 足够大，
    出行量 Q 达到市场上限 M。 -/
theorem free_ride_implies_saturation
    (p : ModelParams) (eq : Equilibrium p)
    (h_free : free_ride_achieved eq.vars)
    (h_demand_strong : p.A + p.β * eq.vars.N ≥ p.M + p.α * eq.vars.pu) :
    market_saturated p eq.vars := by
  have hQ_eq := eq.h_demand
  have h_upper := eq.h_Q_upper
  have hQ_ge_M : p.M ≤ eq.vars.Q := by
    linarith
  have hQ_eq_M : eq.vars.Q = p.M := by
    nlinarith
  exact hQ_eq_M
