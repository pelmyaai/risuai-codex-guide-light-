# ============================================================
#  clawgate 자동 설치 & 설정 스크립트
#  사용법: irm https://raw.githubusercontent.com/pelmyaai/risuai-codex-guide-light-/main/setup.ps1 | iex
# ============================================================

$ErrorActionPreference = "Stop"

function Write-Step($msg) {
    Write-Host ""
    Write-Host ">>> $msg" -ForegroundColor Cyan
}

function Write-Ok($msg) {
    Write-Host "    $msg" -ForegroundColor Green
}

function Write-Warn($msg) {
    Write-Host "    $msg" -ForegroundColor Yellow
}

# ── 1. 설치 확인 / 설치 ──────────────────────────────────────
Write-Step "clawgate 설치 확인 중..."

$installed = $null -ne (Get-Command clawgate -ErrorAction SilentlyContinue)

if ($installed) {
    Write-Ok "이미 설치되어 있어요. 설치 건너뜁니다."
} else {
    Write-Step "clawgate 설치 중..."
    irm clawgate.org/install.ps1 | iex

    # PATH 갱신
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("PATH", "User")

    $installed = $null -ne (Get-Command clawgate -ErrorAction SilentlyContinue)
    if (-not $installed) {
        Write-Host ""
        Write-Host "[오류] 설치 후에도 clawgate를 찾을 수 없어요." -ForegroundColor Red
        Write-Host "       PowerShell을 새로 열고 이 스크립트를 다시 실행해 보세요." -ForegroundColor Red
        exit 1
    }
    Write-Ok "설치 완료!"
}

# ── 2. 로그인 ────────────────────────────────────────────────
Write-Step "ChatGPT 로그인"
Write-Host ""
Write-Host "    브라우저에서 표시되는 주소로 들어가 코드를 입력하고" -ForegroundColor White
Write-Host "    ChatGPT 계정으로 승인하면 됩니다." -ForegroundColor White
Write-Host ""

$skipLogin = Read-Host "    이미 로그인되어 있으면 Enter, 새로 로그인하려면 y 입력"

if ($skipLogin -eq "y" -or $skipLogin -eq "Y") {
    clawgate login
    Write-Ok "로그인 완료!"
} else {
    Write-Warn "로그인 건너뜀. 나중에 'clawgate login' 으로 직접 하면 돼요."
}

# ── 3. 바탕화면 바로가기 생성 ────────────────────────────────
Write-Step "바탕화면 바로가기 만드는 중..."

# clawgate.exe 경로 찾기
$exePath = (Get-Command clawgate -ErrorAction SilentlyContinue)?.Source

if (-not $exePath) {
    # 기본 경로 fallback
    $exePath = "$env:USERPROFILE\.clawgate\bin\clawgate.exe"
}

$desktop = [Environment]::GetFolderPath("Desktop")
$shell   = New-Object -ComObject WScript.Shell

# 바로가기 1: 일반 실행
$sc1 = $shell.CreateShortcut("$desktop\RisuAI GPT 연결.lnk")
$sc1.TargetPath       = $exePath
$sc1.WorkingDirectory = Split-Path $exePath
$sc1.Description      = "clawgate 프록시 실행 (안정 모드)"
$sc1.Save()
Write-Ok "바로가기 생성: RisuAI GPT 연결.lnk"

# 바로가기 2: GPT-5.5 실험 모드
$sc2 = $shell.CreateShortcut("$desktop\RisuAI GPT 연결 (5.5 실험).lnk")
$sc2.TargetPath       = $exePath
$sc2.Arguments        = "--bigModel=gpt-5.5"
$sc2.WorkingDirectory = Split-Path $exePath
$sc2.Description      = "clawgate 프록시 실행 (GPT-5.5 실험 모드)"
$sc2.Save()
Write-Ok "바로가기 생성: RisuAI GPT 연결 (5.5 실험).lnk"

# ── 4. 완료 안내 ─────────────────────────────────────────────
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  설정 완료!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  바탕화면에 바로가기 2개가 생겼어요:" -ForegroundColor White
Write-Host "    - RisuAI GPT 연결          → 안정 모드" -ForegroundColor White
Write-Host "    - RisuAI GPT 연결 (5.5 실험) → GPT-5.5 실험 모드" -ForegroundColor White
Write-Host ""
Write-Host "  RisuAI 설정값:" -ForegroundColor White
Write-Host "    URL      : http://127.0.0.1:8082" -ForegroundColor Yellow
Write-Host "    키/패스워드: dummy" -ForegroundColor Yellow
Write-Host "    요청 모델  : claude-3-opus" -ForegroundColor Yellow
Write-Host "    포맷      : Anthropic Claude" -ForegroundColor Yellow
Write-Host "    스트리밍   : 켜기" -ForegroundColor Yellow
Write-Host ""
Write-Host "  RisuAI 쓰기 전에 바로가기 더블클릭하면 끝!" -ForegroundColor Green
Write-Host ""
