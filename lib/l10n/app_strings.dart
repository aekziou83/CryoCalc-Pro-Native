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
    // App Bar & Navigation
    'dev_name': {AppLang.ar: 'م. أحمد زينور', AppLang.fr: 'Ing. Ahmed Zinnour', AppLang.en: 'Eng. Ahmed Zinnour'},
    'splash_sub': {AppLang.ar: '100% بدون إنترنت • محصّن • 0% إعلانات', AppLang.fr: '100% Hors-ligne • Sécurisé • 0% Pub', AppLang.en: '100% Offline • Secured • 0% Ads'},
    'tab_3d': {AppLang.ar: '3D', AppLang.fr: '3D', AppLang.en: '3D'},
    'tab_panels': {AppLang.ar: 'الألواح', AppLang.fr: 'Panneaux', AppLang.en: 'Panels'},
    'tab_units': {AppLang.ar: 'الضواغط', AppLang.fr: 'Groupes', AppLang.en: 'Units'},
    'tab_sizing': {AppLang.ar: 'المكونات', AppLang.fr: 'Calculs', AppLang.en: 'Sizing'},
    'tab_audit': {AppLang.ar: 'التقييم', AppLang.fr: 'Audit', AppLang.en: 'Audit'},
    'tab_report': {AppLang.ar: 'التقرير', AppLang.fr: 'Rapport', AppLang.en: 'Report'},
    'expert': {AppLang.ar: 'خبير', AppLang.fr: 'Expert', AppLang.en: 'Expert'},
    'basic': {AppLang.ar: 'مبتدئ', AppLang.fr: 'Simple', AppLang.en: 'Basic'},
    'custom': {AppLang.ar: 'مخصص', AppLang.fr: 'Personnalisé', AppLang.en: 'Custom'},
    'themes_title': {AppLang.ar: 'اختيار ألوان وثيم التطبيق', AppLang.fr: 'Thèmes et couleurs Pro', AppLang.en: 'Professional Color Themes'},
    'lang_title': {AppLang.ar: 'لغة التطبيق', AppLang.fr: 'Langue de l\'application', AppLang.en: 'Application Language'},
    'copied': {AppLang.ar: 'تم النسخ بنجاح', AppLang.fr: 'Copié avec succès', AppLang.en: 'Copied successfully'},
    'fb_dev': {AppLang.ar: 'نسخ رابط صفحة المطور على فيسبوك', AppLang.fr: 'Copier la page Facebook du développeur', AppLang.en: 'Copy Developer Facebook Page'},
    'fb_group': {AppLang.ar: 'نسخ رابط مجموعة التبريد M.D.F.CH.É.É', AppLang.fr: 'Copier le groupe froid M.D.F.CH.É.É', AppLang.en: 'Copy M.D.F.CH.É.É HVAC Group'},

    // Tab 1: Cold Room Inputs
    'room_params': {AppLang.ar: 'معطيات غرفة التبريد والعزل', AppLang.fr: 'Paramètres Chambre Froide & Isolation', AppLang.en: 'Cold Room & Insulation Inputs'},
    'reset': {AppLang.ar: 'إعادة تعيين', AppLang.fr: 'Réinitialiser', AppLang.en: 'Reset'},
    'room_type': {AppLang.ar: 'نوع غرفة التبريد', AppLang.fr: 'Type de chambre froide', AppLang.en: 'Cold Room Type'},
    'rt_pos': {AppLang.ar: 'غرفة موجبة (0°C إلى +12°C)', AppLang.fr: 'Chambre positive (0°C à +12°C)', AppLang.en: 'Positive Chiller (0°C to +12°C)'},
    'rt_neg': {AppLang.ar: 'غرفة سالبة (-18°C إلى -25°C)', AppLang.fr: 'Chambre négative (-18°C à -25°C)', AppLang.en: 'Negative Freezer (-18°C to -25°C)'},
    'rt_cor': {AppLang.ar: 'ممر / ساس تجهيز (+8°C إلى +12°C)', AppLang.fr: 'SAS / Couloir (+8°C à +12°C)', AppLang.en: 'Preparation SAS (+8°C to +12°C)'},
    'rt_tun': {AppLang.ar: 'نفق تجميد سريع (-30°C إلى -40°C)', AppLang.fr: 'Tunnel de surgélation (-30°C à -40°C)', AppLang.en: 'Blast Freezer Tunnel (-30°C to -40°C)'},
    'custom_room_hint': {AppLang.ar: 'مثال: غرفة إنضاج أو مختبر', AppLang.fr: 'Ex: Mûrisserie / Laboratoire', AppLang.en: 'Ex: Ripening / Lab Room'},
    'len': {AppLang.ar: 'الطول L (m)', AppLang.fr: 'Longueur L (m)', AppLang.en: 'Length L (m)'},
    'wid': {AppLang.ar: 'العرض W (m)', AppLang.fr: 'Largeur W (m)', AppLang.en: 'Width W (m)'},
    'hei': {AppLang.ar: 'الارتفاع H (m)', AppLang.fr: 'Hauteur H (m)', AppLang.en: 'Height H (m)'},
    't_in': {AppLang.ar: 'الداخلية (°C)', AppLang.fr: 'Intérieure (°C)', AppLang.en: 'Inside (°C)'},
    't_amb': {AppLang.ar: 'الخارجية (°C)', AppLang.fr: 'Ambiante (°C)', AppLang.en: 'Ambient (°C)'},
    'ins_pu': {AppLang.ar: 'عزل PU', AppLang.fr: 'Isolant PU', AppLang.en: 'PU Insul.'},
    'custom_ins': {AppLang.ar: 'سمك العزل المخصص (mm)', AppLang.fr: 'Épaisseur isolant (mm)', AppLang.en: 'Custom Insulation (mm)'},
    'product': {AppLang.ar: 'نوع المنتج المخزن', AppLang.fr: 'Produit stocké', AppLang.en: 'Stored Product'},
    'daily_kg': {AppLang.ar: 'الدخول اليومي (kg)', AppLang.fr: 'Entrée journalière (kg)', AppLang.en: 'Daily Load (kg)'},
    't_prod': {AppLang.ar: 'حرارة المنتج (°C)', AppLang.fr: 'T° entrée produit (°C)', AppLang.en: 'Product Entry Temp (°C)'},
    'door_tr': {AppLang.ar: 'حركة فتح الأبواب', AppLang.fr: 'Trafic des portes', AppLang.en: 'Door Traffic'},
    'tr_low': {AppLang.ar: 'منخفضة', AppLang.fr: 'Faible', AppLang.en: 'Low'},
    'tr_med': {AppLang.ar: 'متوسطة', AppLang.fr: 'Moyen', AppLang.en: 'Medium'},
    'tr_high': {AppLang.ar: 'عالية جداً', AppLang.fr: 'Élevé', AppLang.en: 'High'},
    'air_chg': {AppLang.ar: 'معدل تجديد الهواء / 24h', AppLang.fr: 'Renouvellements d\'air / 24h', AppLang.en: 'Air Changes / 24h'},
    'unit_arch': {AppLang.ar: 'نوع المجموعة', AppLang.fr: 'Architecture groupe', AppLang.en: 'Unit Architecture'},
    'arch_split': {AppLang.ar: 'منفصلة (Split)', AppLang.fr: 'Groupe Split', AppLang.en: 'Split System'},
    'arch_carrosse': {AppLang.ar: 'صامتة مغلفة (ZX)', AppLang.fr: 'Groupe carrossé (ZX)', AppLang.en: 'Housed Silent (ZX)'},
    'arch_mono': {AppLang.ar: 'مدمجة (Monobloc)', AppLang.fr: 'Monobloc', AppLang.en: 'Monoblock'},
    'arch_rack': {AppLang.ar: 'مركزية (Rack)', AppLang.fr: 'Centrale (Rack)', AppLang.en: 'Central Rack'},
    'arch_evi': {AppLang.ar: 'حقن بخاري (EVI)', AppLang.fr: 'Injection vapeur (EVI)', AppLang.en: 'Vapor Injection (EVI)'},
    'custom_arch': {AppLang.ar: 'نوع المجموعة المخصص', AppLang.fr: 'Architecture personnalisée', AppLang.en: 'Custom Unit Type'},
    't_floor': {AppLang.ar: 'حرارة الأرضية (°C)', AppLang.fr: 'T° sol (°C)', AppLang.en: 'Floor Temp (°C)'},
    'op_hours': {AppLang.ar: 'التشغيل (h/24h)', AppLang.fr: 'Marche (h/24h)', AppLang.en: 'Run Time (h/24h)'},
    'pipes_m': {AppLang.ar: 'طول النحاس (m)', AppLang.fr: 'Tuyauterie (m)', AppLang.en: 'Pipe Length (m)'},
    'sh_lbl': {AppLang.ar: 'التحميص SH (K)', AppLang.fr: 'Surchauffe SH (K)', AppLang.en: 'Superheat SH (K)'},
    'sc_lbl': {AppLang.ar: 'التبريد الدوني SC (K)', AppLang.fr: 'Sous-refroidissement SC (K)', AppLang.en: 'Subcooling SC (K)'},
    'defrost': {AppLang.ar: 'نظام إذابة الجليد', AppLang.fr: 'Système de dégivrage', AppLang.en: 'Defrost System'},
    'def_auto': {AppLang.ar: 'تلقائي حسب الحرارة', AppLang.fr: 'Automatique', AppLang.en: 'Automatic'},
    'def_air': {AppLang.ar: 'بالهواء (طبيعي)', AppLang.fr: 'Naturel par air', AppLang.en: 'Off-Cycle Air'},
    'def_elec': {AppLang.ar: 'سخانات كهربائية', AppLang.fr: 'Résistances électriques', AppLang.en: 'Electric Heaters'},
    'def_hotgas': {AppLang.ar: 'غاز ساخن', AppLang.fr: 'Gaz chauds', AppLang.en: 'Hot Gas'},
    'custom_def_kw': {AppLang.ar: 'استطاعة سخان الإذابة (kW)', AppLang.fr: 'Puissance dégivrage (kW)', AppLang.en: 'Custom Defrost Heater (kW)'},
    'calc_btn': {AppLang.ar: 'احسب وارسم المخطط 3D', AppLang.fr: 'Calculer & Plan 3D', AppLang.en: 'Calculate & Render 3D'},
    'kpi_q0': {AppLang.ar: 'الاستطاعة Q₀', AppLang.fr: 'Puissance Q₀', AppLang.en: 'Capacity Q₀'},
    'kpi_vol': {AppLang.ar: 'الحجم', AppLang.fr: 'Volume', AppLang.en: 'Volume'},
    'kpi_temp': {AppLang.ar: 'التبخير / التكثيف', AppLang.fr: 'Évap / Cond', AppLang.en: 'Evap / Cond'},

    // 3D Viewer
    'v3d_title': {AppLang.ar: 'المجسم 3D الواقعي للغرفة والمجموعة (اسحب للتدوير)', AppLang.fr: 'Vue 3D réaliste chambre & groupe (glisser)', AppLang.en: 'Realistic 3D Cold Room & Unit (Drag to Rotate)'},
    'v3d_audit': {AppLang.ar: 'المجسم التشخيصي الحي — تدوير 360°', AppLang.fr: 'Vue 3D diagnostic en direct — 360°', AppLang.en: 'Live Diagnostic 3D View — 360°'},
    'v3d_cut': {AppLang.ar: '3D قطاع داخلي', AppLang.fr: '3D Coupe interne', AppLang.en: '3D Cutaway'},
    'v3d_closed': {AppLang.ar: '3D هيكل خارجي', AppLang.fr: '3D Extérieur', AppLang.en: '3D Exterior'},
    'v3d_2d': {AppLang.ar: 'مسقط 2D', AppLang.fr: 'Plan 2D', AppLang.en: '2D Plan'},
    'v3d_circ': {AppLang.ar: 'مخطط الدائرة', AppLang.fr: 'Schéma circuit', AppLang.en: 'Circuit Diagram'},
    'v3d_sel': {AppLang.ar: 'المجموعة المختارة', AppLang.fr: 'Groupe sélectionné', AppLang.en: 'Selected Unit'},
    'v3d_cond': {AppLang.ar: 'أبعاد وحدة التكثيف', AppLang.fr: 'Dim. groupe cond.', AppLang.en: 'Condensing Unit Dim.'},
    'v3d_evap': {AppLang.ar: 'أبعاد المبخر السقفي', AppLang.fr: 'Dim. évaporateur', AppLang.en: 'Evaporator Dim.'},
    'v3d_pipes': {AppLang.ar: 'النحاس (سحب / سائل)', AppLang.fr: 'Cuivre (Asp / Liq)', AppLang.en: 'Copper (Suc / Liq)'},
    'fans': {AppLang.ar: 'مراوح', AppLang.fr: 'vent.', AppLang.en: 'fans'},
    'n_comp': {AppLang.ar: '1. الضاغط', AppLang.fr: '1. Compresseur', AppLang.en: '1. Compressor'},
    'n_cond': {AppLang.ar: '2. المكثف', AppLang.fr: '2. Condenseur', AppLang.en: '2. Condenser'},
    'n_rec': {AppLang.ar: '3. خزان السائل', AppLang.fr: '3. Réservoir', AppLang.en: '3. Receiver'},
    'n_fd': {AppLang.ar: '4. مجفف + زجاجة', AppLang.fr: '4. Déshy + Voyant', AppLang.en: '4. Drier + Glass'},
    'n_txv': {AppLang.ar: '5. صمام التمدد', AppLang.fr: '5. Détendeur TXV', AppLang.en: '5. TXV Valve'},
    'n_evap': {AppLang.ar: '6. المبخر', AppLang.fr: '6. Évaporateur', AppLang.en: '6. Evaporator'},

    // Tab 2: Sandwich Panels
    'panel_w': {AppLang.ar: 'عرض اللوح (m)', AppLang.fr: 'Largeur panneau (m)', AppLang.en: 'Panel Width (m)'},
    'custom_pw': {AppLang.ar: 'عرض اللوح المخصص (m)', AppLang.fr: 'Largeur personnalisée (m)', AppLang.en: 'Custom Panel Width (m)'},
    'floor_pu': {AppLang.ar: 'عزل الأرضية', AppLang.fr: 'Isolation sol', AppLang.en: 'Floor Insulation'},
    'opt_yes': {AppLang.ar: 'نعم', AppLang.fr: 'Oui', AppLang.en: 'Yes'},
    'opt_no': {AppLang.ar: 'لا', AppLang.fr: 'Non', AppLang.en: 'No'},
    'wall_p': {AppLang.ar: 'عدد ألواح الجدران', AppLang.fr: 'Panneaux muraux', AppLang.en: 'Wall Panels'},
    'roof_p': {AppLang.ar: 'عدد ألواح السقف', AppLang.fr: 'Panneaux plafond', AppLang.en: 'Roof Panels'},
    'floor_p': {AppLang.ar: 'عدد ألواح الأرضية', AppLang.fr: 'Panneaux sol', AppLang.en: 'Floor Panels'},
    'total_area': {AppLang.ar: 'المساحة الإجمالية للألواح', AppLang.fr: 'Surface totale panneaux', AppLang.en: 'Total Panel Area'},
    'u_rail': {AppLang.ar: 'مجرى التثبيت (U-Profile)', AppLang.fr: 'Profilé en U au sol', AppLang.en: 'Floor U-Profile Rail'},
    'coving': {AppLang.ar: 'الزوايا الداخلية والخارجية', AppLang.fr: 'Angles & plinthes', AppLang.en: 'Internal & External Coving'},
    'pu_foam': {AppLang.ar: 'عبوات فوم البولي يوريثان', AppLang.fr: 'Bombes mousse PU', AppLang.en: 'PU Foam Cans'},
    'door_dim': {AppLang.ar: 'مقاس الباب المعزول', AppLang.fr: 'Porte isotherme', AppLang.en: 'Insulated Door Size'},
    'pcs': {AppLang.ar: 'لوح', AppLang.fr: 'panneaux', AppLang.en: 'panels'},
    'cans': {AppLang.ar: 'عبوة', AppLang.fr: 'bombes', AppLang.en: 'cans'},
    'not_inc': {AppLang.ar: 'غير مشمول', AppLang.fr: 'Non inclus', AppLang.en: 'Not included'},

    // Tab 3: Compressors
    'ref_lbl': {AppLang.ar: 'وسيط التبريد', AppLang.fr: 'Fluide frigorigène', AppLang.en: 'Refrigerant'},
    'brand_lbl': {AppLang.ar: 'الماركة التجارية', AppLang.fr: 'Marque compresseur', AppLang.en: 'Compressor Brand'},
    'all_brands': {AppLang.ar: 'كل الماركات (11 ماركة)', AppLang.fr: 'Toutes les marques (11)', AppLang.en: 'All Brands (11)'},
    'custom_ref': {AppLang.ar: 'اسم وسيط التبريد المخصص', AppLang.fr: 'Fluide personnalisé (ex: R452A)', AppLang.en: 'Custom Refrigerant (e.g. R452A)'},
    'custom_comp': {AppLang.ar: 'ماركة وموديل الضاغط المخصص', AppLang.fr: 'Marque & modèle personnalisés', AppLang.en: 'Custom Brand & Model'},
    'power_lbl': {AppLang.ar: 'التغذية الكهربائية', AppLang.fr: 'Alimentation électrique', AppLang.en: 'Power Supply'},
    'volt_lbl': {AppLang.ar: 'الجهد المخصص (V)', AppLang.fr: 'Tension personnalisée (V)', AppLang.en: 'Custom Voltage (V)'},
    'xref_title': {AppLang.ar: 'المعادل الميداني للضواغط (Cross-Reference)', AppLang.fr: 'Équivalence compresseurs (Cross-Ref)', AppLang.en: 'Compressor Cross-Reference'},
    'tap_unit': {AppLang.ar: 'اضغط على أي مجموعة لتثبيتها في الحسابات والـ 3D:', AppLang.fr: 'Touchez un groupe pour l\'appliquer au plan 3D :', AppLang.en: 'Tap a unit to lock it into calculations & 3D:'},

    // Tab 4: Scientific Component Sizing
    'sci_title': {AppLang.ar: 'الحساب العلمي الدقيق لمكونات الدائرة', AppLang.fr: 'Dimensionnement Scientifique du Circuit', AppLang.en: 'Scientific Refrigeration Component Sizing'},
    'sec_0': {AppLang.ar: '0. الدورة الثرموديناميكية', AppLang.fr: '0. Cycle Thermodynamique', AppLang.en: '0. Thermodynamic Cycle'},
    'sec_1': {AppLang.ar: '1. حساب الضاغط (Vb = ṁ·v\'\'/ηv)', AppLang.fr: '1. Compresseur (Vb = ṁ·v\'\'/ηv)', AppLang.en: '1. Compressor (Vb = ṁ·v\'\'/ηv)'},
    'sec_2': {AppLang.ar: '2. حساب المبخر (A = Q₀ / K·ΔT₁)', AppLang.fr: '2. Évaporateur (A = Q₀ / K·ΔT₁)', AppLang.en: '2. Evaporator (A = Q₀ / K·ΔT₁)'},
    'sec_3': {AppLang.ar: '3. حساب المكثف (Qk = Q₀ + P_elec)', AppLang.fr: '3. Condenseur (Qk = Q₀ + P_elec)', AppLang.en: '3. Condenser (Qk = Q₀ + P_elec)'},
    'sec_4': {AppLang.ar: '4. المنظم الحراري + رقم الأورفيس (TXV)', AppLang.fr: '4. Détendeur + Buse / Orifice (TXV)', AppLang.en: '4. Expansion Valve & Orifice (TXV)'},
    'sec_5': {AppLang.ar: '5. الفلتر المجفف وزجاجة البيان', AppLang.fr: '5. Déshydrateur & Voyant Liquide', AppLang.en: '5. Filter Drier & Sight Glass'},
    'sec_6': {AppLang.ar: '6. فاصل الزيت (Séparateur d\'huile)', AppLang.fr: '6. Séparateur d\'huile', AppLang.en: '6. Oil Separator'},
    'sec_7': {AppLang.ar: '7. خزان سائل التبريد (قاعدة 80% EN 378)', AppLang.fr: '7. Réservoir Liquide (Règle 80% EN 378)', AppLang.en: '7. Liquid Receiver (EN 378 80% Rule)'},
    'sec_8': {AppLang.ar: '8. الزجاجة المضادة للطلق (Bouteille ACL)', AppLang.fr: '8. Bouteille Anti-Coup de Liquide (ACL)', AppLang.en: '8. Suction Line Accumulator (ACL)'},
    'sec_9': {AppLang.ar: '9. الصمام الكهرومغناطيسي والخزانة الكهربائية', AppLang.fr: '9. Électrovanne & Armoire Électrique', AppLang.en: '9. Solenoid Valve & Electrical Panel'},
    's_p0': {AppLang.ar: 'ضغط التبخير P₀ (مطلق / نسبي)', AppLang.fr: 'Pression évap. P₀ (abs / rel)', AppLang.en: 'Evap. Pressure P₀ (abs / rel)'},
    's_pk': {AppLang.ar: 'ضغط التكثيف Pk (مطلق / نسبي)', AppLang.fr: 'Pression cond. Pk (abs / rel)', AppLang.en: 'Cond. Pressure Pk (abs / rel)'},
    's_tau': {AppLang.ar: 'نسبة الانضغاط τ = Pk / P₀', AppLang.fr: 'Taux de compression τ = Pk / P₀', AppLang.en: 'Compression Ratio τ = Pk / P₀'},
    's_mdot': {AppLang.ar: 'فرق الإنثالبي Δh / التدفق الكتلي ṁ', AppLang.fr: 'Enthalpie Δh / Débit massique ṁ', AppLang.en: 'Enthalpy Δh / Mass Flow ṁ'},
    's_vsuc': {AppLang.ar: 'الحجم النوعي لبخار السحب v\'\'', AppLang.fr: 'Volume massique aspiration v\'\'', AppLang.en: 'Suction Specific Volume v\'\''},
    's_etav': {AppLang.ar: 'المردود الحجمي ηv', AppLang.fr: 'Rendement volumétrique ηv', AppLang.en: 'Volumetric Efficiency ηv'},
    's_vb': {AppLang.ar: 'الحجم الممسوح المطلوب Vb', AppLang.fr: 'Volume balayé requis Vb', AppLang.en: 'Required Swept Volume Vb'},
    's_comp': {AppLang.ar: 'الضاغط المختار ونوع الزيت', AppLang.fr: 'Compresseur & type d\'huile', AppLang.en: 'Selected Compressor & Oil'},
    's_tdis': {AppLang.ar: 'حرارة الطرد التقديرية T_dis', AppLang.fr: 'T° refoulement estimée T_dis', AppLang.en: 'Est. Discharge Temp T_dis'},
    's_evdt': {AppLang.ar: 'فرق الحرارة ΔT₁ وخطوة الزعانف', AppLang.fr: 'Écart ΔT₁ & pas d\'ailettes', AppLang.en: 'Evap ΔT₁ & Fin Spacing'},
    's_evarea': {AppLang.ar: 'مساحة التبادل الحراري للمبخر', AppLang.fr: 'Surface d\'échange évaporateur', AppLang.en: 'Evaporator Heat Surface'},
    's_evair': {AppLang.ar: 'تدفق الهواء ومعدل التقليب', AppLang.fr: 'Débit d\'air & taux brassage', AppLang.en: 'Evap Airflow & Air Changes'},
    's_evdim': {AppLang.ar: 'الأبعاد / مدى الدفع / الإذابة', AppLang.fr: 'Dim. / Flèche d\'air / Dégivrage', AppLang.en: 'Dimensions / Throw / Defrost'},
    's_qk': {AppLang.ar: 'الحرارة المطرودة بالمكثف Qk', AppLang.fr: 'Puissance calorifique rejetée Qk', AppLang.en: 'Condenser Heat Rejection Qk'},
    's_carea': {AppLang.ar: 'مساحة التبادل وفرق الحرارة ΔTk', AppLang.fr: 'Surface d\'échange & ΔTk', AppLang.en: 'Condenser Surface & ΔTk'},
    's_cair': {AppLang.ar: 'تدفق هواء المكثف المطلوب', AppLang.fr: 'Débit d\'air condenseur requis', AppLang.en: 'Required Condenser Airflow'},
    's_txvdp': {AppLang.ar: 'فرق الضغط الفعّال ΔP ومعامل Ksc', AppLang.fr: 'ΔP efficace & facteur Ksc', AppLang.en: 'Effective ΔP & Factor Ksc'},
    's_txvcap': {AppLang.ar: 'القدرة المصححة للمنظم Q_nom', AppLang.fr: 'Puissance corrigée détendeur', AppLang.en: 'Corrected TXV Capacity'},
    's_txvbody': {AppLang.ar: 'جسم المنظم الحراري', AppLang.fr: 'Corps du détendeur', AppLang.en: 'TXV Valve Body'},
    's_orifice': {AppLang.ar: 'رقم الأورفيس (البوز)', AppLang.fr: 'Numéro de buse / Orifice', AppLang.en: 'Orifice Number'},
    's_mop': {AppLang.ar: 'توصية الـ MOP', AppLang.fr: 'Recommandation MOP', AppLang.en: 'MOP Recommendation'},
    's_drier': {AppLang.ar: 'الفلتر المجفف', AppLang.fr: 'Filtre déshydrateur', AppLang.en: 'Filter Drier'},
    's_sg': {AppLang.ar: 'زجاجة البيان', AppLang.fr: 'Voyant liquide & humidité', AppLang.en: 'Sight Glass'},
    's_oilmod': {AppLang.ar: 'موديل فاصل الزيت وقطر الطرد', AppLang.fr: 'Séparateur d\'huile & Ø refoul.', AppLang.en: 'Oil Separator & Discharge Pipe'},
    's_oilvel': {AppLang.ar: 'سرعة الغاز وشحنة الزيت الأولية', AppLang.fr: 'Vitesse gaz & précharge huile', AppLang.en: 'Discharge Velocity & Oil Charge'},
    's_oilreq': {AppLang.ar: 'حالة التركيب', AppLang.fr: 'Exigence d\'installation', AppLang.en: 'Requirement Status'},
    's_chg': {AppLang.ar: 'الشحنة التقديرية وكثافة السائل', AppLang.fr: 'Charge estimée & densité liq.', AppLang.en: 'Est. Charge & Liquid Density'},
    's_recmin': {AppLang.ar: 'الحجم الأدنى المحسوب (80% × 1.2)', AppLang.fr: 'Volume minimal calculé (80%)', AppLang.en: 'Min Calculated Volume (80%)'},
    's_recstd': {AppLang.ar: 'خزان السائل القياسي', AppLang.fr: 'Réservoir liquide standard', AppLang.en: 'Standard Liquid Receiver'},
    's_aclmin': {AppLang.ar: 'الحجم الأدنى للـ ACL (≥ 55%)', AppLang.fr: 'Volume min. ACL (≥ 55%)', AppLang.en: 'Min ACL Volume (≥ 55%)'},
    's_aclstd': {AppLang.ar: 'موديل الزجاجة المضادة للطلق', AppLang.fr: 'Modèle bouteille ACL', AppLang.en: 'Suction Accumulator Model'},
    's_aclbleed': {AppLang.ar: 'قطر السحب وثقب رجوع الزيت', AppLang.fr: 'Ø Aspiration & orifice huile', AppLang.en: 'Suction Port & Oil Bleed Hole'},
    's_sol': {AppLang.ar: 'الصمام الكهرومغناطيسي والحماية', AppLang.fr: 'Électrovanne & pressostat HP/LP', AppLang.en: 'Solenoid & HP/LP Switch'},
    's_elec': {AppLang.ar: 'القاطع / الكونتاكتور / الكابل', AppLang.fr: 'Disjoncteur / Contacteur / Câble', AppLang.en: 'Breaker / Contactor / Cable'},

    // Tab 5: Audit
    'audit_title': {AppLang.ar: 'قياسات التقييم الميداني (Audit)', AppLang.fr: 'Mesures d\'Audit Terrain', AppLang.en: 'Field Audit Measurements'},
    't_suc': {AppLang.ar: 'حرارة السحب (°C)', AppLang.fr: 'T° aspiration (°C)', AppLang.en: 'Suction Temp (°C)'},
    't_liq': {AppLang.ar: 'حرارة السائل (°C)', AppLang.fr: 'T° liquide (°C)', AppLang.en: 'Liquid Temp (°C)'},
    't_room': {AppLang.ar: 'حرارة الغرفة (°C)', AppLang.fr: 'T° chambre (°C)', AppLang.en: 'Room Temp (°C)'},
    't_dis': {AppLang.ar: 'حرارة الطرد (°C)', AppLang.fr: 'T° refoulement (°C)', AppLang.en: 'Discharge Temp (°C)'},
    'seals_lbl': {AppLang.ar: 'حالة جوانات الباب', AppLang.fr: 'État joints de porte', AppLang.en: 'Door Seals Condition'},
    'clean_lbl': {AppLang.ar: 'نظافة المكثف', AppLang.fr: 'Propreté condenseur', AppLang.en: 'Condenser Cleanliness'},
    'st_good': {AppLang.ar: 'ممتازة / نظيف', AppLang.fr: 'Bon / Propre', AppLang.en: 'Good / Clean'},
    'st_avg': {AppLang.ar: 'متوسطة', AppLang.fr: 'Moyen', AppLang.en: 'Average'},
    'st_bad': {AppLang.ar: 'متدهورة / متسخ', AppLang.fr: 'Mauvais / Encrassé', AppLang.en: 'Poor / Dirty'},
    'custom_note': {AppLang.ar: 'ملاحظة ميدانية مخصصة', AppLang.fr: 'Note terrain personnalisée', AppLang.en: 'Custom Field Note'},
    'audit_btn': {AppLang.ar: 'فحص الدائرة وتحديث الـ 3D', AppLang.fr: 'Diagnostiquer & Maj 3D', AppLang.en: 'Run Audit & Update 3D'},
    'print_audit': {AppLang.ar: 'طباعة / PDF تقرير التقييم', AppLang.fr: 'Imprimer / PDF Audit', AppLang.en: 'Print / PDF Field Audit'},
    'kpi_score': {AppLang.ar: 'التقييم العام', AppLang.fr: 'Score global', AppLang.en: 'Health Score'},
    'err_audit': {AppLang.ar: 'أدخل T₀ و السحب و Tk و السائل أولاً.', AppLang.fr: 'Saisissez T₀, aspiration, Tk et liquide.', AppLang.en: 'Enter T₀, suction, Tk and liquid temps first.'},

    // Tab 6: Report
    'report_title': {AppLang.ar: 'بيانات التقرير الهندسي والطباعة', AppLang.fr: 'Rapport d\'Ingénierie & Impression', AppLang.en: 'Engineering Report & Printing'},
    'client': {AppLang.ar: 'اسم الزبون / المؤسسة', AppLang.fr: 'Client / Entreprise', AppLang.en: 'Client / Company'},
    'project': {AppLang.ar: 'اسم المشروع / الموقع', AppLang.fr: 'Projet / Site', AppLang.en: 'Project / Location'},
    'engineer': {AppLang.ar: 'المهندس / الفني المسؤول', AppLang.fr: 'Ingénieur / Technicien', AppLang.en: 'Lead Engineer'},
    'print_report': {AppLang.ar: 'طباعة / PDF التقرير', AppLang.fr: 'Imprimer / PDF', AppLang.en: 'Print / PDF'},
    'copy_report': {AppLang.ar: 'نسخ التقرير', AppLang.fr: 'Copier', AppLang.en: 'Copy'},
    'need_calc': {
      AppLang.ar: 'أدخل أبعاد الغرفة واضغط «احسب» في تبويب 3D أولاً لإظهار النتائج العلمية الكاملة.',
      AppLang.fr: 'Saisissez les dimensions et cliquez sur « Calculer » dans l\'onglet 3D d\'abord.',
      AppLang.en: 'Enter room dimensions and tap "Calculate" in the 3D tab first to view results.',
    },
    'err_inputs': {
      AppLang.ar: 'يرجى إدخال الأبعاد (L, W, H) ودرجتي الحرارة الداخلية والخارجية أولاً.',
      AppLang.fr: 'Veuillez saisir les dimensions (L, W, H) et les températures intérieure/ambiante.',
      AppLang.en: 'Please enter dimensions (L, W, H) and inside/ambient temperatures first.',
    },
  };
}
