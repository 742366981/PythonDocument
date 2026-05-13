#!/bin/bash
# 拉取规范体系并合并到当前目录
# 用法: bash pull_norms.sh
# 规则：
#   - 拉取到临时目录后，基于文件逐个判断是否覆盖
#   - 目标文件已存在：不覆盖（跳过）
#   - 目标文件不存在：创建
#   - .gitignore、README.md 即使存在也不覆盖

set -e

REPO_URL="https://github.com/742366981/PythonDocument"
BRANCH="master"

echo "正在拉取规范体系..."

# 创建临时目录
TEMP_DIR=$(mktemp -d)

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

echo "合并到当前目录..."

# 遍历源目录内容
for item in "${SOURCE_DIR}"/*; do
    item_name=$(basename "${item}")

    # 不处理脚本本身
    if [ "${item_name}" = "pull_norms.sh" ] || [ "${item_name}" = "pull_norms.bat" ]; then
        continue
    fi

    if [ -d "${item}" ]; then
        # 目录：逐个文件处理
        if [ ! -d "${item_name}" ]; then
            # 目标目录不存在，直接创建
            cp -r "${item}" .
            echo "  + ${item_name}/ (新建)"
        else
            # 目标目录已存在，只复制不覆盖已存在的文件
            for sub_item in "${item}"/*; do
                sub_name=$(basename "${sub_item}")
                if [ -f "${sub_item}" ]; then
                    if [ ! -f "${item_name}/${sub_name}" ]; then
                        cp "${sub_item}" "${item_name}/"
                        echo "  + ${item_name}/${sub_name}"
                    fi
                elif [ -d "${sub_item}" ]; then
                    if [ ! -d "${item_name}/${sub_name}" ]; then
                        cp -r "${sub_item}" "${item_name}/"
                        echo "  + ${item_name}/${sub_name}/ (新建)"
                    fi
                fi
            done
        fi
    else
        # 文件：判断是否覆盖
        if [ -f "${item_name}" ]; then
            # 文件已存在
            if [ "${item_name}" = ".gitignore" ] || [ "${item_name}" = "README.md" ]; then
                echo "  = ${item_name} (跳过，不覆盖)"
            else
                cp "${item}" "${item_name}"
                echo "  ~ ${item_name} (覆盖)"
            fi
        else
            # 文件不存在，直接创建
            cp "${item}" .
            echo "  + ${item_name} (新建)"
        fi
    fi
done

# 清理临时目录
rm -rf "${TEMP_DIR}"

echo "完成！规范体系已合并到当前目录"
