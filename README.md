# Windows Sleep-Mode Wake & Display

**Run your scheduled tasks, automations, and workflows on time — without leaving your PC running 24/7.**

Got a nightly job, a scheduled automation, or a workflow that has to fire at a
set time? The usual "fix" is to just never let your machine sleep — burning
power all night so one task can run for two minutes. This tool lets your PC
**sleep normally and wake itself only when the work needs to happen**.

There's a catch Windows never solved: it *can* wake a sleeping PC on a timer,
but on an unattended wake it leaves the **screen black** until you physically
touch the mouse or keyboard — which breaks any automation that needs a live,
lit desktop. This tool fixes exactly that: it registers a daily wake task that
wakes the machine **and forces the screen on**, so your automation runs on a
real, visible desktop while you sleep.

**Wake a sleeping Windows PC on a daily schedule — and actually turn the screen on.**

Windows can wake a sleeping PC with a Task Scheduler wake timer, but on an
*unattended* wake it keeps the display powered off until real input arrives.
This tool registers a daily wake task whose action generates a tiny synthetic
mouse movement, forcing the screen on. Useful for unattended nightly jobs that
need a live, lit desktop (automation that drives a visible app, screen capture,
scheduled data syncs, RPA-style workflows, etc.).

*(العربية بالاسفل)*

---

## Quick install

Open the **classic blue Windows PowerShell** (press `Win+R`, type `powershell`,
Enter) and run:

```powershell
irm https://raw.githubusercontent.com/badrAlzahrani/windows-sleep-wake-display/main/install.ps1 | iex
```

A UAC prompt appears — click **Yes**. Then pick an option from the menu.

> Prefer not to pipe to `iex`? Use **Code → Download ZIP**, then right-click
> `wake-display.ps1` and choose **Run with PowerShell**.

---

## Menu options

| # | Option | What it does |
|---|--------|--------------|
| 1 | Install wake task | Asks for a wake time (24h `HH:mm`), enables wake timers, registers a daily wake task that lights the screen |
| 2 | Show status | Shows NextRunTime / LastRunTime and the armed wake timers |
| 3 | Test (dry-run) | Arms a one-time wake 3 minutes out so you can verify it works |
| 4 | Disable / Enable | Temporarily pauses the wake task without deleting it (toggle) |
| 5 | Uninstall | Deletes the task and its action script |
| 6 | Exit | |

---

## Requirements

| Requirement | Notes |
|-------------|-------|
| Windows 10 / 11 | |
| S3 sleep + wake timers | Check with `powercfg /a` (needs `Standby (S3)`) |
| Windows PowerShell 5.1 | The classic **blue** console, not `pwsh` |
| Administrator | The tool self-elevates via UAC |

---

## How it works

A daily Task Scheduler task is registered with the **wake-the-computer** flag,
so Windows arms a hardware wake timer. When it fires, its first action runs a
tiny PowerShell script that calls `mouse_event` (`user32.dll`) to emit a real
input event — which is what convinces Windows to power the display back on. The
cursor moves a few pixels and returns, so its position never actually changes.

**Verify, don't assume.** After installing, use *Show status* and confirm
`NextRunTime` is set and the task appears under the wake-timers list. Then run
*Test* once to confirm your hardware really wakes from sleep.

---

## Disclaimer

Use at your own risk. The tool registers a standard Windows scheduled task and
adjusts the "allow wake timers" power setting. It does not modify system files
or security settings. Whether your specific hardware wakes from sleep on a timer
depends on your BIOS/UEFI and power configuration.

Licensed under MIT.

---
---

# ايقاظ ويندوز من وضع النوم واضاءة الشاشة

**شغّل مهامك المجدولة واتمتتك وسير عملك في وقتها — دون ان تترك جهازك يعمل 24 ساعة.**

عندك مهمة ليلية، او اتمتة مجدولة، او workflow لازم يشتغل في وقت محدد؟ الحل الشائع
هو ان تمنع جهازك من النوم اطلاقا — فيستهلك الكهرباء طوال الليل لتشتغل مهمة واحدة
دقيقتين. هذه الاداة تجعل جهازك **ينام بشكل طبيعي ويستيقظ وحده فقط حين يحين وقت
العمل**.

