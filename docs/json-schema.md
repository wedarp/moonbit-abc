# ABC JSON 输出

`to_json(document)` 返回稳定的 JSON 对象，供曲库工具、教学应用和后续编辑器使用。输出保留源文本中的行列位置，因此诊断和编辑器高亮可以回到 ABC 原文。

## 顶层字段

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `schema_version` | string | JSON 结构版本；当前为 `1` |
| `headers` | array | 按规范化顺序排列的字段节点 |
| `voices` | array | 声部及其音乐节点 |
| `items` | array | 文档级音乐节点，包含声部切换节点 |
| `lyrics` | array | `w:`/`W:` 歌词行 |

字段节点包含 `kind`, `key`, `value` 和 `span`。音乐节点包含 `kind`, `value` 和 `span`；`kind` 可为 `note`、`rest`、`bar`、`repeat`、`ornament`、`voice` 或 `raw`。歌词节点包含 `text` 和 `span`。

## 位置对象

每个 `span` 都包含从零开始的 `start`、`end`、`line` 和 `column` 数值。`start`/`end` 是源字符串偏移量，`line`/`column` 是面向编辑器的可读位置。

## 示例

输入：

```abc
X: 1
T: Demo
K: C
C D | E
```

输出的形状如下（数组中的完整节点和位置字段由库生成）：

```json
{
  "schema_version": "1",
  "headers": [
    {"kind": "header", "key": "X", "value": "1", "span": {}}
  ],
  "voices": [],
  "items": [
    {"kind": "note", "value": "C", "span": {}},
    {"kind": "note", "value": "D", "span": {}},
    {"kind": "bar", "value": "|", "span": {}},
    {"kind": "note", "value": "E", "span": {}}
  ],
  "lyrics": []
}
```

该格式是项目自己的稳定接口，不声称是 ABC 标准的替代品。新增字段会保持现有字段语义，并在变更日志中说明兼容性影响。
