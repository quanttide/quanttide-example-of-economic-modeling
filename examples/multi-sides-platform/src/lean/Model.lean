/-
  三边市场 MCP 均衡模型
  =====================
  对应 Python 端 MCP 求解模型的公理定义。
  所有变量和参数取值于 ℝ，与 PATH 求解器数值类型对齐。

  模型结构见 docs/model-mcp.md。
-/

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
  -- 合理参数范围假设
  hA      : A ≥ 0
  hM      : M > 0
  hα      : α > 0
  hγ      : γ ≥ 0          -- γ=0 是有效场景（用户量不影响入驻）
  hδf     : δ_f ≥ 0        -- δ=0 是有效场景（价格不敏感）
  hδl     : δ_l ≥ 0
  h_denom : β * γ ≠ 1      -- 保证 Q_of_p / N_of_p 分母非零

/-- 模型内生变量（不含约束，约束在 Equilibrium 中定义） -/
structure ModelVars where
  pu : ℝ   -- 用户价格（可负，即补贴）
  pf : ℝ   -- 按流量收费
  pl : ℝ   -- 按入驻收费
  Q  : ℝ   -- 出行量
  N  : ℝ   -- 入驻商家数

/-- 用户需求方程：Q = A - α·pu + β·N -/
def demand_eq (p : ModelParams) (v : ModelVars) : Prop :=
  v.Q = p.A - p.α * v.pu + p.β * v.N

/-- 商家入驻方程：N = B + γ·Q - δ_f·pf - δ_l·pl -/
def entry_eq (p : ModelParams) (v : ModelVars) : Prop :=
  v.N = p.B + p.γ * v.Q - p.δ_f * v.pf - p.δ_l * v.pl

/-- 平台利润函数 -/
def platform_profit (p : ModelParams) (v : ModelVars) : ℝ :=
  (v.pu - p.c) * v.Q + v.pf * v.N * v.Q + v.pl * v.N

/-! ### 闭式解与 FOC 解析条件 -/

/-- D = 1 - β·γ（分母） -/
def D (p : ModelParams) : ℝ := 1 - p.β * p.γ

/-- Q 的分子（Q = Q_num / D） -/
def Q_num (p : ModelParams) (pu pf pl : ℝ) : ℝ :=
  p.A - p.α * pu + p.β * (p.B - p.δ_f * pf - p.δ_l * pl)

/-- N 的分子（N = N_num / D） -/
def N_num (p : ModelParams) (pu pf pl : ℝ) : ℝ :=
  p.B - p.δ_f * pf - p.δ_l * pl + p.γ * (p.A - p.α * pu)

/-- 代入行为方程后的均衡出行量（D ≠ 0 时成立） -/
def Q_of_p (p : ModelParams) (pu pf pl : ℝ) : ℝ :=
  Q_num p pu pf pl / D p

/-- 代入行为方程后的均衡入驻数（D ≠ 0 时成立） -/
def N_of_p (p : ModelParams) (pu pf pl : ℝ) : ℝ :=
  N_num p pu pf pl / D p

/-- 代入均衡后的平台利润（仅依赖价格变量） -/
def π (p : ModelParams) (pu pf pl : ℝ) : ℝ :=
  let Q := Q_of_p p pu pf pl
  let N := N_of_p p pu pf pl
  (pu - p.c) * Q + pf * N * Q + pl * N

/-- D²·π = π_scaled（乘以 D² 清除分母，D≠0 时符号/零点不变） -/
def π_scaled (p : ModelParams) (pu pf pl : ℝ) : ℝ :=
  (pu - p.c) * Q_num p pu pf pl * D p + pf * Q_num p pu pf pl * N_num p pu pf pl + pl * N_num p pu pf pl * D p

/-- ∂(π_scaled)/∂pu = D·(Q_num - α·(pu-c)) - pf·α·(γ·Q_num + N_num) - pl·D·γ·α

    等价于 D²·∂π/∂pu = 0（因为 D ≠ 0）。 -/
def foc_pu_eq (p : ModelParams) (pu pf pl : ℝ) : ℝ :=
  let Dv := D p
  let Qn := Q_num p pu pf pl
  let Nn := N_num p pu pf pl
  Dv * (Qn - p.α * (pu - p.c)) - pf * p.α * (p.γ * Qn + Nn) - pl * Dv * p.γ * p.α

/-- ∂(π_scaled)/∂pf 的相反数（FOC 互补松弛用，等价于 -D²·∂π/∂pf） -/
def foc_pf_slack (p : ModelParams) (pu pf pl : ℝ) : ℝ :=
  let Dv := D p
  let Qn := Q_num p pu pf pl
  let Nn := N_num p pu pf pl
  (pu - p.c) * Dv * p.β * p.δ_f - Qn * Nn + pf * p.δ_f * (Qn + p.β * Nn) + pl * Dv * p.δ_f

/-- ∂(π_scaled)/∂pl 的相反数（FOC 互补松弛用） -/
def foc_pl_slack (p : ModelParams) (pu pf pl : ℝ) : ℝ :=
  let Dv := D p
  let Qn := Q_num p pu pf pl
  let Nn := N_num p pu pf pl
  (pu - p.c) * Dv * p.β * p.δ_l + pf * p.δ_l * (Qn + p.β * Nn) - Nn * Dv + pl * Dv * p.δ_l

/-- FOC：pu 自由 → ∂π/∂pu = 0（等价于 foc_pu_eq = 0） -/
def foc_pu_cond (p : ModelParams) (pu pf pl : ℝ) : Prop :=
  foc_pu_eq p pu pf pl = 0

/-- FOC：pf ≥ 0 → foc_pf_slack ≥ 0 且 pf·foc_pf_slack = 0 -/
def foc_pf_cond (p : ModelParams) (pu pf pl : ℝ) : Prop :=
  foc_pf_slack p pu pf pl ≥ 0 ∧ pf * foc_pf_slack p pu pf pl = 0

/-- FOC：pl ≥ 0 → foc_pl_slack ≥ 0 且 pl·foc_pl_slack = 0 -/
def foc_pl_cond (p : ModelParams) (pu pf pl : ℝ) : Prop :=
  foc_pl_slack p pu pf pl ≥ 0 ∧ pl * foc_pl_slack p pu pf pl = 0

/-- MCP 均衡 -/
structure Equilibrium (p : ModelParams) where
  vars          : ModelVars
  h_demand      : demand_eq p vars
  h_entry       : entry_eq p vars
  h_pf_nonneg   : 0 ≤ vars.pf
  h_pl_nonneg   : 0 ≤ vars.pl
  h_N_nonneg    : 0 ≤ vars.N
  h_Q_nonneg    : 0 ≤ vars.Q
  h_Q_upper     : vars.Q ≤ p.M
  h_foc_pu      : foc_pu_cond p vars.pu vars.pf vars.pl
  h_foc_pf      : foc_pf_cond p vars.pu vars.pf vars.pl
  h_foc_pl      : foc_pl_cond p vars.pu vars.pf vars.pl

/-- 免费出行定义：pu ≤ 0 -/
def free_ride_achieved (v : ModelVars) : Prop :=
  v.pu ≤ 0

/-- 市场饱和定义：Q = M -/
def market_saturated (p : ModelParams) (v : ModelVars) : Prop :=
  v.Q = p.M
