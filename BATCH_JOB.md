# BATCH JOB - Dynamic Input Mode (Feature Fixed Mode)

## 当前任务模式

本任务为**动态输入模式 + 固定 feature 审查模式**。

Claude Code 不应在本文件中预设固定的目标文件夹。  
本次审查的目标文件或目标目录，必须从**用户当前输入**中读取。

**所有输入文档固定按 `feature` 类型处理，不再执行分类判断。**

允许的用户输入形式包括但不限于：

- `RUN_REVIEW <文件路径>`
- `RUN_REVIEW <目录路径>`
- `Read CLAUDE.md and BATCH_JOB.md first, then run review for <路径>.`

若用户提供的是目录，则对该目录下的目标文档执行批量审查。  
若用户提供的是文件，则只对该单一文件执行审查。

---

## 输入解析规则

### 1. 目标路径来源
本次任务的目标路径只能来自：
- 用户当前消息中明确给出的文件路径
- 用户当前消息中明确给出的目录路径

不得：
- 默认写死为某个 batch
- 自动猜测用户想审查哪个目录
- 继续沿用上一次任务的输入路径，除非用户明确要求 `RESUME`

### 2. 路径类型判断
收到路径后，必须先判断它是：
- 单文件
- 目录

然后决定执行方式：

- 若为单文件：执行单文档审查
- 若为目录：递归扫描并执行批量审查

### 3. 未提供路径时的处理
如果用户只说：
- `RUN_REVIEW`
- `开始审查`
- `继续`

但没有给出目标路径，则必须先要求用户提供路径，不能自行猜测。

---

## 输出目录规则

### 1. 中间产物目录
所有中间产物统一输出到：

- `reports/_meta/`
- `reports/_work/<doc_basename>/`

### 2. 最终报告目录
最终报告输出到：

- `reports_final/<target_name>/`

其中 `<target_name>` 的取值规则如下：

- 如果用户输入的是目录路径，则取该目录名作为 `<target_name>`
- 如果用户输入的是文件路径，则取该文件所在目录名；如无上级目录名可用，则使用 `single_file`

示例：
- 输入 `input-docs/batch_001/`  
  -> 输出到 `reports_final/batch_001/`
- 输入 `input-docs/batch_002/`  
  -> 输出到 `reports_final/batch_002/`
- 输入 `input-docs/batch_001/017_xxx.md`  
  -> 输出到 `reports_final/batch_001/`

---

## 本批次必须先读取的文件

在执行任何文档审查之前，必须先读取以下文件：

1. `CLAUDE.md`
2. `.claude/skills/_shared/base_standards.md`
3. `.claude/skills/_shared/severity-standards.md`
4. `.claude/skills/_shared/format-review.md`
5. `.claude/skills/_shared/language-review.md`
6. `.claude/skills/_shared/terms-review.md`
7. `.claude/skills/_shared/logic-review.md`
8. `.claude/skills/_shared/code-review.md`
9. `.claude/skills/review-feature/SKILL.md`

在生成最终报告前，必须使用：

10. `.claude/skills/_shared/generate-review-report/`
11. `.claude/skills/_shared/check-review-report/`

---

## 每篇文档的固定执行顺序

对每篇文档，严格按以下顺序执行：

1. 读取文档内容
2. 执行全部 7 个 L1 共享技能
3. 执行固定的 L2 feature 业务技能
4. 聚合全部 issues
5. 生成 `issues_merged_raw.json`
6. 生成 `issues_deduped.json`
7. 生成最终报告
8. 执行报告后二次去重检查
9. 写入运行日志
10. 执行发布脚本

---

## 本批次强制要求

### 1. 不允许跳过 L1
以下 7 个 L1 技能必须全部执行：

- `base_standards.md`
- `severity-standards.md`
- `format-review.md`
- `language-review.md`
- `terms-review.md`
- `logic-review.md`
- `code-review.md`

### 2. 固定执行 feature 业务审查
每篇文档固定执行：
- `review-feature/SKILL.md`

禁止：
- 分类
- 选择其他业务 Skill
- 同时执行多个业务 Skill

### 3. 不允许直接生成最终报告
必须先有以下中间文件：

