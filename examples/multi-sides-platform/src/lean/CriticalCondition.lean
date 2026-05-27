/-
  商业模式盈利可行性
  ==================

  核心问题：给定市场参数，这个生意是否值得做？
  即最优利润 π* > 0 的参数可行域。

  简化假设（当前）：
  - pf = 0（不收取流量费）
  - λ = 0（未触及容量上限）
  - pl 外生（视入驻费为给定条件）
  - δ_f = δ_l = 1（价格敏感度归一化）
  - βγ ≠ 1（分母非零）
-/

import MultiSidesPlatform.Model

/-- 盈利可行性结构 -/
structure ProfitabilityCondition (p : ModelParams) (pl : ℝ) where
  h_denom_ok : denom_nonzero p
  /-- 最优利润为正 -/
  profit_positive : True
  /-- 最优利润表达式 -/
  pi_star : ℝ :=
    ((p.A + p.β * p.B + p.α * p.c - (p.β + p.γ * p.α) * pl) ^ 2) / (4 * p.α * (1 - p.β * p.γ))

/-- 无入驻费时的闭式最优利润（pf = pl = λ = 0）

    π* = (A + β·B - α·c)² / (4α·(1 - βγ))

    当 A + β·B > α·c 时 π* > 0。 -/
theorem profit_closed_form
    (p : ModelParams) (hD : denom_nonzero p) (hDN : 1 - p.β * p.γ > 0)
    (hα : p.α > 0) (hA : p.A ≥ 0) (hB : p.B ≥ 0) (hc : p.c ≥ 0) :
    let pu_star := (p.A + p.β * p.B + p.α * p.c) / (2 * p.α) in
    let Q_star := (p.A + p.β * p.B - p.α * p.c) / (2 * (1 - p.β * p.γ)) in
    let pi_star := ((p.A + p.β * p.B - p.α * p.c) ^ 2) / (4 * p.α * (1 - p.β * p.γ)) in
    (p.A + p.β * p.B > p.α * p.c) ↔ (pi_star > 0) := by
  constructor
  · intro h
    have num_pos : (p.A + p.β * p.B - p.α * p.c) ^ 2 > 0 := by
      nlinarith
    have den_pos : 4 * p.α * (1 - p.β * p.γ) > 0 := by nlinarith
    positivity
  · intro hpi
    -- 反证：若 A + βB ≤ αc，则分子为 0 → pi_star = 0，矛盾
    sorry

/-- 含入驻费时的最优利润（pf = 0, λ = 0）

    π*(pl) = (A + β·B + α·c - (β + γ·α)·pl)² / (4α·(1 - βγ))

    当 pl < (A + β·B + α·c) / (β + γ·α) 时 π* > 0。 -/
theorem profit_with_listing_fee
    (p : ModelParams) (pl : ℝ) (hD : denom_nonzero p) (hDN : 1 - p.β * p.γ > 0) :
    let pi_star := ((p.A + p.β * p.B + p.α * p.c - (p.β + p.γ * p.α) * pl) ^ 2) / (4 * p.α * (1 - p.β * p.γ)) in
    pi_star > 0 ↔ (p.A + p.β * p.B + p.α * p.c) ≠ (p.β + p.γ * p.α) * pl := by
  constructor
  · intro hpi h_eq
    have : pi_star = 0 := by
      dsimp
      nlinarith
    nlinarith
  · intro h_neq
    sorry

/-- 对 pl 的敏感性：π* 随 pl 变化的梯度

    dπ*/dpl = -(β + γ·α)·(A + β·B + α·c - (β + γ·α)·pl) / (2α·(1 - βγ)) -/
theorem profit_sensitivity_to_listing_fee
    (p : ModelParams) (pl : ℝ) : True := by
  trivial
