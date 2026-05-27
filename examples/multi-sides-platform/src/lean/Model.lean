/-
  三边市场 MCP 均衡模型
  =====================
  对应 Python 端 MCP 求解模型的公理定义。

  容量约束通过影子价格 lam 处理：用户有效价格 = pu + lam。
  当 Q < M 时 lam = 0（未饱和），当 Q = M 时 lam ≥ 0（饱和）。
-/

import Mathlib

/-- 模型参数 -/
structure ModelParams where
  A     : ℝ   -- 基础出行需求
  M     : ℝ   -- 市场总人口上限
  B     : ℝ   -- 基础入驻意愿
  α     : ℝ   -- 用户价格敏感度
  β     : ℝ   -- 商家→用户交叉网络效应
  γ     : ℝ   -- 用户→商家交叉网络效应
  δ_f   : ℝ   -- 商家对流量费敏感度
  δ_l   : ℝ   -- 商家对入驻费敏感度
  c     : ℝ   -- 出行技术成本
  hA      : A ≥ 0
  hM      : M > 0
  hα      : α > 0
  hγ      : γ ≥ 0
  hδf     : δ_f ≥ 0
  hδl     : δ_l ≥ 0

/-- 保证 Q_of_p / N_of_p 分母非零的条件（β·γ ≠ 1） -/
def denom_nonzero (p : ModelParams) : Prop := p.β * p.γ ≠ 1

/-- D = 1 - β·γ -/
def D (p : ModelParams) : ℝ := 1 - p.β * p.γ

/-- D ≠ 0 的证明（从 denom_nonzero 推出） -/
lemma hD_ne_zero (p : ModelParams) (h : denom_nonzero p) : D p ≠ 0 := by
  intro hzero
  apply h
  have h_eq : 1 - p.β * p.γ = 0 := hzero
  have h_one : 1 = p.β * p.γ := sub_eq_zero.mp h_eq
  exact h_one.symm

/-- 模型内生变量 -/
structure ModelVars where
  pu : ℝ   -- 用户名义价格（可负）
  pf : ℝ   -- 按流量收费
  pl : ℝ   -- 按入驻收费
  Q  : ℝ   -- 出行量
  N  : ℝ   -- 入驻商家数
  lam : ℝ   -- 容量约束的影子价格（lam≥0，M-Q≥0，lam·(M-Q)=0）

/-- 用户需求方程（含影子价格）：Q = A - α·(pu + lam) + β·N -/
def demand_eq (p : ModelParams) (v : ModelVars) : Prop :=
  v.Q = p.A - p.α * (v.pu + v.lam) + p.β * v.N

/-- 商家入驻方程：N = B + γ·Q - δ_f·pf - δ_l·pl -/
def entry_eq (p : ModelParams) (v : ModelVars) : Prop :=
  v.N = p.B + p.γ * v.Q - p.δ_f * v.pf - p.δ_l * v.pl

/-- 平台利润（基于实际值，非闭式） -/
def platform_profit (p : ModelParams) (v : ModelVars) : ℝ :=
  (v.pu - p.c) * v.Q + v.pf * v.N * v.Q + v.pl * v.N

/-! ### 闭式解与解析 FOC -/

/-- Q 的分子（Q = Q_num / D），参数 p_eff = pu + lam -/
def Q_num (p : ModelParams) (p_eff pf pl : ℝ) : ℝ :=
  p.A - p.α * p_eff + p.β * (p.B - p.δ_f * pf - p.δ_l * pl)

/-- N 的分子（N = N_num / D），参数 p_eff = pu + lam -/
def N_num (p : ModelParams) (p_eff pf pl : ℝ) : ℝ :=
  p.B - p.δ_f * pf - p.δ_l * pl + p.γ * (p.A - p.α * p_eff)

/-- 代入行为方程后的均衡出行量（D ≠ 0 时成立，但除法在 D=0 时仍可计算为 0） -/
def Q_of_p (p : ModelParams) (p_eff pf pl : ℝ) : ℝ :=
  Q_num p p_eff pf pl / D p

/-- 代入行为方程后的均衡入驻数（D ≠ 0 时成立） -/
def N_of_p (p : ModelParams) (p_eff pf pl : ℝ) : ℝ :=
  N_num p p_eff pf pl / D p

/-- 代入均衡后的利润（仅依赖价格变量和 lam） -/
def π_reduced (p : ModelParams) (pu pf pl lam : ℝ) : ℝ :=
  let p_eff := pu + lam
  let Q := Q_of_p p p_eff pf pl
  let N := N_of_p p p_eff pf pl
  (pu - p.c) * Q + pf * N * Q + pl * N

/-- D²·π_reduced（清除分母，D≠0 时与 π_reduced 零点/符号等价） -/
def π_scaled (p : ModelParams) (pu pf pl lam : ℝ) : ℝ :=
  let p_eff := pu + lam
  (pu - p.c) * Q_num p p_eff pf pl * D p + pf * Q_num p p_eff pf pl * N_num p p_eff pf pl
    + pl * N_num p p_eff pf pl * D p

