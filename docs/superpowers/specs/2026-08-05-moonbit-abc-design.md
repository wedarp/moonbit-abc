# moonbit-abc 设计说明

## 背景与目标

`moonbit-abc` 是一个纯 MoonBit 优先的 ABC notation 文本处理库，并配套一个可直接运行的命令行示例。它面向民谣谱面、音乐教学材料和曲库文本处理，负责把 ABC 文本解析为带来源位置的结构化 AST，执行语法与结构校验，输出稳定的 JSON，并将 AST 规范化打印回可读的 ABC 文本。

本项目不把播放、音频合成、MIDI 导出或 MusicXML 转换作为本次交付目标。这样可以保持与现有音乐播放/格式转换项目的边界差异，同时为未来增加事件导出、曲库索引、编辑器诊断和 ABC 方言扩展保留稳定接口。

## 比赛约束对齐

- 核心功能全部使用 MoonBit 实现；仅使用标准库或经过核对的 Mooncakes 依赖。
- 仓库提供 README、申报材料、来源说明、许可证、可执行示例、测试和 GitHub Actions CI。
- CI 与本地验证覆盖 `moon fmt --deny-warn`、`moon info --deny-warn`、`moon check`、`moon test` 和构建。
- 目标工具链按组委会建议的 MoonBit 0.10.3 验证；当前本机报告为 `moon 0.1.20260713`，实现阶段需要确认安装器、CI action 与 0.10.3 的实际版本标识，并在文档中记录真实输出。
- 通过小步、可追踪的真实提交形成至少 10 次有效提交；提交作者只使用仓库所有者本人，不添加机器人或虚拟贡献者。
- 采用 Apache-2.0；不复制来源不明的实现，第三方来源、规范参考和依赖均在 `docs/sources.md` 中列出。

## 方案选择

### 选择：库 + CLI + 校验/规范化工具链

核心库提供可复用 API，CLI 提供评审和用户快速体验入口，校验器与 pretty printer 让项目不止是“能解析一份样例”的演示，而是可以加入教学/曲库处理流程的基础工具。MIDI/MusicXML 只作为明确的非目标，避免与音乐数据转换库产生高度重合。

### 放弃的方案

- 只做解析库：实现成本低，但运行示例、工程价值和后续扩展入口不足。
- 同时做 MIDI/MusicXML 转换：范围大且容易重复已有音乐生态，无法在有限时间内把 ABC 文本诊断做深。

## 分层结构

```text
moonbit-abc/
├─ moon.mod                         # 模块元数据
├─ moon.pkg                         # 根包配置（如工具链需要）
├─ src/abc/
│  ├─ moon.pkg                      # 可发布公共包
│  ├─ span.mbt                      # Span、位置和来源上下文
│  ├─ diagnostics.mbt               # Severity、DiagnosticCode、Diagnostic
│  ├─ ast_document.mbt              # Document、Header、Voice、MusicItem
│  ├─ ast_music.mbt                 # 音符、节拍、连线、小节、重复、装饰音
│  ├─ ast_lyrics.mbt                # 歌词及其对齐项
│  ├─ scanner.mbt                   # 字符/行扫描与 token 来源位置
│  ├─ parser_header.mbt             # X/T/M/L/K/V 等 header 解析
│  ├─ parser_music.mbt              # body、voice、bar、repeat、ornament、lyrics
│  ├─ validator.mbt                # 文档级和声部级语义检查
│  ├─ normalize.mbt                 # 稳定顺序、默认值、空白和表示规范化
│  ├─ json.mbt                      # 版本化 JSON 输出
│  ├─ pretty.mbt                    # 确定性的 ABC pretty printer
│  └─ *_test.mbt                    # 黑盒测试和必要的白盒测试
├─ cmd/abc/
│  ├─ moon.pkg                      # is-main 命令包
│  └─ main.mbt                      # parse/check/format/json 命令
├─ examples/
│  ├─ folk.abc                      # 多声部民谣示例
│  ├─ teaching.abc                  # 节拍、装饰音和歌词示例
│  └─ README.md                     # 运行命令和输出说明
├─ docs/
│  ├─ proposal.md                   # 比赛申报书
│  ├─ grammar.md                    # 支持范围、语法边界和非目标
│  ├─ json-schema.md                # JSON 字段和 schema 版本
│  ├─ sources.md                    # ABC 规范、依赖和来源说明
│  └─ superpowers/specs/...         # 本设计
├─ .github/workflows/ci.yml         # MoonBit 0.10.3 兼容的 CI
├─ CHANGELOG.md
├─ CONTRIBUTING.md
├─ LICENSE
└─ README.md
```

