#!/bin/bash
# 拉取规范体系并覆盖到当前目录
# 用法: bash pull_norms.sh
# 规则：
#   - 拉取到临时目录后合并到当前目录
#   - .gitignore 和 README.md 存在时不覆盖
#   - 不拉取 pull_norms.sh 和 pull_norms.bat 本身

set -e

REPO_URL="https://github.com/742366981/PythonDocument"
BRANCH="master"

echo "正在拉取规范体系..."

# 创建临时目录
TEMP_DIR=$(mktemp -d)
WORK_DIR="${TEMP_DIR}/work"

# 下载 tarball
echo "下载中..."
curl -sL "${REPO_URL}/archive/${BRANCH}.tar.gz" -o "${TEMP_DIR}/archive.tar.gz"

# 解压
echo "解压中..."
tar -xzf "${TEMP_DIR}/archive.tar.gz" -C "${TEMP_DIR}"

# 规范内容在 PythonDocument-master/ai/AI开发流程通用结构/
SOURCE_DIR="${TEMP_DIR}/PythonDocument-${BRANCH}/ai/AI开发流程通用结构"

if [ ! -d "${SOURCE_DIR}" ]; then
    echo "错误：未找到规范目录"
    rm -rf "${TEMP_DIR}"
    exit 1
fi

# 复制内容到工作目录（排除脚本本身）
echo "准备文件..."
mkdir -p "${WORK_DIR}"

for item in "${SOURCE_DIR}"/*; do
    item_name=$(basename "${item}")

    # 不拉取脚本本身
    if [ "${item_name}" = "pull_norms.sh" ] || [ "${item_name}" = "pull_norms.bat" ]; then
        continue
    fi

    if [ -d "${item}" ]; then
        cp -r "${item}" "${WORK_DIR}/"
    else
        cp "${item}" "${WORK_DIR}/"
    fi
done

# 备份当前的 .gitignore 和 README.md（如存在）
SKIP_GITIGNORE=0
SKIP_README=0

if [ -f ".gitignore" ]; then
    cp .gitignore "${TEMP_DIR}/gitignore_backup"
    SKIP_GITIGNORE=1
fi

if [ -f "README.md" ]; then
    cp README.md "${TEMP_DIR}/readme_backup"
    SKIP_README=1
fi

# 备份当前的 tools 目录（如存在）
SKIP_TOOLS=0
if [ -d "tools" ]; then
    cp -r tools "${TEMP_DIR}/tools_backup"
    SKIP_TOOLS=1
fi

# 合并到当前目录
echo "合并到当前目录..."

for item in "${WORK_DIR}"/*; do
    item_name=$(basename "${item}")

    if [ -d "${item}" ]; then
        # 目录：合并内容
        if [ -d "${item_name}" ]; then
            cp -r "${item}"/* "${item_name}/"
        else
            cp -r "${item}" .
        fi
    else
        # 文件：直接覆盖
        cp "${item}" .
    fi
done

# 恢复备份的文件
if [ ${SKIP_GITIGNORE} -eq 1 ]; then
    cp "${TEMP_DIR}/gitignore_backup" ./.gitignore
    echo "  - .gitignore 已恢复"
fi

if [ ${SKIP_README} -eq 1 ]; then
    cp "${TEMP_DIR}/readme_backup" ./README.md
    echo "  - README.md 已恢复"
fi

if [ ${SKIP_TOOLS} -eq 1 ]; then
    cp -r "${TEMP_DIR}/tools_backup" ./tools
    echo "  - tools/ 已恢复"
fi

# 清理临时目录
rm -rf "${TEMP_DIR}"

echo "完成！规范体系已更新"
