<#
.SYNOPSIS
    Windows Sleep-Mode Wake & Display
    ---------------------------------
    Wakes a Windows PC from sleep on a daily schedule and forces the screen
    on (Windows leaves the display off on an unattended timer wake).

    Interactive menu — just run it and pick a number.

.NOTES
    Target shell : Windows PowerShell 5.1 (the classic "blue" console).
    Requires     : Administrator (the script self-elevates via UAC).
    Sleep state  : S3 with wake timers enabled. Check with `powercfg /a`.
#>

# ─────────────────────────────────────────────────────────────
#  SELF-ELEVATE (UAC) — relaunch as admin if we're not already
# ─────────────────────────────────────────────────────────────
$principal = New-Object Security.Principal.WindowsPrincipal(
    [Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process -FilePath "powershell.exe" -Verb RunAs `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

# ─────────────────────────────────────────────────────────────
#  SETTINGS (fixed — the user picks the wake time from the menu)
# ─────────────────────────────────────────────────────────────
$TaskName   = "SleepWakeDisplay"
$ScriptDir  = "C:\SleepWakeDisplay"
$ScriptPath = Join-Path $ScriptDir "wake-display-action.ps1"

# The screen-wake action. mouse_event fires a real, system-level input event
# that lights the display. dx/dy are int (allow negative) so the cursor
# returns to its start — its position never actually changes.
$ActionBody = @'
Add-Type -MemberDefinition @"
[DllImport("user32.dll")]
public static extern void mouse_event(uint f, int dx, int dy, uint d, int e);
"@ -Name Mouse -Namespace Win

for ($i = 0; $i -lt 3; $i++) {
    [Win.Mouse]::mouse_event(0x0001, 10, 0, 0, 0)
    Start-Sleep -Milliseconds 150
    [Win.Mouse]::mouse_event(0x0001, -10, 0, 0, 0)
    Start-Sleep -Milliseconds 150
}
Start-Sleep -Seconds 5
'@

# ─────────────────────────────────────────────────────────────
#  HELPERS
# ─────────────────────────────────────────────────────────────

function Write-WakeScript {
    New-Item -ItemType Directory -Path $ScriptDir -Force | Out-Null
    $ActionBody | Out-File -FilePath $ScriptPath -Encoding UTF8
}

function Read-WakeTime {
    # Prompts for a 24-hour HH:mm time and validates it. Returns [datetime].
    while ($true) {
        Write-Host ""
        Write-Host "Enter wake time in 24-hour format (HH:mm)" -ForegroundColor Cyan
        Write-Host "ادخل وقت الايقاظ بصيغة 24 ساعة (HH:mm)" -ForegroundColor Cyan
        Write-Host "Examples / امثلة:  00:20   03:00   22:30" -ForegroundColor DarkGray
        $raw = Read-Host "  >"
        try {
            $t = [datetime]::ParseExact($raw.Trim(), "HH:mm", $null)
            return $t
        } catch {
            Write-Host "Invalid format. Use HH:mm (e.g. 03:00)." -ForegroundColor Red
            Write-Host "صيغة خاطئة. استخدم HH:mm (مثال 03:00)." -ForegroundColor Red
        }
    }
}

function Install-Wake {
    $time = Read-WakeTime
    $hhmm = $time.ToString("HH:mm")

    Write-Host ""
    Write-Host "Installing wake task for $hhmm ..." -ForegroundColor Cyan
    Write-Host "جاري تثبيت مهمة الايقاظ الساعة $hhmm ..." -ForegroundColor Cyan

    # 1) write the screen-wake action script
    Write-WakeScript

    # 2) allow wake timers (1 = Enable, not "important only")
    powercfg /setacvalueindex SCHEME_CURRENT SUB_SLEEP RTCWAKE 1 | Out-Null
    powercfg /setactive SCHEME_CURRENT | Out-Null

    # 3) register the daily wake task
    $action = New-ScheduledTaskAction -Execute "powershell.exe" `
        -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`""
    $trigger  = New-ScheduledTaskTrigger -Daily -At $time
    $settings = New-ScheduledTaskSettingsSet -WakeToRun `
        -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

    Register-ScheduledTask -TaskName $TaskName `
        -Action $action -Trigger $trigger -Settings $settings `
        -RunLevel Highest -Force | Out-Null

    Write-Host ""
    Write-Host "Installed. Verify below that NextRunTime is set and the task" -ForegroundColor Green
    Write-Host "appears in the wake-timers list." -ForegroundColor Green
    Write-Host "تم التثبيت. تاكد ادناه ان NextRunTime محدد وان المهمة تظهر في قائمة مؤقتات الايقاظ." -ForegroundColor Green
    Write-Host ""
    Show-Status
}

function Show-Status {
    $task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if (-not $task) {
        Write-Host "Not installed yet. Pick option 1 to install." -ForegroundColor Yellow
        Write-Host "غير مثبتة بعد. اختر 1 للتثبيت." -ForegroundColor Yellow
        return
    }

    $state = $task.State
    Write-Host "=== Task / المهمة ===" -ForegroundColor Cyan
    Get-ScheduledTaskInfo -TaskName $TaskName |
        Select-Object @{n="Task"; e={$TaskName}},
                      @{n="State"; e={$state}},
                      NextRunTime, LastRunTime, LastTaskResult |
        Format-List

    Write-Host "=== Armed wake timers / مؤقتات الايقاظ المسلّحة ===" -ForegroundColor Cyan
    powercfg /waketimers
}

function Test-Wake {
    if (-not (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue)) {
        Write-Host "Install first (option 1)." -ForegroundColor Yellow
        Write-Host "ثبّت اولا (الخيار 1)." -ForegroundColor Yellow
        return
    }

    Write-WakeScript   # make sure the action script exists
    $testName = "$TaskName-TEST"
    $runAt    = (Get-Date).AddMinutes(3)

    $action = New-ScheduledTaskAction -Execute "powershell.exe" `
        -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`""
    $trigger  = New-ScheduledTaskTrigger -Once -At $runAt
    $settings = New-ScheduledTaskSettingsSet -WakeToRun `
        -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

    Register-ScheduledTask -TaskName $testName `
        -Action $action -Trigger $trigger -Settings $settings `
        -RunLevel Highest -Force | Out-Null

    Write-Host ""
    Write-Host "Test wake armed for $($runAt.ToString('HH:mm:ss'))." -ForegroundColor Green
    Write-Host "اختبار الايقاظ مجدول الساعة $($runAt.ToString('HH:mm:ss'))." -ForegroundColor Green
    Write-Host ""
    Write-Host "NOW: put the PC to sleep and DON'T touch it. Watch if it wakes" -ForegroundColor Yellow
    Write-Host "and the screen lights up on its own." -ForegroundColor Yellow
    Write-Host "الان: نوّم الجهاز ولا تلمسه. راقب هل يستيقظ وتضيء الشاشة وحدها." -ForegroundColor Yellow
    Write-Host ""
    powercfg /waketimers
    Write-Host ""
    Write-Host "After it wakes, check the source with:  powercfg /lastwake" -ForegroundColor DarkGray
    Write-Host "The test task auto-expires; remove it from option 5 if you like." -ForegroundColor DarkGray
}

function Disable-Wake {
    $task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if (-not $task) {
        Write-Host "Not installed." -ForegroundColor Yellow
        Write-Host "غير مثبتة." -ForegroundColor Yellow
        return
    }
    if ($task.State -eq "Disabled") {
        Enable-ScheduledTask -TaskName $TaskName | Out-Null
        Write-Host "Re-enabled. The wake task is active again." -ForegroundColor Green
        Write-Host "تمت اعادة التفعيل. مهمة الايقاظ نشطة مجددا." -ForegroundColor Green
    } else {
        Disable-ScheduledTask -TaskName $TaskName | Out-Null
        Write-Host "Temporarily disabled (not deleted). Pick this option again to re-enable." -ForegroundColor Green
        Write-Host "تم التعطيل المؤقت (دون حذف). اختر هذا الخيار مجددا لاعادة التفعيل." -ForegroundColor Green
    }
}

function Remove-Wake {
    Get-ScheduledTask -TaskName "$TaskName*" -ErrorAction SilentlyContinue |
        Unregister-ScheduledTask -Confirm:$false
    if (Test-Path $ScriptPath) { Remove-Item $ScriptPath -Force }
    Write-Host "Removed. (Power settings left unchanged.)" -ForegroundColor Green
    Write-Host "تم الحذف. (لم تُغيَّر اعدادات الطاقة.)" -ForegroundColor Green
}

# ─────────────────────────────────────────────────────────────
#  MENU LOOP
# ─────────────────────────────────────────────────────────────
function Show-Menu {
    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Blue
    Write-Host "  Windows Sleep-Mode Wake & Display" -ForegroundColor White
    Write-Host "  ايقاظ ويندوز من النوم واضاءة الشاشة" -ForegroundColor White
    Write-Host "==================================================" -ForegroundColor Blue
    Write-Host "  1.  Install wake task      /  تثبيت الايقاظ"
    Write-Host "  2.  Show status            /  عرض الحالة"
    Write-Host "  3.  Test (dry-run)         /  اختبار مضغوط"
    Write-Host "  4.  Disable / Enable       /  تعطيل مؤقت / تفعيل"
    Write-Host "  5.  Uninstall (delete)     /  حذف نهائي"
    Write-Host "  6.  Exit                   /  خروج"
    Write-Host "==================================================" -ForegroundColor Blue
}

while ($true) {
    Show-Menu
    $choice = Read-Host "Select / اختر (1-6)"
    switch ($choice.Trim()) {
        "1" { Install-Wake }
        "2" { Show-Status }
        "3" { Test-Wake }
        "4" { Disable-Wake }
        "5" { Remove-Wake }
        "6" { Write-Host "Bye. / مع السلامة."; break }
        default {
            Write-Host "Enter a number from 1 to 6." -ForegroundColor Red
            Write-Host "ادخل رقما من 1 الى 6." -ForegroundColor Red
        }
    }
    if ($choice.Trim() -eq "6") { break }
    Write-Host ""
    Write-Host "Press Enter to return to the menu... / اضغط Enter للعودة للقائمة..." -ForegroundColor DarkGray
    [void](Read-Host)
}
