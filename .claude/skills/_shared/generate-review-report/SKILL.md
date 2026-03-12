---
name: generate-review-report
description: 将各审查模块输出的 JSON 汇总为清晰、易读、有重点的 Markdown 报告，并支持双周统计分析。
---

# 文档审查报告生成规范

## When to Use
- 完成所有审查模块（共享层 + 业务层）后，需要生成统一的 Markdown 报告
- 需要将多个 JSON 格式的审查结果汇总为一份可读性强的报告

## Instructions

**⚠️ 重要说明**：
- **输入来源**：审查结果来自内存中的 JSON 数据（各审查模块在对话中输出的结果），**不读取文件**
- **输出文件**：
  - **最终汇总 JSON**：`reports/{文档名}-review.json`（包含所有审查模块的结果）
  - **最终 Markdown 报告**：`reports/{文档名}-review.md`
- **不保存中间 JSON 文件**：各审查模块（format-review, code-review 等）的 JSON 结果不单独保存为文件

### Step 0：汇总所有审查结果并生成最终 JSON

**检查目标**：将所有审查模块的 JSON 结果汇总为一个完整的 JSON 文件，并进行问题去重和合并。

**汇总格式**：
```json
{
  "document_name": "文档名称",
  "review_time": "2026-01-18 15:30:00",
  "review_skill": "review-integration",
  "format_issues": [...],
  "code_issues": [...],
  "language_issues": [...],
  "logic_issues": [...],
  "terms_issues": [...],
  "integration_issues": [...],
  "test_issues": [...],
  "test_summary": {
    "test_time": "测试时间",
    "integration_success": true/false,
    "function_usable": true/false,
    "total_issues": 0,
    "p0_count": 0,
    "p1_count": 0,
    "p2_count": 0
  },
  "deduplication_log": {
    "total_before_dedup": 50,
    "total_after_dedup": 35,
    "merged_count": 10,
    "cross_category_dedup_count": 5
  }
}
```

**注意**：
- `test_issues` 和 `test_summary` 仅在 `review_skill` 为 `review-integration` 时存在
- 如果未执行集成测试，这两个字段不存在或为空
- `deduplication_log` 记录去重和合并情况，便于调试

**操作步骤**：
1. 从内存中收集所有审查模块的 JSON 结果
2. **执行 Step 0.5：问题去重和合并**（新增，见下文）
3. 合并为一个完整的 JSON 对象
4. 保存为 `reports/{文档名}-review.json`
5. 然后基于此 JSON 生成 Markdown 报告

---

### Step 0.5：问题去重和合并（新增步骤，强制执行）

**检查目标**：在汇总 JSON 之前，对所有问题进行去重和智能合并，避免同一问题重复出现。

**执行顺序**：在 Step 0 收集完所有模块结果后，生成最终 JSON 之前执行。

#### 0.5.1 跨 category 去重

**目标**：解决同一问题在不同审查模块（code/logic/integration 等）中重复报告的问题。

**检测规则**：

如果两个问题满足以下**所有条件**，则判定为重复：
1. **location 相同或重叠**
   - 完全相同：如都是"步骤5"
   - 区域重叠：如"步骤5"和"步骤5：创建房间"
   - 连续区域：如"步骤5"和"步骤6"且描述主题相同

2. **核心问题相同**
   - 关键词匹配：description 中包含相同的核心关键词（如"RoomMainView"、"导入"、"缺失"）
   - 或者 type 语义相同：如"导入缺失"（code）、"信息缺失"（logic）、"初始化配置缺失"（integration）

**判定示例**：

```json
// 示例 1：明显重复（完全相同的问题）
问题 A: {
  "category": "code",
  "type": "导入缺失",
  "location": "步骤5：创建房间",
  "description": "代码中使用了 RoomMainView 但未导入"
}

问题 B: {
  "category": "logic",
  "type": "信息缺失",
  "location": "步骤5：创建房间",
  "description": "代码中使用了 RoomMainView 但未说明如何导入"
}

问题 C: {
  "category": "integration",
  "type": "初始化配置缺失",
  "location": "步骤5：创建房间",
  "description": "代码示例中使用了 RoomMainView 但缺少导入语句"
}

→ 判定：三个问题都指向同一个根本问题（RoomMainView 未导入）
→ 处理：合并为一个问题
```

