# moonbit-abc 黑客松项目计划

## 目标

为 2026 年 8 月 MoonBit 黑客松制作可公开验收的 `moonbit-abc`：一个面向民谣、教学和曲库处理的 ABC notation 解析、校验、结构化 AST/JSON 与规范化 pretty printer 工具包，并完成 Mooncakes、GitHub、GitLink、CI、测试和仓库自检。

## 当前阶段

- [completed] 比赛规则、生态重复度与工具链调研
- [completed] 设计评审与实现方案确认
- [pending] MoonBit 模块与解析器核心实现
- [pending] 校验、JSON、pretty printer、CLI/示例与测试扩充
- [pending] CI、文档、许可证、版本与 Mooncakes 发布准备
- [pending] Git 历史、GitHub/GitLink 推送与 OSC2026 自检

## 约束

- 主要实现语言必须是 MoonBit。
- 目标工具链优先按 MoonBit 0.10.3 验证；执行 `moon fmt --deny-warn` 与 `moon info --deny-warn`，并补充 `moon check`/`moon test`/构建检查。
- 有效提交次数至少 10 次；作者身份只使用仓库所有者本人，不创建虚拟贡献者。
- GitHub 推送只使用用户已通过 `gh auth login` 建立的当前授权；不使用历史缓存账号。
- GitLink 推送使用用户提供的账号认证，不将密码写入文件、提交或回复。
- 选题应避开 MoonBit 生态已有成熟项目的高度重合，并保持可扩展边界。

## 错误记录

| 错误 | 尝试 | 处理 |
|---|---:|---|
| Firecrawl CLI 不在 PATH | 1 | 改用内置网页访问完成公开资料核验，并记录环境限制 |
| 浏览器插件脚本路径误定位 | 1 | 只读核验后改用插件根目录 `scripts/browser-client.mjs` |
