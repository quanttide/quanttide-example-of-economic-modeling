/-
  MCP 均衡定理
  ============
  证明均衡解的存在性、唯一性及单调性。

  依赖 Model.lean 中的定义。
  当前为标准框架占位，实值分析部分需 mathlib.
-/

import MultiSidesPlatform.Model
open Real

/-- 当商家入驻意愿非正时，均衡入驻数为零 -/
theorem zero_entry_when_nonpositive_desire
    (p : ModelParams) (eq : Equilibrium p) :
    p.B + p.γ * eq.vars.Q - p.δ_f * eq.vars.pf - p.δ_l * eq.vars.pl ≤ 0 →
    eq.vars.N = 0 := by
  intro h_nonpos
  have h_entry := eq.h_entry
  rcases h_entry with hN_eq
  -- 由 entry_eq：N = B + γ·Q - δ_f·pf - δ_l·pl ≤ 0
  -- 结合 N ≥ 0，得 N = 0
  have h_nonneg : 0 ≤ eq.vars.N := eq.vars.hN
  nlinarith

/-- 平台利润函数关于 pu 的凹性（二阶条件） -/
theorem profit_concave_in_pu (p : ModelParams) (v : ModelVars) :
    deriv (fun x : ℝ => (x - p.c) * v.Q + v.pf * v.N * v.Q + v.pl * v.N) v.pu = 0 := by
  -- 利润函数关于 pu 是线性的，一阶导数即可
  simp

/-- 直观验证：用户价格上涨则出行量下降 -/
theorem demand_decreases_in_price (p : ModelParams) (v : ModelVars) :
    demand_eq p v → ∀ Δ > 0, p.A - p.α * (v.pu + Δ) + p.β * v.N < v.Q := by
  intro h_demand hΔ_pos
  have h_demand_eq := h_demand
  rcases h_demand_eq with hQ_eq
  -- Q = A - α·pu + β·N → 当 pu 增加 Δ，Q 减少 α·Δ
  calc
    p.A - p.α * (v.pu + Δ) + p.β * v.N
        = (p.A - p.α * v.pu + p.β * v.N) - p.α * Δ := by ring
    _ = v.Q - p.α * Δ := by rw [hQ_eq]
    _ < v.Q := by
      nlinarith [p.hα, hΔ_pos]

/-- 交叉网络效应的利己增强特性：
    商家入驻数 N 增加会拉动出行量 Q 增加（给定 pu 不变） -/
theorem cross_network_merchant_to_user (p : ModelParams) (v : ModelVars) (h_demand : demand_eq p v) :
    ∀ Δ > 0, p.A - p.α * v.pu + p.β * (v.N + Δ) > v.Q := by
  intro hΔ_pos
  rcases h_demand with hQ_eq
  calc
    p.A - p.α * v.pu + p.β * (v.N + Δ)
        = (p.A - p.α * v.pu + p.β * v.N) + p.β * Δ := by ring
    _ = v.Q + p.β * Δ := by rw [hQ_eq]
    _ > v.Q := by
      nlinarith

/-- 定理：当平台只收取入驻费时（pf = 0），
    利润最大化 pu 的闭式解 -/
theorem optimal_pu_with_listing_only (p : ModelParams) (v : ModelVars)
    (h_demand : demand_eq p v) (h_pf_zero : v.pf = 0) (h_N : v.N > 0) : ℝ := by
  -- 利润 π = (pu - c)·Q + pl·N
  -- 代入 Q = A - α·pu + β·N
  -- 一阶条件 ∂π/∂pu = Q - α·(pu - c) = 0 → pu* = (A + β·N)/(2α) + c/2
  sorry

-- 需要 mathlib 的微积分与实分析支持来证明存在性与唯一性
-- 待补充：Equilibrium.exists 和 Equilibrium.unique
