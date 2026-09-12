# رفيق المسلم — تطبيق إسلامي محلي (Offline-First, Flutter)

## ⚠️ ملاحظة مهمة عن هذا الإصدار
اكتشف فحصك في VS Code أن نسخة المشروع على جهازك كانت تحتوي فقط على النواة
الأولى (الأذكار/الصلاة/التقدم) دون الوحدات الأربع الإضافية (الالتزام،
الأحاديث، القرآن/الختمة، القصص). هذا الملف المضغوط يحتوي **المشروع كاملاً
بكل الوحدات مجتمعة في مكان واحد**، بعد تطبيق الإصلاحات التي اكتشفتها
بنفسك سابقاً:
- تصحيح استدعاء `CalculationMethod` في `notification_service.dart`
  (⚠️ لم أستطع التحقق من اسم الدالة الدقيق في هذه الجلسة لعدم وجود وصول
  لمصدر الحزمة — إن فشل التحليل هنا، استخدم نفس أمر `grep` الذي استخدمته
  قبل ذلك بنجاح لإيجاد الاسم الصحيح وتعديله).
- استبدال كل `withOpacity(...)` المهملة بـ `withValues(alpha: ...)`.
- تعطيل قسم خط Amiri افتراضياً في `pubspec.yaml` (كان سيفشل `pub get`
  لعدم وجود ملفات .ttf فعلية) — فعّله لاحقاً بعد إضافة الخط الحقيقي.
- إزالة الاعتماد على ملف صوت أذان غير موجود من `AndroidNotificationDetails`
  حتى لا يفشل شيء بصمت أو يسبب استثناء عند التنفيذ الفعلي.

## طريقة الاستبدال الصحيحة (مهم)
لتفادي تكرار مشكلة "ملفات ناقصة" التي اكتشفتها:
1. أغلق VS Code.
2. احذف مجلد `islamic_app` القديم بالكامل من جهازك (أو أعد تسميته
   احتياطياً، مثل `islamic_app_old`).
3. فك ضغط هذا الملف الجديد ليحل محله بنفس الاسم `islamic_app`.
4. افتح المجلد الجديد في VS Code وشغّل `flutter pub get` من جديد.

**لا تدمج الملفات يدوياً بالنسخ فوق بعضها** — لأن هذا هو على الأرجح سبب
اختفاء الوحدات الأربع في المرة السابقة (نسخ جزئي غير مكتمل).

## هيكل المشروع الكامل
```
lib/
├── main.dart
├── theme/app_theme.dart
├── models/ (zikr, prayer, streak, hadith, quran_progress, story)
├── data/ (azkar_data, hadith_data, stories_data) — محتوى تمثيلي، راجعه شرعياً
├── services/ (storage_service, notification_service)
├── providers/ (azkar, points, prayer, streak, hadith, quran, stories)
├── widgets/ (streak_lantern_card, hadith_of_the_day_card)
└── screens/ (home, azkar, progress, hadith, quran, quran_reader,
              khatmah_completion, stories)
```

## نقاط لسه ناقصة (بنفس القائمة اللي فحصتها في VS Code)
1. نص القرآن الكامل غير مضمَّن في `quran_reader_screen.dart`.
2. اسم دالة `CalculationMethod` قد يحتاج تصحيحاً حسب نسخة `adhan_dart`
   المثبَّتة فعلياً — راجع التعليق في `notification_service.dart`.
3. خط Amiri معطّل، وملف صوت الأذان غير مرفق.
4. بيانات الأذكار/الأحاديث/القصص تمثيلية وتحتاج مراجعة شرعية كاملة.

## التشغيل
```bash
flutter pub get
flutter analyze
flutter run          # على محاكي أندرويد متصل (وليس -d linux لأن مشروع سطح المكتب غير مُهيأ)
flutter build apk --release   # يتطلب Android SDK مثبتاً على الجهاز
```