**处理策略**：

1. **保留优先级最高的版本**
   - 如果有 P0、P1、P2 同时存在，保留 P0

2. **保留描述最详细的版本**
   - 优先保留 suggestion 更具体、可操作的版本

3. **合并 category 信息**
   - 在 description 末尾注明："该问题在代码审查、逻辑审查、集成审查中均被发现"

4. **选择最合适的 category**
   - 优先保留在 `code_issues`（最直接的代码问题）
   - 从其他 category 中删除

**处理后结果**：

```json
{
  "category": "code",
  "type": "导入缺失",
  "severity": "P0",
  "location": "步骤5：创建房间、步骤6：加入房间",
  "original": "代码中使用了 RoomMainView 但未导入",
  "description": "代码示例中使用了 RoomMainView 类，但缺少导入语句（该问题在代码审查、逻辑审查、集成审查中均被发现）",
  "suggestion": "在代码块开头添加导入语句：import io.trtc.tuikit.roomkit.view.main.roomview.RoomMainView"
}
```

#### 0.5.2 同 category 内批量合并

**目标**：同一类型的重复问题（如多处"中英文空格缺失"）合并为一条批量问题。

**检测规则**：

同一 category 内，如果满足以下条件，则合并为批量问题：
1. **type 完全相同**
2. **问题数量 ≥ 2**（降低阈值，从 3 改为 2）
3. **问题性质相同**（如都是格式问题、都是同一类代码问题）

**特别关注的批量问题类型**：
- 中英文空格缺失
- 代码块语言标记错误
- 过度使用"您"
- 同一类型的格式问题

**处理策略**：

1. **合并为一条问题**
2. **列出典型案例**（最多 3 个）
3. **标注总数量**
4. **提供批量修复建议**（如正则表达式）

**处理前**：
```json
"format_issues": [
  {"type": "中英文空格", "location": "第12行", "original": "LiveKit提供"},
  {"type": "中英文空格", "location": "第25行", "original": "Android系统"},
  {"type": "中英文空格", "location": "第38行", "original": "调用方法"},
  {"type": "中英文空格", "location": "第52行", "original": "Flutter项目"}
]
```

**处理后**：
```json
"format_issues": [
  {
    "type": "中英文空格缺失（批量问题）",
    "severity": "P2",
    "category": "format",
    "location": "全文多处（共4处）",
    "typical_cases": [
      "第12行：「LiveKit提供」→「LiveKit 提供」",
      "第25行：「Android系统」→「Android 系统」",
      "第38行：「调用方法」→「调用 方法」"
    ],
    "description": "全文中存在多处中英文之间缺少空格的问题（共4处）",
    "suggestion": "使用编辑器的查找替换功能批量修复。可使用正则表达式：\n查找：([\\u4e00-\\u9fa5])([a-zA-Z0-9])\n替换：$1 $2\n\n全文存在多处，请批量修改。"
  }
]
```

#### 0.5.3 相似问题聚合

**目标**：位置连续、主题相同但 type 不同的问题，考虑合并。

**检测规则**：

如果满足以下所有条件，考虑合并：
1. **同一 category**
2. **location 连续**（如"步骤5"和"步骤6"）
3. **description 主题相同**（如都提到"RoomMainView 导入"）
4. **severity 相同**

**处理策略**：

1. **扩展 location 范围**："步骤5、步骤6"
2. **合并 description**：说明影响范围
3. **保留最完整的 suggestion**

**示例**：

**处理前**：
```json
[
  {"location": "步骤5", "description": "RoomMainView 未导入"},
  {"location": "步骤6", "description": "RoomMainView 未导入"}
]
```

**处理后**：
```json
[
  {
    "location": "步骤5、步骤6",
    "description": "代码示例中使用了 RoomMainView 但未导入（影响步骤5和步骤6）"
  }
]
```

#### 0.5.4 生成去重日志

**目标**：记录去重和合并的详细信息，便于调试和质量检查。

