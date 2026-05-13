#!/bin/bash
# 拉取规范体系并覆盖到当前目录
# 用法: bash pull_norms.sh
# 规则：
#   - .gitignore、README.md 存在就跳过
#   - tools/ 下：覆盖所有文件
#   - docs/ 和其他目录：只新建不存在的，已有的不动

set -e

REPO_URL="https://github.com/742366981/PythonDocument"
# 国内加速镜像（如需）
# REPO_URL="https://ghproxy.com/https://github.com/742366981/PythonDocument"
BRANCH="master"

echo "正在拉取规范体系..."

# 创建临时目录
TEMP_DIR=$(mktemp -d)

# 使用 git clone 拉取（--depth 1 只拉取最新版本）
echo "下载中..."
git clone --depth 1 --single-branch --branch "${BRANCH}" "${REPO_URL}" "${TEMP_DIR}/repo" 2>/dev/null || {
    echo "错误：下载失败"
    rm -rf "${TEMP_DIR}"
    exit 1
}

# 规范目录
NORM_DIR="${TEMP_DIR}/repo/ai/AI开发流程通用结构"
if [ ! -d "${NORM_DIR}" ]; then
    echo "错误：未找到规范目录"
    rm -rf "${TEMP_DIR}"
    exit 1
fi

echo "合并到当前目录..."

# 定义处理函数
process_item() {
    local src="$1"
    local dst="$2"
    local name="$3"
    local is_tools="$4"

    if [ -d "${src}" ]; then
        mkdir -p "${dst}"
        for sub in "${src}"/*; do
            [ -e "$sub" ] || continue
            sub_name=$(basename "$sub")
            # 跳过脚本
            [ "$sub_name" = "pull_norms.sh" ] && continue
            process_item "$sub" "${dst}/${sub_name}" "$sub_name" "$is_tools"
        done
    elif [ -f "${src}" ]; then
        # 跳过 .gitignore 和 README.md
        [ "$name" = ".gitignore" ] && return
        [ "$name" = "README.md" ] && return

        if [ -f "${dst}" ]; then
            if [ "$is_tools" = "yes" ]; then
                # tools 目录：覆盖
                cp -f "${src}" "${dst}"
                echo "  ~ ${name}"
            else
                # 其他目录：保留原有的
                :
            fi
        else
            # 不存在则创建
            cp -f "${src}" "${dst}"
            echo "  + ${name}"
        fi
    fi
}

# 遍历规范目录
for item in "${NORM_DIR}"/*; do
    [ -e "$item" ] || continue
    item_name=$(basename "$item")

    # 跳过脚本
    [ "$item_name" = "pull_norms.sh" ] && continue

    if [ -d "$item" ]; then
        if [ "$item_name" = "tools" ]; then
            # tools 目录：覆盖所有文件
            process_item "$item" "./tools" "$item_name" "yes"
        else
            # 其他目录：只新建不存在的
            process_item "$item" "./${item_name}" "$item_name" "no"
        fi
    else
        # 文件
        [ "$item_name" = ".gitignore" ] && echo "  = ${item_name} (跳过)" && continue
        [ "$item_name" = "README.md" ] && echo "  = ${item_name} (跳过)" && continue
        if [ -f "$item_name" ]; then
            cp -f "$item" "$item_name"
            echo "  ~ ${item_name}"
        else
            cp -f "$item" "$item_name"
            echo "  + ${item_name}"
        fi
    fi
done

# 清理
rm -rf "${TEMP_DIR}"

echo "完成！规范体系已更新"
