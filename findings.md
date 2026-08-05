# 调研记录

## 比赛官网

来源：<https://bxup9uklfcb.feishu.cn/wiki/KNrVwEVFziPHiGkQtwhc6w3gndd>

- 页面标题为“2026 MoonBit 国产基础软件生态开源大赛-8月黑客松活动说明”，最新修改时间显示为 07 月 28 日。
- 8 月黑客松报名截止时间：2026 年 8 月 24 日 24:00。
- 活动面向 MoonBit 生态，鼓励完成生态库、开发工具和示例工程的设计、开发、移植与完善。
- 代码仓库及验收要求：MoonBit 为主要实现语言；仓库公开可访问；README 清晰完整；说明用途、功能、使用方法；有可运行示例；配置 CI；有可运行测试；可正常构建；按要求发布至 mooncakes.io；开发过程和提交记录可追踪；功能边界明确且有后续维护价值；第三方代码、素材和依赖符合许可证要求。
- 项目规模参考为 4,000–10,000 行有效 MoonBit 代码，但不是硬性验收标准；真实可用性、边界、工程结构、文档、测试、示例、维护性和生态价值更重要。
- 页面另列出项目申报、项目类型、移植、开源版权、AI 工具使用、参考方向、奖励及审核反馈章节，后续需逐节核对。
- 已逐节核对关键章节：报名材料需要公开仓库链接、一页左右 Markdown 申报书、现有基础、本次新增内容、预期目标/技术路线，以及预计功能/测试/文档；原创 MoonBit 库、移植库、开发工具和示例工程均可参赛，但应避免与成熟项目高度重合。
- 版权要求：必须采用 OSI 认可许可证；不得提交未经授权私有/闭源/商业/来源不明代码或生成内容；使用、参考或移植开源项目时必须保留版权、许可证和来源说明，并由参赛者自行确认依赖、文档、图片等授权。
- AI 规则允许代码生成、接口设计、测试补全、文档、移植分析、解释、调试和工程改进，但参赛者对目标、技术路线、质量、边界、安全、AI 内容来源/准确性、许可证合规、可解释性、可测试性和可维护性负责；不得借 AI 提交未经授权或来源不明内容。
- 参考方向包括解释器/运行时、事件总线、QUIC、前端状态/表单校验、API 动态规则校验、WebHook 等；方向仅供参考，也可选择其他具有生态价值的项目。通过初审 150 元/人，项目验收再 350 元/人；初审不通过会反馈原因，可按反馈调整后重新提交。

## 用户给定选题

- 标识：`moonbit-abc`
- 方向：ABC notation 解析器
- 核心范围：header、voice、meter、key、bar、repeat、ornament、lyrics；规范化 AST/JSON；pretty printer。
- 生态错位点：不做 MIDI/MusicXML 播放或转换库，聚焦文本谱面、民谣/教学/曲库数据处理。

## 初步生态查重

- Mooncakes 搜索 `ABC notation MoonBit`、`MoonBit music parser MIDI MusicXML`、`MoonBit parser notation` 未发现明确的 ABC notation 成熟实现；结果主要是通用 parser/lexer、tree-sitter 绑定、JSON/字符串 API 与其他格式解析器。
- 进一步检索 Mooncakes 的 `abc`、`midi`、`musicxml`、`music` 关键词：`abc` 命中主要是字符串/哈希示例文本；`music` 命中 raylib 的音频播放绑定；未检索到 ABC notation、MIDI 或 MusicXML 的解析/AST 成熟库。该结论应在 README 中注明为 2026-08-05 的关键词查重快照，不宣称生态永久不存在相关项目。
- 已确认的邻近项目包括 `moonbit-community/sqlparser`（SQL lexer/parser）、`tonyfettes/tree_sitter`（tree-sitter 绑定）、`moonbit-community/cmark`（CommonMark 工具包）。它们说明 MoonBit 有通用解析器生态，但没有证明存在 ABC notation 重复项目。
- 需要在实现前进一步查找 Mooncakes 的 `music`、`midi`、`musicxml`、`abc`、`notation` 关键词，并在 README 中写明查重日期与错位边界。

## 工具和环境

- 当前工作区为空 Git 仓库，无既有源码或提交。
- 本地未找到名为 `osc2026-guide` 的 skill 或 `moonbitlang/skills` 副本；已安装并遵循 MoonBit agent/orientation 指引。
- `firecrawl` CLI 未安装；网页研究使用内置网页访问能力完成。

## 待核对公开来源

- 指定 CI 示例：<https://github.com/PaiGack/moonbitlang-OSC2026/blob/main/.github/workflows/test.yml>
- MoonBit 社区 workflow 模板：<https://github.com/moonbit-community/.github/tree/main/workflow-templates>
- Mooncakes：<https://mooncakes.io>
- MoonBit v0.10.3 包配置文档：<https://docs.moonbitlang.com/en/stable/toolchain/moon/package.html>
- MoonBit v0.10.3 教程中的发布流程：<https://docs.moonbitlang.com/en/stable/tutorial/tour.html>