**记录内容**：
```json
"deduplication_log": {
  "total_before_dedup": 50,
  "total_after_dedup": 35,
  "cross_category_dedup": [
    {
      "merged_issue": "RoomMainView 导入缺失",
      "original_categories": ["code", "logic", "integration"],
      "kept_in": "code",
      "removed_from": ["logic", "integration"]
    }
  ],
  "batch_merge": [
    {
      "type": "中英文空格缺失",
      "original_count": 15,
      "merged_to": 1,
      "category": "format"
    },
    {
      "type": "代码块语言标记错误",
      "original_count": 10,
      "merged_to": 1,
      "category": "code"
    }
  ],
  "similar_issue_merge": [
    {
      "merged_issue": "RoomMainView 导入缺失",
      "original_locations": ["步骤5", "步骤6"],
      "merged_location": "步骤5、步骤6"
    }
  ]
}
```

---

**统一的 JSON 输入格式**：
所有审查模块输出的 JSON 格式已统一（数组名可不同）：

```json
{
  "logic_issues | code_issues | format_issues | language_issues | feature_guide_issues": [
    {
      "type": "具体问题类型",
      "severity": "P0/P1/P2",
      "category": "logic/code/format/language/feature",
      "location": "问题所在位置",
      "original": "原文内容或代码片段",
      "description": "问题描述",
      "suggestion": "修改建议"
    }
  ]
}
```

**核心原则**：
1. **优先级优先**：P0 问题必须最先展示，P1/P2 问题按顺序展示
2. **先总览后细节**：顶部给出问题统计，让读者知道整体情况
3. **分类聚合**：按问题类型分组，格式问题合并展示
4. **突出重点**：使用视觉标记（🔴/🟡/🔵）区分优先级
5. **可操作性**：每个问题必须有具体的位置和修改建议

---

### Step 1：生成报告头部（Summary）
**检查目标**：让读者一眼看到文档基本信息和问题统计。

**必须包含的信息**：
- 文档名称（完整路径）
- 审查时间（格式：YYYY-MM-DD HH:mm:ss）
- 使用的审查 Skill（如 review-feature）

**问题统计表格**：

| 优先级 | 数量 | 说明 |
|--------|------|------|
| 🔴 P0（严重） | X | 必须修复，影响功能使用 |
| 🟡 P1（警告） | X | 建议修复，影响用户体验 |
| 🔵 P2（建议） | X | 可选修复，风格优化 |
| **总计** | **X** | - |

**集成测试问题统计**（仅当存在 test_issues 时显示）：

| 优先级 | 数量 | 说明 |
|--------|------|------|
| 🔴 P0（严重） | X | 导致无法完成集成或集成后无法使用 |
| 🟡 P1（警告） | X | 导致集成困难或需要额外摸索 |
| 🔵 P2（建议） | X | 不影响集成，但影响体验 |
| **集成测试问题总计** | **X** | - |
| **集成是否成功** | 是/否 | - |
| **功能是否可用** | 是/否 | - |

**特殊情况**：
- 如果 P0 = 0，可以用 ✅ 表示"无严重问题"
- 如果所有问题数 = 0，跳转到 Step 5（无问题报告）

**示例输出**（普通文档）：

```markdown
# 📋 文档审查报告

**文档名称**：`path/to/document.md`  
**审查时间**：2026-01-18 14:30:00  
**审查 Skill**：review-feature

---

## 📊 问题统计

| 优先级 | 数量 | 说明 |
|--------|------|------|
| 🔴 P0（严重） | 3 | 必须修复，影响功能使用 |
| 🟡 P1（警告） | 5 | 建议修复，影响用户体验 |
| 🔵 P2（建议） | 2 | 可选修复，风格优化 |
| **总计** | **10** | - |

---
```

**示例输出**（集成文档，包含集成测试）：

