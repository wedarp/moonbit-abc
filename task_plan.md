# moonbit-abc 黑客松项目计划

## 目标

为 2026 年 8 月 MoonBit 黑客松制作可公开验收的 `moonbit-abc`：一个面向民谣、教学和曲库处理的 ABC notation 解析、校验、结构化 AST/JSON 与规范化 pretty printer 工具包，并完成 Mooncakes、GitHub、GitLink、CI、测试和仓库自检。

## 当前阶段

- [completed] 比赛规则、生态重复度与工具链调研
- [completed] 设计评审与实现方案确认
- [in_progress] MoonBit 模块与解析器核心实现
- [pending] 校验、JSON、pretty printer、CLI/示例与测试扩充
- [pending] CI、文档、许可证、版本与 Mooncakes 发布准备
- [pending] Git 历史、GitHub/GitLink 推送与 OSC2026 自检

## Implementation plan

详见 `docs/superpowers/plans/2026-08-05-moonbit-abc-implementation.md`，按 Task 1–12 执行。

## 约束

- 主要实现语言必须是 MoonBit。
- 目标工具链优先按 MoonBit 0.10.3 验证；当前工具链用 `moon fmt --check`、`moon check --deny-warn --fmt`、`moon info`、`moon test --deny-warn` 和构建检查实现严格门禁；`moon fmt --deny-warn` 与 `moon info --deny-warn` 在本机帮助中不存在。
- 有效提交次数至少 10 次；作者身份只使用仓库所有者本人，不创建虚拟贡献者。
- GitHub 推送只使用用户已通过 `gh auth login` 建立的当前授权；不使用历史缓存账号。
- GitLink 推送使用用户提供的账号认证，不将密码写入文件、提交或回复。
- 选题应避开 MoonBit 生态已有成熟项目的高度重合，并保持可扩展边界。

## Errors Encountered

| Error | Attempt | Resolution |
|---|---:|---|
| `moon fmt --check --warn` rejected because the two options are mutually exclusive | 1 | Use `moon fmt --check` and enforce warnings/format through `moon check --deny-warn --fmt` |
| Existing header test expected pre-parser Raw segment count after music item classification | 1 | Updated the regression expectation from 2 to 4 items for `C D | E` |
| `|:` was classified as a header because the parser only checked key length | 1 | Added a shared legal field-key predicate and regression test; repeat parsing now reaches the music parser |
| Temporary `debug_inspect(codes)` caused an expect-test failure after root-cause output was captured | 1 | Removed the diagnostic instrumentation and reran the full suite |
| `@json.Json` was not a valid qualified type name in the installed MoonBit toolchain | 1 | Confirmed the prelude `Json` type and constructors with `moon ide doc`, then used unqualified `Json` in the serializer |

## 错误记录

| 错误 | 尝试 | 处理 |
|---|---:|---|
| Firecrawl CLI 不在 PATH | 1 | 改用内置网页访问完成公开资料核验，并记录环境限制 |
| 浏览器插件脚本路径误定位 | 1 | 只读核验后改用插件根目录 `scripts/browser-client.mjs` |
