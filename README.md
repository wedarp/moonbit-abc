# moonbit-abc

一个面向民谣、教学和曲库处理的 ABC notation 解析器。它把 ABC 源文本解析为带源位置的结构化 AST，提供校验、规范化 JSON 和 pretty printer；项目不负责 MIDI 播放、MusicXML 转换或音频渲染，因此和这些方向保持清晰边界。

## 能做什么

- 解析 `X`、`T`、`M`、`L`、`K`、`V` 等 header，并保留扩展字段。
- 解析 voice、note、rest、bar、repeat、ornament 和 lyrics 节点。
- 用 `Span` 保留节点在源文本中的偏移、行号和列号。
- 检查缺少的 `X`/`K`、非法 meter、重复 voice、未配对 repeat，以及暂未支持但已保留的原文语法。
- 输出稳定的 schema v1 JSON，并按 `X/T/M/L/K/V` 与扩展字段排序后打印 ABC。

JSON 字段定义见 [`docs/json-schema.md`](docs/json-schema.md)，可运行样例见 [`examples/demo.abc`](examples/demo.abc)。

代码仓库： [GitHub](https://github.com/wedarp/moonbit-abc) · [GitLink](https://gitlink.org.cn/Qqwkkr/moonbit-abc)

## 使用库

在 `moon.pkg` 中依赖 `Qqwkkr/moonbit-abc/src/abc` 后：

```moonbit
let document = @abc.parse(source)
let diagnostics = @abc.validate(document)
let json = @abc.to_json(document).stringify(indent=2)
let normalized = @abc.pretty_print(document)
let notes = @abc.parse_note_value("^C'3/2")
let meter = @abc.parse_meter("3+2/8")
let key = @abc.parse_key_signature("Dm")
let statistics = document.statistics()
```

核心包刻意只依赖 MoonBit core；仓库中的 CLI 使用 `moonbitlang/x` 提供跨平台文件读取。

## 使用 CLI

```bash
moon run cmd/abc --target native check examples/demo.abc
moon run cmd/abc --target native format examples/demo.abc
moon run cmd/abc --target native json examples/demo.abc
```

`check` 在没有诊断时输出 `ok` 并返回 0；发现错误时返回非零状态。`format` 输出规范化 ABC，`json` 输出 schema v1 JSON。

GitHub Actions 在 Ubuntu 上固定安装 MoonBit 0.10.3，并执行格式化、无警告检查、测试、接口生成、构建和 CLI smoke test。工作流位于 [`.github/workflows/test.yml`](.github/workflows/test.yml)。

## 开发与验证

```bash
moon test
moon check --deny-warn --fmt
moon fmt --check
moon info
```

本机安装的工具链是 `moon 0.1.20260713`。比赛材料提到的 0.10.3 与当前可执行文件版本命名不同，因此仓库把严格门禁写成当前工具链实际支持的组合：`moon fmt --check`、`moon check --deny-warn --fmt`、`moon test --deny-warn` 和 `moon info`。CI 会在固定工具链上重复这些检查。

## 设计边界与后续方向

解析器目前是 source-aware 的轻量 AST，优先保障 header、声部、节拍、调号、重复记号、装饰音和歌词在编辑器/曲库场景中的可追踪性。后续可以在不破坏 schema 的前提下增加拍号语义、宏展开、引用解析、增量解析、更多 ABC 标准字段和编辑器诊断适配。

## 来源与生态核验

设计以 [ABC notation standard v2.1](https://abcnotation.com/wiki/abc:standard:v2.1) 的字段和记号约定为边界，并参考 [MoonBit 官方文档](https://www.moonbitlang.com/docs) 的包、测试和格式化规范。2026-08-05 对 Mooncakes 的 `abc`、`notation`、`parser`、`music`、`midi` 和 `musicxml` 关键词做了核验，未发现功能高度重合且成熟的 ABC notation 解析器；发现的相邻项目主要是通用 SQL/parser、Markdown parser 或 MIDI/音乐绑定，因此本项目选择 source-aware ABC AST 这一交叉位置。完整记录见 [`findings.md`](findings.md)。

## 许可证

Apache License 2.0，见 [`LICENSE`](LICENSE)。