```markdown
# 📋 文档审查报告

**文档名称**：`path/to/integration-doc.md`  
**审查时间**：2026-01-18 14:30:00  
**审查 Skill**：review-integration

---

## 📊 问题统计

| 优先级 | 数量 | 说明 |
|--------|------|------|
| 🔴 P0（严重） | 2 | 必须修复，影响功能使用 |
| 🟡 P1（警告） | 3 | 建议修复，影响用户体验 |
| 🔵 P2（建议） | 1 | 可选修复，风格优化 |
| **总计** | **6** | - |

## 📊 集成测试问题统计

| 优先级 | 数量 | 说明 |
|--------|------|------|
| 🔴 P0（严重） | 1 | 导致无法完成集成或集成后无法使用 |
| 🟡 P1（警告） | 2 | 导致集成困难或需要额外摸索 |
| 🔵 P2（建议） | 0 | 不影响集成，但影响体验 |
| **集成测试问题总计** | **3** | - |
| **集成是否成功** | 否 | - |
| **功能是否可用** | 否 | - |

---
```

---

### Step 2：展示 P0 问题详情（全部展开，批量问题合并）
**检查目标**：P0 问题必须全部展开展示，不折叠。但同一类型的问题如果出现 ≥ 2 次，应合并为批量问题。

**批量问题判断标准**（已在 Step 0.5 中完成合并）：
- 同一 `type` 的问题出现 ≥ 2 次（已降低阈值，从 3 改为 2）
- 合并后只展示 3 个典型案例
- 标题注明"（批量问题）"
- 显示问题总数量
- 提供批量修复建议（如正则表达式或统一修改说明）

**注意**：如果 Step 0.5 已经完成批量合并，此步骤只需按格式展示，无需再次判断。

```

**问题展示格式**（非批量问题）：
- 问题标题格式：`### N. [category] type`
- 每个问题包含：位置、问题描述、原文、修改建议
- 问题之间用 `---` 分隔
- 原文使用引用格式（`>`）或代码块展示
- 修改建议必须具体可操作
- **引用原文时**：不要使用原文中未出现的符号或格式（如「」）；使用英文双引号 `"..."` 或与原文一致的中性引用方式

**示例**：

```
## 🔴 P0 问题（必须修复）

### 1. [逻辑] 步骤遗漏

**位置**：第 3 章节 "开始录制"

**问题描述**：  
文档直接说明"调用 startRecord() 开始录制"，但未说明录制前是否需要先加入房间。

**原文**：
> 调用 startRecord() 开始录制。

**修改建议**：  
在"开始录制"章节开头增加前置条件说明：
需先完成快速集成并调用 joinRoom() 加入房间。

---

### 2. [代码] 导入缺失

**位置**：第 4 章节 代码示例

**问题描述**：  
代码示例中使用了 RTCClient 类，但未导入。

**原文**：
const client = new RTCClient();

**修改建议**：  
在代码块开头添加导入语句：
import { RTCClient } from '@sdk/rtc';
const client = new RTCClient();

---
```

---

### Step 3：展示 P1 问题详情（全部展开，批量问题合并）
**检查目标**：P1 问题全部展开，同一类型的问题如果出现 ≥ 2 次，应合并为批量问题。

**批量问题判断标准**（已在 Step 0.5 中完成合并）：
- 同一 `type` 的问题出现 ≥ 2 次（已降低阈值）
- 合并后只展示 3 个典型案例
- 标题注明"（批量问题）"
- 显示问题总数量
- 提供批量修复建议（如正则表达式）

**注意**：如果 Step 0.5 已经完成批量合并，此步骤只需按格式展示，无需再次判断。

**批量问题展示格式**：

```markdown
### X. [格式] type（批量问题）

**问题数量**：全文共 N 处  

**典型案例**：
1. location1："original1" → "suggestion1"
2. location2："original2" → "suggestion2"
3. location3："original3" → "suggestion3"

**修改建议**：  
使用编辑器的查找替换功能批量修复。可使用正则表达式：
- 查找：`pattern`
- 替换：`replacement`

全文存在多处，请批量修改。

---
```

**示例输出**：

