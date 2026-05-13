#!/bin/bash
# 拉取规范体系并覆盖到当前目录
# 用法: bash pull_norms.sh
# 规则：.gitignore 和 README.md 存在时不覆盖，其他都覆盖

set -e

REPO_URL="https://github.com/742366981/PythonDocument"
BRANCH="master"
TARGET_DIR="ai/AI开发流程通用结构"

echo "正在拉取规范体系..."

# 创建临时目录
TEMP_DIR=$(mktemp -d)

# 下载 tarball
curl -sL "${REPO_URL}/archive/${BRANCH}.tar.gz" -o "${TEMP_DIR}/archive.tar.gz"

# 解压
tar -xzf "${TEMP_DIR}/archive.tar.gz" -C "${TEMP_DIR}"

# 覆盖到当前目录
SOURCE_DIR="${TEMP_DIR}/PythonDocument-${BRANCH}/${TARGET_DIR}"

if [ ! -d "${SOURCE_DIR}" ]; then
    echo "错误：未找到规范目录 ${TARGET_DIR}"
    rm -rf "${TEMP_DIR}"
    exit 1
fi

# 备份 .gitignore 和 README.md（如存在）
SKIP_GITIGNORE=0
SKIP_README=0

if [ -f "${TARGET_DIR}/.gitignore" ]; then
    cp "${TARGET_DIR}/.gitignore" "${TEMP_DIR}/gitignore_backup"
    SKIP_GITIGNORE=1
    echo "  - .gitignore 已备份，将跳过覆盖"
fi

if [ -f "${TARGET_DIR}/README.md" ]; then
    cp "${TARGET_DIR}/README.md" "${TEMP_DIR}/readme_backup"
    SKIP_README=1
    echo "  - README.md 已备份，将跳过覆盖"
fi

# 删除目标目录（如存在）
if [ -d "${TARGET_DIR}" ]; then
    rm -rf "${TARGET_DIR}"
fi

# 移动到当前目录
mv "${SOURCE_DIR}" ./

# 恢复备份的文件
if [ ${SKIP_GITIGNORE} -eq 1 ]; then
    mv "${TEMP_DIR}/gitignore_backup" "${TARGET_DIR}/.gitignore"
fi

if [ ${SKIP_README} -eq 1 ]; then
    mv "${TEMP_DIR}/readme_backup" "${TARGET_DIR}/README.md"
fi

# 清理
rm -rf "${TEMP_DIR}"

echo "完成！规范体系已更新：${TARGET_DIR}/"