لكن هناك عقبة لم يحلّها ويندوز: يستطيع ايقاظ الجهاز بمؤقّت، لكنه في الايقاظ غير
المصحوب بمستخدم يُبقي **الشاشة سوداء** حتى تحرّك الفأرة او الكيبورد بنفسك — وهذا
يكسر اي اتمتة تحتاج سطح مكتب حيّا ومضاءً. هذه الاداة تحلّ هذا بالضبط: تسجّل مهمة
ايقاظ يومية توقظ الجهاز **وتجبر الشاشة على العمل**، فتشتغل اتمتتك على سطح مكتب
حقيقي مرئي وانت نائم.

**يوقظ جهاز ويندوز النائم في وقت محدد يوميا — ويضيء الشاشة فعلا.**

يستطيع ويندوز ايقاظ الجهاز النائم عبر مؤقّت في Task Scheduler، لكنه في الايقاظ
غير المصحوب بمستخدم يُبقي الشاشة مطفأة حتى يصل ادخال حقيقي. هذه الاداة تسجّل مهمة
ايقاظ يومية، اجراؤها يولّد حركة فأرة صناعية دقيقة تجبر الشاشة على العمل. مفيدة
للمهام الليلية التي تحتاج سطح مكتب حيّا ومضاءً (اتمتة تشغّل تطبيقا مرئيا، التقاط
شاشة، مزامنة بيانات مجدولة، سير عمل RPA، وغيرها).

## التثبيت السريع

افتح **Windows PowerShell الازرق الكلاسيكي** (اضغط `Win+R`، اكتب `powershell`،
ثم Enter) وشغّل:

```powershell
irm https://raw.githubusercontent.com/badrAlzahrani/windows-sleep-wake-display/main/install.ps1 | iex
```

ستظهر نافذة UAC — اضغط **نعم**. ثم اختر من القائمة.

> لا تفضّل `iex`؟ استخدم **Code → Download ZIP**، ثم نقرة يمين على
> `wake-display.ps1` واختر **Run with PowerShell**.

## خيارات القائمة

| # | الخيار | ماذا يفعل |
|---|--------|-----------|
| 1 | تثبيت الايقاظ | يسأل عن الوقت (صيغة 24 ساعة `HH:mm`)، يفعّل مؤقّتات الايقاظ، ويسجّل مهمة يومية تضيء الشاشة |
| 2 | عرض الحالة | يعرض وقت التشغيل القادم/الاخير ومؤقّتات الايقاظ المسلّحة |
| 3 | اختبار مضغوط | يجدول ايقاظا لمرة واحدة بعد 3 دقائق للتأكد من العمل |
| 4 | تعطيل / تفعيل | يوقف المهمة مؤقتا دون حذفها (تبديل) |
| 5 | حذف نهائي | يحذف المهمة وسكربت الاجراء |
| 6 | خروج | |

## المتطلبات

| المتطلب | ملاحظات |
|---------|---------|
| ويندوز 10 / 11 | |
| نوم S3 + مؤقّتات ايقاظ | تحقق بـ `powercfg /a` (يحتاج `Standby (S3)`) |
| Windows PowerShell 5.1 | الكونسول **الازرق** الكلاسيكي، لا `pwsh` |
| صلاحية مسؤول | الاداة ترفع الصلاحية عبر UAC تلقائيا |

## كيف تعمل

تُسجَّل مهمة يومية في Task Scheduler مع خيار **ايقاظ الجهاز**، فيُسلّح ويندوز
مؤقّت ايقاظ في العتاد. حين يعمل، اول اجراء فيه يشغّل سكربتا صغيرا يستدعي
`mouse_event` من `user32.dll` ليولّد ادخالا حقيقيا — وهو ما يقنع ويندوز باعادة
تشغيل الشاشة. يتحرك المؤشر بضع نقاط ثم يعود، فلا يتغير موضعه فعليا.

**تحقّق، لا تفترض.** بعد التثبيت، استخدم *عرض الحالة* وتأكد ان `NextRunTime`
محدد وان المهمة تظهر في قائمة مؤقّتات الايقاظ. ثم شغّل *اختبار* مرة للتأكد ان
عتادك يستيقظ فعلا من النوم.

## اخلاء مسؤولية

الاستخدام على مسؤوليتك. تسجّل الاداة مهمة ويندوز مجدولة عادية وتضبط اعداد
"السماح بمؤقّتات الايقاظ". لا تعدّل ملفات النظام ولا اعدادات الامان. اعتماد ايقاظ
عتادك من النوم عبر مؤقّت يعتمد على اعدادات BIOS/UEFI والطاقة لديك.

مرخّصة بموجب MIT.
