/-
  MCP 均衡定理
  ============
  均衡解的基本性质，依赖 Model.lean 的定义。
-/

import MultiSidesPlatform.Model

/-- 入驻意愿 ≤ 0 时均衡入驻数为零 -/
theorem zero_entry_when_nonpositive_desire
    (p : ModelParams) (eq : Equilibrium p) :
    p.B + p.γ * eq.vars.Q - p.δ_f * eq.vars.pf - p.δ_l * eq.vars.pl ≤ 0 →
    eq.vars.N = 0 := by
  intro h_nonpos
  have hN_eq : eq.vars.N = p.B + p.γ * eq.vars.Q - p.δ_f * eq.vars.pf - p.δ_l * eq.vars.pl :=
    eq.h_entry
  have h_nonneg : 0 ≤ eq.vars.N := eq.h_N_nonneg
  nlinarith

/-- 直接效应：固定 N 和 λ，pu 上涨 → Q 下降 -/
theorem demand_decreases_in_price_partial
    (p : ModelParams) (v : ModelVars) (h_demand : demand_eq p v) :
    ∀ Δ > 0, p.A - p.α * (v.pu + v.λ + Δ) + p.β * v.N < v.Q := by
  intro hΔ_pos
  have hQ_eq := h_demand
  calc
    p.A - p.α * (v.pu + v.λ + Δ) + p.β * v.N
        = (p.A - p.α * (v.pu + v.λ) + p.β * v.N) - p.α * Δ := by ring
    _ = v.Q - p.α * Δ := by rw [hQ_eq]
    _ < v.Q := by nlinarith

/-- 直接效应：N 增加 → Q 增加（固定 pu, λ） -/
theorem cross_network_merchant_to_user_partial
    (p : ModelParams) (v : ModelVars) (h_demand : demand_eq p v) :
    ∀ Δ > 0, p.A - p.α * (v.pu + v.λ) + p.β * (v.N + Δ) > v.Q := by
  intro hΔ_pos
  have hQ_eq := h_demand
  calc
    p.A - p.α * (v.pu + v.λ) + p.β * (v.N + Δ)
        = (p.A - p.α * (v.pu + v.λ) + p.β * v.N) + p.β * Δ := by ring
    _ = v.Q + p.β * Δ := by rw [hQ_eq]
    _ > v.Q := by nlinarith

/-- 未饱和时（λ = 0），平台利润关于 pu 线性（固定 Q,N） -/
theorem profit_linear_in_pu_unsaturated
    (p : ModelParams) (v : ModelVars) (hλ_zero : v.λ = 0) :
    (fun (pu : ℝ) => (pu - p.c) * v.Q + v.pf * v.N * v.Q + v.pl * v.N) =
    (fun (pu : ℝ) => v.Q * pu + (v.pf * v.N * v.Q + v.pl * v.N - p.c * v.Q)) := by
  ext pu
  ring

/-- 简化场景（pf = pl = 0, λ = 0）：均衡 pu 的闭式解

    pu* = (A + β·B - c·(1 - β·γ)) / (2α)   （βγ ≠ 1） -/
theorem optimal_pu_listing_only_unsaturated
    (p : ModelParams) (eq : Equilibrium p)
    (h_pf_zero : eq.vars.pf = 0) (h_pl_zero : eq.vars.pl = 0)
    (h_λ_zero : eq.vars.λ = 0) :
    let pu_star := (p.A + p.β * p.B - p.c * (1 - p.β * p.γ)) / (2 * p.α) in
    eq.vars.pu = pu_star := by
  -- 依赖 eq.h_foc_pu 展开 foc_pu_cond
  -- 代入 pf=pl=λ=0 后 foc_pu_eq = 0 可解出 pu
  sorry

/-- 饱和时（Q = M）：λ 吸收价格压力，使名义 pu 保持 FOC 条件 -/
theorem lambda_absorbs_capacity_pressure
    (p : ModelParams) (eq : Equilibrium p) (h_saturated : market_saturated p eq.vars) :
    eq.vars.pu + eq.vars.λ = (p.A + p.β * eq.vars.N - p.M) / p.α := by
  have h_demand := eq.h_demand
  rcases h_demand with hQ_eq
  -- Q = A - α·(pu + λ) + β·N → pu + λ = (A + β·N - Q) / α
  -- Q = M（饱和）→ pu + λ = (A + β·N - M) / α
  have hQ_eq_M := h_saturated
  have h_expr : eq.vars.Q = p.M := hQ_eq_M
  have : eq.vars.pu + eq.vars.λ = (p.A + p.β * eq.vars.N - eq.vars.Q) / p.α := by
    linarith
  rw [h_expr] at this
  exact this
