# Git 规范

## 1. 忽略文件检测（强制）

**每次开始任务前，必须检查项目是否有 `.gitignore` 文件：**

1. **检查 `.gitignore` 是否存在**
   - 若**存在** → 检查内容是否完整，确保敏感文件和临时文件被忽略
   - 若**不存在** → **必须创建** `.gitignore`，参考下方通用模板

2. **禁止随意 `git add .`**
   - ❌ 禁止直接 `git add .` 或 `git add *`
   - ✅ 必须明确指定要提交的文件或目录
   - 若不确定某个文件是否应该提交，先检查 `.gitignore` 规则

**通用 `.gitignore` 模板：**

```
# 临时文件
temp/
*.tmp
*.log

# Python
__pycache__/
*.py[cod]
*.egg-info/
dist/
build/
.venv/
venv/

# Node
node_modules/
package-lock.json

# IDE
.idea/
.vscode/
*.swp
*.swo

# 环境配置（包含敏感信息）
.env
.env.*
config.ini

# 操作系统
.DS_Store
Thumbs.db

# 数据库
*.db
*.sqlite

# 其他
*.bak
*.backup
```

---

## 2. 核心规则

本项目采用"每次操作后自动 commit"的方式，确保会话压缩后可快速恢复记忆。

**任务执行流程（按顺序）：**

1. **执行任务**
2. **确认文件** - 检查 `.gitignore`，确认要提交的文件
3. **git add \<文件\>** - 只添加需要提交的文件
4. **git commit** - 提交变更

> **重要**：
> - 所有文件修改都需要提交（代码、文档、配置、模板等）
> - 必须先确认 `.gitignore` 存在且完整

---

## 3. Commit Message 格式

```
<类型>: <简短描述>

可选的详细说明（超过一行时使用）
```

**类型标签：**

| 类型 | 适用场景 | 示例 |
|:-----|:---------|:-----|
| `feat` | 新增功能 | `feat: 完成用户模块创建` |
| `fix` | 修复bug | `fix: 修复登录错误` |
| `refactor` | 重构 | `refactor: 重构用户模块结构` |
| `docs` | 文档 | `docs: 更新API文档` |
| `config` | 配置 | `config: 调整某配置` |
| `test` | 测试 | `test: 添加单元测试` |
| `chore` | 杂项 | `chore: 清理临时文件` |

---

## 4. 会话压缩/中断后恢复流程

**第一步：查看最近操作**

```bash
git log --oneline -20
```

**第二步：查看具体改动**

```bash
# 查看某个提交的具体改动
git show <commit-hash>

# 只看改动的文件列表
git show <commit-hash> --stat
```

---

## 5. 判断标准：什么时候需要 commit

| 场景 | 需要commit | 示例 |
|:-----|:----------|:-----|
| 完成一个功能模块 | ✅ | 创建了用户模块的模型+视图+注册 |
| 完成一个接口 | ✅ | 完成了/user/list接口 |
| 完成bug修复 | ✅ | 修复了某个导入错误 |
| 完成文档更新 | ✅ | 更新了API文档 |
| 完成配置修改 | ✅ | 修改了某项配置 |
| 完成规范修改 | ✅ | 修改了AI操作规范 |
| 完成测试验证 | ✅ | 添加了单元测试 |
| 探索性/临时代码 | ❌ | 临时测试、调试（验证后删除） |
| 不完整的修改 | ❓ | 写到一半需要下次继续（标注TODO） |

> **注意**：文档、规范、配置文件的修改与代码同等重要，必须立即提交。

---

## 6. 良好实践

**✅ 好的 commit message**

```bash
git commit -m "feat: 完成用户模块模型、视图和API接口"
git commit -m "fix: 修复导入时字段获取错误的bug"
git commit -m "docs: 更新API文档示例"
```

**❌ 差的 commit message**

```bash
git commit -m "update"           # 太模糊
git commit -m "fix bug"          # 不完整
git commit -m "changes"          # 不知道改了什么
```

---

## 6. 相关文件

| 文件 | 说明 |
|:-----|:-----|
| `AGENTS.md` | 项目规范和Git使用规范 |
| `AI操作规范.md` | 项目AI操作规范 |
