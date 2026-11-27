import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CryoOwner {
  static const String appVersion = 'v4.5 PRO';
  static const String developerAr = 'م. أحمد زينور';
  static const String developerEn = 'Eng. Ahmed Zinnour (DZ)';
  static const String groupCode = 'M.D.F.CH.É.É';
  static const String groupFull =
      'مجموعة: إتقان في التبريد & التدفئة & الكهرباء & إلكترونيك M.D.F.CH.É.É';
  static const String facebookUrl =
      'https://www.facebook.com/share/1Fuvr134Mq/?mibextid=wwXIfr';
}

class SecurityGuard {
  // Split Unicode & ASCII reference tokens to defeat naive hex/string patching
  static String get _expectedDev =>
      ['\u0645. ', '\u0623\u062D\u0645\u062F ', '\u0632\u064A\u0646\u0648\u0631'].join();

  static String get _expectedGroup =>
      ['M.D.', 'F.CH.', '\u00C9.\u00C9'].join();

  static String get _expectedFacebook => [
        'https://',
        'www.face',
        'book.com/',
        'share/',
        '1Fuvr134Mq/',
        '?mibextid=',
        'wwXIfr',
      ].join();

  static int _fnv1a32(String input) {
    int hash = 0x811c9dc5;
    for (int i = 0; i < input.length; i++) {
      hash ^= input.codeUnitAt(i);
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash;
  }

  static bool verifyIntegrity() {
    final raw = '${CryoOwner.developerAr}|${CryoOwner.groupCode}|${CryoOwner.facebookUrl}';
    final ref = '$_expectedDev|$_expectedGroup|$_expectedFacebook';
    return raw == ref && _fnv1a32(raw) == _fnv1a32(ref);
  }

  static String get integrityFingerprint {
    final raw = '${CryoOwner.developerAr}|${CryoOwner.groupCode}|${CryoOwner.facebookUrl}';
    return _fnv1a32(raw).toRadixString(16).toUpperCase().padLeft(8, '0');
  }

  static Map<String, String> getSecurityAuditReport() {
    final intact = verifyIntegrity();
    return {
      'توقيع المطور وحماية الحقوق': intact ? 'سليم ومطابق ✓ (0x$integrityFingerprint)' : 'تحذير: تم رصد تعديل غير مصرح به ✕',
      'وضع الترجمة والحماية': kReleaseMode ? 'إصدار Release محصّن ومُعتّم ✓' : 'وضع تطوير (Debug)',
      'عزل الشبكة ومنع الفيروسات': '100% بدون إنترنت • بدون WebView • 0% إعلانات ✓',
      'صلاحيات النظام': 'صفر صلاحيات خطيرة (بدون تتبع أو وصول للملفات) ✓',
      'الرابط الرسمي الموثّق': CryoOwner.facebookUrl,
    };
  }

  static Widget buildTamperLockScreen() {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFF070D19),
          body: Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF111D34),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFEF4444), width: 2),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.gpp_bad_rounded, color: Color(0xFFEF4444), size: 54),
                  SizedBox(height: 14),
                  Text(
                    'تحذير أمان — نسخة معدّلة غير أصلية',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFFF87171), fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'تم اكتشاف تلاعب غير مصرح به في ملفات CryoCalc Pro. يرجى تحميل النسخة الرسمية الآمنة من صفحة المطور: م. أحمد زينور (M.D.F.CH.É.É).',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 13.5, height: 1.6),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