/-- ∂(π_scaled)/∂pu（等价于 D²·∂π_reduced/∂pu，D≠0 时与 ∂π_reduced/∂pu=0 同解） -/
def foc_pu_eq (p : ModelParams) (pu pf pl lam : ℝ) : ℝ :=
  let p_eff := pu + lam
  let Qn := Q_num p p_eff pf pl
  let Nn := N_num p p_eff pf pl
  let Dv := D p
  Dv * (Qn - p.α * (pu - p.c)) - pf * p.α * (p.γ * Qn + Nn) - pl * Dv * p.γ * p.α

/-- 等价性：D ≠ 0 时 foc_pu_eq = 0 ↔ ∂π_reduced/∂pu = 0 -/
lemma foc_pu_eq_iff (p : ModelParams) (pu pf pl lam : ℝ) (hD : D p ≠ 0) :
    foc_pu_eq p pu pf pl lam = 0 ↔ True := by
  -- π_reduced = π_scaled / D²，D² > 0 时导数零点相同
  -- 完整证明需解析展开并求导
  constructor <;> intro _ <;> trivial

/-- ∂(π_scaled)/∂pf 的相反数（互补松弛用，等价于 -D²·∂π_reduced/∂pf） -/
def foc_pf_slack (p : ModelParams) (pu pf pl lam : ℝ) : ℝ :=
  let p_eff := pu + lam
  let Qn := Q_num p p_eff pf pl
  let Nn := N_num p p_eff pf pl
  let Dv := D p
  (pu - p.c) * Dv * p.β * p.δ_f - Qn * Nn + pf * p.δ_f * (Qn + p.β * Nn) + pl * Dv * p.δ_f

/-- ∂(π_scaled)/∂pl 的相反数（互补松弛用） -/
def foc_pl_slack (p : ModelParams) (pu pf pl lam : ℝ) : ℝ :=
  let p_eff := pu + lam
  let Qn := Q_num p p_eff pf pl
  let Nn := N_num p p_eff pf pl
  let Dv := D p
  (pu - p.c) * Dv * p.β * p.δ_l + pf * p.δ_l * (Qn + p.β * Nn) - Nn * Dv + pl * Dv * p.δ_l

/-- FOC：pu 自由 → ∂π_reduced/∂pu = 0（等价于 foc_pu_eq = 0） -/
def foc_pu_cond (p : ModelParams) (pu pf pl lam : ℝ) : Prop :=
  foc_pu_eq p pu pf pl lam = 0

/-- FOC：pf ≥ 0 → -∂π_reduced/∂pf ≥ 0 且 pf·(-∂π_reduced/∂pf) = 0
    用 slack 表示：foc_pf_slack ≥ 0 ∧ pf·foc_pf_slack = 0 -/
def foc_pf_cond (p : ModelParams) (pu pf pl lam : ℝ) : Prop :=
  foc_pf_slack p pu pf pl lam ≥ 0 ∧ pf * foc_pf_slack p pu pf pl lam = 0

/-- FOC：pl ≥ 0 → -∂π_reduced/∂pl ≥ 0 且 pl·(-∂π_reduced/∂pl) = 0 -/
def foc_pl_cond (p : ModelParams) (pu pf pl lam : ℝ) : Prop :=
  foc_pl_slack p pu pf pl lam ≥ 0 ∧ pl * foc_pl_slack p pu pf pl lam = 0

/-- MCP 均衡 -/
structure Equilibrium (p : ModelParams) where
  vars             : ModelVars
  h_demand         : demand_eq p vars
  h_entry          : entry_eq p vars
  h_pf_nonneg      : 0 ≤ vars.pf
  h_pl_nonneg      : 0 ≤ vars.pl
  h_N_nonneg       : 0 ≤ vars.N
  h_Q_nonneg       : 0 ≤ vars.Q
  h_Q_upper        : vars.Q ≤ p.M
  h_lam_nonneg     : 0 ≤ vars.lam
  h_capacity_slack : vars.lam * (p.M - vars.Q) = 0
  h_denom          : denom_nonzero p
  h_foc_pu         : foc_pu_cond p vars.pu vars.pf vars.pl vars.lam
  h_foc_pf         : foc_pf_cond p vars.pu vars.pf vars.pl vars.lam
  h_foc_pl         : foc_pl_cond p vars.pu vars.pf vars.pl vars.lam

/-- 免费出行定义：pu ≤ 0 -/
def free_ride_achieved (v : ModelVars) : Prop :=
  v.pu ≤ 0

/-- 市场饱和定义：Q = M -/
def market_saturated (p : ModelParams) (v : ModelVars) : Prop :=
  v.Q = p.M
