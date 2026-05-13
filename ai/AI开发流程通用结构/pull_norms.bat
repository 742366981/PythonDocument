@echo off
:: 拉取规范体系并覆盖到当前目录
:: 用法: 双击运行 或 cmd /c pull_norms.bat
:: 规则：.gitignore 和 README.md 存在时不覆盖，其他都覆盖

set REPO_URL=https://github.com/742366981/PythonDocument
set BRANCH=master
set TARGET_DIR=ai\AI开发流程通用结构

echo 正在拉取规范体系...

:: 创建临时目录
set TEMP_DIR=%TEMP%\pull_norms_%RANDOM%
mkdir %TEMP_DIR% 2>nul

:: 下载 tarball (需要 curl 或 powershell)
where curl >nul 2>&1
if %errorlevel%==0 (
    curl -sL "%REPO_URL%/archive/%BRANCH%.tar.gz" -o "%TEMP_DIR%\archive.tar.gz"
) else (
    powershell -Command "Invoke-WebRequest -Uri '%REPO_URL%/archive/%BRANCH%.tar.gz' -OutFile '%TEMP_DIR%\archive.tar.gz'"
)

:: 解压 (需要 tar 或 powershell)
where tar >nul 2>&1
if %errorlevel%==0 (
    tar -xzf "%TEMP_DIR%\archive.tar.gz" -C "%TEMP_DIR%"
) else (
    powershell -Command "Expand-Archive -Path '%TEMP_DIR%\archive.tar.gz' -DestinationPath '%TEMP_DIR%' -Force"
)

:: 查找解压后的目录
for /d %%i in ("%TEMP_DIR%\PythonDocument-%BRANCH%") do set SOURCE_DIR=%%i\%TARGET_DIR%

if not exist "%SOURCE_DIR%" (
    echo 错误：未找到规范目录
    rmdir /s /q "%TEMP_DIR%" 2>nul
    pause
    exit /b 1
)

:: 备份 .gitignore 和 README.md（如存在）
set SKIP_GITIGNORE=0
set SKIP_README=0

if exist "%TARGET_DIR%\.gitignore" (
    copy "%TARGET_DIR%\.gitignore" "%TEMP_DIR%\gitignore_backup" >nul
    set SKIP_GITIGNORE=1
    echo   - .gitignore 已备份，将跳过覆盖
)

if exist "%TARGET_DIR%\README.md" (
    copy "%TARGET_DIR%\README.md" "%TEMP_DIR%\readme_backup" >nul
    set SKIP_README=1
    echo   - README.md 已备份，将跳过覆盖
)

:: 删除目标目录（如存在）
if exist "%TARGET_DIR%" (
    rmdir /s /q "%TARGET_DIR%"
)

:: 移动到当前目录
move "%SOURCE_DIR%" "%TARGET_DIR%"

:: 恢复备份的文件
if %SKIP_GITIGNORE%==1 (
    copy "%TEMP_DIR%\gitignore_backup" "%TARGET_DIR%\.gitignore" >nul
    echo   - .gitignore 已恢复
)

if %SKIP_README%==1 (
    copy "%TEMP_DIR%\readme_backup" "%TARGET_DIR%\README.md" >nul
    echo   - README.md 已恢复
)

:: 清理
rmdir /s /q "%TEMP_DIR%" 2>nul

echo 完成！规范体系已更新：%TARGET_DIR%\
pause