- `L1_base-standards.json`
- `L1_severity-standards.json`
- `L1_format-review.json`
- `L1_language-review.json`
- `L1_terms-review.json`
- `L1_logic-review.json`
- `L1_code-review.json`
- `L2_business-review.json`
- `issues_merged_raw.json`
- `issues_deduped.json`

缺任一文件，禁止输出最终报告。

### 4. 报告内不允许重复问题
同类问题最多保留 1 条，必须合并位置。  
若报告生成后仍有重复，必须删除重复项并在末尾记录被删除位置。

### 5. 失败不可静默跳过
任一文档失败时：
- 必须记录失败原因
- 必须继续处理下一篇
- 不允许不留痕迹直接跳过

### 6. 固定 feature 语境
即使文档中包含：
- 接口片段
- 参数表
- 示例代码
- 局部接入步骤

也仍然按 feature 审查，不得切换到其他类型逻辑。

---

## 运行产物要求

### 每篇文档必须生成
- `reports/_work/<doc_basename>/L1_base-standards.json`
- `reports/_work/<doc_basename>/L1_severity-standards.json`
- `reports/_work/<doc_basename>/L1_format-review.json`
- `reports/_work/<doc_basename>/L1_language-review.json`
- `reports/_work/<doc_basename>/L1_terms-review.json`
- `reports/_work/<doc_basename>/L1_logic-review.json`
- `reports/_work/<doc_basename>/L1_code-review.json`
- `reports/_work/<doc_basename>/L2_business-review.json`
- `reports/_work/<doc_basename>/issues_merged_raw.json`
- `reports/_work/<doc_basename>/issues_deduped.json`
- `reports/_work/<doc_basename>/dedup_removed_locations.json`

### 每篇成功文档必须生成
- `reports_final/<target_name>/<doc_basename>-review.md`

---

## 发布规则

当第一轮报告文件已成功生成并写入目标目录后，执行：

`bash scripts/publish_reports.sh main "update round1 review reports"`

若无文件变更，则跳过提交与推送。  
若推送失败，保留本地生成结果并输出失败原因。  
发布动作必须记录到 `reports/_meta/run_log.md`。

---

## 完成标准

当且仅当以下条件全部满足时，本次任务才算完成：

1. 用户输入路径下的所有目标文档均已处理
2. 每篇文档都有最终报告或失败记录
3. 所有成功文档的最终报告均位于对应的 `reports_final/<target_name>/`
4. `reports/_meta/run_log.md` 中存在每篇文档的处理结果
5. 没有“未执行全部 L1 但仍生成报告”的情况
6. 没有“未执行 L2 feature 业务技能却仍生成报告”的情况
7. 没有“报告中重复问题未删除”的情况

---

## 失败记录格式

每篇失败文档至少记录以下信息到 `reports/_meta/run_log.md`：

- `doc_path`
- `failed_step`
- `reason`
- `missing_files`（如有）
- `next_action`

如涉及发布失败，额外记录：
- `publish_attempted`
- `publish_status`
- `publish_error`

---

## 小规模验证建议

若是首次运行某个新目录，建议先小规模验证：

1. 先处理其中 1 篇文档
2. 检查 `reports/_work/<doc_basename>/` 是否真的生成了全部 L1 证据文件
3. 检查是否生成了 `L2_business-review.json`
4. 检查是否生成了 `issues_deduped.json`
5. 检查是否生成了最终报告
6. 确认无误后再处理整个目录

---

## 推荐对话指令

推荐使用以下形式启动：

- `RUN_REVIEW <文件路径>`
- `RUN_REVIEW <目录路径>`

例如：

- `RUN_REVIEW input-docs/batch_001`
- `RUN_REVIEW input-docs/batch_002`
- `RUN_REVIEW input-docs/batch_001/017_xxx.md`

也可使用：

- `Read CLAUDE.md and BATCH_JOB.md first, then run review for <路径>.`

---

## 核心执行心智

本批任务的执行原则只有一句话：

> **所有输入文档固定走 feature 审查链路；完整生成证据文件、聚合去重、输出报告、校验报告、记录日志、自动发布。**

禁止分类，禁止跳步，禁止绕过中间产物直接生成最终报告。