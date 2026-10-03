@echo off
chcp 65001 > nul
setlocal

REM ============================================================
REM  中国传统纹样图鉴 一键推送到个人 GitHub
REM  目标仓库：git@github.com:BlaineGale/chinese-traditional-patterns.git
REM  推送分支：main
REM  注意：源仓库必须是完整历史克隆，不能用 --depth 1
REM ============================================================

set REPO=git@github.com:BlaineGale/chinese-traditional-patterns.git
set SRC=%TEMP%\ctp_git

echo ==========================================
echo    中国传统纹样图鉴 推送工具
echo ==========================================
echo.

if not exist "%SRC%\.git" (
    echo [错误] 找不到源仓库：%SRC%
    echo.
    echo 请先执行完整克隆（注意不要加 --depth 1）：
    echo     git clone https://github.com/dososo/chinese-traditional-patterns.git ctp_git
    echo.
    pause
    exit /b 1
)

cd /d "%SRC%"

REM --- 检查浅克隆 ---
git rev-parse --is-shallow-repository | findstr /C:"true" > nul
if not errorlevel 1 (
    echo [错误] 检测到浅克隆仓库，无法推送。
    echo 请改用完整克隆（不要加 --depth 1）。
    pause
    exit /b 1
)

echo [1/3] 源仓库：%SRC%
for /f %%c in ('git rev-list --count HEAD') do echo       提交数：%%c
for /f %%f in ('git ls-tree -r --name-only HEAD ^| find /c /v ""') do echo       文件数：%%f
echo.

REM --- 检查 SSH ---
echo [2/3] 检查 GitHub SSH 连接...
ssh -T git@github.com 2>&1 | findstr /C:"successfully authenticated" > nul
if errorlevel 1 (
    echo [错误] SSH 未认证，请先运行：ssh -T git@github.com
    pause
    exit /b 1
)
echo       SSH 正常，账号：BlaineGale
echo.

REM --- 确认远端仓库 ---
echo [3/3] 确认远端仓库...
git ls-remote --heads %REPO% > nul 2>&1
if errorlevel 1 (
    echo.
    echo ==========================================
    echo    远端仓库不存在，需要先创建
    echo ==========================================
    echo.
    echo 请在浏览器打开：https://github.com/new
    echo.
    echo   填写内容（仓库名务必用纯英文）：
    echo     Repository name : chinese-traditional-patterns
    echo     Description     : 中国传统纹样图鉴 100 纹样
    echo     Visibility      : Public
    echo     下面三个初始化选项全部不要勾
    echo.
    echo   注意：填完先看地址栏确认为
    echo         /BlaineGale/chinese-traditional-patterns
    echo         仓库名输入框会吞字符，之前的坑就出在这。
    echo.
    echo 建好后回到本窗口按任意键继续推送。
    echo.
    pause
)

echo.
echo 开始推送（约 245MB，需 3-10 分钟）...
echo.
git push -u %REPO% main
if errorlevel 1 (
    echo [错误] 推送失败
    pause
    exit /b 1
)

echo.
echo ==========================================
echo    推送完成
echo ==========================================
echo.
echo 仓库地址：https://github.com/BlaineGale/chinese-traditional-patterns
echo.
echo 提醒：本仓库内容为 CC BY-NC 4.0，限非商业用途。
echo.
pause
