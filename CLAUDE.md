# 技术文档审查项目 - Claude Code 运行总则

> 本文件 `CLAUDE.md` 为本项目最高优先级运行说明。  
> Claude Code 在本仓库中执行任何文档审查任务时，必须优先遵守本文件。  
> 若与临时 prompt、默认行为、历史文档或其他说明冲突，一律以本文件为准。

---

## 1. 项目目标

本项目用于对技术文档进行结构化审查，覆盖以下文档类型：

- API Reference
- Demo / 示例工程跑通文档
- Integration / 接入文档
- Feature / 功能说明与使用指南

输出目标不是泛泛点评，而是：

1. 低误报
2. 可追溯
3. 可执行
4. 可批处理
5. 可复检

---

## 2. 唯一技能真源

Claude Code 只能从以下目录读取技能并执行：

- `.claude/skills/`

---

## 3. 当前项目真实目录约定

### 3.1 技能目录
- `.claude/skills/_shared/`
- `.claude/skills/review-api/`
- `.claude/skills/review-demo/`
- `.claude/skills/review-feature/`
- `.claude/skills/review-integration/`

### 3.2 输入目录
- 理解用户输入后查找对应文件

### 3.3 中间产物目录
- `reports/`

### 3.4 最终交付目录
- `reports_final/`

### 3.5 历史兼容目录
- `report/`
- `skills/`

以上两个目录可以保留，但**不作为当前主执行依据**。

---

## 4. 技能分层

### 4.1 L1 共享层（每篇文档必须全部执行）

以下共享技能必须全部执行，且顺序固定：

1. `.claude/skills/_shared/base_standards.md`
2. `.claude/skills/_shared/severity-standards.md`
3. `.claude/skills/_shared/format-review.md`
4. `.claude/skills/_shared/language-review.md`
5. `.claude/skills/_shared/terms-review.md`
6. `.claude/skills/_shared/logic-review.md`
7. `.claude/skills/_shared/code-review.md`

### 4.2 L2 业务层（每篇文档只能执行一个）

可选业务技能如下：

- `.claude/skills/review-api/SKILL.md`
- `.claude/skills/review-demo/SKILL.md`
- `.claude/skills/review-feature/SKILL.md`
- `.claude/skills/review-integration/SKILL.md`

每篇文档只能判定一个类型，并且只执行一个 L2 Skill。

### 4.3 L3 报告与校验层

报告生成与报告检查统一使用：

- `.claude/skills/_shared/generate-review-report/`
- `.claude/skills/_shared/check-review-report/`

如有需要，可进一步使用：
- `.claude/skills/_shared/handle-user-feedback/`
- `.claude/skills/_shared/update-review-rules/`

但这两个不是本批处理的必经步骤。

---

## 5. 审查原则

### 5.1 零误报优先
- 不确定的问题必须标记为 `[需人工确认]`
- 禁止凭经验猜测 API、方法名、字段名、参数名
- 有疑点必须基于文档上下文或工程检索验证

### 5.2 证据优先
- 每条问题必须能回溯到文档位置、规则条款，或必要时的工程检索结果
- 不允许“看起来像有问题”这种无证据结论

### 5.3 可执行优先
- 每条问题必须给出明确修改建议
- 不允许只给抽象评价，不给操作方向

### 5.4 不允许重复问题
- 同类问题在最终报告中最多保留 1 条
- 必须合并不同出现位置
- 若报告生成后仍发现重复，必须删除重复项并在报告末尾记录“去重删除记录”

---

## 6. 文档类型判定规则（L2 单标签）

每篇文档只能选择一个标签：

- `api`
- `demo`
- `integration`
- `feature`

判定依据必须是**全文主线任务 / 读者要完成的主要动作**，而不是共享词汇。

### 6.1 冲突优先级
`demo > integration > api > feature`

### 6.2 integration 输出门槛（Gate-INT）
只有原文中出现以下任一**完全一致字样**时，才允许输出 `integration`：

- “快速集成”
- “快速接入”
- “准备工作”
- “全功能接入”
- “集成并引入组件”

其中“集成并引入组件”必须是二级或三级标题，且下文有详细说明，不能只是甩链接。

若未命中以上任一项，则 `integration` 禁用。

### 6.3 demo 判定
若主线是跑通 Demo / 示例工程，例如出现以下链路，则必须判为 `demo`：

- git clone / 下载源码
- 安装依赖
- 编译运行
- localhost 访问
- 跑通效果说明

### 6.4 api 判定
仅当主线是 API Reference / 接口查询时，才输出 `api`，例如：

- 方法签名
- 参数与返回值
- 错误码
- 字段说明
- 回调说明

教程式步骤文即使有参数表，也不能直接判 api。

