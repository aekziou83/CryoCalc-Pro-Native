import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'engine/cryo_engine.dart';
import 'widgets/room_3d_viewer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const CryoCalcApp());
}

class CryoCalcApp extends StatelessWidget {
  const CryoCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CryoCalc Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF070D19),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF38BDF8),
          secondary: Color(0xFF22C55E),
          surface: Color(0xFF111D34),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF081121),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          hintStyle: TextStyle(color: Colors.white.withAlpha(75), fontSize: 12.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withAlpha(32)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withAlpha(28)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.6),
          ),
        ),
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: CryoHomeScreen(),
      ),
    );
  }
}

class CryoHomeScreen extends StatefulWidget {
  const CryoHomeScreen({super.key});

  @override
  State<CryoHomeScreen> createState() => _CryoHomeScreenState();
}

class _CryoHomeScreenState extends State<CryoHomeScreen> {
  int _tabIndex = 0;
  bool _expertMode = false;

  // Empty Controllers on App Startup (Zero pre-filled numbers)
  final _lenCtrl = TextEditingController();
  final _widCtrl = TextEditingController();
  final _heiCtrl = TextEditingController();
  final _tInCtrl = TextEditingController();
  final _tAmbCtrl = TextEditingController();
  final _tFloorCtrl = TextEditingController();
  final _opHoursCtrl = TextEditingController();
  final _kgCtrl = TextEditingController();
  final _tProdCtrl = TextEditingController();
  final _pipeCtrl = TextEditingController();

  // Selections
  String _roomType = 'positive';
  double _insMm = 80;
  String _productId = 'veg';
  String _doorTraffic = 'med';
  String _arch = 'split';
  String _defrostType = 'auto';
  String _refrigerant = 'R404A';
  String _brandFilter = 'ALL';
  String _voltageFilter = '400';
  double _panelWidth = 1.15;
  String _floorPanelMode = 'auto';
  String? _selectedCompId;
  String _xrefSourceId = 'c4';

  // Results start NULL on startup -> No numbers shown until Calculate is pressed
  CryoInput? _lastInput;
  CryoResult? _result;

  // Field Audit Empty Controllers
  final _audT0Ctrl = TextEditingController();
  final _audTsucCtrl = TextEditingController();
  final _audTkCtrl = TextEditingController();
  final _audTliqCtrl = TextEditingController();
  final _audTroomCtrl = TextEditingController();
  final _audTdisCtrl = TextEditingController();
  final _audP0Ctrl = TextEditingController();
  final _audPelecCtrl = TextEditingController();
  String _audSeals = 'good';
  String _audClean = 'good';
  AuditResult? _auditResult;

