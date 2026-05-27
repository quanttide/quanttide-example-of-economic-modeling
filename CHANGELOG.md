# CHANGELOG

## [0.2.0] - 2026-05-27

### Changed

- 混合收费模式：按流量费(p_f) + 按入驻费(p_l)
- 使用 Pyomo derivative() 自动求偏导，不手动推导 FOC
- 通用参数扫描函数 scan_parameter_range()
- 参数扫描改用 JSON 配置文件驱动

### Added

- 市场规模上限 Q ≤ M（参数 M）
- 输出新增 market_saturated 字段
- JSON 参数扫描配置文件格式

## [0.1.0] - 2026-05-27

### Added

- 项目初始化
- 多边平台 MCP 经济模型（结果交付型城际出行平台）
  - 用户需求、商家入驻、平台最优定价
  - Pyomo + PATH Solver 实现
  - Rust 产线 JSON 接口预留
- DevOps 发布技能（SKILL.md）
