@echo off
:: 拉取规范体系并合并到当前目录
:: 用法: 双击运行 或 cmd /c pull_norms.bat
:: 规则：
::   - 拉取到临时目录后，基于文件逐个判断是否覆盖
::   - 目标文件已存在：不覆盖（跳过）
::   - 目标文件不存在：创建
::   - .gitignore、README.md 即使存在也不覆盖

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

    if exist "!ITEM_NAME!" (
        :: 目标目录已存在，只复制不覆盖已存在的文件
        for /d %%j in ("%%i\*") do (
            set SUB_NAME=%%~nj
            if not exist "!ITEM_NAME!\%%~nj" (
                xcopy /E /I /Y "%%j" "!ITEM_NAME!\%%~nj" >nul
                echo   + !ITEM_NAME!\%%~nj\ (新建)
            )
        )
        for %%j in ("%%i\*") do (
            set SUB_NAME=%%~nj
            if not exist "!ITEM_NAME!\%%~nxj" (
                copy /Y "%%j" "!ITEM_NAME!\" >nul
                echo   + !ITEM_NAME!\%%~nxj
            )
        )
    ) else (
        :: 目标目录不存在，直接创建
        xcopy /E /I /Y "%%i" "!ITEM_NAME!" >nul
        echo   + !ITEM_NAME!\ (新建)
    )

    :skip_item
)

:: 处理文件
for %%i in ("%SOURCE_DIR%\*.md") do (
    set FILE_NAME=%%~nxi
    if "%%~nxi"=="pull_norms.sh" goto :skip_file
    if "%%~nxi"=="pull_norms.bat" goto :skip_file

    if exist "%%~nxi" (
        if "%%~nxi"==".gitignore" (
            echo   = %%~nxi (跳过，不覆盖)
        ) else if "%%~nxi"=="README.md" (
            echo   = %%~nxi (跳过，不覆盖)
        ) else (
            copy /Y "%%i" . >nul
            echo   ~ %%~nxi (覆盖)
        )
    ) else (
        copy "%%i" . >nul
        echo   + %%~nxi (新建)
    )
    :skip_file
)

for %%i in ("%SOURCE_DIR%\*.txt") do (
    set FILE_NAME=%%~nxi
    if exist "%%~nxi" (
        copy /Y "%%i" . >nul
        echo   ~ %%~nxi (覆盖)
    ) else (
        copy "%%i" . >nul
        echo   + %%~nxi (新建)
    )
)

for %%i in ("%SOURCE_DIR%\*.json") do (
    set FILE_NAME=%%~nxi
    if exist "%%~nxi" (
        copy /Y "%%i" . >nul
        echo   ~ %%~nxi (覆盖)
    ) else (
        copy "%%i" . >nul
        echo   + %%~nxi (新建)
    )
)

for %%i in ("%SOURCE_DIR%\AGENTS.*") do (
    if exist "%%~nxi" (
        copy /Y "%%i" . >nul
        echo   ~ %%~nxi (覆盖)
    ) else (
        copy "%%i" . >nul
        echo   + %%~nxi (新建)
    )
)

for %%i in ("%SOURCE_DIR%\CLAUDE.*") do (
    if exist "%%~nxi" (
        copy /Y "%%i" . >nul
        echo   ~ %%~nxi (覆盖)
    ) else (
        copy "%%i" . >nul
        echo   + %%~nxi (新建)
    )
)

:: 清理
rmdir /s /q "%TEMP_DIR%" 2>nul

echo 完成！规范体系已合并到当前目录
pause
