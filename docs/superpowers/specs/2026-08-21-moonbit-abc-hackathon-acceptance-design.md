# moonbit-abc 黑客松验收扩展设计

## 目标

在不修改申报书的前提下，将 `wedarp/moonbit-abc` 完善为可实际用于曲库导入、教学工具和编辑器诊断的 MoonBit ABC notation 工具链。现有公开 API 与 JSON schema v1 是兼容基线；新增能力通过扩展类型、方法、包和 CLI 命令提供。

最终交付必须包含真实有效的 MoonBit 实现、边界测试、可复现基准、成熟项目文档、稳定 CI、可追踪提交历史和 Mooncakes 发布准备。生产 MoonBit 源码目标为 7000 行以上；统计排除 `_build`、`.mooncakes`、依赖、生成接口、空行和注释，并在仓库中提供统计命令与实际结果。

## 范围与架构

保留 `src/abc` 作为稳定公共库，按职责扩展以下层次：

- `source`：统一换行、偏移、行列映射和源码片段提取。
- `scanner`：完整 ABC token 化，支持 header、inline field、music、lyrics、directive、comment、quoted text 和嵌套记号。
- `ast`：保持现有节点和字段兼容，新增语义信息不得改变现有 JSON v1 字段含义。
- `semantics`：按声部维护拍号、单位音长、调号、音符时值、连音、重复段和歌词上下文。
- `analysis`：提供小节完整性、声部一致性、音域、节奏统计、重复结构、歌词覆盖率和曲谱质量报告。
- `diagnostics`：统一错误、警告、提示等级，提供稳定代码、Span、修复建议和 CLI 文本/JSON 输出。
- `normalize`：提供排序、空白策略、换行策略和稳定格式化，保留现有 `pretty_print` 行为。
- `cli`：保留 `check`、`format`、`json`，增加 `analyze`、`check-path`、`format --check` 和 `benchmark`。

数据流为：

```text
ABC source → source map → scanner → parser → compatible AST
           → semantic context → diagnostics / analysis
           → JSON / normalized ABC / CLI reports
```

## 功能设计

### 语法与语义

扩展常见 ABC 字段 `C/O/A/G/S/R/B/F/H/N/Z`，保留未知字段并定义重复字段策略；补充 inline field、directive、微分音标记、broken rhythm、tie/slur、grace note、长休止、chord name、歌词连字符/下划线/星号和多声部切换。

对 `M`、`L`、`K`、`V` 建立上下文，计算音符实际时值、小节拍数、声部活动区间和歌词槽位。提供 `ScoreSummary`、`VoiceSummary`、`MeasureSummary` 和 `RhythmProfile` 等稳定查询结果。

### 分析与诊断

检查小节不完整或超拍、重复段不平衡、声部 metadata 不一致、歌词槽位不足、非法调号/拍号、不可解析 token 和字段冲突。统计音符/休止数量、音域、平均与最大时值、拍号分布、重复结构和歌词覆盖率。

诊断同时支持文本和结构化 JSON，包含 code、severity、message、span 和 hint，并使用稳定的机器可读退出码。只为安全的格式问题提供建议，不自动改变用户谱面的语义。

### CLI 与批量处理

保留现有三个命令，增加：

- `analyze`：输出人类可读或 JSON 分析报告。
- `check-path`：递归检查目录，支持扩展名过滤、并行度参数、错误汇总和非零退出。
- `format --check`：检查规范化状态，不修改文件。
- `benchmark`：对固定样例输出测量结果，并明确运行环境和命令。

增加编辑器集成示例，展示如何把 Span/diagnostic 转成行列范围。

## 兼容性与边界

- `parse`、`validate`、`to_json`、`pretty_print` 和现有 typed parsing API 必须继续可用。
- JSON schema v1 既有字段含义不变；新增字段只采用向后兼容方式。
- 继续明确不实现 MIDI 播放、MusicXML 转换和音频渲染。
- 申报书为只读参考文件，不在本次工程修改中更新。
- README 不出现申报人、结项、唯一贡献者、内部审核过程或申报书修改说明等内部表述，也不保留 GitLink 作为项目交付入口。

## 测试与基准

测试分为单元、属性/不变量、集成和 CLI 层。重点覆盖空输入、超长输入、异常重复记号、未知字段、重复字段、非法时值、零/负边界、CRLF/LF、UTF-8 文本、歌词错位、多声部不一致、目录混合文件和失败退出状态。

必须验证：规范化输出再次解析后关键 AST 语义保持；JSON 字段稳定；Span 始终落在源码范围内；解析器对异常输入不崩溃。

基准样例固定存放在仓库内，分为 small/medium/large，记录源码字节数、行数、节点数、诊断数、解析耗时和分析耗时。基准输出是实际运行结果，不硬编码跨机器性能承诺，也不把结果伪写进实现代码。

## CI、文档与发布

CI 参考指定的 MoonBit workflow 和社区模板，包含 stable 工具链版本输出、格式检查、无警告检查、接口生成一致性、测试、构建、CLI 正负例、批量检查、格式检查和基准 smoke test；发布预检手动触发，不在普通 PR 自动发布。

README 重组为成熟开源项目结构：简介、特性、安装、快速开始、库 API、CLI、架构、测试/基准、贡献、路线图、许可证。完善 `CONTRIBUTING.md`、`CHANGELOG.md`、来源说明、Issue/PR 模板和许可证检查。

GitHub 推送前验证当前 `gh auth` 账号、默认分支、远程地址、作者身份、提交历史、CI 状态、README、许可证和源码统计。Mooncakes 仅在本地验证和远程状态满足条件后按 GitHub 推送流程准备/发布；不操作 GitLink。

## 验收证据

最终报告必须给出实际命令和结果：MoonBit 版本、格式检查、无警告检查、测试数量、构建目标、CLI 正负例、基准原始输出、生产/测试源码行数、Git 提交作者与数量、GitHub 默认分支和 CI 状态、Mooncakes 发布状态。任何未完成项必须明确标记，不用估算或宣传性数字替代证据。
