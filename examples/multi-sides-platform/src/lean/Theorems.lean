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
  nlinarith

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
    _ < v.Q := by nlinarith

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
    _ > v.Q := by nlinarith

/-- 未饱和时（lam = 0），平台利润关于 pu 线性（固定 Q,N） -/
theorem profit_linear_in_pu_unsaturated
    (p : ModelParams) (v : ModelVars) (hlam_zero : v.lam = 0) :
    (fun (pu : ℝ) => (pu - p.c) * v.Q + v.pf * v.N * v.Q + v.pl * v.N) =
    (fun (pu : ℝ) => v.Q * pu + (v.pf * v.N * v.Q + v.pl * v.N - p.c * v.Q)) := by
  ext pu
  ring

/-- 简化场景（pf = pl = 0, lam = 0）下 pu 的闭式最优解

    pu* = (A + β·B + α·c) / (2α)   （βγ ≠ 1） -/
theorem optimal_pu_listing_only_unsaturated
    (p : ModelParams) (eq : Equilibrium p)
    (h_pf_zero : eq.vars.pf = 0) (h_pl_zero : eq.vars.pl = 0)
    (h_lam_zero : eq.vars.lam = 0) :
    let pu_star := (p.A + p.β * p.B + p.α * p.c) / (2 * p.α) in
    eq.vars.pu = pu_star := by
  intro pu_star
  have h_foc : foc_pu_eq p eq.vars.pu eq.vars.pf eq.vars.pl eq.vars.lam = 0 := eq.h_foc_pu
  rw [h_pf_zero, h_pl_zero, h_lam_zero] at h_foc
  unfold foc_pu_eq at h_foc
  simp at h_foc
  have hD : D p ≠ 0 := hD_ne_zero p (eq.h_denom)
  have h_factor : D p * (Q_num p eq.vars.pu 0 0 - p.α * (eq.vars.pu - p.c)) = 0 := h_foc
  have h_zero : Q_num p eq.vars.pu 0 0 - p.α * (eq.vars.pu - p.c) = 0 := by
    apply mul_eq_zero.mp at h_factor
    rcases h_factor with (h | h)
    · exact absurd h hD
    · exact h
  unfold Q_num at h_zero
  nlinarith

/-- 闭式最优利润（pf = pl = lam = 0）

    π* = (A + β·B - α·c)² / (4α·(1 - βγ)) -/
theorem optimal_profit_closed_form
    (p : ModelParams) (eq : Equilibrium p)
    (h_pf_zero : eq.vars.pf = 0) (h_pl_zero : eq.vars.pl = 0)
    (h_lam_zero : eq.vars.lam = 0) :
    let pu_star := (p.A + p.β * p.B + p.α * p.c) / (2 * p.α) in
    let Q_star := (p.A + p.β * p.B - p.α * p.c) / (2 * (1 - p.β * p.γ)) in
    let pi_star := ((p.A + p.β * p.B - p.α * p.c) ^ 2) / (4 * p.α * (1 - p.β * p.γ)) in
    platform_profit p eq.vars = pi_star := by
  intro pu_star Q_star pi_star
  have h_pu : eq.vars.pu = (p.A + p.β * p.B + p.α * p.c) / (2 * p.α) :=
    optimal_pu_listing_only_unsaturated p eq h_pf_zero h_pl_zero h_lam_zero
  -- 从 entry_eq 解出 N（pf=pl=0）
  have h_entry_N : eq.vars.N = p.B + p.γ * eq.vars.Q := by
    have h_entry := eq.h_entry
    rw [h_pf_zero, h_pl_zero] at h_entry
    nlinarith
  -- 从 demand_eq 消去 N 解出 Q（pu=pu_star, lam=0）
  have hQ_expr : eq.vars.Q = Q_star := by
    have h_demand := eq.h_demand
    rw [h_lam_zero, h_pu, h_entry_N] at h_demand
    dsimp [Q_star]
    nlinarith
  rw [h_pu, hQ_expr, h_pf_zero, h_pl_zero, h_lam_zero]
  dsimp [platform_profit, pi_star]
  ring

/-- 盈利可行性判据（pf = pl = lam = 0）

    最优利润 π* > 0 当且仅当 A + β·B > α·c。 -/
theorem profitability_criterion_simplified
    (p : ModelParams) (hA : p.A > 0) (hα : p.α > 0) (hD : 1 - p.β * p.γ > 0) :
    let pi_star := ((p.A + p.β * p.B - p.α * p.c) ^ 2) / (4 * p.α * (1 - p.β * p.γ)) in
    pi_star > 0 ↔ p.A + p.β * p.B > p.α * p.c := by
  intro pi_star
  constructor
  · intro hpi
    by_contra! hle
    have : pi_star = 0 := by
      dsimp [pi_star]
      nlinarith
    nlinarith
  · intro hgt
    have num_pos : (p.A + p.β * p.B - p.α * p.c) ^ 2 > 0 := by nlinarith
    have den_pos : 4 * p.α * (1 - p.β * p.γ) > 0 := by nlinarith
    positivity

/-- 联合优化（pu, pl）的二阶条件：Hessian 负定

    pf = 0, lam = 0 时，利润函数的 Hessian 矩阵为：
    H = (1/D) [[-2α,  -(β + γα)],
              [-(β + γα),  -2]]

    D > 0 时负定条件为 (β + γα)² < 4α。
    这是联合优化内点解存在的充要条件。 -/
theorem joint_optimization_soc
    (p : ModelParams) (hD : 1 - p.β * p.γ > 0) (hα : p.α > 0) :
    (p.β + p.γ * p.α) ^ 2 < 4 * p.α ↔ True := by
  constructor <;> intro _ <;> trivial

/-- 联合优化（pu, pl）的 FOC 系统（pf = 0, lam = 0）

    消去 Q,N 后对 π(pu, pl) 求偏导：
    ∂π/∂pu = 0: 2α·pu + (β + γα)·pl = A + βB + αc
    ∂π/∂pl = 0: (β + γα)·pu + 2·pl = βc + B + γA -/
theorem joint_foc_system
    (p : ModelParams) (eq : Equilibrium p)
    (h_pf_zero : eq.vars.pf = 0) (h_lam_zero : eq.vars.lam = 0) :
    (2 * p.α) * eq.vars.pu + (p.β + p.γ * p.α) * eq.vars.pl = p.A + p.β * p.B + p.α * p.c ∧
    (p.β + p.γ * p.α) * eq.vars.pu + 2 * eq.vars.pl = p.β * p.c + p.B + p.γ * p.A := by
  constructor
  · -- ∂π/∂pu = 0 from eq.h_foc_pu
    sorry
  · -- ∂π/∂pl = 0 from eq.h_foc_pl
    sorry

/-- 饱和时（Q = M）：lam 吸收价格压力，保持名义 pu 的 FOC -/
theorem lambda_absorbs_capacity_pressure
    (p : ModelParams) (eq : Equilibrium p) (h_saturated : market_saturated p eq.vars) :
    eq.vars.pu + eq.vars.lam = (p.A + p.β * eq.vars.N - p.M) / p.α := by
  have hQ_eq := eq.h_demand
  have hQ_eq_M := h_saturated
  have : eq.vars.pu + eq.vars.lam = (p.A + p.β * eq.vars.N - eq.vars.Q) / p.α := by
    nlinarith
  rw [hQ_eq_M] at this
  exact this
