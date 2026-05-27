/-
  MCP 均衡定理
  ============
-/

import Model

/-- 入驻意愿 ≤ 0 时均衡入驻数为零 -/
theorem zero_entry_when_nonpositive_desire
    (p : ModelParams) (eq : Equilibrium p) :
    p.B + p.γ * eq.vars.Q - p.δ_f * eq.vars.pf - p.δ_l * eq.vars.pl ≤ 0 →
    eq.vars.N = 0 := by
  intro h_nonpos
  have hN_eq : eq.vars.N = p.B + p.γ * eq.vars.Q - p.δ_f * eq.vars.pf - p.δ_l * eq.vars.pl :=
    eq.h_entry
  have h_nonneg : 0 ≤ eq.vars.N := eq.h_N_nonneg
  sorry

/-- 直接效应：固定 N 和 lam，pu 上涨 → Q 下降 -/
theorem demand_decreases_in_price_partial
    (p : ModelParams) (v : ModelVars) (h_demand : demand_eq p v) :
    ∀ Δ > 0, p.A - p.α * (v.pu + v.lam + Δ) + p.β * v.N < v.Q := by
  intro hΔ_pos
  have hQ_eq := h_demand
  calc
    p.A - p.α * (v.pu + v.lam + Δ) + p.β * v.N
        = (p.A - p.α * (v.pu + v.lam) + p.β * v.N) - p.α * Δ := by ring
    _ = v.Q - p.α * Δ := by rw [hQ_eq]
    _ < v.Q := by sorry

/-- 直接效应：N 增加 → Q 增加（固定 pu, lam） -/
theorem cross_network_merchant_to_user_partial
    (p : ModelParams) (v : ModelVars) (h_demand : demand_eq p v) :
    ∀ Δ > 0, p.A - p.α * (v.pu + v.lam) + p.β * (v.N + Δ) > v.Q := by
  intro hΔ_pos
  have hQ_eq := h_demand
  calc
    p.A - p.α * (v.pu + v.lam) + p.β * (v.N + Δ)
        = (p.A - p.α * (v.pu + v.lam) + p.β * v.N) + p.β * Δ := by ring
    _ = v.Q + p.β * Δ := by rw [hQ_eq]
    _ > v.Q := by sorry

/-- 未饱和时（lam = 0），平台利润关于 pu 线性（固定 Q,N） -/
theorem profit_linear_in_pu_unsaturated
    (p : ModelParams) (v : ModelVars) (hlam_zero : v.lam = 0) :
    (fun (pu : ℝ) => (pu - p.c) * v.Q + v.pf * v.N * v.Q + v.pl * v.N) =
    (fun (pu : ℝ) => v.Q * pu + (v.pf * v.N * v.Q + v.pl * v.N - p.c * v.Q)) := by
  ext pu
  ring

/-- 简化场景（pf = pl = 0, lam = 0）下 pu 的闭式最优解

    设 pf = pl = lam = 0，由需求与入驻方程消去 N：
    Q = (A + β·B - α·pu) / (1 - β·γ)
    π = (pu - c)·Q

    利润对 pu 求导（分母为常数）：
    dπ/dpu ∝ (A + β·B - α·pu) - α·(pu - c) = A + β·B + α·c - 2α·pu

    令为 0 得：pu* = (A + β·B + α·c) / (2α)   （βγ ≠ 1） -/
theorem optimal_pu_listing_only_unsaturated
    (p : ModelParams) (eq : Equilibrium p)
    (h_pf_zero : eq.vars.pf = 0) (h_pl_zero : eq.vars.pl = 0)
    (h_lam_zero : eq.vars.lam = 0) :
    let pu_star := (p.A + p.β * p.B + p.α * p.c) / (2 * p.α) in
    eq.vars.pu = pu_star := by
  have h_foc : foc_pu_eq p eq.vars.pu eq.vars.pf eq.vars.pl eq.vars.lam = 0 := eq.h_foc_pu
  rw [h_pf_zero, h_pl_zero, h_lam_zero] at h_foc
  unfold foc_pu_eq at h_foc
  simp at h_foc
  have hD : D p ≠ 0 := hD_ne_zero p
  have h_factor : D p * (Q_num p eq.vars.pu 0 0 - p.α * (eq.vars.pu - p.c)) = 0 := h_foc
  have h_zero : Q_num p eq.vars.pu 0 0 - p.α * (eq.vars.pu - p.c) = 0 := by
    apply mul_eq_zero.mp at h_factor
    rcases h_factor with (h | h)
    · exact absurd h hD
    · exact h
  unfold Q_num at h_zero
  sorry

/-- 闭式最优利润（pf = pl = lam = 0）

    代入 pu* = (A + βB + αc)/(2α) 到 π = (pu-c)·Q 得：
    π* = (A + βB - αc)² / (4α·(1 - βγ)) -/
theorem optimal_profit_closed_form
    (p : ModelParams) (eq : Equilibrium p)
    (h_pf_zero : eq.vars.pf = 0) (h_pl_zero : eq.vars.pl = 0)
    (h_lam_zero : eq.vars.lam = 0) :
    let pu_star := (p.A + p.β * p.B + p.α * p.c) / (2 * p.α) in
    let Q_star := (p.A + p.β * p.B - p.α * p.c) / (2 * (1 - p.β * p.γ)) in
    let pi_star := ((p.A + p.β * p.B - p.α * p.c) ^ 2) / (4 * p.α * (1 - p.β * p.γ)) in
    platform_profit p eq.vars = pi_star := by
  -- 由 optimal_pu_listing_only_unsaturated 得 eq.vars.pu = pu_star
  -- 代入 demand_eq, entry_eq 消去 Q,N 得利润表达式
  sorry

/-- 盈利可行性判据（pf = pl = lam = 0）

    最优利润 π* > 0 当且仅当 A + β·B > α·c。
    即净基础需求（潜在出行 - 成本门槛）为正。 -/
theorem profitability_criterion_simplified
    (p : ModelParams) (hA : p.A > 0) (hα : p.α > 0) (hD : 1 - p.β * p.γ > 0) :
    let pi_star := ((p.A + p.β * p.B - p.α * p.c) ^ 2) / (4 * p.α * (1 - p.β * p.γ)) in
    pi_star > 0 ↔ p.A + p.β * p.B > p.α * p.c := by
  constructor
  · intro hpi
    by_contra! hle
    have : pi_star = 0 := by
      dsimp
      nlinarith
    nlinarith
  · intro hgt
    have num_pos : (p.A + p.β * p.B - p.α * p.c) ^ 2 > 0 := by
      nlinarith
    have den_pos : 4 * p.α * (1 - p.β * p.γ) > 0 := by nlinarith
    positivity

/-- 饱和时（Q = M）：lam 吸收价格压力，保持名义 pu 的 FOC -/
theorem lambda_absorbs_capacity_pressure
    (p : ModelParams) (eq : Equilibrium p) (h_saturated : market_saturated p eq.vars) :
    eq.vars.pu + eq.vars.lam = (p.A + p.β * eq.vars.N - p.M) / p.α := by
  have hQ_eq := eq.h_demand
  have hQ_eq_M := h_saturated
  have : eq.vars.pu + eq.vars.lam = (p.A + p.β * eq.vars.N - eq.vars.Q) / p.α := by
    sorry
  rw [hQ_eq_M] at this
  exact this
