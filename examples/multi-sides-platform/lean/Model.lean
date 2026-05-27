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
  -- 合理的参数范围假设
  hA  : A ≥ 0
  hM  : M > 0
  hα  : α > 0
  hγ  : γ > 0
  hδf : δ_f > 0
  hδl : δ_l > 0

/-- 模型内生变量 -/
structure ModelVars where
  pu : ℝ   -- 用户价格（可负，即补贴）
  pf : ℝ   -- 按流量收费
  pl : ℝ   -- 按入驻收费
  Q  : ℝ   -- 出行量
  N  : ℝ   -- 入驻商家数
  -- 非负约束与上界
  hQ  : 0 ≤ Q ∧ Q ≤ ?_.M   -- 无法直接引用外部 M，改用命题
  hN  : 0 ≤ N
  hpf : 0 ≤ pf
  hpl : 0 ≤ pl

/-- 用户需求方程：Q = A - α·pu + β·N -/
def demand_eq (p : ModelParams) (v : ModelVars) : Prop :=
  v.Q = p.A - p.α * v.pu + p.β * v.N

/-- 商家入驻方程：N = B + γ·Q - δ_f·pf - δ_l·pl -/
def entry_eq (p : ModelParams) (v : ModelVars) : Prop :=
  v.N = p.B + p.γ * v.Q - p.δ_f * v.pf - p.δ_l * v.pl

/-- 平台利润函数 -/
def platform_profit (p : ModelParams) (v : ModelVars) : ℝ :=
  (v.pu - p.c) * v.Q + v.pf * v.N * v.Q + v.pl * v.N

/-- MCP 均衡：所有变量满足其互补条件 -/
structure Equilibrium (p : ModelParams) where
  vars     : ModelVars
  h_demand : demand_eq p vars        -- pu free → 用户市场出清
  h_entry  : entry_eq p vars         -- N ≥ 0 → 商家入驻实现
  h_foc_pf : 0 ≤ vars.pf ∧ vars.pf * (-deriv_profit_pf p vars) = 0
  h_foc_pl : 0 ≤ vars.pl ∧ vars.pl * (-deriv_profit_pl p vars) = 0
  h_foc_pu : 0 = deriv_profit_pu p vars
  h_Q_bound : 0 ≤ vars.Q ∧ vars.Q ≤ p.M
  where
    deriv_profit_pf (p : ModelParams) (v : ModelVars) : ℝ :=
      v.N * v.Q
    deriv_profit_pl (p : ModelParams) (v : ModelVars) : ℝ :=
      v.N
    deriv_profit_pu (p : ModelParams) (v : ModelVars) : ℝ :=
      v.Q

/-- 免费出行定义：pu ≤ 0 -/
def free_ride_achieved (v : ModelVars) : Prop :=
  v.pu ≤ 0

/-- 市场饱和定义：Q = M -/
def market_saturated (p : ModelParams) (v : ModelVars) : Prop :=
  v.Q = p.M