### 6.5 feature 兜底
除 `demo` / `integration` / `api` 之外，其余一律判为 `feature`。

---

## 7. 强制执行流程

### Step 0：建立运行索引
每次批处理开始时，必须先建立技能索引与运行日志。

输出到：
- `reports/_meta/skill_index.json`
- `reports/_meta/run_log.md`

`skill_index.json` 必须列出本次运行实际读取的技能路径。

---

### Step 1：读取文档
只从文件系统读取目标文档，不从对话中获取文档正文。

---

### Step 2：执行全部 L1
每篇文档必须依次执行全部 7 个 L1 共享技能。

执行结果必须落盘到：
- `reports/_work/<doc_basename>/`

必须生成以下文件：

- `L1_base-standards.json`
- `L1_severity-standards.json`
- `L1_format-review.json`
- `L1_language-review.json`
- `L1_terms-review.json`
- `L1_logic-review.json`
- `L1_code-review.json`

每个文件必须包含：
- `doc_path`
- `skill_id`
- `rule_path`
- `executed_at`
- `status`
- `issues`

任意一个缺失，则本文档失败，不能进入 L2。

---

### Step 3：L2 分类
必须生成：

- `reports/_work/<doc_basename>/L2_classification.json`

字段必须包含：
- `doc_path`
- `label`
- `gate_int_hit`
- `priority_used`
- `evidence`

---

### Step 4：执行一个 L2
只允许执行一个与分类标签一致的业务技能。

必须生成：
- `reports/_work/<doc_basename>/L2_business-review.json`

字段必须包含：
- `doc_path`
- `label`
- `business_skill_id`
- `rule_path`
- `executed_at`
- `status`
- `issues`

若发现执行多个业务技能，本文档直接失败。

---

### Step 5：聚合与去重
聚合来源只能是：
- 7 个 L1 的 issues
- 1 个 L2 的 issues

必须输出：
- `reports/_work/<doc_basename>/issues_merged_raw.json`
- `reports/_work/<doc_basename>/issues_deduped.json`
- `reports/_work/<doc_basename>/dedup_removed_locations.json`

同类问题判定 Key 为：
- `category`
- `type`
- `issue`
- `suggestion`

同 Key 的问题必须合并为 1 条，位置合并去重。

---

### Step 6：生成最终报告
最终报告输出到：
- `reports_final/<target_name>/<doc_basename>-review.md`

其中 `<target_name>` 的取值规则如下：

- 如果用户输入的是目录路径，则取该目录名作为 `<target_name>`
- 如果用户输入的是文件路径，则取该文件所在目录名；如无上级目录名可用，则使用 `single_file`

报告生成必须基于：
- `issues_deduped.json`

不得跳过中间 JSON 直接口头生成结果。

---

### Step 7：报告后二次去重检查
生成报告后必须再次检查是否仍有重复问题。

若仍有重复：
- 删除重复问题，只保留 1 条
- 在报告末尾追加：

`## 🧹 去重删除记录`

内容包括：
- 保留的问题摘要
- 保留位置
- 已删除位置

如果重复未被清除，则本文档失败。

---

## 8. 输出目录约定

### 8.1 最终报告
- `reports_final/<batch_name>/`

### 8.2 report 目录
- `report/` 可保留，但不作为当前主输出目录

---

## 9. 完成条件

只有同时满足以下条件，才允许标记“完成”：

1. 该文档 7 个 L1 证据文件齐全
2. 已生成且仅生成 1 个 L2 业务审查结果
3. 已生成去重后的 issues JSON
4. 已输出最终报告
5. 报告后二次去重完成
6. `run_log.md` 中记录为成功

---

## 10. 失败条件

以下任一情况出现，必须标记失败并记录到 `reports/_meta/run_log.md`：

- 未执行全部 L1
- L2 执行了多个
- 未生成去重中间文件
- 报告中仍有重复问题
- 规则文件读取失败
- 证据不足却直接下结论

---

## 11. 当前批任务默认入口

Claude Code 不得在本文件中预设固定的目标文件夹或默认 batch。

本次审查的目标文件或目标目录，必须从用户当前输入中读取。

允许的用户输入形式包括但不限于：

- `RUN_REVIEW <文件路径>`
- `RUN_REVIEW <目录路径>`
- `Read CLAUDE.md and BATCH_JOB.md first, then run review for <路径>.`

若用户提供的是目录，则递归扫描该目录下的目标文档并执行批量审查。  
若用户提供的是文件，则仅对该单一文件执行审查。

若用户没有提供目标路径，则不得默认使用任何 batch，也不得自动猜测；必须先要求用户补充路径。

运行前必须先读取：
1. `CLAUDE.md`
2. `BATCH_JOB.md`