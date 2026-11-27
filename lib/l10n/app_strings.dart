import 'package:flutter/material.dart';

enum AppLang { ar, fr, en }

class AppThemePreset {
  final String id;
  final String nameAr;
  final String nameFr;
  final String nameEn;
  final Color bg;
  final Color appBar;
  final Color card;
  final Color inputBg;
  final Color primary;
  final Color secondary;
  final Color accent;
  final bool isLight;

  const AppThemePreset({
    required this.id,
    required this.nameAr,
    required this.nameFr,
    required this.nameEn,
    required this.bg,
    required this.appBar,
    required this.card,
    required this.inputBg,
    required this.primary,
    required this.secondary,
    required this.accent,
    this.isLight = false,
  });

  String label(AppLang lang) {
    if (lang == AppLang.fr) return nameFr;
    if (lang == AppLang.en) return nameEn;
    return nameAr;
  }

  ThemeData toThemeData() {
    final brightness = isLight ? Brightness.light : Brightness.dark;
    final borderCol = isLight ? Colors.black.withAlpha(32) : Colors.white.withAlpha(28);
    final hintCol = isLight ? Colors.black.withAlpha(110) : Colors.white.withAlpha(85);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: isLight
          ? ColorScheme.light(primary: primary, secondary: secondary, surface: card)
          : ColorScheme.dark(primary: primary, secondary: secondary, surface: card),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        hintStyle: TextStyle(color: hintCol, fontSize: 12.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderCol)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderCol)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primary, width: 1.7)),
      ),
    );
  }
}

class AppThemes {
  static const List<AppThemePreset> presets = [
    AppThemePreset(
      id: 'cryo_navy',
      nameAr: 'كرايو أزرق داكن (الافتراضي)',
      nameFr: 'Bleu Cryo Sombre',
      nameEn: 'Cryo Deep Navy',
      bg: Color(0xFF070D19),
      appBar: Color(0xFF0A1324),
      card: Color(0xFF111D34),
      inputBg: Color(0xFF081121),
      primary: Color(0xFF38BDF8),
      secondary: Color(0xFF22C55E),
      accent: Color(0xFFF59E0B),
    ),
    AppThemePreset(
      id: 'industrial_amber',
      nameAr: 'صناعي فحمي كهرماني',
      nameFr: 'Industriel Carbone Ambre',
      nameEn: 'Industrial Slate Amber',
      bg: Color(0xFF0E1117),
      appBar: Color(0xFF141922),
      card: Color(0xFF1B2230),
      inputBg: Color(0xFF10151E),
      primary: Color(0xFFF59E0B),
      secondary: Color(0xFF10B981),
      accent: Color(0xFF38BDF8),
    ),
    AppThemePreset(
      id: 'emerald_pro',
      nameAr: 'زمردي هندسي داكن',
      nameFr: 'Émeraude Ingénierie',
      nameEn: 'Emerald HVAC Pro',
      bg: Color(0xFF051412),
      appBar: Color(0xFF081D1A),
      card: Color(0xFF0F2B26),
      inputBg: Color(0xFF071A17),
      primary: Color(0xFF10B981),
      secondary: Color(0xFF38BDF8),
      accent: Color(0xFFFBBF24),
    ),
    AppThemePreset(
      id: 'titanium_red',
      nameAr: 'تيتانيوم أحمر صناعي',
      nameFr: 'Titane Rouge Industriel',
      nameEn: 'Titanium Crimson',
      bg: Color(0xFF111216),
      appBar: Color(0xFF171920),
      card: Color(0xFF20232D),
      inputBg: Color(0xFF13151B),
      primary: Color(0xFFF97316),
      secondary: Color(0xFF22C55E),
      accent: Color(0xFF60A5FA),
    ),
    AppThemePreset(
      id: 'royal_cobalt',
      nameAr: 'كوبالت ملكي تقني',
      nameFr: 'Cobalt Royal Tech',
      nameEn: 'Royal Cobalt Tech',
      bg: Color(0xFF0A0D22),
      appBar: Color(0xFF101533),
      card: Color(0xFF182047),
      inputBg: Color(0xFF0D112B),
      primary: Color(0xFF818CF8),
      secondary: Color(0xFF2DD4BF),
      accent: Color(0xFFF472B6),
    ),
    AppThemePreset(
      id: 'arctic_light',
      nameAr: 'نهاري فاتح (للعمل الميداني)',
      nameFr: 'Clair Arctique (Terrain)',
      nameEn: 'Arctic Daylight (Field)',
      bg: Color(0xFFF1F5F9),
      appBar: Color(0xFFFFFFFF),
      card: Color(0xFFFFFFFF),
      inputBg: Color(0xFFF8FAFC),
      primary: Color(0xFF0284C7),
      secondary: Color(0xFF16A34A),
      accent: Color(0xFFD97706),
      isLight: true,
    ),
  ];
}