文件名只是组织方式，不形成 MoonBit namespace；公共类型放在 `src/abc`，扫描器和内部解析辅助保持私有，避免把实现细节泄漏到 Mooncakes 公共 API。

## 公共 API 草案

公共 API 以稳定的 AST 和诊断数据为中心，具体 MoonBit 签名在实现前用本机 `moon ide doc` 与最小编译样例确认。

```text
parse(input) -> Document 或带 Span 的 ParseError
validate(document) -> Array[Diagnostic]
parse_and_validate(input) -> ParsedDocument
normalize(document) -> Document
to_json(document) -> Json
format(document) -> String
format_with_options(document, ...) -> String
```

核心公共数据包括：

- `Span`：起始/结束偏移、行、列和可选源名称。
- `Diagnostic`：严重级别、稳定诊断码、人类可读消息、Span 和可选修复建议。
- `Document`：文件级元数据、header 序列、声部集合、音乐项和歌词关联。
- `Header`：标准字段、带结构化值的 `Meter`/`Key`/`Voice`，以及不丢失文本的扩展字段。
- `MusicItem`：音符、休止、连音/连线、bar、repeat、ornament、voice 切换和 lyrics。
- `Json`：根对象带 `schema_version`，输出字段顺序稳定，便于快照和曲库 diff。

未知 header 和未覆盖的行不会被静默吞掉：在可保留的情况下进入扩展节点并产生 warning；无法安全解释时产生 error，继续解析仅限于不会破坏后续边界的情况。

## 解析与校验流程

```text
String
  → Scanner（字符、行、注释、字段和值的 Span）
  → Parser 状态机（header / voice body / lyrics）
  → Document AST
  → Validator（局部语法 + 文档语义）
  → Normalize
  → JSON 或 pretty printer
```

解析器采用显式状态机，不依赖正则表达式堆叠整行规则。这样可以：

- 给错误提供可靠的行列位置；
- 在多声部和歌词切换时保持上下文；
- 未来为方言增加新的 token/节点，而不重写整个 parser；
- 用线性扫描处理大型曲库文本，避免明显的重复切片。

第一期支持边界：

- 常见 ABC header：`X:`、`T:`、`M:`、`L:`、`K:`、`V:`，并支持扩展 header 的保留。
- body 中的音符、休止、时值、八度、临时变音、连音、bar、repeat、常见 ornament 和 voice 切换。
- `w:`/`W:` 歌词行，保留歌词 token 与音符/休止的相对对齐信息。
- `%` 注释和空行按文档策略保留或规范化。
- 重复记号、终止小节和基本小节长度检查。

明确不保证完整覆盖所有 ABC 方言；支持范围、暂不支持项和诊断码会在 `docs/grammar.md` 中逐项列出，并在 README 中给出示例。

## 规范化与打印

`normalize` 不改变音乐语义，只统一可观察表示：

- header 的结构化字段使用稳定顺序；
- 默认长度、默认声部和可选值以明确规则表达；
- 空白、换行、bar 周边格式和歌词分隔符采用固定策略；
- 扩展字段按原顺序保留；
- JSON 的 schema version 和字段顺序稳定。

