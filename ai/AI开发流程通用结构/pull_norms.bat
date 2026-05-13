@echo off
:: 拉取规范体系并覆盖到当前目录
:: 用法: 双击运行 或 cmd /c pull_norms.bat
:: 规则：
::   - 项目外拉取 AI开发流程通用结构/
::   - 覆盖所有文件，除了 .gitignore、README.md、tools/下已存在的文件

set REPO_URL=https://github.com/742366981/PythonDocument
set BRANCH=master

echo 正在拉取规范体系...

:: 创建临时目录
set TEMP_DIR=%TEMP%\pull_norms_%RANDOM%
mkdir %TEMP_DIR% 2>nul

:: 下载 tarball
echo 下载中...
where curl >nul 2>&1
if %errorlevel%==0 (
    curl -sL "%REPO_URL%/archive/%BRANCH%.tar.gz" -o "%TEMP_DIR%\archive.tar.gz"
) else (
    powershell -Command "Invoke-WebRequest -Uri '%REPO_URL%/archive/%BRANCH%.tar.gz' -OutFile '%TEMP_DIR%\archive.tar.gz'"
)

:: 解压
echo 解压中...
powershell -Command "Expand-Archive -Path '%TEMP_DIR%\archive.tar.gz' -DestinationPath '%TEMP_DIR%' -Force"

:: 查找解压后的目录
for /d %%i in ("%TEMP_DIR%\PythonDocument-%BRANCH%") do set SOURCE_BASE=%%i
set SOURCE_DIR=%SOURCE_BASE%\ai\AI开发流程通用结构

if not exist "%SOURCE_DIR%" (
    echo 错误：未找到规范目录
    rmdir /s /q "%TEMP_DIR%" 2>nul
    pause
    exit /b 1
)

echo 合并到当前目录...

:: 遍历源目录内容
for /d %%i in ("%SOURCE_DIR%\*") do (
    set ITEM_NAME=%%~nxi

    :: 跳过脚本本身
    if "!ITEM_NAME!"=="pull_norms.sh" goto :skip_item
    if "!ITEM_NAME!"=="pull_norms.bat" goto :skip_item

    if "!ITEM_NAME!"=="tools" (
        :: tools 目录：只覆盖已存在的文件
        for %%j in ("%%i\*") do (
            set SUB_NAME=%%~nxj
            if exist "tools\!SUB_NAME!" (
                copy /Y "%%j" "tools\!SUB_NAME!" >nul
                echo   ~ tools\!SUB_NAME!
            ) else (
                copy "%%j" "tools\" >nul
                echo   + tools\!SUB_NAME!
            )
        )
    ) else (
        :: 其他目录：直接覆盖
        rmdir /s /q "!ITEM_NAME!" 2>nul
        xcopy /E /I /Y "%%i" "!ITEM_NAME!" >nul
        echo   ~ !ITEM_NAME!\ (覆盖)
    )

    :skip_item
)

:: 处理文件
for %%i in ("%SOURCE_DIR%\*") do (
    set FILE_NAME=%%~nxi

    :: 跳过脚本本身
    if "!FILE_NAME!"=="pull_norms.sh" goto :skip_file
    if "!FILE_NAME!"=="pull_norms.bat" goto :skip_file

    if exist "!FILE_NAME!" (
        if "!FILE_NAME!"==".gitignore" (
            echo   = !FILE_NAME! (跳过)
        ) else if "!FILE_NAME!"=="README.md" (
            echo   = !FILE_NAME! (跳过)
        ) else (
            copy /Y "%%i" . >nul
            echo   ~ !FILE_NAME! (覆盖)
        )
    ) else (
        copy "%%i" . >nul
        echo   + !FILE_NAME! (新建)
    )

    :skip_file
)

:: 清理
rmdir /s /q "%TEMP_DIR%" 2>nul

echo 完成！规范体系已更新
pause