```markdown
## 🟡 P1 问题（建议修复）

### 1. [功能指南] 场景适配缺失

**位置**：第 2 章节 "录制模式"

**问题描述**：  
文档提到"支持自动模式和手动模式"，但未说明什么场景用自动、什么场景用手动。

**修改建议**：  
补充场景说明：
```
- **自动模式**：适用于单人录制场景，SDK 自动选择最佳参数
- **手动模式**：适用于多人录制，需自行指定每个流的录制参数
```

---

### 2. [格式] 中英文空格缺失（批量问题）

**问题数量**：全文共 15 处  

**典型案例**：
1. 第 1 章节第 3 行："LiveKit提供" → "LiveKit 提供"
2. 第 3 章节第 12 行："调用方法" → "调用 方法"
3. 第 5 章节第 8 行："Android系统" → "Android 系统"

**修改建议**：  
使用编辑器的查找替换功能批量修复。可使用正则表达式：
- 查找：`([\u4e00-\u9fa5])([a-zA-Z0-9])`
- 替换：`$1 $2`

全文存在多处，请批量修改。

---
```

---

### Step 4：展示 P2 问题详情（全部展开，批量问题合并）
**检查目标**：P2 问题也全部展开，保持一致的结构。同一类型的问题如果出现 ≥ 2 次，应合并为批量问题。

**批量问题判断标准**（已在 Step 0.5 中完成合并）：
- 与 P0/P1 的批量问题判断标准一致
- 同一 `type` 的问题出现 ≥ 2 次时合并为批量问题

**注意**：如果 Step 0.5 已经完成批量合并，此步骤只需按格式展示，无需再次判断。

**展示格式**：与 P0/P1 保持一致，使用相同的问题展示模板。

---

### Step 4.5：展示集成测试问题（仅当存在 test_issues 时执行）

**检查目标**：展示集成测试过程中发现的问题，包括测试环境信息和问题详情。

**执行条件**：
- 仅当 `review_skill` 为 `review-integration` 时执行
- 仅当存在 `test_issues` 且 `test_issues.length > 0` 时执行

**展示顺序**：
1. 先展示测试环境信息
2. 然后按优先级（P0 → P1 → P2）展示问题详情

**测试环境信息格式**：

```markdown
## 集成测试问题

### 测试环境信息

- **测试时间**：YYYY-MM-DD HH:mm:ss
- **操作系统**：xxx
- **Node.js 版本**：xxx
- **npm 版本**：xxx（或其他包管理器）
- **测试项目路径**：xxx
- **集成是否成功**：是/否
- **功能是否可用**：是/否
```

**问题展示格式**：

按优先级分组展示，每个问题包含以下信息：

```markdown
### 测试问题详情

#### 🔴 P0 问题（导致无法完成集成）

##### 1. [步骤名称] 问题类型

**位置**：文档中的具体位置（列出章节名称）

**问题原因**：  
实际遇到的问题描述

**错误信息**（如有）：  
```
具体的错误信息
```

**预期行为**：  
文档中描述的行为

**实际行为**：  
实际发生的行为

**解决方案**：  
如何解决这个问题（如果是环境问题，说明如何修复环境；如果是文档问题，说明如何修改文档）

**修改建议**（仅当 is_document_issue 为 true 时显示）：  
对文档的具体修改建议

**问题分类**：文档问题 / 环境问题

---
```

**问题分类说明**：
- **文档问题**：`is_document_issue: true`，需要修改文档
- **环境问题**：`is_document_issue: false`，属于测试环境或系统配置问题

**优先级分组**：
- 先展示 P0 问题（导致无法完成集成）
- 再展示 P1 问题（导致集成困难）
- 最后展示 P2 问题（影响体验）

**特殊情况**：
- 如果所有 test_issues 的 `is_document_issue` 都为 `false`，说明都是环境问题，可以在测试环境信息后添加说明："本次测试发现的问题均为环境问题，非文档问题"
- 如果 `integration_success: true` 且 `function_usable: true`，可以在测试环境信息后添加说明："集成测试通过，功能可用"

---

### Step 5：报告自查（强制执行）
**检查目标**：输出报告前，必须对报告中的逐个问题进行二次审核，避免输出无效或错误的问题。

**核心检查项（4 项必查）**：

1. **原文≠建议**  
   每个问题的"原文"和"修改建议"必须不同
   - ❌ `"LiveKit提供" → "LiveKit提供"`（相同，无效问题）
   - ✅ `"LiveKit提供" → "LiveKit 提供"`（不同，有效问题）

