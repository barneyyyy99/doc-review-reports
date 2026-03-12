# 集成文档实际测试

本目录包含集成文档的实际测试功能，用于验证文档中的集成步骤是否真的可行。

## 功能说明

- **实际测试**：按照集成文档的步骤，在实际项目中执行操作
- **记录卡点**：记录集成过程中遇到的所有问题
- **生成报告**：生成 `test_issues` JSON，用于补充文档审查报告

## 使用方法

### 1. 创建测试项目

#### Web React 项目
```bash
cd skills/review-integration/integration-test
./create-web-project.sh react web-react-test
```

#### Web Vue3 项目
```bash
cd skills/review-integration/integration-test
./create-web-project.sh vue3 web-vue3-test
```

### 2. 执行集成测试

按照以下流程进行测试：

1. **解析集成文档**
   - 提取文档类型、环境要求、集成步骤等信息
   - 制定测试计划

2. **创建测试项目**
   - 使用脚本创建对应类型的测试项目
   - 检查项目创建是否成功

3. **环境准备验证**
   - 检查 Node.js 版本是否符合要求
   - 检查其他工具版本

4. **执行集成步骤**
   - 按照文档步骤逐一执行
   - 记录每个步骤的执行结果
   - 记录遇到的问题

5. **验证集成结果**
   - 检查项目是否能成功编译和运行
   - 检查功能是否可用

6. **生成测试报告**
   - 汇总所有问题
   - 生成 `test_issues` JSON

### 3. 输出格式

测试完成后，生成 `test_issues.json` 文件，格式如下：

```json
{
  "test_issues": [
    {
      "step": "安装依赖",
      "type": "命令失败",
      "severity": "P0",
      "location": "## 步骤 1：安装依赖",
      "description": "执行 npm install 时出现错误",
      "error_message": "npm ERR! code ERESOLVE",
      "expected": "依赖安装成功",
      "actual": "依赖安装失败",
      "solution": "使用 --legacy-peer-deps 参数或更新 npm 版本",
      "is_document_issue": false,
      "test_environment": {
        "os": "macOS",
        "node_version": "v18.19.1",
        "npm_version": "10.2.4",
        "project_path": "integration-test-projects/web-react-test"
      }
    }
  ],
  "test_summary": {
    "test_time": "2024-01-01 10:00:00",
    "integration_success": false,
    "function_usable": false,
    "total_issues": 1,
    "p0_count": 1,
    "p1_count": 0,
    "p2_count": 0
  }
}
```

## 测试项目目录结构

测试项目会创建在 `integration-test-projects/` 目录下：

```
integration-test-projects/
├── web-react-test/          # React 测试项目
│   ├── package.json
│   ├── vite.config.js
│   ├── src/
│   └── TEST_LOG.md          # 测试记录
└── web-vue3-test/           # Vue3 测试项目
    ├── package.json
    ├── vite.config.js
    ├── src/
    └── TEST_LOG.md          # 测试记录
```

## 注意事项

1. **测试环境隔离**：每个文档的测试应在独立的项目中进行
2. **敏感信息处理**：使用测试账号，不要使用生产环境信息
3. **版本记录**：详细记录测试时使用的所有工具版本
4. **错误记录**：对于重要错误，保存截图或日志文件

## 问题分类

### 文档问题 (is_document_issue: true)
- 步骤错误
- 代码示例错误
- 配置说明不准确
- API 名称错误

### 环境问题 (is_document_issue: false)
- 网络问题
- 系统配置问题
- 工具版本问题（非文档要求）

## 严重程度说明

- **P0**：导致无法完成集成或集成后无法使用
- **P1**：导致集成困难或需要额外摸索
- **P2**：不影响集成，但影响体验
