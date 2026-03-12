#!/bin/bash

# 创建 Web 测试项目的脚本
# 用法: ./create-web-project.sh <framework> <project-name>
# 示例: ./create-web-project.sh react web-react-test

set -e

FRAMEWORK=$1
PROJECT_NAME=$2
BASE_DIR="integration-test-projects"

if [ -z "$FRAMEWORK" ] || [ -z "$PROJECT_NAME" ]; then
    echo "用法: $0 <framework> <project-name>"
    echo "支持的框架: react, vue3"
    echo "示例: $0 react web-react-test"
    exit 1
fi

# 创建基础目录
mkdir -p "$BASE_DIR"
cd "$BASE_DIR"

# 检查项目是否已存在
if [ -d "$PROJECT_NAME" ]; then
    echo "⚠️  项目 $PROJECT_NAME 已存在"
    read -p "是否删除并重新创建? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$PROJECT_NAME"
    else
        echo "取消创建"
        exit 1
    fi
fi

# 根据框架创建项目
case $FRAMEWORK in
    react)
        echo "📦 创建 React 项目: $PROJECT_NAME"
        npm create vite@latest "$PROJECT_NAME" -- --template react
        cd "$PROJECT_NAME"
        echo "📥 安装依赖..."
        npm install
        echo "✅ React 项目创建完成"
        ;;
    vue3)
        echo "📦 创建 Vue3 项目: $PROJECT_NAME"
        npm create vite@latest "$PROJECT_NAME" -- --template vue
        cd "$PROJECT_NAME"
        echo "📥 安装依赖..."
        npm install
        echo "✅ Vue3 项目创建完成"
        ;;
    *)
        echo "❌ 不支持的框架: $FRAMEWORK"
        echo "支持的框架: react, vue3"
        exit 1
        ;;
esac

# 创建测试记录文件
cat > TEST_LOG.md <<EOF
# 集成测试记录

## 项目信息
- **项目名称**: $PROJECT_NAME
- **框架**: $FRAMEWORK
- **创建时间**: $(date '+%Y-%m-%d %H:%M:%S')
- **测试文档**: [待填写]

## 测试环境
- **操作系统**: $(uname -s)
- **Node.js 版本**: $(node -v)
- **npm 版本**: $(npm -v)

## 测试步骤记录

### Step 1: 项目创建
- [x] 项目创建成功
- [x] 依赖安装成功

### Step 2: 环境检查
- [ ] Node.js 版本检查
- [ ] 其他工具版本检查

### Step 3: 集成步骤
- [ ] 安装 SDK 依赖
- [ ] 配置 SDK
- [ ] 初始化 SDK
- [ ] API 调用测试

### Step 4: 验证结果
- [ ] 编译检查
- [ ] 运行检查
- [ ] 功能检查

## 遇到的问题

（在此记录测试过程中遇到的所有问题）

## 测试结果

- **集成是否成功**: [待填写]
- **功能是否可用**: [待填写]
- **总体评价**: [待填写]

EOF

echo ""
echo "📝 测试记录文件已创建: TEST_LOG.md"
echo ""
echo "🚀 项目已创建，可以开始测试了！"
echo "   项目路径: $BASE_DIR/$PROJECT_NAME"
echo "   进入项目: cd $BASE_DIR/$PROJECT_NAME"
