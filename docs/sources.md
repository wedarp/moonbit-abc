# 来源与范围说明

## 语法来源

- [ABC notation standard v2.1](https://abcnotation.com/wiki/abc:standard:v2.1)：header、voice、meter、key、bar、repeat、ornament 和 lyrics 的语法边界。
- [ABC notation 官网](https://abcnotation.com/)：ABC 生态和格式背景。

实现只取与 source-aware AST 直接相关的语法约定，不复制其他解析器的实现代码。遇到暂未建模的语法时，解析器保留 `Raw` 节点并生成 `unsupported_syntax` 警告，方便后续扩展而不是静默丢失输入。

## MoonBit 来源

- [MoonBit 官方文档](https://www.moonbitlang.com/docs)：模块、包、测试、格式化和生成接口文件的工具链规范。
- [MoonBit core](https://github.com/moonbitlang/core)：标准库 API 的实现来源。
- [MoonBit X](https://github.com/moonbitlang/x)：CLI 读文件所需的同步文件系统 API；它只位于 `cmd/abc`，不进入核心解析器。
- [MoonBit community workflow templates](https://github.com/moonbit-community/.github/tree/main/workflow-templates)：CI 触发、工具链安装和基础检查的参考。

## 生态核验

核验日期：2026-08-05。

在 [Mooncakes](https://mooncakes.io/) 对 `abc`、`notation`、`parser`、`music`、`midi`、`musicxml` 做了关键词检索，并查看了相邻的通用 parser、Markdown parser 和 MIDI/音乐绑定项目。没有发现成熟且直接提供 ABC notation source parser + AST + pretty printer 的项目。这个结论是截至 2026-08-05 的选题边界快照，不构成对 Mooncakes 全站的永久性排除。