pretty printer 输出 UTF-8 文本，不依赖平台换行。核心性质测试为：对支持范围内的文档，`parse(format(normalize(parse(input))))` 应成功，并且两次 normalize 的 JSON 相同。无法无损打印的未知内容必须通过扩展节点或诊断显式暴露。

## CLI 设计

命令包提供以下入口：

```text
moon run cmd/abc -- parse examples/folk.abc
moon run cmd/abc -- check examples/teaching.abc
moon run cmd/abc -- format examples/folk.abc
moon run cmd/abc -- json examples/folk.abc
```

- `parse` 输出摘要和诊断；`check` 只输出诊断并在存在 error 时返回非零状态；`format` 输出规范化 ABC；`json` 输出版本化 AST JSON。
- 文件读取失败、参数错误、解析错误和校验错误使用不同的可识别文本前缀，但不把内部堆栈泄漏给用户。
- CLI 不是公共库的唯一入口；所有功能先通过 `src/abc` API 测试，再由命令包薄封装。

## 测试策略

测试先于实现按以下层次推进：

1. scanner：空输入、行尾、注释、Unicode 文本、header 分隔、错误 Span。
2. header parser：X/T/M/L/K/V、重复 header、未知 header、meter/key 边界。
3. music parser：音符/休止/时值/八度、bar、repeat、ornament、voice、lyrics。
4. validator：缺少必要字段、声部引用、歌词对齐、小节长度、非法重复结构。
5. normalize/pretty：快照、幂等性、parse-print-parse 结构一致性。
6. JSON：schema version、字段稳定性、空数组/可选值和诊断位置。
7. CLI：四个子命令的成功/失败退出码和示例文件。
8. 回归样例：至少 6 个小型谱面，覆盖单声部、多声部、教学节拍、歌词和错误输入。

优先使用 MoonBit 原生测试与快照；只有在需要验证私有扫描状态时才添加白盒测试。测试文件按包拆分，避免单个测试文件成为无法维护的样例仓库。

## CI 与发布

`.github/workflows/ci.yml` 在 push、pull_request 和手动触发时执行：安装/选择官方 MoonBit 工具链，运行格式、接口信息、检查、测试、构建和示例 CLI。CI 还会检查工作区没有未提交的 formatter 变更，并保存必要的测试输出。

发布前清单：

- `moon fmt --deny-warn`
- `moon info --deny-warn`
- `moon check`
- `moon test`
- `moon build`
- 命令行示例全部实际运行
- `moon publish` 所需模块名、许可证和版本信息确认
- README、CHANGELOG、申报书和来源说明互相一致

Mooncakes 的准确模块路径和发布账号在 GitHub 授权身份确认后确定，不把未经验证的账号名写死到设计之外的文件中。

## 来源、版权与 AI 使用说明

本项目采用自主实现的 scanner/parser/AST；ABC notation 的公开语法资料只作为规范参考，不复制其他实现的代码。`docs/sources.md` 记录规范链接、检索日期、Mooncakes 查重关键词、依赖版本、许可证和任何改编说明。README 会明确说明 AI 仅作为辅助工具，最终代码由仓库所有者审阅、测试和维护。

## 风险与应对

- ABC 方言复杂：先锁定文档化的核心子集，并对未知语法提供扩展节点/诊断，不承诺隐含兼容。
- MoonBit 0.10.3 与本机日期版本标识可能不同：实现前用 `moon --help`、官方安装器和 CI 实际运行确认，不凭记忆写 flag。
- 4,000–10,000 行是参考规模而非堆代码目标：通过多包 AST、scanner、诊断、校验、JSON、formatter、CLI 和真实测试自然形成规模，禁止机械复制或虚构代码。
- 双平台远程仓库身份：先用 `gh auth status` 确认 GitHub 当前授权，再配置 GitLink 远程；不得在日志、URL 或提交中写入密码。

