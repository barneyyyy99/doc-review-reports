#!/bin/bash

# 集成测试执行脚本
# 用法: ./run-integration-test.sh <doc-path> <framework>
# 示例: ./run-integration-test.sh ../../input-docs/准备工作（Web React）.md react

set -e

DOC_PATH=$1
FRAMEWORK=$2
PROJECT_NAME="web-${FRAMEWORK}-test-$(date +%Y%m%d-%H%M%S)"
BASE_DIR="integration-test-projects"
OUTPUT_DIR="../../reports"

if [ -z "$DOC_PATH" ] || [ -z "$FRAMEWORK" ]; then
    echo "用法: $0 <doc-path> <framework>"
    echo "示例: $0 ../../input-docs/准备工作（Web React）.md react"
    exit 1
fi

if [ ! -f "$DOC_PATH" ]; then
    echo "❌ 文档不存在: $DOC_PATH"
    exit 1
fi

echo "📄 开始测试文档: $DOC_PATH"
echo "🔧 框架: $FRAMEWORK"
echo "📦 项目名称: $PROJECT_NAME"
echo ""

# Step 1: 创建测试项目
echo "=== Step 1: 创建测试项目 ==="
./create-web-project.sh "$FRAMEWORK" "$PROJECT_NAME"
echo ""

# Step 2: 环境检查
echo "=== Step 2: 环境检查 ==="
echo "Node.js 版本: $(node -v)"
echo "npm 版本: $(npm -v)"
echo ""

# Step 3: 解析文档（这里需要 AI 来执行）
echo "=== Step 3: 解析集成文档 ==="
echo "⚠️  请使用 AI 助手解析文档并提取集成步骤"
echo ""

# Step 4: 执行集成步骤（这里需要 AI 来执行）
echo "=== Step 4: 执行集成步骤 ==="
echo "⚠️  请使用 AI 助手按照文档步骤执行集成"
echo "   项目路径: $BASE_DIR/$PROJECT_NAME"
echo ""

# Step 5: 生成测试报告
echo "=== Step 5: 生成测试报告 ==="
DOC_NAME=$(basename "$DOC_PATH" .md)
OUTPUT_FILE="$OUTPUT_DIR/${DOC_NAME}-test-issues.json"

echo "📝 测试报告将保存到: $OUTPUT_FILE"
echo ""
echo "⚠️  请使用 AI 助手汇总测试结果并生成 test_issues.json"
echo ""

echo "✅ 测试流程准备完成！"
echo ""
echo "下一步："
echo "1. 进入项目目录: cd $BASE_DIR/$PROJECT_NAME"
echo "2. 使用 AI 助手解析文档并执行集成步骤"
echo "3. 记录遇到的问题"
echo "4. 生成 test_issues.json 报告"
