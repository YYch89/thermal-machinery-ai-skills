# Thermal Machinery AI Skills

[English](README.md) | [简体中文](README.zh-CN.md)

面向燃气轮机与耦合热力机械系统分阶段动态建模的 AI Agent 工作流。

本仓库提供开源 Codex Skills、建模流程、验证清单和可运行的合成示例，帮助 AI Agent 从工程需求出发，逐步完成设计点计算、稳态闭合校核、动态初始化、Simulink 实现和运行级冒烟检查。

这是较早公开的、面向复杂热力机械系统 AI 辅助动态建模的 skillset 之一。第一个公开运行示例是一个合成双轴燃气轮机模型，已使用 MATLAB/Simulink R2023a 完成运行级验证。

这不是简单提示词，也不是单纯代码生成。
这个项目尝试把领域建模经验转化为 AI Agent 可复用的工程化建模工作流。

## 为什么需要这个项目

大语言模型可以快速写出方程和脚本，但复杂热力系统的建模失败往往不是因为少写了几行代码，而是因为建模过程没有分阶段展开。燃气轮机、热机、制冷循环和混合热力系统需要可追溯的假设、部件接口与方程约定、逐节点工质流台账、动态初始条件、特性图有效域检查和验证门槛。

这些 skills 的目标是让 AI Agent 放慢速度，按层次建立模型，并让每一个压力、温度、质量流量、组分、功率平衡、状态变量和假设都可以被审查。

## 包含的 Skills

### `thermal-machinery-dynamic-modeling`

通用热力机械动态建模工作流 skill。它引导 AI Agent 完成：

- 建模范围与需求梳理；
- 系统拓扑和节点工质流台账；
- 部件接口、输入输出和方程约定；
- 设计点与稳态一致性检查；
- 动态状态选择和动态初始化；
- 控制或优化接入前的验证门槛。

适用对象包括热机、动力循环、压缩机、透平、泵、风机、燃烧室、反应器、换热器、回热器、混合器、布雷顿循环、朗肯循环、制冷系统、热泵和混合热力系统。

### `gas-turbine-ai-modeling`

面向燃气轮机分阶段建模的领域 skill，尤其关注多轴燃气轮机。它重点覆盖：

- 设计点计算和状态点表；
- MATLAB 到 Simulink 的分阶段建模；
- 压气机和透平特性图；
- 转子、容腔和燃烧室动态；
- 初始条件登记表和配平检查；
- 在开环对象初始化完成后接入控制；
- 动态 Simulink 模型的验证与修复。

## 公开示例

### 合成双轴燃气轮机

`examples/synthetic-dual-shaft-gt-dynamic` 包含一个自洽的公开燃气轮机动态示例，包括：

- MATLAB 设计点数据源；
- 合成压气机特性图数据；
- 额定稳态特性图封装闭合校核；
- 简化动态对象方程；
- Simulink 模型生成脚本；
- 基于 Simulink 原生模块的部件模型生成；
- MATLAB 单元测试和运行级冒烟检查；
- 部件接口约定和验证说明。

该示例是探索级、简化的合成案例，用于展示可审查的建模流程，不代表经过认证的发动机模型或厂商模型。

运行级冒烟检查已使用 MATLAB/Simulink R2023a 验证：

```text
R2023_PUBLIC_GT_CORE_CHECKS_PASSED
R2023_PUBLIC_GT_RUNTTESTS_PASSED
R2023_PUBLIC_GT_README_SCRIPTS_COMPLETED
```

### 合成热泵工质流台账

`examples/synthetic-heat-pump-ledger` 提供一个非燃气轮机的紧凑示例，用于展示通用热力机械工作流中的系统拓扑、节点台账、工质流变量和验证边界。

## 应该使用哪个 Skill？

| 使用场景 | 推荐方式 |
| --- | --- |
| 新建热力系统或混合能量转换拓扑 | 先使用 `thermal-machinery-dynamic-modeling` 梳理范围、拓扑、节点台账、部件约定、初始化和验证门槛。 |
| 燃气轮机设计点、动态对象、特性图拟合、转子/容腔动态或 Simulink 修复 | 使用 `gas-turbine-ai-modeling`。 |
| 包含燃气轮机和其他热力部件的集成系统 | 用 `thermal-machinery-dynamic-modeling` 管理全系统拓扑和工质流台账，再用 `gas-turbine-ai-modeling` 处理燃气轮机子系统。 |
| 快速外部审查某个建模方案 | 使用对应领域 skill，再对照验证清单和交付物要求检查输出。 |

## 快速开始

可以将某个 skill 文件夹复制到 Codex skills 目录，或在 Codex 能加载 skills 的工作区中引用本仓库。

对于新的热力系统：

```text
Use the thermal-machinery-dynamic-modeling skill to plan a dynamic model.
Start with scope, topology, node ledger, component contracts, dynamic initialization, and validation gates.
```

对于燃气轮机：

```text
Use the gas-turbine-ai-modeling skill to build a staged design-point to dynamic modeling workflow.
Do not jump directly to Simulink. Produce state tables, loop contracts, initial-condition registry, and validation gates.
```

在 MATLAB 中运行公开燃气轮机示例：

```matlab
runtests('tests')
run('scripts/build_gt_simulink_model.m')
run('scripts/run_simulink_closed_loop.m')
run('scripts/build_gt_component_native_model.m')
run('scripts/run_component_native_closed_loop.m')
```

Simulink 模型由脚本在本地生成，不提交到仓库中。

## 这个项目不是什么

本仓库不是经过认证的工程仿真器，不是厂商模型，不提供性能保证，也不能替代领域专家审查。仓库不包含专有特性图、私有标定数据、未公开项目模型或安全关键系统认证材料。

这些 skills 提供的是建模纪律、产物模板和验证门槛。真正用于工程研究时，仍然需要有来源支撑的方程、部件数据、实验或厂商验证，以及专业审查。

## 术语翻译约定

| English | 中文译法 |
| --- | --- |
| thermal machinery | 热力机械 |
| coupled thermal-machinery systems | 耦合热力机械系统 |
| staged dynamic modeling | 分阶段动态建模 |
| design-point calculation | 设计点计算 |
| steady-state closure | 稳态闭合校核 |
| dynamic initialization | 动态初始化 |
| smoke-check validation | 运行级冒烟检查 |
| node ledger / stream ledger | 节点台账 / 工质流台账 |
| component contract | 部件接口与方程约定 |
| characteristic map | 特性图 |
| map validity | 特性图有效域 |
| initial-condition registry | 初始条件登记表 |
| trim check | 配平检查 |
| native Simulink blocks | Simulink 原生模块 |

## 发布检查

发布或打标签前运行：

```bash
python scripts/validate_release.py
```

这些检查覆盖仓库结构、隐私和打包安全，不代表工程模型正确性验证。

独立外审提示词见 `docs/external-review-prompts.md`。

## 仓库结构

```text
skills/
  thermal-machinery-dynamic-modeling/
  gas-turbine-ai-modeling/
examples/
  synthetic-dual-shaft-gt-dynamic/
  synthetic-heat-pump-ledger/
docs/
  privacy-review.md
  release-checklist.md
  github-release-plan.md
```

## 维护者说明

本项目由能动方向博士研究生发起，目标是让 AI Agent 更严谨地参与科研建模：不是直接猜一个完整模型答案，而是遵循分阶段、可审查的工程建模流程。

## 许可证

MIT License。见 `LICENSE`。
