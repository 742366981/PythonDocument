#!/bin/bash
# 拉取规范体系并覆盖到当前目录
# 用法: bash pull_norms.sh
# 规则：
#   - .gitignore、README.md 存在就跳过
#   - tools/：只新建不存在的，已有不动
#   - docs/ 和其他目录：覆盖所有文件

set -e

REPO_URL="https://githubfast.com/742366981/PythonDocument"
# 国内加速镜像（如需）
# REPO_URL="https://ghproxy.com/https://github.com/742366981/PythonDocument"
# REPO_URL="https://gitclone.com/github.com/742366981/PythonDocument"
# REPO_URL="https://hub.fastgit.xyz"
BRANCH="master"

# 创建临时目录
TEMP_DIR=$(mktemp -d)

# 退出时清理临时目录
trap 'rm -rf "${TEMP_DIR}"' EXIT INT TERM

echo "正在拉取规范体系..."

# 使用 git clone 拉取（--depth 1 只拉取最新版本）
echo "下载中..."
git clone --depth 1 --single-branch --branch "${BRANCH}" "${REPO_URL}" "${TEMP_DIR}/repo" || {
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
# 参数：$1=源 $2=目标 $3=名称 $4=是否覆盖(yes/no)
process_item() {
    local src="$1"
    local dst="$2"
    local name="$3"
    local overwrite="$4"

    if [ -d "${src}" ]; then
        mkdir -p "${dst}"
        for sub in "${src}"/*; do
            [ -e "$sub" ] || continue
            sub_name=$(basename "$sub")
            # 跳过脚本
            [ "$sub_name" = "pull_norms.sh" ] && continue
            process_item "$sub" "${dst}/${sub_name}" "$sub_name" "$overwrite"
        done
    elif [ -f "${src}" ]; then
        # 跳过 .gitignore 和 README.md
        [ "$name" = ".gitignore" ] && return
        [ "$name" = "README.md" ] && return

        if [ -f "${dst}" ]; then
            if [ "$overwrite" = "yes" ]; then
                # 覆盖已有文件
                cp -f "${src}" "${dst}"
                echo "  ~ ${name}"
            else
                # 不覆盖已有文件
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
            # tools/ 只新建不覆盖
            process_item "$item" "./${item_name}" "$item_name" "no"
        else
            # 其他目录覆盖所有文件
            process_item "$item" "./${item_name}" "$item_name" "yes"
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