2. **统计=实际**  
   统计表的数量必须与实际列出的问题数量一致
   - 统计表 P0/P1/P2 数量 = 实际列出的问题数量
   - 总计 = P0 + P1 + P2

3. **批量≥2**  
   只有同类型问题 ≥ 2 个时才标记为"批量问题"（已降低阈值）
   - 1 个问题：正常列出
   - ≥ 2 个问题：标记批量，列出典型案例（最多 3 个）

4. **位置准确**  
   每个问题必须有明确的定位信息
   - 包含章节名称

5. **引用格式**  
   描述中引用原文时，不得使用原文未使用的符号（如「」）；应使用英文双引号 `"..."` 或与原文一致的中性写法。

6. 是否有吹毛求疵的审核意见，如果有，删除这个问题

**快速自查方法**：
```
报告生成后 → 逐个检查问题 → 发现错误立即修正 → 重新统计数量 → 确认后输出
```

**高频错误对照表**：

| 错误 | 快速识别 | 快速修正 |
|------|---------|---------|
| 原文=建议 | 看到 `"X" → "X"` | 删除该问题 |
| 统计不符 | 统计 5 个，实际 4 个 | 重新数一遍 |
| 误标批量 | 只有 1 个标记批量 | 去掉批量标记 |
| 位置缺失 | "某处有问题" | 补充章节名 |
| 跨category重复 | 同一问题在多个 category 中出现 | 执行 Step 0.5 去重 |

---

### Step 6：生成报告尾部
**检查目标**：说明执行了哪些审查模块。

**⚠️ 强制要求**：只有通过 Step 5 自查、确认无误后，才能输出最终报告。

**必须包含的信息**：
- 共享层审查模块列表
- 业务层审查模块名称
- 集成测试（如果执行了）

**示例输出**：

```markdown
---

## ✅ 审查完成

**共享层审查**：logic-review, code-review, format-review, language-review  
**业务层审查**：review-feature
**集成测试**：已执行（仅针对集成文档）
```

**集成文档示例输出**：

```markdown
---

## ✅ 审查完成

**共享层审查**：logic-review, code-review, format-review, language-review, terms-review  
**业务层审查**：review-integration
**集成测试**：已执行
```

**特殊情况：无问题报告**

如果所有审查模块都返回空数组 `[]`，报告应显示：

```markdown
# 📋 文档审查报告

**文档名称**：`path/to/document.md`  
**审查时间**：2026-01-18 14:30:00  
**审查 Skill**：review-feature

---

## ✅ 审查通过

该文档未发现任何问题，符合所有审查标准。

**已执行审查**：
- 共享层：logic-review, code-review, format-review, language-review, terms-review
- 业务层：review-feature
- 集成测试：未执行（非集成文档）
```

**集成文档无问题示例**：

```markdown
# 📋 文档审查报告

**文档名称**：`path/to/document.md`  
**审查时间**：2026-01-18 14:30:00  
**审查 Skill**：review-integration

---

## ✅ 审查通过

该文档未发现任何问题，符合所有审查标准。

**已执行审查**：
- 共享层：logic-review, code-review, format-review, language-review, terms-review
- 业务层：review-integration
- 集成测试：已执行，集成成功，功能可用
```

---

## Output Format（强制）

**必须同时生成两个文件**：

1. **最终汇总 JSON 文件**：
   - 文件名格式：`{文档名}-review.json`
   - 保存路径：`reports/{文档名}-review.json`
   - 内容：包含所有审查模块的结果（format_issues, code_issues, language_issues, logic_issues, terms_issues, 以及业务层 issues）
   - 对于集成文档，还包含 test_issues 和 test_summary（如果执行了集成测试）

2. **最终 Markdown 报告**：
   - 文件名格式：`{文档名}-review.md`
   - 保存路径：`reports/{文档名}-review.md`
   - 内容：基于汇总 JSON 生成的 Markdown 格式报告

**⚠️ 重要说明**：
- **不保存中间 JSON 文件**：各审查模块（format-review, code-review 等）的 JSON 结果不单独保存
- **只保存最终的两个文件**：汇总 JSON + Markdown 报告


