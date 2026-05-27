/-
  MCP 均衡定理
  ============
  均衡解的基本性质：单调性、边界行为、简化场景下的闭式解。

  依赖于 Model.lean 的定义。实值分析部分需 mathlib。
-/

import MultiSidesPlatform.Model
open Real

/-- 引理：当入驻意愿 ≤ 0 时，均衡入驻数为零 -/
theorem zero_entry_when_nonpositive_desire
    (p : ModelParams) (eq : Equilibrium p) :
    p.B + p.γ * eq.vars.Q - p.δ_f * eq.vars.pf - p.δ_l * eq.vars.pl ≤ 0 →
    eq.vars.N = 0 := by
  intro h_nonpos
  have hN_eq : eq.vars.N = p.B + p.γ * eq.vars.Q - p.δ_f * eq.vars.pf - p.δ_l * eq.vars.pl :=
    eq.h_entry
  have h_nonneg : 0 ≤ eq.vars.N := eq.h_N_nonneg
  nlinarith

/-- 直接效应（partial effect）：其他变量不变时，
    用户价格上涨 → 出行量下降

    注意：这仅是直接效应（固定 N），
    总效应（total effect）需通过 Q_of_p 的闭式分析。 -/
theorem demand_decreases_in_price_partial
    (p : ModelParams) (v : ModelVars) (h_demand : demand_eq p v) :
    ∀ Δ > 0, p.A - p.α * (v.pu + Δ) + p.β * v.N < v.Q := by
  intro hΔ_pos
  have hQ_eq := h_demand
  calc
    p.A - p.α * (v.pu + Δ) + p.β * v.N
        = (p.A - p.α * v.pu + p.β * v.N) - p.α * Δ := by ring
    _ = v.Q - p.α * Δ := by rw [hQ_eq]
    _ < v.Q := by nlinarith

/-- 交叉网络效应的直接效应：商家入驻数 N 增加 → 出行量 Q 增加 -/
theorem cross_network_merchant_to_user_partial
    (p : ModelParams) (v : ModelVars) (h_demand : demand_eq p v) :
    ∀ Δ > 0, p.A - p.α * v.pu + p.β * (v.N + Δ) > v.Q := by
  intro hΔ_pos
  have hQ_eq := h_demand
  calc
    p.A - p.α * v.pu + p.β * (v.N + Δ)
        = (p.A - p.α * v.pu + p.β * v.N) + p.β * Δ := by ring
    _ = v.Q + p.β * Δ := by rw [hQ_eq]
    _ > v.Q := by nlinarith

/-- 平台利润关于 pu 的线性性（固定 Q,N 时） -/
theorem profit_linear_in_pu (p : ModelParams) (v : ModelVars) :
    (fun (pu : ℝ) => (pu - p.c) * v.Q + v.pf * v.N * v.Q + v.pl * v.N) =
    (fun (pu : ℝ) => v.Q * pu + (v.pf * v.N * v.Q + v.pl * v.N - p.c * v.Q)) := by
  ext pu
  ring

/-- 简化场景（pf = pl = 0）：均衡中 pu 的最优闭式解

    当 pf = pl = 0 时，利润 π(pu) = (pu - c)·Q(pu)
    代入需求方程 Q = A - α·pu + β·N
    再代入入驻方程 N = B + γ·Q 消去 N，得 Q(pu) 闭式。

    一阶条件 ∂π/∂pu = 0 给出：
    pu* = (A + β·B - c·(1 - β·γ)) / (2α)   （当 βγ ≠ 1） -/
theorem optimal_pu_listing_only
    (p : ModelParams) (eq : Equilibrium p)
    (h_pf_zero : eq.vars.pf = 0) (h_pl_zero : eq.vars.pl = 0) :
    let pu_star := (p.A + p.β * p.B - p.c * (1 - p.β * p.γ)) / (2 * p.α) in
    eq.vars.pu = pu_star := by
  -- 依赖 eq.h_foc_pu 展开 foc_pu_cond
  -- foc_pu_cond p eq.vars.pu 0 0 展开为 foc_pu_eq = 0
  -- 代入 pf=pl=0 后化简可解出 pu
  -- 完整推导待补
  sorry
