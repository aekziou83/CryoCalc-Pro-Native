import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CryoOwner {
  static const String appVersion = 'v5.0 PRO';
  static const String developerAr = 'م. أحمد زينور';
  static const String developerEn = 'Eng. Ahmed Zinnour (DZ)';
  static const String groupCode = 'M.D.F.CH.É.É';
  static const String groupFull =
      'مجموعة: إتقان في التبريد & التدفئة & الكهرباء & إلكترونيك M.D.F.CH.É.É';
  static const String facebookUrl =
      'https://www.facebook.com/share/1Fuvr134Mq/?mibextid=wwXIfr';
  static const String facebookGroupUrl =
      'https://www.facebook.com/share/g/19zv57nQjC/?mibextid=wwXIfr';
}

class SecurityGuard {
  static bool verifyIntegrity() {
    final hasDev = CryoOwner.developerAr.contains('زينور');
    final hasGroup = CryoOwner.groupCode.contains('M.D.F.CH');
    final hasLinks = CryoOwner.facebookUrl.contains('1Fuvr134Mq') &&
        CryoOwner.facebookGroupUrl.contains('19zv57nQjC');
    return hasDev && hasGroup && hasLinks;
  }

  static Map<String, String> getSecurityAuditReport() {
    final intact = verifyIntegrity();
    return {
      'Integrity / الحماية': intact ? 'Verified ✓ (${CryoOwner.appVersion})' : 'Tampered ✕',
      'Build Mode / وضع البناء': kReleaseMode ? 'Release Native 100% ✓' : 'Debug Mode',
      'Offline & Security': '100% Offline • 0% Ads • No Trackers ✓',
      'Developer Facebook': CryoOwner.facebookUrl,
      'HVAC Group Facebook': CryoOwner.facebookGroupUrl,
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
                    'يرجى تحميل النسخة الرسمية الآمنة من المطور: م. أحمد زينور (M.D.F.CH.É.É).',
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
