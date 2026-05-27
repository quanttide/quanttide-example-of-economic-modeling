/-
  MCP 均衡定理
  ============
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

/-- 简化场景（pf = pl = 0, λ = 0）下 pu 的闭式最优解

    设 pf = pl = λ = 0，由需求与入驻方程消去 N：
    Q = (A + β·B - α·pu) / (1 - β·γ)
    π = (pu - c)·Q

    利润对 pu 求导（分母为常数）：
    dπ/dpu ∝ (A + β·B - α·pu) - α·(pu - c) = A + β·B + α·c - 2α·pu

    令为 0 得：pu* = (A + β·B + α·c) / (2α)   （βγ ≠ 1） -/
theorem optimal_pu_listing_only_unsaturated
    (p : ModelParams) (eq : Equilibrium p)
    (h_pf_zero : eq.vars.pf = 0) (h_pl_zero : eq.vars.pl = 0)
    (h_λ_zero : eq.vars.λ = 0) :
    let pu_star := (p.A + p.β * p.B + p.α * p.c) / (2 * p.α) in
    eq.vars.pu = pu_star := by
  -- 代入 pf=pl=λ=0 到 foc_pu_eq = 0 求解：
  -- foc_pu_eq = D·(Qn - α·(pu-c))  (因 pf=pl=λ=0 时 pf·pl 项为零)
  -- foc_pu_eq = 0 → Qn = α·(pu-c)
  -- 展开 Qn = A + β·B - α·pu，代入化简得 pu*
  sorry

/-- 饱和时（Q = M）：λ 吸收价格压力，保持名义 pu 的 FOC -/
theorem lambda_absorbs_capacity_pressure
    (p : ModelParams) (eq : Equilibrium p) (h_saturated : market_saturated p eq.vars) :
    eq.vars.pu + eq.vars.λ = (p.A + p.β * eq.vars.N - p.M) / p.α := by
  have hQ_eq := eq.h_demand
  have hQ_eq_M := h_saturated
  have : eq.vars.pu + eq.vars.λ = (p.A + p.β * eq.vars.N - eq.vars.Q) / p.α := by
    linarith
  rw [hQ_eq_M] at this
  exact this
