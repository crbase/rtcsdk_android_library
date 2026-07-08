@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

set VerName=4.8.3

:: ================= 配置区域 =================
set "ZIP_PATH=\\192.168.123.128\测试版本基线\RTCSDK\androidV4\RTCSDK_Android(V!VerName!).zip"
set "REPO_PATH=E:\GitCode\rtcsdk_android_library"
set "COMMIT_MSG=!VerName!"
set "TAG_NAME=!VerName!"
set "RELEASE_TITLE=!VerName!"
set "RELEASE_NOTES=!VerName!"
set "EXTRACT_DIR=!REPO_PATH!\rtcsdk_extract"
set "TARGET_PATH=!REPO_PATH!\libs"
:: ==========================================

echo VerName: !VerName!
echo ZIP_PATH: !ZIP_PATH!
echo REPO_PATH: !REPO_PATH!
echo EXTRACT_DIR: !EXTRACT_DIR!
echo TARGET_PATH: !TARGET_PATH!

:: 检查 ZIP 文件是否存在
if not exist "!ZIP_PATH!" (
    echo 错误：ZIP 文件不存在！
    echo 路径：!ZIP_PATH!
    pause
    exit /b 1
)

echo 正在创建临时解压目录...
if not exist "!EXTRACT_DIR!" mkdir "!EXTRACT_DIR!"

echo 正在解压 ZIP 文件...
powershell -command "Expand-Archive -Path '!ZIP_PATH!' -DestinationPath '!EXTRACT_DIR!' -Force"
if errorlevel 1 (
    echo 解压失败！请检查 ZIP 文件是否完整。
    pause
    exit /b 1
)

echo 正在拷贝 libs 目录...
if not exist "!TARGET_PATH!" mkdir "!TARGET_PATH!"

:: 检查解压后是否存在 libs 目录
if not exist "!EXTRACT_DIR!\libs" (
    echo 警告：解压后未找到 libs 目录，尝试查找...
    dir "!EXTRACT_DIR!"
    pause
    exit /b 1
)

xcopy "!EXTRACT_DIR!\libs\*" "!TARGET_PATH!\" /E /I /Y /H
if errorlevel 1 (
    echo 拷贝失败！
    pause
    exit /b 1
)

echo 拷贝完成，正在清理临时文件...
rmdir /s /q "!EXTRACT_DIR!"

echo 正在切换到项目目录: !REPO_PATH!
cd /d "!REPO_PATH!"
if errorlevel 1 (
    echo 错误：无法切换到目录 !REPO_PATH!
    pause
    exit /b 1
)
powershell -Command "(Get-Content build.gradle) -replace 'versionName \".*\"', 'versionName \"%VerName%\"' | Set-Content build.gradle"

echo 开始执行Git命令...

:: 添加文件变更
git add ./
if errorlevel 1 (
    echo 错误：git add 失败
    pause
    exit /b 1
)

:: 检查是否有变更需要提交
git diff --staged --quiet
if errorlevel 1 (
    echo 有文件变更，开始提交和推送...
    git commit -m "!COMMIT_MSG!"
    if errorlevel 1 (
        echo 错误：提交失败
        pause
        exit /b 1
    )
    git push
    if errorlevel 1 (
        echo 错误：推送失败
        pause
        exit /b 1
    )
    echo 代码推送成功
) else (
    echo 没有检测到任何文件变更，跳过提交和推送步骤
)

:: 2. 创建标签并推送到远程仓库
echo 正在创建标签: !TAG_NAME!
::  git tag -a "!TAG_NAME!" -m "!COMMIT_MSG!"
if errorlevel 1 (
    echo 标签 !TAG_NAME! 已存在，尝试直接推送...
    :: git push origin main
    if errorlevel 1 (
        echo 错误：推送标签失败
        pause
        exit /b 1
    )
    echo 标签推送成功
) else (
    ::  git push origin main
    if errorlevel 1 (
        echo 错误：推送标签失败
        pause
        exit /b 1
    )
    echo 标签推送成功
)

:: 3. 使用GitHub CLI (gh) 创建Release
:: 检查 gh 是否可用
:: gh --version >nul 2>&1
if errorlevel 1 (
    echo 警告: 未找到 GitHub CLI (gh)
    echo 请访问 https://cli.github.com/ 安装并登录
    pause
    exit /b 1
)

:: 检查 Release 是否已存在
echo 正在检查 Release 是否已存在...
:: gh release view "!TAG_NAME!" >nul 2>nul
if errorlevel 1 (
    echo Release 不存在，正在创建...
    gh release create "!TAG_NAME!" --title "!RELEASE_TITLE!" --notes "!RELEASE_NOTES!" --target main
    if errorlevel 1 (
        echo 错误：创建 Release 失败
        pause
        exit /b 1
    )
    echo Release 创建成功
) else (
    echo Release !TAG_NAME! 已存在，跳过创建
)

echo ======================================
echo 全部完成
echo ======================================
pause