  // Report Info
  final _clientCtrl = TextEditingController();
  final _projectCtrl = TextEditingController();
  final _engCtrl = TextEditingController(text: 'م. أحمد زينور');

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: const Color(0xFF1E293B)),
    );
  }

  void _runCalculation() {
    final l = double.tryParse(_lenCtrl.text.trim());
    final w = double.tryParse(_widCtrl.text.trim());
    final h = double.tryParse(_heiCtrl.text.trim());
    final tIn = double.tryParse(_tInCtrl.text.trim());
    final tAmb = double.tryParse(_tAmbCtrl.text.trim());

    if (l == null || w == null || h == null || tIn == null || tAmb == null) {
      _showMsg('يرجى إدخال الأبعاد (الطول، العرض، الارتفاع) ودرجتي الحرارة الداخلية والخارجية بالأرقام أولاً.');
      return;
    }
    if (l <= 0 || w <= 0 || h <= 0) {
      _showMsg('يجب أن تكون أبعاد الغرفة أكبر من الصفر.');
      return;
    }

    HapticFeedback.mediumImpact();
    final inp = CryoInput(
      roomType: _roomType,
      length: l,
      width: w,
      height: h,
      insMm: _insMm,
      tInside: tIn,
      tAmbient: tAmb,
      tFloor: double.tryParse(_tFloorCtrl.text.trim()) ?? 18.0,
      opHours: double.tryParse(_opHoursCtrl.text.trim()) ?? 16.0,
      productId: _productId,
      dailyKg: double.tryParse(_kgCtrl.text.trim()) ?? 0.0,
      tProdIn: double.tryParse(_tProdCtrl.text.trim()) ?? 20.0,
      doorTraffic: _doorTraffic,
      arch: _arch,
      pipeLen: double.tryParse(_pipeCtrl.text.trim()) ?? 10.0,
      defrostType: _defrostType,
      refrigerant: _refrigerant,
      brandFilter: _brandFilter,
      voltageFilter: _voltageFilter,
      panelWidth: _panelWidth,
      floorPanelMode: _floorPanelMode,
    );

    setState(() {
      _lastInput = inp;
      _result = CryoEngine.calculate(inp, forcedCompId: _selectedCompId);
    });
  }

  void _resetAllCalculations() {
    HapticFeedback.lightImpact();
    setState(() {
      for (final c in [
        _lenCtrl, _widCtrl, _heiCtrl, _tInCtrl, _tAmbCtrl,
        _tFloorCtrl, _opHoursCtrl, _kgCtrl, _tProdCtrl, _pipeCtrl,
        _audT0Ctrl, _audTsucCtrl, _audTkCtrl, _audTliqCtrl,
        _audTroomCtrl, _audTdisCtrl, _audP0Ctrl, _audPelecCtrl,
      ]) {
        c.clear();
      }
      _selectedCompId = null;
      _lastInput = null;
      _result = null;
      _auditResult = null;
    });
    _showMsg('تمت إعادة تعيين جميع الحسابات والمدخلات بنجاح.');
  }

  void _runAudit() {
    final t0 = double.tryParse(_audT0Ctrl.text.trim());
    final tSuc = double.tryParse(_audTsucCtrl.text.trim());
    final tk = double.tryParse(_audTkCtrl.text.trim());
    final tLiq = double.tryParse(_audTliqCtrl.text.trim());

    if (t0 == null || tSuc == null || tk == null || tLiq == null) {
      _showMsg('يرجى إدخال درجات T₀ والسحب و Tk والسائل أولاً.');
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _auditResult = CryoEngine.evaluateAudit(AuditInput(
        t0: t0,
        tSuc: tSuc,
        tk: tk,
        tLiq: tLiq,
        tRoom: double.tryParse(_audTroomCtrl.text.trim()) ?? (t0 + 7.0),
        tDis: double.tryParse(_audTdisCtrl.text.trim()) ?? 82.0,
        p0Kw: double.tryParse(_audP0Ctrl.text.trim()) ?? (_result?.q0Kw ?? 5.0),
        pElecKw: double.tryParse(_audPelecCtrl.text.trim()) ?? (_result?.pElecKw ?? 2.0),
        seals: _audSeals,
        cleanliness: _audClean,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1324),
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0284C7), Color(0xFF38BDF8)]),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Text('CC', style: TextStyle(color: Color(0xFF04101F), fontWeight: FontWeight.w900)),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CryoCalc PRO', style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900)),
                  Text('م. أحمد زينور 🇩🇿 • M.D.F.CH.É.É • 0% إعلانات', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                ],
              ),
            ),
            // Guided / Expert Mode Switch
            InkWell(
              onTap: () => setState(() => _expertMode = !_expertMode),
              borderRadius: BorderRadius.circular(9),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _expertMode ? const Color(0xFF38BDF8).withAlpha(35) : const Color(0xFF13223D),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: _expertMode ? const Color(0xFF38BDF8) : Colors.white.withAlpha(25)),
                ),
                child: Text(
                  _expertMode ? 'وضع خبير' : 'وضع مبتدئ',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: _expertMode ? const Color(0xFF38BDF8) : Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _tabIndex,
        children: [
          _buildThermalAnd3DTab(),
          _buildPanelsTab(),
          _buildUnitsTab(),
          _buildAuditTab(),
          _buildReportTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF0A1324),
        indicatorColor: const Color(0xFF38BDF8).withAlpha(42),
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) {
          HapticFeedback.selectionClick();
          setState(() => _tabIndex = i);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.view_in_ar_outlined), selectedIcon: Icon(Icons.view_in_ar), label: 'الغرفة و3D'),
          NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view_rounded), label: 'الساندويتش'),
          NavigationDestination(icon: Icon(Icons.settings_input_component_outlined), selectedIcon: Icon(Icons.settings_input_component), label: 'المجموعة'),
          NavigationDestination(icon: Icon(Icons.fact_check_outlined), selectedIcon: Icon(Icons.fact_check_rounded), label: 'التقييم'),
          NavigationDestination(icon: Icon(Icons.description_outlined), selectedIcon: Icon(Icons.description_rounded), label: 'التقرير'),
        ],
      ),
    );
  }

  /* -------------------- TAB 1: THERMAL LOAD + REALISTIC 3D CAD -------------------- */
  Widget _buildThermalAnd3DTab() {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        // Input Card
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFF111D34),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withAlpha(22)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('معطيات غرفة التبريد والعزل', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  TextButton.icon(
                    onPressed: _resetAllCalculations,
                    icon: const Icon(Icons.restart_alt_rounded, size: 18, color: Color(0xFFF59E0B)),
                    label: const Text('إعادة تعيين', style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _roomType,
                decoration: const InputDecoration(labelText: 'نوع غرفة التبريد'),
                items: const [
                  DropdownMenuItem(value: 'positive', child: Text('غرفة تبريد موجبة (0°C إلى +12°C)')),
                  DropdownMenuItem(value: 'negative', child: Text('غرفة تبريد سالبة (-18°C إلى -25°C)')),
                  DropdownMenuItem(value: 'corridor', child: Text('ممر / ساس تجهيز (+8°C إلى +12°C)')),
                  DropdownMenuItem(value: 'tunnel', child: Text('نفق تجميد سريع (-30°C إلى -40°C)')),
                ],
                onChanged: (v) => setState(() => _roomType = v ?? 'positive'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _numInput(_lenCtrl, 'الطول L (m)', 'مثال: 6')),
                  const SizedBox(width: 9),
                  Expanded(child: _numInput(_widCtrl, 'العرض W (m)', 'مثال: 4')),
                  const SizedBox(width: 9),
                  Expanded(child: _numInput(_heiCtrl, 'الارتفاع H (m)', 'مثال: 3')),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _numInput(_tInCtrl, 'الداخلية (°C)', 'مثال: 2')),
                  const SizedBox(width: 9),
                  Expanded(child: _numInput(_tAmbCtrl, 'الخارجية (°C)', 'مثال: 38')),
                  const SizedBox(width: 9),
                  Expanded(
                    child: DropdownButtonFormField<double>(
                      value: _insMm,
                      decoration: const InputDecoration(labelText: 'عزل PU'),
                      items: const [60, 80, 100, 120, 140, 160, 180, 200]
                          .map((v) => DropdownMenuItem(value: v.toDouble(), child: Text('$v mm')))
                          .toList(),
                      onChanged: (v) => setState(() => _insMm = v ?? 80),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _productId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'نوع المنتج المخزن'),
                items: CryoEngine.products
                    .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name, overflow: TextOverflow.ellipsis)))
                    .toList(),
                onChanged: (v) => setState(() => _productId = v ?? 'veg'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _numInput(_kgCtrl, 'الدخول اليومي (kg)', 'مثال: 1500')),
                  const SizedBox(width: 9),
                  Expanded(child: _numInput(_tProdCtrl, 'حرارة المنتج (°C)', 'مثال: 20')),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _doorTraffic,
                      decoration: const InputDecoration(labelText: 'فتح الأبواب'),
                      items: const [
                        DropdownMenuItem(value: 'low', child: Text('منخفضة')),
                        DropdownMenuItem(value: 'med', child: Text('متوسطة')),
                        DropdownMenuItem(value: 'high', child: Text('عالية جداً')),
                      ],
                      onChanged: (v) => setState(() => _doorTraffic = v ?? 'med'),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _arch,
                      decoration: const InputDecoration(labelText: 'نوع المجموعة'),
                      items: const [
                        DropdownMenuItem(value: 'split', child: Text('منفصلة Split')),
                        DropdownMenuItem(value: 'carrosse', child: Text('صامتة ZX')),
                        DropdownMenuItem(value: 'monobloc', child: Text('مدمجة Monobloc')),
                        DropdownMenuItem(value: 'rack', child: Text('مركزية Rack')),
                        DropdownMenuItem(value: 'evi', child: Text('حقن بخاري EVI')),
                      ],
                      onChanged: (v) => setState(() => _arch = v ?? 'split'),
                    ),
                  ),
                ],
              ),

              // Expert Mode Fields
              if (_expertMode) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _numInput(_tFloorCtrl, 'حرارة الأرضية (°C)', '18')),
                    const SizedBox(width: 9),
                    Expanded(child: _numInput(_opHoursCtrl, 'التشغيل (h/24h)', '16')),
                    const SizedBox(width: 9),
                    Expanded(child: _numInput(_pipeCtrl, 'الأنابيب (m)', '12')),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _defrostType,
                  decoration: const InputDecoration(labelText: 'نظام إذابة الجليد (Dégivrage)'),
                  items: const [
                    DropdownMenuItem(value: 'auto', child: Text('تلقائي حسب درجة الحرارة')),
                    DropdownMenuItem(value: 'air', child: Text('طبيعي بالهواء (Off-Cycle)')),
                    DropdownMenuItem(value: 'electric', child: Text('سخانات كهربائية (Électrique)')),
                    DropdownMenuItem(value: 'hotgas', child: Text('غاز ساخن (Hot Gas)')),
                  ],
                  onChanged: (v) => setState(() => _defrostType = v ?? 'auto'),
                ),
              ],

              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 48,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF38BDF8),
                          foregroundColor: const Color(0xFF04101F),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                        ),
                        onPressed: _runCalculation,
                        icon: const Icon(Icons.bolt_rounded),
                        label: const Text('احسب وارسم المخطط 3D', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFF59E0B),
                          side: const BorderSide(color: Color(0xFFF59E0B)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                        ),
                        onPressed: _resetAllCalculations,
                        child: const Icon(Icons.refresh_rounded),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Empty State Banner on Startup OR Full Results after Calculate
        if (_result == null || _lastInput == null)
          _emptyPlaceholderCard(
            icon: Icons.calculate_outlined,
            title: 'جاهز للحساب والرسم الهندسي',
            subtitle: 'أدخل أبعاد الغرفة ودرجات الحرارة في الأعلى ثم اضغط على «احسب» لإظهار الاستطاعة والمخطط ثلاثي الأبعاد والقياسات.',
          )
        else ...[
          // KPI Strip
          Row(
            children: [
              Expanded(child: _kpiCard('الاستطاعة Q₀', '${_result!.q0Kw} kW', '${_result!.kcalH} kcal/h', const Color(0xFF22C55E))),
              const SizedBox(width: 9),
              Expanded(child: _kpiCard('حجم الغرفة', '${_result!.volume} m³', 'الأرضية ${_result!.areaFloor} m²', const Color(0xFF38BDF8))),
              const SizedBox(width: 9),
              Expanded(child: _kpiCard('الكهرباء / التبخير', '${_result!.pElecKw} kW', 'T₀ ${_result!.t0.toStringAsFixed(0)}°C', const Color(0xFFF59E0B))),
            ],
          ),
          const SizedBox(height: 14),

          // Realistic 3D CAD + 2D Plan + Circuit Schematic
          Room3DViewer(input: _lastInput!, result: _result!),
          const SizedBox(height: 14),

          // Detailed Heat Load Breakdown Card
          _buildHeatBreakdownCard(_result!),
          const SizedBox(height: 14),

          // Engineering Alerts Card
          _buildAlertsCard('التنبيهات والتوصيات الهندسية', _result!.alerts),
        ],
      ],
    );
  }

  /* -------------------- TAB 2: SANDWICH PANELS CALCULATOR -------------------- */
  Widget _buildPanelsTab() {
    if (_result == null || _lastInput == null) {
      return ListView(
        padding: const EdgeInsets.all(14),
        children: [
          _emptyPlaceholderCard(
            icon: Icons.grid_view_rounded,
            title: 'حاسبة ألواح الساندويتش (Panneau Sandwich)',
            subtitle: 'قم بإجراء الحساب في شاشة «الغرفة و3D» أولاً ليتم حساب عدد الألواح والمجاري والزوايا وفوم PU تلقائياً.',
          ),
        ],
      );
    }

    final r = _result!;
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF111D34),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<double>(
                  value: _panelWidth,
                  decoration: const InputDecoration(labelText: 'عرض اللوح (m)'),
                  items: const [
                    DropdownMenuItem(value: 1.15, child: Text('1.15 m (قياسي)')),
                    DropdownMenuItem(value: 1.12, child: Text('1.12 m')),
                    DropdownMenuItem(value: 1.00, child: Text('1.00 m')),
                  ],
                  onChanged: (v) {
                    setState(() => _panelWidth = v ?? 1.15);
                    _runCalculation();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _floorPanelMode,
                  decoration: const InputDecoration(labelText: 'عزل الأرضية'),
                  items: const [
                    DropdownMenuItem(value: 'auto', child: Text('تلقائي للسالب')),
                    DropdownMenuItem(value: 'yes', child: Text('تضمين الأرضية')),
                    DropdownMenuItem(value: 'no', child: Text('بدون أرضية')),
                  ],
                  onChanged: (v) {
                    setState(() => _floorPanelMode = v ?? 'auto');
                    _runCalculation();
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _infoTile('عدد ألواح الجدران', '${r.wallPanels} لوح (ارتفاع ${_lastInput!.height} m)'),
        _infoTile('عدد ألواح السقف', '${r.roofPanels} لوح (طول ${_lastInput!.length} m)'),
        _infoTile('عدد ألواح الأرضية', r.floorInsIncluded ? '${r.floorPanels} لوح' : 'غير مشمول'),
        _infoTile('المساحة الإجمالية للألواح', '${r.totalPanelArea} m² (سمك ${_lastInput!.insMm.toInt()} mm)'),
        _infoTile('مجرى تثبيت الأرضية (U-Profile)', '${r.uRailMeters} متر طولي'),
        _infoTile('زوايا التغليف الداخلية والخارجية (Coving)', '${r.covingMeters} متر طولي'),
        _infoTile('عبوات فوم البولي يوريثان (Mousse PU)', '${r.puFoamCans} عبوة (750 ml)'),
        _infoTile('مقاس الباب المعزول القياسي', '${r.doorWidth} × ${r.doorHeight} m'),
      ],
    );
  }

  /* -------------------- TAB 3: UNITS, COMPRESSORS & CROSS-REFERENCE -------------------- */
  Widget _buildUnitsTab() {
    final xrefList = CryoEngine.findCrossReference(_xrefSourceId);

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF111D34),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _refrigerant,
                      decoration: const InputDecoration(labelText: 'وسيط التبريد'),
                      items: const ['R404A', 'R449A', 'R134a', 'R407F', 'R290']
                          .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                          .toList(),
                      onChanged: (v) {
                        setState(() => _refrigerant = v ?? 'R404A');
                        if (_result != null) _runCalculation();
                      },
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _brandFilter,
                      decoration: const InputDecoration(labelText: 'العلامة التجارية'),
                      items: const [
                        DropdownMenuItem(value: 'ALL', child: Text('كل العلامات')),
                        DropdownMenuItem(value: 'Copeland', child: Text('Copeland')),
                        DropdownMenuItem(value: 'Bitzer', child: Text('Bitzer')),
                        DropdownMenuItem(value: 'Dorin', child: Text('Dorin')),
                        DropdownMenuItem(value: 'Frascold', child: Text('Frascold')),
                        DropdownMenuItem(value: 'Tecumseh', child: Text('Tecumseh')),
                        DropdownMenuItem(value: 'Danfoss', child: Text('Danfoss')),
                      ],
                      onChanged: (v) {
                        setState(() => _brandFilter = v ?? 'ALL');
                        if (_result != null) _runCalculation();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _voltageFilter,
                decoration: const InputDecoration(labelText: 'التغذية الكهربائية'),
                items: const [
                  DropdownMenuItem(value: '400', child: Text('400V • 3Ph • 50Hz (ثلاثي الطور)')),
                  DropdownMenuItem(value: '230', child: Text('230V • 1Ph • 50Hz (أحادي الطور)')),
                ],
                onChanged: (v) {
                  setState(() => _voltageFilter = v ?? '400');
                  if (_result != null) _runCalculation();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        if (_result == null)
          _emptyPlaceholderCard(
            icon: Icons.settings_input_component_rounded,
            title: 'اختيار المجموعة والضاغط المناسب',
            subtitle: 'اضغط على «احسب» في التبويب الأول لترشيح الضواغط المطابقة لحمل غرفتك مع أبعادها الفيزيائية.',
          )
        else ...[
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text('انقر على أي مجموعة لتثبيت قياساتها في المجسم 3D:', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
          ),
          ..._result!.candidates.map((sc) {
            final isSel = sc.item.id == _result!.selectedUnit.item.id;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedCompId = sc.item.id);
                _runCalculation();
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF111D34),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSel ? const Color(0xFF22C55E) : Colors.white.withAlpha(22),
                    width: isSel ? 2.0 : 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${sc.item.brand} • ${sc.item.model}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E).withAlpha(35),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text('تغطية ${sc.coveragePct.toInt()}%', style: const TextStyle(color: Color(0xFF22C55E), fontSize: 11, fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'الاستطاعة: ${sc.adjustedCapKw} kW  •  الكهرباء: ${sc.item.pElecKw} kW (${sc.currentAmps} A)  •  ${sc.item.volt}V',
                      style: const TextStyle(fontSize: 12, color: Color(0xFFCBD5E1)),
                    ),
                    const SizedBox(height: 4),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        'Dimensions: ${sc.item.dimMm[0]} × ${sc.item.dimMm[1]} × ${sc.item.dimMm[2]} mm (${sc.item.tech})',
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF38BDF8), fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],

        // Compressor Cross-Reference Section
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF111D34),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🔄 المعادل الميداني للضواغط (Cross-Reference)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _xrefSourceId,
                decoration: const InputDecoration(labelText: 'الضاغط الأصلي / المعطل'),
                items: CryoEngine.compressors
                    .map((c) => DropdownMenuItem(value: c.id, child: Text('${c.brand} ${c.model} (${c.dispM3h} m³/h)')))
                    .toList(),
                onChanged: (v) => setState(() => _xrefSourceId = v ?? 'c4'),
              ),
              const SizedBox(height: 10),
              ...xrefList.map((alt) => Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: _infoTile('${alt.brand} ${alt.model}', '${alt.dispM3h} m³/h • ${alt.tech}'),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  /* -------------------- TAB 4: FIELD AUDIT & DIAGNOSTICS -------------------- */
  Widget _buildAuditTab() {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFF111D34),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('قياسات التقييم الميداني (Audit)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  TextButton.icon(
                    onPressed: _resetAllCalculations,
                    icon: const Icon(Icons.restart_alt_rounded, size: 18, color: Color(0xFFF59E0B)),
                    label: const Text('مسح', style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _numInput(_audT0Ctrl, 'التبخير T₀ (°C)', '-10')),
                  const SizedBox(width: 9),
                  Expanded(child: _numInput(_audTsucCtrl, 'السحب (°C)', '-3')),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _numInput(_audTkCtrl, 'التكثيف Tk (°C)', '45')),
                  const SizedBox(width: 9),
                  Expanded(child: _numInput(_audTliqCtrl, 'خط السائل (°C)', '40')),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _numInput(_audTroomCtrl, 'حرارة الغرفة (°C)', '-2')),
                  const SizedBox(width: 9),
                  Expanded(child: _numInput(_audTdisCtrl, 'خط الطرد (°C)', '85')),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _numInput(_audP0Ctrl, 'الاستطاعة (kW)', '8.5')),
                  const SizedBox(width: 9),
                  Expanded(child: _numInput(_audPelecCtrl, 'الكهرباء (kW)', '3.2')),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _audSeals,
                      decoration: const InputDecoration(labelText: 'حالة الجوانات'),
                      items: const [
                        DropdownMenuItem(value: 'good', child: Text('ممتازة')),
                        DropdownMenuItem(value: 'avg', child: Text('متوسطة')),
                        DropdownMenuItem(value: 'bad', child: Text('متدهورة')),
                      ],
                      onChanged: (v) => setState(() => _audSeals = v ?? 'good'),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _audClean,
                      decoration: const InputDecoration(labelText: 'نظافة المكثف'),
                      items: const [
                        DropdownMenuItem(value: 'good', child: Text('ممتازة')),
                        DropdownMenuItem(value: 'avg', child: Text('متوسطة')),
                        DropdownMenuItem(value: 'bad', child: Text('متسخة')),
                      ],
                      onChanged: (v) => setState(() => _audClean = v ?? 'good'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    foregroundColor: const Color(0xFF04101F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                  ),
                  onPressed: _runAudit,
                  icon: const Icon(Icons.fact_check_rounded),
                  label: const Text('فحص الدائرة وتحديث المخطط الحي', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        if (_auditResult == null)
          _emptyPlaceholderCard(
            icon: Icons.analytics_outlined,
            title: 'التشخيص الميداني للدائرة التبريدية',
            subtitle: 'أدخل قراءات الضغوط ودرجات الحرارة المقاسة ميدانياً ثم اضغط على زر الفحص.',
          )
        else ...[
          Row(
            children: [
              Expanded(child: _kpiCard('التحميص SH', '${_auditResult!.superheat} K', 'المثالي 5–10 K', const Color(0xFF38BDF8))),
              const SizedBox(width: 9),
              Expanded(child: _kpiCard('التبريد الدوني SC', '${_auditResult!.subcooling} K', 'المثالي 4–8 K', const Color(0xFFF59E0B))),
              const SizedBox(width: 9),
              Expanded(child: _kpiCard('تقييم الحالة', '${_auditResult!.score}/100', 'COP ${_auditResult!.cop}', const Color(0xFF22C55E))),
            ],
          ),
          const SizedBox(height: 14),
          if (_result != null && _lastInput != null) ...[
            Room3DViewer(input: _lastInput!, result: _result!, audit: _auditResult),
            const SizedBox(height: 14),
          ],
          _buildAlertsCard('نتائج التشخيص والصيانة', _auditResult!.findings),
        ],
      ],
    );
  }

  /* -------------------- TAB 5: OFFICIAL ENGINEERING REPORT -------------------- */
  Widget _buildReportTab() {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFF111D34),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('بيانات التقرير الهندسي', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              TextField(controller: _clientCtrl, decoration: const InputDecoration(labelText: 'اسم الزبون / المؤسسة')),
              const SizedBox(height: 9),
              TextField(controller: _projectCtrl, decoration: const InputDecoration(labelText: 'اسم المشروع / الموقع')),
              const SizedBox(height: 9),
              TextField(controller: _engCtrl, decoration: const InputDecoration(labelText: 'المهندس / الفني المسؤول')),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (_result == null || _lastInput == null)
          _emptyPlaceholderCard(
            icon: Icons.description_outlined,
            title: 'التقرير الهندسي فارغ حالياً',
            subtitle: 'أكمل الحسابات في التبويب الأول وسيتم توليد التقرير الهندسي الرسمي هنا تلقائياً.',
          )
        else ...[
          _infoTile('المشروع / الزبون', '${_projectCtrl.text.isEmpty ? "دراسة غرفة تبريد" : _projectCtrl.text} — ${_clientCtrl.text}'),
          _infoTile('المهندس المشرف', _engCtrl.text),
          _infoTile('أبعاد الغرفة والحجم', '${_lastInput!.length} × ${_lastInput!.width} × ${_lastInput!.height} m (${_result!.volume} m³)'),
          _infoTile('الاستطاعة التبريدية Q₀', '${_result!.q0Kw} kW (${_result!.kcalH} kcal/h)'),
          _infoTile('المجموعة المقترحة', '${_result!.selectedUnit.item.brand} ${_result!.selectedUnit.item.model} (${_lastInput!.refrigerant})'),
          _infoTile('أبعاد المجموعة والمبخر', '${_result!.condDimMm.join("×")} mm  |  ${_result!.evapDimMm.join("×")} mm'),
          _infoTile('أقطار أنابيب النحاس', 'سحب ${_result!.sucInch}  /  سائل ${_result!.liqInch}'),
          _infoTile('ألواح الساندويتش PU ${_lastInput!.insMm.toInt()}mm', '${_result!.wallPanels} جدار + ${_result!.roofPanels} سقف (${_result!.totalPanelArea} m²)'),
        ],
      ],
    );
  }

  /* -------------------- REUSABLE UI WIDGETS -------------------- */
  Widget _buildHeatBreakdownCard(CryoResult r) {
    final total = r.qTransW + r.qProdW + r.qInfilW + r.qIntW;
    Widget row(String label, double valW) {
      final pct = total > 0 ? (valW / total) : 0.0;
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontSize: 12.5, color: Color(0xFFCBD5E1))),
                Text('${(valW / 1000).toStringAsFixed(2)} kW (${(pct * 100).toStringAsFixed(0)}%)',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: pct.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: const Color(0xFF071020),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF38BDF8)),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF111D34),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📊 تفصيل الأحمال الحرارية (Bilan Thermique)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          row('انتقال الحرارة عبر الجدران والسقف والأرضية', r.qTransW),
          row('تبريد وتجميد المنتج المخزن والتنفس', r.qProdW),
          row('تسرب الهواء وفتح الأبواب', r.qInfilW),
          row('المراوح والإضاءة وإذابة الجليد', r.qIntW),
        ],
      ),
    );
  }

  Widget _buildAlertsCard(String title, List<EngineeringAlert> alerts) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF111D34),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          ...alerts.map((a) {
            final col = a.level == 'bad'
                ? const Color(0xFFEF4444)
                : (a.level == 'warn' ? const Color(0xFFF59E0B) : const Color(0xFF22C55E));
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: col.withAlpha(24),
                borderRadius: BorderRadius.circular(10),
                border: Border(right: BorderSide(color: col, width: 3.5)),
              ),
              child: Text(a.text, style: const TextStyle(fontSize: 12.5, height: 1.45)),
            );
          }),
        ],
      ),
    );
  }

  Widget _emptyPlaceholderCard({required IconData icon, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF0E182B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF38BDF8).withAlpha(45)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 42, color: const Color(0xFF38BDF8)),
          const SizedBox(height: 10),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8), height: 1.5)),
        ],
      ),
    );
  }

  Widget _numInput(TextEditingController ctrl, String label, String hint) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }

  Widget _kpiCard(String title, String main, String sub, Color accent) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFF111D34),
        borderRadius: BorderRadius.circular(14),
        border: Border(top: BorderSide(color: accent, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8))),
          const SizedBox(height: 3),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(main, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
          ),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(sub, style: TextStyle(fontSize: 10, color: accent, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFF111D34),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(title, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5))),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
