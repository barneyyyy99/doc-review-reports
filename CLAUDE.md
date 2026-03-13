# 技术文档审查项目 - Claude Code 运行总则

> 本文件 `CLAUDE.md` 为本项目最高优先级运行说明。  
> Claude Code 在本仓库中执行任何文档审查任务时，必须优先遵守本文件。  
> 若与临时 prompt、默认行为、历史文档或其他说明冲突，一律以本文件为准。

---

## 1. 项目目标

本项目用于对技术文档进行结构化审查。  
**当前阶段，所有输入文档一律视为 `feature` 类型文档，不再执行分类判断。**

输出目标不是泛泛点评，而是：

1. 低误报
2. 可追溯
3. 可执行
4. 可批处理
5. 可复检
6. 稳定落盘
7. 稳定生成最终报告

---

## 2. 唯一技能真源

Claude Code 只能从以下目录读取技能并执行：

- `.claude/skills/`

禁止从其他目录推断或替代当前技能体系。

---

## 3. 当前项目真实目录约定

### 3.1 技能目录
- `.claude/skills/_shared/`
- `.claude/skills/review-feature/`

### 3.2 输入目录
- 从用户当前输入中读取目标文件或目标目录

### 3.3 中间产物目录
- `reports/`

### 3.4 最终交付目录
- `reports_final/`

### 3.5 历史兼容目录
- `report/`
- `skills/`

以上目录可以保留，但**不作为当前主执行依据**。

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

### 4.2 L2 业务层（固定走 feature）

每篇文档固定执行：

- `.claude/skills/review-feature/SKILL.md`

**不再执行分类，不再选择其他 L2 Skill，不再保留 api / demo / integration 分支。**

### 4.3 L3 报告与校验层

报告生成与报告检查统一使用：

- `.claude/skills/_shared/generate-review-report/`
- `.claude/skills/_shared/check-review-report/`

如有需要，可进一步使用：
- `.claude/skills/_shared/handle-user-feedback/`
- `.claude/skills/_shared/update-review-rules/`

但这两个不是当前批处理的必经步骤。

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

### 5.5 严禁跳步
- 不允许跳过中间 JSON 证据文件直接生成最终报告
- 不允许只输出口头总结替代正式报告

### 5.6 固定按 feature 语境审查
- 当前批次所有文档都按 feature 文档理解
- 不再做类型判断
- 不允许因为局部出现接口说明、参数表、集成步骤等片段，就切换到其他文档类型逻辑

---

## 6. 固定文档类型规则

### 6.1 固定类型
每篇文档固定标签为：

- `feature`

### 6.2 禁止事项
禁止执行以下动作：
- 禁止生成 `api` 分类结论
- 禁止生成 `demo` 分类结论
- 禁止生成 `integration` 分类结论
- 禁止尝试多标签判断
- 禁止为了“更像某类文档”而偏离 feature 审查流程

### 6.3 允许处理的特殊情况
即使文档中出现：
- 参数表
- 接口片段
- 步骤说明
- 配置说明
- 局部示例代码

也仍然按 **feature 文档** 执行审查。  
这些内容只影响具体 issue 判断，不影响业务技能选择。

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

### Step 3：执行固定 L2 feature 审查
不再分类。每篇文档固定执行 feature 业务技能。

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

其中：
- `label` 固定为 `feature`
- `business_skill_id` 固定指向 `review-feature`

若未执行 feature 业务技能，则本文档失败。  
若执行了多个业务技能，则本文档直接失败。

---

### Step 4：聚合与去重
聚合来源只能是：
- 7 个 L1 的 issues
- 1 个 L2 feature 的 issues

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

### Step 5：生成最终报告
最终报告输出到：
- `reports_final/<target_name>/<doc_basename>-review.md`

其中 `<target_name>` 的取值规则如下：

- 如果用户输入的是目录路径，则取该目录名作为 `<target_name>`
- 如果用户输入的是文件路径，则取该文件所在目录名；如无上级目录名可用，则使用 `single_file`

报告生成必须基于：
- `issues_deduped.json`

不得跳过中间 JSON 直接口头生成结果。

---

### Step 6：报告后二次去重检查
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

### Step 7：记录运行结果并发布
每篇文档处理完成后，必须将成功或失败结果写入：
- `reports/_meta/run_log.md`

当本轮报告文件已成功生成并写入目标目录后，执行：
`bash scripts/publish_reports.sh main "update round1 review reports"`

若无文件变更，则跳过提交与推送。  
若推送失败，保留本地生成结果并输出失败原因。

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
2. 已生成且仅生成 1 个 L2 feature 业务审查结果
3. 已生成去重后的 issues JSON
4. 已输出最终报告
5. 报告后二次去重完成
6. `run_log.md` 中记录为成功
7. 报告已尝试执行发布步骤（成功或失败均需留痕）

---

## 10. 失败条件

以下任一情况出现，必须标记失败并记录到 `reports/_meta/run_log.md`：

- 未执行全部 L1
- 未执行 L2 feature 业务审查
- 执行了多个业务技能
- 未生成去重中间文件
- 报告中仍有重复问题
- 规则文件读取失败
- 证据不足却直接下结论
- 报告生成失败
- 报告发布失败且未记录原因

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

---

## 12. 核心执行心智

当前项目的稳定执行原则只有一句话：

> **所有输入文档固定按 feature 流程执行；先完整产出 L1 与 L2 feature 证据，再聚合去重，再生成报告，再校验并发布。**

禁止自行加分类，禁止跳步，禁止绕过中间产物直接出最终结论。