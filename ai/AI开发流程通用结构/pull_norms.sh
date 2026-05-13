#!/bin/bash
# 拉取规范体系并覆盖到当前目录
# 用法: bash pull_norms.sh
# 规则：.gitignore 和 README.md 存在时不覆盖，其他都覆盖

set -e

REPO_URL="https://github.com/742366981/PythonDocument"
BRANCH="master"

echo "正在拉取规范体系..."

# 创建临时目录
TEMP_DIR=$(mktemp -d)

# 下载 tarball
curl -sL "${REPO_URL}/archive/${BRANCH}.tar.gz" -o "${TEMP_DIR}/archive.tar.gz"

# 解压
tar -xzf "${TEMP_DIR}/archive.tar.gz" -C "${TEMP_DIR}"

# 规范内容在 PythonDocument-master/ai/AI开发流程通用结构/
SOURCE_DIR="${TEMP_DIR}/PythonDocument-${BRANCH}/ai/AI开发流程通用结构"

if [ ! -d "${SOURCE_DIR}" ]; then
    echo "错误：未找到规范目录"
    rm -rf "${TEMP_DIR}"
    exit 1
fi

# 备份 .gitignore 和 README.md（如存在）
SKIP_GITIGNORE=0
SKIP_README=0

if [ -f "${SOURCE_DIR}/.gitignore" ]; then
    cp "${SOURCE_DIR}/.gitignore" "${TEMP_DIR}/gitignore_backup"
    SKIP_GITIGNORE=1
fi

if [ -f "${SOURCE_DIR}/README.md" ]; then
    cp "${SOURCE_DIR}/README.md" "${TEMP_DIR}/readme_backup"
    SKIP_README=1
fi

# 删除目标目录（如存在）
if [ -d "${SOURCE_DIR}" ]; then
    rm -rf "${SOURCE_DIR}"
fi

# 重新解压一次（因为上面删除了）
tar -xzf "${TEMP_DIR}/archive.tar.gz" -C "${TEMP_DIR}"

# 把 AI开发流程通用结构 里面的内容移到当前目录
for item in "${SOURCE_DIR}"/*; do
    item_name=$(basename "${item}")
    if [ -f "${item}" ]; then
        # 文件
        if [ -f "${item_name}" ]; then
            # 当前目录已有同名文件
            if [ "${item_name}" = ".gitignore" ] || [ "${item_name}" = "README.md" ]; then
                echo "  - ${item_name} 已存在，跳过覆盖"
            else
                rm -f "${item_name}"
                mv "${item}" .
            fi
        else
            mv "${item}" .
        fi
    elif [ -d "${item}" ]; then
        # 目录
        if [ -d "${item_name}" ]; then
            # 目录已存在，合并内容
            cp -r "${item}"/* "${item_name}/"
        else
            mv "${item}" .
        fi
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

# 清理
rm -rf "${TEMP_DIR}"

echo "完成！规范体系已更新到当前目录"
