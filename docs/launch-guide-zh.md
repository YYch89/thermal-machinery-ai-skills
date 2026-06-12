# 中文发布指南

这个文档解释“发介绍”具体可以怎么做。GitHub 仓库本身已经有 README、topics 和 Release 页面；对外发布通常指在朋友圈、微信群、知乎、公众号、B 站动态、X/Twitter、LinkedIn 或课题组内部渠道发一条项目介绍，引导别人打开 GitHub 链接。

## 发布前确认

1. 打开仓库首页，确认 README 渲染正常。
2. 确认中文入口可见：`README.zh-CN.md`。
3. 打开 Release 页面，确认 `v0.1.0 public preview` 存在。
4. 发布时使用仓库链接：

```text
https://github.com/YYch89/thermal-machinery-ai-skills
```

## 推荐发布顺序

1. 先在小范围渠道发，例如课题组群、朋友圈或专业交流群。
2. 收集 1 到 3 条反馈，重点看别人是否理解这是 AI Agent 建模 workflow，而不是现成商业仿真软件。
3. 再发知乎、公众号或更正式的平台。
4. 后续可以把反馈转成 GitHub Issues，例如“增加 Rankine 示例”“增加中文教程”“增加三轴燃机公开合成案例”。

## 短版介绍

适合朋友圈、微信群、X/Twitter、LinkedIn：

```text
我开源了一个面向复杂热力机械动态建模的 AI Agent Skill 项目：Thermal Machinery AI Skills。

它不是简单提示词，也不是单纯让 AI 写代码，而是把能动领域的建模流程沉淀成 AI 可执行的科研工作流：需求澄清、设计点计算、稳态校核、动态初始化、Simulink 建模、控制接入和运行级冒烟检查。

第一版聚焦燃气轮机动态建模，并附带一个可运行的合成双轴燃气轮机 MATLAB/Simulink 示例，已用 MATLAB/Simulink R2023a 完成 smoke check。

GitHub: https://github.com/YYch89/thermal-machinery-ai-skills
```

## 长版介绍

适合知乎、公众号、个人主页或项目介绍帖：

```text
我开源了一个面向复杂热力机械动态建模的 AI Agent Skill 项目：Thermal Machinery AI Skills。

现在很多 AI 工具已经能快速写公式、写 MATLAB、搭 Simulink 模型，但复杂热力系统建模真正困难的地方，往往不只是代码，而是建模流程本身：需求如何澄清，设计点如何确定，稳态如何闭合，动态状态如何选择，初始条件如何配平，特性图有效域如何检查，控制系统应该在什么阶段接入，以及每一步如何验证。

这个项目尝试把能动领域的建模经验整理成 AI Agent 可执行的工作流。它包含两个开源 skills：

1. thermal-machinery-dynamic-modeling：面向通用热力机械和耦合热力系统；
2. gas-turbine-ai-modeling：面向燃气轮机分阶段建模，覆盖设计点、稳态、动态、特性图、Simulink、控制和验证。

第一版附带一个可运行的合成双轴燃气轮机 MATLAB/Simulink 动态示例，已使用 MATLAB/Simulink R2023a 完成运行级 smoke check。这个示例不是厂商模型，也不是工程认证模型，而是用于展示从 0 到动态模型的可审查建模流程。

我希望这个项目能推动 AI 从“代码助手”进一步走向“科研建模协作者”：让 AI 不只是生成代码，而是按专业建模流程工作，留下可检查的状态点表、部件接口、工质流台账、初始条件登记表和验证记录。

GitHub: https://github.com/YYch89/thermal-machinery-ai-skills
```

## 个人 IP 版本

适合你想把“交大能动博士”身份讲出来的场景：

```text
我是交大能动方向博士研究生，长期关注燃气轮机、复杂热力系统和 AI 科研建模。

最近我开源了 Thermal Machinery AI Skills，一个面向复杂热力机械动态建模的 AI Agent Skill 项目。它的目标不是做一个新的商业仿真软件，而是把能动领域从需求、设计点、稳态、动态、控制到验证的建模流程，转化为 AI Agent 可复用、可审查的科研工作流。

第一版已在一个合成双轴燃气轮机 MATLAB/Simulink 动态示例上完成运行级 smoke check。后续我会继续补充更多热力机械、动力循环和耦合能源系统的公开示例。

GitHub: https://github.com/YYch89/thermal-machinery-ai-skills
```

## 不建议使用的说法

避免直接说：

```text
全球首个。
已经可替代专业仿真软件。
可以直接用于工程设计。
突破所有国外仿真技术壁垒。
```

推荐说：

```text
较早公开的、面向复杂热力机械动态建模的 AI Agent Skill 之一。
已在合成燃气轮机 MATLAB/Simulink 示例上完成运行级 smoke check。
面向科研建模流程，不是工程认证仿真器。
```

这种表达更专业，也更不容易被外部读者质疑。
