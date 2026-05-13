@echo off
:: 拉取规范体系并覆盖到当前目录
:: 用法: 双击运行 或 cmd /c pull_norms.bat
:: 规则：
::   - .gitignore 和 README.md 存在时不覆盖
::   - 不拉取 pull_norms.bat 和 pull_norms.sh 本身

set REPO_URL=https://github.com/742366981/PythonDocument
set BRANCH=master

echo 正在拉取规范体系...

:: 创建临时目录
set TEMP_DIR=%TEMP%\pull_norms_%RANDOM%
mkdir %TEMP_DIR% 2>nul
set WORK_DIR=%TEMP_DIR%\work
mkdir %WORK_DIR% 2>nul

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

:: 备份 .gitignore 和 README.md（如存在）
set SKIP_GITIGNORE=0
set SKIP_README=0

if exist ".gitignore" (
    copy ".gitignore" "%TEMP_DIR%\gitignore_backup" >nul
    set SKIP_GITIGNORE=1
)

if exist "README.md" (
    copy "README.md" "%TEMP_DIR%\readme_backup" >nul
    set SKIP_README=1
)

:: 备份 tools 目录（如存在）
set SKIP_TOOLS=0
if exist "tools" (
    xcopy /E /I /Y "tools" "%TEMP_DIR%\tools_backup" >nul
    set SKIP_TOOLS=1
)

:: 复制内容到工作目录（排除脚本本身）
echo 准备文件...
for /d %%i in ("%SOURCE_DIR%\*") do (
    set ITEM_NAME=%%~nxi
    if not "!ITEM_NAME!"=="pull_norms.bat" if not "!ITEM_NAME!"=="pull_norms.sh" (
        xcopy /E /I /Y "%%i" "%WORK_DIR%\%%~nxi" >nul
    )
)
for %%i in ("%SOURCE_DIR%\*.md") do (
    xcopy /Y "%%i" "%WORK_DIR%\" >nul
)
for %%i in ("%SOURCE_DIR%\*.txt") do (
    xcopy /Y "%%i" "%WORK_DIR%\" >nul
)
for %%i in ("%SOURCE_DIR%\*.json") do (
    xcopy /Y "%%i" "%WORK_DIR%\" >nul
)
for %%i in ("%SOURCE_DIR%\AGENTS.*") do (
    xcopy /Y "%%i" "%WORK_DIR%\" >nul
)
for %%i in ("%SOURCE_DIR%\CLAUDE.*") do (
    xcopy /Y "%%i" "%WORK_DIR%\" >nul
)

:: 合并到当前目录
echo 合并到当前目录...
for /d %%i in ("%WORK_DIR%\*") do (
    set ITEM_NAME=%%~nxi
    if exist "!ITEM_NAME!" (
        xcopy /E /I /Y "%%i" "!ITEM_NAME!\" >nul
    ) else (
        xcopy /E /I /Y "%%i" . >nul
    )
)
for %%i in ("%WORK_DIR%\*.md") do xcopy /Y "%%i" . >nul
for %%i in ("%WORK_DIR%\*.txt") do xcopy /Y "%%i" . >nul
for %%i in ("%WORK_DIR%\*.json") do xcopy /Y "%%i" . >nul
for %%i in ("%WORK_DIR%\AGENTS.*") do xcopy /Y "%%i" . >nul
for %%i in ("%WORK_DIR%\CLAUDE.*") do xcopy /Y "%%i" . >nul

:: 恢复备份的文件
if %SKIP_GITIGNORE%==1 (
    copy "%TEMP_DIR%\gitignore_backup" ".gitignore" >nul
    echo   - .gitignore 已恢复
)

if %SKIP_README%==1 (
    copy "%TEMP_DIR%\readme_backup" "README.md" >nul
    echo   - README.md 已恢复
)

if %SKIP_TOOLS%==1 (
    xcopy /E /I /Y "%TEMP_DIR%\tools_backup" "tools\" >nul
    echo   - tools/ 已恢复
)

:: 清理
rmdir /s /q "%TEMP_DIR%" 2>nul

echo 完成！规范体系已更新
pause