class AppStrings {
  static String t(AppLang lang, String key) {
    final map = _dict[key];
    if (map == null) return key;
    return map[lang] ?? map[AppLang.en] ?? key;
  }

  static const Map<String, Map<AppLang, String>> _dict = {
    'tab_3d': {AppLang.ar: '3D', AppLang.fr: '3D', AppLang.en: '3D'},
    'tab_panels': {AppLang.ar: 'الألواح', AppLang.fr: 'Panneaux', AppLang.en: 'Panels'},
    'tab_units': {AppLang.ar: 'الضواغط', AppLang.fr: 'Groupes', AppLang.en: 'Units'},
    'tab_sizing': {AppLang.ar: 'المكونات', AppLang.fr: 'Calculs', AppLang.en: 'Sizing'},
    'tab_audit': {AppLang.ar: 'التقييم', AppLang.fr: 'Audit', AppLang.en: 'Audit'},
    'tab_report': {AppLang.ar: 'التقرير', AppLang.fr: 'Rapport', AppLang.en: 'Report'},
    'expert': {AppLang.ar: 'خبير', AppLang.fr: 'Expert', AppLang.en: 'Expert'},
    'basic': {AppLang.ar: 'مبتدئ', AppLang.fr: 'Simple', AppLang.en: 'Basic'},
    'custom': {AppLang.ar: 'مخصص (Custom)', AppLang.fr: 'Personnalisé (Custom)', AppLang.en: 'Custom'},
    'room_params': {AppLang.ar: 'معطيات غرفة التبريد والعزل', AppLang.fr: 'Paramètres Chambre Froide', AppLang.en: 'Cold Room & Insulation Inputs'},
    'reset': {AppLang.ar: 'إعادة تعيين', AppLang.fr: 'Réinitialiser', AppLang.en: 'Reset'},
    'room_type': {AppLang.ar: 'نوع غرفة التبريد', AppLang.fr: 'Type de chambre', AppLang.en: 'Cold Room Type'},
    'len': {AppLang.ar: 'الطول L (m)', AppLang.fr: 'Longueur L (m)', AppLang.en: 'Length L (m)'},
    'wid': {AppLang.ar: 'العرض W (m)', AppLang.fr: 'Largeur W (m)', AppLang.en: 'Width W (m)'},
    'hei': {AppLang.ar: 'الارتفاع H (m)', AppLang.fr: 'Hauteur H (m)', AppLang.en: 'Height H (m)'},
    't_in': {AppLang.ar: 'الداخلية (°C)', AppLang.fr: 'Intérieure (°C)', AppLang.en: 'Inside (°C)'},
    't_amb': {AppLang.ar: 'الخارجية (°C)', AppLang.fr: 'Ambiante (°C)', AppLang.en: 'Ambient (°C)'},
    'ins_pu': {AppLang.ar: 'عزل PU', AppLang.fr: 'Isolant PU', AppLang.en: 'PU Insul.'},
    'product': {AppLang.ar: 'نوع المنتج المخزن', AppLang.fr: 'Produit stocké', AppLang.en: 'Stored Product'},
    'daily_kg': {AppLang.ar: 'الدخول اليومي (kg)', AppLang.fr: 'Entrée/jour (kg)', AppLang.en: 'Daily Load (kg)'},
    't_prod': {AppLang.ar: 'حرارة المنتج (°C)', AppLang.fr: 'T° produit (°C)', AppLang.en: 'Prod Temp (°C)'},
    'door_tr': {AppLang.ar: 'فتح الأبواب', AppLang.fr: 'Trafic portes', AppLang.en: 'Door Traffic'},
    'unit_arch': {AppLang.ar: 'نوع المجموعة', AppLang.fr: 'Architecture', AppLang.en: 'Unit Type'},
    'calc_btn': {AppLang.ar: 'احسب وارسم المخطط 3D', AppLang.fr: 'Calculer & Plan 3D', AppLang.en: 'Calculate & Render 3D'},
    'print_report': {AppLang.ar: 'طباعة / PDF التقرير', AppLang.fr: 'Imprimer / PDF Rapport', AppLang.en: 'Print / PDF Report'},
    'print_audit': {AppLang.ar: 'طباعة / PDF التقييم', AppLang.fr: 'Imprimer / PDF Audit', AppLang.en: 'Print / PDF Audit'},
    'copy_report': {AppLang.ar: 'نسخ التقرير', AppLang.fr: 'Copier Rapport', AppLang.en: 'Copy Report'},
    'themes_title': {AppLang.ar: 'اختيار ألوان وثيم التطبيق', AppLang.fr: 'Thèmes & Couleurs Pro', AppLang.en: 'Professional Color Themes'},
    'lang_title': {AppLang.ar: 'لغة التطبيق', AppLang.fr: 'Langue de l\'application', AppLang.en: 'App Language'},
    'sci_title': {AppLang.ar: 'الحساب العلمي الدقيق لمكونات الدائرة', AppLang.fr: 'Dimensionnement Scientifique du Circuit', AppLang.en: 'Scientific Refrigeration Component Sizing'},
    'audit_title': {AppLang.ar: 'قياسات التقييم الميداني (Audit)', AppLang.fr: 'Mesures d\'Audit Terrain', AppLang.en: 'Field Audit Measurements'},
    'audit_btn': {AppLang.ar: 'فحص الدائرة وتحديث المخطط الحي', AppLang.fr: 'Diagnostiquer & Mettre à jour', AppLang.en: 'Run Diagnostic & Update 3D'},
    'report_title': {AppLang.ar: 'بيانات التقرير الهندسي والطباعة', AppLang.fr: 'Rapport d\'Ingénierie & Impression', AppLang.en: 'Engineering Report & Print'},
    'client': {AppLang.ar: 'اسم الزبون / المؤسسة', AppLang.fr: 'Client / Entreprise', AppLang.en: 'Client / Company'},
    'project': {AppLang.ar: 'اسم المشروع / الموقع', AppLang.fr: 'Projet / Site', AppLang.en: 'Project / Location'},
    'engineer': {AppLang.ar: 'المهندس / الفني المسؤول', AppLang.fr: 'Ingénieur / Technicien', AppLang.en: 'Lead Engineer'},
    'need_calc': {
      AppLang.ar: 'قم بإجراء الحساب في تبويب «3D» أولاً لإظهار النتائج العلمية الكاملة.',
      AppLang.fr: 'Lancez d\'abord le calcul dans l\'onglet « 3D » pour afficher les résultats.',
      AppLang.en: 'Run the calculation in the "3D" tab first to generate full scientific results.',
    },
    'err_inputs': {
      AppLang.ar: 'يرجى إدخال الأبعاد (L, W, H) ودرجتي الحرارة الداخلية والخارجية أولاً.',
      AppLang.fr: 'Veuillez saisir les dimensions (L, W, H) et les températures intérieure/ambiante.',
      AppLang.en: 'Please enter dimensions (L, W, H) and inside/ambient temperatures first.',
    },
  };
}
