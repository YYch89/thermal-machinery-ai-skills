# Thermal Machinery AI Skills

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.20666571.svg)](https://doi.org/10.5281/zenodo.20666571)

[English](README.md) | [简体中文](README.zh-CN.md)

面向燃气轮机与耦合热力机械系统分阶段动态建模的 AI Agent 工作流。

本仓库提供开源 Codex Skills、建模流程、验证清单和可运行的合成示例，帮助 AI Agent 从工程需求出发，逐步完成设计点计算、稳态闭合校核、动态初始化、Simulink 实现和运行级冒烟检查。

这是较早公开的、面向复杂热力机械系统 AI 辅助动态建模的 skillset 之一。第一个公开运行示例是一个合成双轴燃气轮机模型，已使用 MATLAB/Simulink R2023a 完成运行级验证。

通用热力机械工作流现在会明确要求 AI Agent 先定义模型深度和允许简化程度，把拓扑作为设计变量处理，检查热品位和压力兼容性，并在声称动态或控制效果前确认控制变量具备真实物理执行权限。

这不是简单提示词，也不是单纯代码生成。
这个项目尝试把领域建模经验转化为 AI Agent 可复用的工程化建模工作流。

## 引用

如果你使用本项目，请引用：

```text
Wen, J. (2026). Thermal Machinery AI Skills (v0.1.1) [Software]. Zenodo. https://doi.org/10.5281/zenodo.20666571
```

## 为什么需要这个项目

大语言模型可以快速写出方程和脚本，但复杂热力系统的建模失败往往不是因为少写了几行代码，而是因为建模过程没有分阶段展开。燃气轮机、热机、制冷循环和混合热力系统需要可追溯的假设、部件接口与方程约定、逐节点工质流台账、动态初始条件、特性图有效域检查和验证门槛。

这些 skills 的目标是让 AI Agent 放慢速度，按层次建立模型，并让每一个压力、温度、质量流量、组分、功率平衡、状态变量和假设都可以被审查。

## 建模原则

公开版 skills 强调几条跨热力机械领域通用的规则：

- 实现前先定义模型深度和简化契约：概念拓扑、设计点、可执行设计点复现、稳态对象、简化动态对象、详细动态对象，或控制/优化对象。
- 拓扑是设计变量，不只是示意图。部件顺序、分流/混合、热回收路径、压力等级、轴系、负载和执行机构路径都会决定系统是否可行。
- 不只检查能量守恒，还要检查能量品质和热品位。一个模型可能总能量守恒，但把高品位热量浪费在低温需求上，或者强行指定不可实现的换热器端差。
- 区分简化闭合和详细动态。平衡求解、稳态关联式、简化进度变量、库存型动态状态需要不同证据。
- 控制变量必须有物理执行权限。只有当拓扑中存在真实执行机构、负载、轴系、热源、阀门、电气装置或储能环节时，控制器才有物理意义。
- 模型能运行不等于已经验证。验证需要守恒残差、初始残差、数据来源、约束信号和明确容差。

## 包含的 Skills

### `thermal-machinery-dynamic-modeling`

通用热力机械动态建模工作流 skill。它引导 AI Agent 完成：

- 建模范围与需求梳理；
- 模型深度和简化契约；
- 系统拓扑和节点工质流台账；
- 热品位、压力兼容性和执行机构权限检查；
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
Start with scope, model-depth contract, topology, node ledger, component contracts, dynamic initialization, and validation gates.
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
| model-depth contract | 模型深度契约 |
| simplification contract | 简化契约 |
| design-point calculation | 设计点计算 |
| steady-state closure | 稳态闭合校核 |
| dynamic initialization | 动态初始化 |
| energy quality / heat grade | 能量品质 / 热品位 |
| control authority | 控制权限 / 执行机构权限 |
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
