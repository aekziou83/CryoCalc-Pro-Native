import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'l10n/app_strings.dart';
import 'security/security_guard.dart';
import 'engine/cryo_engine.dart';
import 'services/pdf_printer.dart';
import 'widgets/room_3d_viewer.dart';
import 'widgets/industrial_compressor_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  if (!SecurityGuard.verifyIntegrity()) {
    runApp(SecurityGuard.buildTamperLockScreen());
    return;
  }

  runApp(const CryoCalcApp());
}

class CryoCalcApp extends StatefulWidget {
  const CryoCalcApp({super.key});

  @override
  State<CryoCalcApp> createState() => _CryoCalcAppState();
}

class _CryoCalcAppState extends State<CryoCalcApp> {
  AppLang _lang = AppLang.ar;
  AppThemePreset _themePreset = AppThemes.presets.first;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1900), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CryoCalc Pro v5.3',
      debugShowCheckedModeBanner: false,
      theme: _themePreset.toThemeData(),
      builder: (context, child) => Directionality(
        textDirection: _lang == AppLang.ar ? TextDirection.rtl : TextDirection.ltr,
        child: child ?? const SizedBox.shrink(),
      ),
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 420),
        child: _showSplash
            ? _InlineBootSplash(lang: _lang)
            : CryoHomeScreen(
                lang: _lang,
                themePreset: _themePreset,
                onLangChanged: (l) => setState(() => _lang = l),
                onThemeChanged: (t) => setState(() => _themePreset = t),
              ),
      ),
    );
  }
}

class _InlineBootSplash extends StatelessWidget {
  final AppLang lang;
  const _InlineBootSplash({required this.lang});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070D19),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.25),
            radius: 1.1,
            colors: [Color(0xFF102547), Color(0xFF070D19)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 126,
              height: 126,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [BoxShadow(color: const Color(0xFF38BDF8).withAlpha(85), blurRadius: 32)],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/icon.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF0F2547),
                  alignment: Alignment.center,
                  child: const Icon(Icons.ac_unit_rounded, color: Color(0xFF38BDF8), size: 60),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('CryoCalc PRO', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 6),
            Text(AppStrings.t(lang, 'dev_name'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF38BDF8))),
            const SizedBox(height: 4),
            const Text(CryoOwner.groupCode, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, letterSpacing: 1.4, color: Color(0xFFF59E0B))),
            const SizedBox(height: 26),
            const SizedBox(
              width: 110,
              child: LinearProgressIndicator(minHeight: 3, backgroundColor: Color(0xFF111D34), valueColor: AlwaysStoppedAnimation(Color(0xFF38BDF8))),
            ),
            const SizedBox(height: 12),
            Text(AppStrings.t(lang, 'splash_sub'), style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          ],
        ),
      ),
    );
  }
}

class CryoHomeScreen extends StatefulWidget {
  final AppLang lang;
  final AppThemePreset themePreset;
  final ValueChanged<AppLang> onLangChanged;
  final ValueChanged<AppThemePreset> onThemeChanged;

  const CryoHomeScreen({
    super.key,
    required this.lang,
    required this.themePreset,
    required this.onLangChanged,
    required this.onThemeChanged,
  });

  @override
  State<CryoHomeScreen> createState() => _CryoHomeScreenState();
}

class _CryoHomeScreenState extends State<CryoHomeScreen> {
  int _tabIndex = 0;
  bool _expertMode = false;

  // Custom-panel visibility toggles per settings section
  bool _roomCustomOpen = false;
  bool _sizingCustomOpen = false;
  bool _auditCustomOpen = false;
  bool _reportCustomOpen = false;

  // ALL calculation input fields start EMPTY on app entry
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
  final _scCtrl = TextEditingController();
  final _shCtrl = TextEditingController();

  // Custom fields for EVERY section (start empty)
  final _customCalcLineCtrl = TextEditingController();
  final _customRoomCtrl = TextEditingController();
  final _customInsMmCtrl = TextEditingController();
  final _customLambdaCtrl = TextEditingController();
  final _customCpAboveCtrl = TextEditingController();
  final _customCpBelowCtrl = TextEditingController();
  final _customLatentCtrl = TextEditingController();
  final _customAirChgCtrl = TextEditingController();
  final _customArchCtrl = TextEditingController();
  final _customDefrostKwCtrl = TextEditingController();
  final _customRefCtrl = TextEditingController();
  final _customCompModelCtrl = TextEditingController();
  final _customCompCapCtrl = TextEditingController();
  final _customCompElecCtrl = TextEditingController();
  final _customVoltCtrl = TextEditingController();
  final _customCosPhiCtrl = TextEditingController();
  final _customPanelWCtrl = TextEditingController();
  final _customXrefDispCtrl = TextEditingController();
  final _customAudSealCtrl = TextEditingController();
  final _customAudCleanCtrl = TextEditingController();
  final _customReportLineCtrl = TextEditingController();

  // Direct Scientific Sizing controllers (Tab 4 — start empty)
  final _dirQ0Ctrl = TextEditingController();
  final _dirT0Ctrl = TextEditingController();
  final _dirTkCtrl = TextEditingController();
  final _dirPipeCtrl = TextEditingController();
  final _dirCustomSpecCtrl = TextEditingController();
  ScientificComponentSizing? _directSizing;
  ElectricalSizing? _directElectrical;
  double? _directT0;
  double? _directTk;

  // Selections
  String _roomType = 'positive';
  String _insOption = '80';
  String _productId = 'veg';
  String _doorTraffic = 'med';
  String _arch = 'split';
  String _defrostType = 'auto';
  String _refrigerant = 'R404A';
  String _brandFilter = 'ALL';
  String _voltageFilter = '400';
  String _panelWidthOpt = '1.15';
  String _floorPanelMode = 'auto';
  String? _selectedCompId;
  String _xrefSourceId = 'cp2';
  String _xrefCustomRegime = 'MT';

  CryoInput? _lastInput;
  CryoResult? _result;

  // Field Audit controllers (start empty)
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

  // Report controllers
  final _clientCtrl = TextEditingController();
  final _projectCtrl = TextEditingController();
  final _engCtrl = TextEditingController();

  String tr(String key) => AppStrings.t(widget.lang, key);
  String _l(String ar, String fr, String en) {
    if (widget.lang == AppLang.fr) return fr;
    if (widget.lang == AppLang.en) return en;
    return ar;
  }

  AppThemePreset get th => widget.themePreset;
  Color get _textMuted => th.isLight ? const Color(0xFF475569) : const Color(0xFF94A3B8);
  Color get _textMain => th.isLight ? const Color(0xFF0F172A) : Colors.white;

  @override
  void didUpdateWidget(covariant CryoHomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lang != widget.lang) {
      final defaults = [
        AppStrings.t(AppLang.ar, 'dev_name'),
        AppStrings.t(AppLang.fr, 'dev_name'),
        AppStrings.t(AppLang.en, 'dev_name'),
      ];
      if (defaults.contains(_engCtrl.text.trim())) {
        _engCtrl.text = tr('dev_name');
      }
      if (_lastInput != null) {
        _result = CryoEngine.calculate(_lastInput!, forcedCompId: _selectedCompId, lang: widget.lang.name);
      }
      if (_auditResult != null) {
        _runAudit(silent: true);
      }
      if (_directSizing != null) {
        _runDirectSizing(silent: true);
      }
    }
  }

  @override
  void dispose() {
    for (final c in [
      _lenCtrl, _widCtrl, _heiCtrl, _tInCtrl, _tAmbCtrl, _tFloorCtrl, _opHoursCtrl,
      _kgCtrl, _tProdCtrl, _pipeCtrl, _scCtrl, _shCtrl, _customCalcLineCtrl,
      _customRoomCtrl, _customInsMmCtrl, _customLambdaCtrl, _customCpAboveCtrl,
      _customCpBelowCtrl, _customLatentCtrl, _customAirChgCtrl, _customArchCtrl,
      _customDefrostKwCtrl, _customRefCtrl, _customCompModelCtrl, _customCompCapCtrl,
      _customCompElecCtrl, _customVoltCtrl, _customCosPhiCtrl, _customPanelWCtrl,
      _customXrefDispCtrl, _customAudSealCtrl, _customAudCleanCtrl,
      _customReportLineCtrl, _dirQ0Ctrl, _dirT0Ctrl, _dirTkCtrl, _dirPipeCtrl,
      _dirCustomSpecCtrl, _audT0Ctrl, _audTsucCtrl, _audTkCtrl, _audTliqCtrl,
      _audTroomCtrl, _audTdisCtrl, _audP0Ctrl, _audPelecCtrl,
      _clientCtrl, _projectCtrl, _engCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: th.card),
    );
  }

  Future<void> _copyLink(String url) async {
    HapticFeedback.lightImpact();
    await Clipboard.setData(ClipboardData(text: url));
    if (mounted) _showMsg(tr('copied'));
  }

  void _openThemeAndLangPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: th.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(tr('lang_title'), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: _textMain)),
              const SizedBox(height: 10),
              Row(
                children: [
                  _langBtn('العربية', AppLang.ar, ctx),
                  const SizedBox(width: 8),
                  _langBtn('Français', AppLang.fr, ctx),
                  const SizedBox(width: 8),
                  _langBtn('English', AppLang.en, ctx),
                ],
              ),
              const SizedBox(height: 18),
              Text(tr('themes_title'), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: _textMain)),
              const SizedBox(height: 10),
              ...AppThemes.presets.map((p) {
                final sel = p.id == th.id;
                return InkWell(
                  onTap: () {
                    widget.onThemeChanged(p);
                    Navigator.pop(ctx);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: p.bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: sel ? p.primary : Colors.grey.withAlpha(80), width: sel ? 2.2 : 1.0),
                    ),
                    child: Row(
                      children: [
                        Container(width: 20, height: 20, decoration: BoxDecoration(color: p.primary, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Container(width: 14, height: 14, decoration: BoxDecoration(color: p.secondary, shape: BoxShape.circle)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            p.label(widget.lang),
                            style: TextStyle(fontWeight: FontWeight.w800, color: p.isLight ? Colors.black87 : Colors.white),
                          ),
                        ),
                        if (sel) Icon(Icons.check_circle_rounded, color: p.primary, size: 20),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _langBtn(String label, AppLang target, BuildContext sheetCtx) {
    final active = widget.lang == target;
    return Expanded(
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: active ? th.primary : th.inputBg,
          foregroundColor: active ? (th.isLight ? Colors.white : const Color(0xFF04101F)) : _textMain,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
        ),
        onPressed: () {
          widget.onLangChanged(target);
          Navigator.pop(sheetCtx);
        },
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
      ),
    );
  }

  void _openDeveloperAndSecuritySheet() {
    final auditMap = SecurityGuard.getSecurityAuditReport();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: th.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.verified_user_rounded, color: th.secondary, size: 26),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CryoCalc PRO ${CryoOwner.appVersion}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: _textMain)),
                        Text('${tr("dev_name")} • ${CryoOwner.groupCode}', style: TextStyle(fontSize: 12, color: _textMuted)),
                      ],
                    ),
                  ),
                  IconButton(onPressed: () => Navigator.pop(sheetCtx), icon: const Icon(Icons.close_rounded)),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF1877F2), foregroundColor: Colors.white),
                  onPressed: () => _copyLink(CryoOwner.facebookUrl),
                  icon: const Icon(Icons.facebook_rounded),
                  label: Text(tr('fb_dev')),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: th.primary, foregroundColor: const Color(0xFF04101F)),
                  onPressed: () => _copyLink(CryoOwner.facebookGroupUrl),
                  icon: const Icon(Icons.groups_rounded),
                  label: Text(tr('fb_group')),
                ),
              ),
              const SizedBox(height: 14),
              ...auditMap.entries.map((e) => _infoTile(e.key, e.value)),
            ],
          ),
        ),
      ),
    );
  }

  /* ==================== AUTO FILL HELPERS PER TAB ==================== */
  void _autoFillRoom() {
    HapticFeedback.lightImpact();
    setState(() {
      _roomCustomOpen = false;
      _lenCtrl.text = '6';
      _widCtrl.text = '4';
      _heiCtrl.text = '3';
      _tInCtrl.text = _roomType == 'negative' ? '-20' : (_roomType == 'tunnel' ? '-35' : '2');
      _tAmbCtrl.text = '38';
      _kgCtrl.text = '1500';
      _tProdCtrl.text = '20';
      _insOption = _roomType == 'negative' ? '120' : (_roomType == 'tunnel' ? '160' : '80');
      _doorTraffic = 'med';
      _arch = 'split';
    });
    _runCalculation();
    _showMsg(tr('auto_filled'));
  }

  void _autoFillDirectSizing() {
    HapticFeedback.lightImpact();
    setState(() {
      _sizingCustomOpen = false;
      _dirQ0Ctrl.text = _result != null ? _result!.q0Kw.toString() : '6.5';
      _dirT0Ctrl.text = _result != null ? _result!.t0.toString() : '-10';
      _dirTkCtrl.text = _result != null ? _result!.tk.toString() : '45';
      _dirPipeCtrl.text = _lastInput != null ? _lastInput!.pipeLen.toStringAsFixed(0) : '10';
    });
    _runDirectSizing();
    _showMsg(tr('auto_filled'));
  }

  void _autoFillAudit() {
    HapticFeedback.lightImpact();
    setState(() {
      _auditCustomOpen = false;
      _audT0Ctrl.text = _result != null ? _result!.t0.toString() : '-10';
      _audTsucCtrl.text = _result != null ? (_result!.t0 + 7).toStringAsFixed(1) : '-3';
      _audTkCtrl.text = _result != null ? _result!.tk.toString() : '45';
      _audTliqCtrl.text = _result != null ? (_result!.tk - 5).toStringAsFixed(1) : '40';
      _audTroomCtrl.text = _lastInput != null ? _lastInput!.tInside.toString() : '-2';
      _audTdisCtrl.text = '82';
      _audP0Ctrl.text = _result != null ? _result!.q0Kw.toString() : '8.5';
      _audPelecCtrl.text = _result != null ? _result!.pElecKw.toString() : '3.2';
      _audSeals = 'good';
      _audClean = 'good';
    });
    _runAudit();
    _showMsg(tr('auto_filled'));
  }

  void _autoFillReport() {
    HapticFeedback.lightImpact();
    setState(() {
      _reportCustomOpen = false;
      _projectCtrl.text = _l('دراسة غرفة تبريد', 'Etude chambre froide', 'Cold Room Study');
      _engCtrl.text = tr('dev_name');
    });
    _showMsg(tr('auto_filled'));
  }

  /* ==================== CALCULATIONS ==================== */
  void _runCalculation() {
    final l = double.tryParse(_lenCtrl.text.trim());
    final w = double.tryParse(_widCtrl.text.trim());
    final h = double.tryParse(_heiCtrl.text.trim());
    final tIn = double.tryParse(_tInCtrl.text.trim());
    final tAmb = double.tryParse(_tAmbCtrl.text.trim());

    if (l == null || w == null || h == null || tIn == null || tAmb == null || l <= 0 || w <= 0 || h <= 0) {
      _showMsg(tr('err_inputs'));
      return;
    }

    HapticFeedback.mediumImpact();
    final insVal = _insOption == 'custom'
        ? (double.tryParse(_customInsMmCtrl.text.trim()) ?? 120.0)
        : (double.tryParse(_insOption) ?? 80.0);
    final pwVal = _panelWidthOpt == 'custom'
        ? (double.tryParse(_customPanelWCtrl.text.trim()) ?? 1.15)
        : (double.tryParse(_panelWidthOpt) ?? 1.15);

    final inp = CryoInput(
      roomType: _roomType,
      customRoomLabel: _customRoomCtrl.text.trim(),
      length: l,
      width: w,
      height: h,
      insMm: insVal,
      lambdaIns: double.tryParse(_customLambdaCtrl.text.trim()) ?? 0.023,
      tInside: tIn,
      tAmbient: tAmb,
      tFloor: double.tryParse(_tFloorCtrl.text.trim()) ?? 18.0,
      opHours: double.tryParse(_opHoursCtrl.text.trim()) ?? 16.0,
      productId: _productId,
      customCpAbove: double.tryParse(_customCpAboveCtrl.text.trim()) ?? 3.5,
      customCpBelow: double.tryParse(_customCpBelowCtrl.text.trim()) ?? 1.8,
      customLatent: double.tryParse(_customLatentCtrl.text.trim()) ?? 240.0,
      dailyKg: double.tryParse(_kgCtrl.text.trim()) ?? 0.0,
      tProdIn: double.tryParse(_tProdCtrl.text.trim()) ?? 20.0,
      doorTraffic: _doorTraffic,
      customAirChanges: double.tryParse(_customAirChgCtrl.text.trim()),
      arch: _arch,
      pipeLen: double.tryParse(_pipeCtrl.text.trim()) ?? 10.0,
      defrostType: _defrostType,
      customDefrostKw: double.tryParse(_customDefrostKwCtrl.text.trim()),
      refrigerant: _refrigerant,
      customRefName: _customRefCtrl.text.trim(),
      brandFilter: _brandFilter,
      customCompBrandModel: _customCompModelCtrl.text.trim(),
      customCompCapKw: double.tryParse(_customCompCapCtrl.text.trim()),
      customCompElecKw: double.tryParse(_customCompElecCtrl.text.trim()),
      voltageFilter: _voltageFilter,
      customVolt: double.tryParse(_customVoltCtrl.text.trim()) ?? 400.0,
      customCosPhi: double.tryParse(_customCosPhiCtrl.text.trim()) ?? 0.84,
      panelWidth: pwVal,
      floorPanelMode: _floorPanelMode,
      subcoolingK: double.tryParse(_scCtrl.text.trim()) ?? 5.0,
      superheatK: double.tryParse(_shCtrl.text.trim()) ?? 7.0,
    );

    final res = CryoEngine.calculate(inp, forcedCompId: _selectedCompId, lang: widget.lang.name);
    setState(() {
      _lastInput = inp;
      _result = res;
      _directSizing = null;
      _directElectrical = null;
    });
  }

  void _runDirectSizing({bool silent = false}) {
    final q0 = double.tryParse(_dirQ0Ctrl.text.trim());
    final t0 = double.tryParse(_dirT0Ctrl.text.trim());
    final tk = double.tryParse(_dirTkCtrl.text.trim());
    if (q0 == null || t0 == null || tk == null || q0 <= 0) {
      if (!silent) {
        _showMsg(_l(
          'أدخل الاستطاعة Q₀ (kW) وحرارة التبخير T₀ والتكثيف Tk أولاً (أو اضغط «تلقائي»).',
          'Saisissez Q₀ (kW), T₀ et Tk (ou Automatique).',
          'Enter Q₀ (kW), T₀, and Tk first (or tap Auto).',
        ));
      }
      return;
    }

    if (!silent) HapticFeedback.mediumImpact();
    final pipeLen = (double.tryParse(_dirPipeCtrl.text.trim()) ?? 10.0).clamp(1.0, 100.0);
    final sc = (double.tryParse(_scCtrl.text.trim()) ?? 5.0).clamp(1.0, 15.0);
    final sh = (double.tryParse(_shCtrl.text.trim()) ?? 7.0).clamp(3.0, 15.0);
    final isLT = t0 <= -12.0;

    final refProps = CryoEngine.refrigerants.firstWhere((r) => r.id == _refrigerant, orElse: () => CryoEngine.refrigerants.first);
    final p0Abs = double.parse(refProps.satPressureBarAbs(t0).toStringAsFixed(2));
    final pkAbs = double.parse(refProps.satPressureBarAbs(tk).toStringAsFixed(2));
    final p0Rel = double.parse((p0Abs - 1.013).toStringAsFixed(2));
    final pkRel = double.parse((pkAbs - 1.013).toStringAsFixed(2));
    final tau = double.parse((pkAbs / math.max(0.5, p0Abs)).toStringAsFixed(2));

    final dhEvap = double.parse(
      (refProps.dhRefKjKg * (1.0 - (tk - 40.0) * 0.008 + (sc - 4.0) * 0.009 - (isLT ? 0.08 : 0.0))).clamp(65.0, 320.0).toStringAsFixed(1),
    );
    final mDotKgS = q0 / dhEvap;
    final mDotKgH = double.parse((mDotKgS * 3600.0).toStringAsFixed(1));
    final tSucK = (t0 + sh) + 273.15;
    final vSuc = double.parse(((8.3145 * tSucK * 0.86) / (refProps.molarMass * p0Abs * 100.0)).toStringAsFixed(4));
    final etaV = double.parse((1.0 - 0.05 * tau).clamp(0.52, 0.90).toStringAsFixed(2));
    final reqVb = double.parse(((mDotKgH * vSuc) / etaV).toStringAsFixed(2));
    final tDisC = double.parse(((tSucK * math.pow(tau, 0.165)) - 273.15).clamp(55.0, 132.0).toStringAsFixed(1));

    final pElecEst = double.parse((q0 / (isLT ? 1.85 : 2.65)).toStringAsFixed(2));
    final evapDt1 = isLT ? 6.5 : 7.0;
    final evapAreaM2 = double.parse(((q0 * 1000.0) / ((isLT ? 24.0 : 28.0) * evapDt1)).toStringAsFixed(1));
    final finMm = isLT ? 7.0 : 4.5;
    final evapAir = (q0 * 700).round();
    final defrostKw = isLT ? double.parse((q0 * 0.42).clamp(1.2, 16.0).toStringAsFixed(1)) : 0.0;

    final qCondKw = double.parse((q0 + pElecEst).toStringAsFixed(2));
    final condDt = 12.0;
    final condAreaM2 = double.parse(((qCondKw * 1000.0) / (32.0 * condDt)).toStringAsFixed(1));
    final condAir = ((qCondKw * 3600.0) / (1.18 * 1.005 * 6.5)).round();

    String suc = '5/8"', liq = '3/8"', dis = '1/2"';
    if (q0 < 2.2) {
      suc = isLT ? '5/8"' : '1/2"';
      dis = '3/8"';
    } else if (q0 < 5.5) {
      suc = isLT ? '7/8"' : '5/8"';
      dis = '1/2"';
    } else if (q0 < 11.5) {
      suc = isLT ? '1-1/8"' : '7/8"';
      liq = '1/2"';
      dis = '5/8"';
    } else if (q0 < 20.0) {
      suc = isLT ? '1-3/8"' : '1-1/8"';
      liq = '5/8"';
      dis = '7/8"';
    } else {
      suc = isLT ? '1-5/8"' : '1-3/8"';
      liq = '7/8"';
      dis = '1-1/8"';
    }

    final dpEff = double.parse((pkAbs - p0Abs - (1.6 + pipeLen * 0.03)).clamp(2.5, 22.0).toStringAsFixed(1));
    final kSc = double.parse((1.0 + (sc - 4.0) * 0.014).clamp(0.90, 1.20).toStringAsFixed(2));
    final txvNomKw = double.parse((q0 / (kSc * math.sqrt(dpEff / (isLT ? 8.0 : 6.0)))).toStringAsFixed(2));

    String txvBody = isLT ? 'Danfoss TES2 / Alco TI' : 'Danfoss TEX2 / TES2';
    String orifice = 'Orifice 01';
    if (txvNomKw < 1.2) {
      orifice = 'Orifice 0X (0.6-1.2 kW)';
    } else if (txvNomKw < 2.2) {
      orifice = 'Orifice 00 (1.2-2.2 kW)';
    } else if (txvNomKw < 3.6) {
      orifice = 'Orifice 01 (2.2-3.6 kW)';
    } else if (txvNomKw < 5.2) {
      orifice = 'Orifice 02 (3.6-5.2 kW)';
    } else if (txvNomKw < 7.6) {
      orifice = 'Orifice 03 (5.2-7.6 kW)';
    } else if (txvNomKw < 10.5) {
      orifice = 'Orifice 04 (7.6-10.5 kW)';
    } else if (txvNomKw < 14.2) {
      orifice = 'Orifice 05 (10.5-14.2 kW)';
    } else if (txvNomKw < 18.5) {
      orifice = 'Orifice 06 (14.2-18.5 kW)';
    } else {
      txvBody = 'Danfoss TE5 / Alco TCLE';
      orifice = txvNomKw < 26 ? 'TE5 Orifice 01' : (txvNomKw < 36 ? 'TE5 Orifice 02' : 'TE5 Orifice 03');
    }

    final drierModel = liq == '3/8"'
        ? (q0 < 3.5 ? 'Danfoss DML 083 (3/8")' : 'Danfoss DML 163 (3/8")')
        : (liq == '1/2"' ? 'Danfoss DML 164 (1/2")' : (liq == '5/8"' ? 'Danfoss DML 305 (5/8")' : 'Danfoss DML 417 (7/8")'));

    final disIdMm = dis == '3/8"' ? 7.9 : dis == '1/2"' ? 10.9 : dis == '5/8"' ? 13.8 : dis == '7/8"' ? 20.2 : 26.0;
    final vDisGas = (8.3145 * (tDisC + 273.15) * 0.90) / (refProps.molarMass * pkAbs * 100.0);
    final disVel = double.parse(((mDotKgS * vDisGas) / (math.pi * math.pow((disIdMm / 1000.0) / 2.0, 2))).clamp(3.0, 24.0).toStringAsFixed(1));
    final oilMandatory = isLT || pipeLen > 15.0;
    final oilModel = q0 < 5 ? 'Castel 5540/4 ($dis)' : q0 < 12 ? 'Castel 5540/5 ($dis)' : q0 < 22 ? 'Castel 5540/7 ($dis)' : 'Castel 5540/9 ($dis)';

    final totalChargeKg = double.parse((q0 * 0.22 + qCondKw * 0.20 + pipeLen * 0.09).clamp(1.2, 65.0).toStringAsFixed(2));
    final recMinL = double.parse(((totalChargeKg / (0.80 * refProps.liquidDensityKgL)) * 1.20).toStringAsFixed(1));
    final recStdL = [2.3, 3.9, 5.6, 8.0, 10.0, 12.0, 16.0, 20.0, 25.0, 35.0, 50.0, 75.0].firstWhere((v) => v >= recMinL, orElse: () => 75.0);
    final aclMinL = double.parse(((totalChargeKg * 0.55) / (refProps.liquidDensityKgL * 1.12)).clamp(1.0, 45.0).toStringAsFixed(1));
    final aclStdL = [1.5, 2.3, 3.5, 5.0, 7.5, 10.0, 14.0, 20.0, 30.0, 45.0].firstWhere((v) => v >= aclMinL, orElse: () => 45.0);

    final iNom = double.parse(((pElecEst * 1000.0) / (400 * 1.732 * 0.84)).toStringAsFixed(1));
    final brk = iNom <= 6 ? 10 : iNom <= 10 ? 16 : iNom <= 16 ? 20 : iNom <= 22 ? 32 : 40;
    final cnt = iNom <= 9 ? 12 : iNom <= 16 ? 18 : iNom <= 24 ? 25 : 40;
    final cab = iNom <= 10 ? '2.5' : iNom <= 16 ? '4.0' : iNom <= 25 ? '6.0' : '10.0';

    setState(() {
      _directT0 = t0;
      _directTk = tk;
      _directSizing = ScientificComponentSizing(
        p0BarAbs: p0Abs,
        p0BarRel: p0Rel,
        pkBarAbs: pkAbs,
        pkBarRel: pkRel,
        compressionRatio: tau,
        dhEvapKjKg: dhEvap,
        massFlowKgH: mDotKgH,
        suctionSpecVolM3Kg: vSuc,
        volumetricEff: etaV,
        reqSweptVolM3h: reqVb,
        estDischargeTempC: tDisC,
        oilType: refProps.oilType,
        evapDeltaT1K: evapDt1,
        evapSurfaceM2: evapAreaM2,
        evapFinSpacingMm: finMm,
        evapAirFlowM3h: evapAir,
        evapBrassageVolH: isLT ? 50 : 40,
        defrostHeaterKw: defrostKw,
        condRejectionKw: qCondKw,
        condDeltaTK: condDt,
        condSurfaceM2: condAreaM2,
        condAirFlowM3h: condAir,
        txvDeltaPBar: dpEff,
        txvSubcoolingK: sc,
        txvCorrFactorKsc: kSc,
        txvNominalCapKw: txvNomKw,
        txvBody: txvBody,
        txvOrificeNumber: orifice,
        txvMopNote: isLT ? _l('MOP -15/-20 لحماية الضاغط', 'MOP -15/-20', 'MOP -15/-20') : _l('بدون MOP (أو +15)', 'Sans MOP (+15)', 'No MOP (+15)'),
        filterDrierModel: drierModel,
        filterConnInch: liq,
        sightGlassModel: 'Danfoss SGN / Castel 3940 ($liq)',
        dischargeVelocityMs: disVel,
        dischargePipeInch: dis,
        oilSeparatorModel: oilModel,
        oilPreChargeL: q0 < 5 ? 0.45 : (q0 < 15 ? 0.65 : 1.0),
        oilSeparatorMandatory: oilMandatory,
        oilSeparatorStatus: oilMandatory ? _l('إلزامي', 'Obligatoire', 'Mandatory') : _l('اختياري (مصيدة زيت)', 'Optionnel (piege)', 'Optional (oil trap)'),
        estTotalChargeKg: totalChargeKg,
        liquidDensityKgL: refProps.liquidDensityKgL,
        receiverMinVolL: recMinL,
        receiverStdVolL: recStdL,
        receiverModel: 'Carly / Castel ${recStdL}L (PS 33 bar)',
        aclMinVolL: aclMinL,
        aclStdVolL: aclStdL,
        aclModel: 'Carly LCY / Castel 5520 (${aclStdL}L | $suc)',
        aclConnInch: suc,
        aclBleedHoleMm: q0 < 6 ? '1.5 mm' : (q0 < 15 ? '2.0 mm' : '2.5 mm'),
        solenoidValve: 'Danfoss EVR ${q0 < 6 ? "3" : q0 < 14 ? "6" : "10"} ($liq | 230V)',
        hpLpSwitch: 'Danfoss KP15 (HP: ${(pkAbs + 4.5).clamp(16.0, 30.0).toStringAsFixed(1)} bar / LP: ${math.max(0.3, p0Rel - 0.6).toStringAsFixed(1)} bar)',
      );
      _directElectrical = ElectricalSizing(
        nominalAmps: iNom,
        breakerRating: '3P+N ${brk}A (Courbe D)',
        contactorRating: 'LC1D$cnt (${cnt}A AC-3)',
        overloadRange: '${(iNom * 0.85).toStringAsFixed(1)} - ${(iNom * 1.25).toStringAsFixed(1)} A',
        cableSection: '5G $cab mm2 (Cu RO2V)',
        defrostHeaterKw: defrostKw,
      );
    });
  }

  void _resetAll() {
    HapticFeedback.lightImpact();
    setState(() {
      for (final c in [
        _lenCtrl, _widCtrl, _heiCtrl, _tInCtrl, _tAmbCtrl, _tFloorCtrl,
        _opHoursCtrl, _kgCtrl, _tProdCtrl, _pipeCtrl, _scCtrl, _shCtrl,
        _customCalcLineCtrl, _customRoomCtrl, _customInsMmCtrl, _customLambdaCtrl,
        _customCpAboveCtrl, _customCpBelowCtrl, _customLatentCtrl, _customAirChgCtrl,
        _customArchCtrl, _customDefrostKwCtrl, _customRefCtrl, _customCompModelCtrl,
        _customCompCapCtrl, _customCompElecCtrl, _customVoltCtrl, _customCosPhiCtrl,
        _customPanelWCtrl, _customXrefDispCtrl, _dirQ0Ctrl, _dirT0Ctrl,
        _dirTkCtrl, _dirPipeCtrl, _dirCustomSpecCtrl, _audT0Ctrl, _audTsucCtrl,
        _audTkCtrl, _audTliqCtrl, _audTroomCtrl, _audTdisCtrl, _audP0Ctrl,
        _audPelecCtrl, _customAudSealCtrl, _customAudCleanCtrl,
      ]) {
        c.clear();
      }
      _roomCustomOpen = false;
      _sizingCustomOpen = false;
      _auditCustomOpen = false;
      _roomType = 'positive';
      _insOption = '80';
      _productId = 'veg';
      _doorTraffic = 'med';
      _arch = 'split';
      _defrostType = 'auto';
      _refrigerant = 'R404A';
      _brandFilter = 'ALL';
      _voltageFilter = '400';
      _panelWidthOpt = '1.15';
      _floorPanelMode = 'auto';
      _audSeals = 'good';
      _audClean = 'good';
      _selectedCompId = null;
      _lastInput = null;
      _result = null;
      _directSizing = null;
      _directElectrical = null;
      _auditResult = null;
    });
    _showMsg(tr('reset'));
  }

  void _resetReportFields() {
    HapticFeedback.lightImpact();
    setState(() {
      _clientCtrl.clear();
      _projectCtrl.clear();
      _engCtrl.clear();
      _customReportLineCtrl.clear();
      _reportCustomOpen = false;
    });
    _showMsg(tr('reset'));
  }

  void _resetUnitsSettings() {
    HapticFeedback.lightImpact();
    setState(() {
      _refrigerant = 'R404A';
      _brandFilter = 'ALL';
      _voltageFilter = '400';
      _selectedCompId = null;
      _xrefSourceId = 'cp2';
      _xrefCustomRegime = 'MT';
      _customXrefDispCtrl.clear();
      _customRefCtrl.clear();
      _customCompModelCtrl.clear();
      _customCompCapCtrl.clear();
      _customCompElecCtrl.clear();
      _customVoltCtrl.clear();
      _customCosPhiCtrl.clear();
    });
    if (_result != null) _runCalculation();
    _showMsg(tr('reset'));
  }

  void _runAudit({bool silent = false}) {
    final t0 = double.tryParse(_audT0Ctrl.text.trim());
    final tSuc = double.tryParse(_audTsucCtrl.text.trim());
    final tk = double.tryParse(_audTkCtrl.text.trim());
    final tLiq = double.tryParse(_audTliqCtrl.text.trim());
    if (t0 == null || tSuc == null || tk == null || tLiq == null) {
      if (!silent) _showMsg(tr('err_audit'));
      return;
    }
    if (!silent) HapticFeedback.mediumImpact();
    setState(() {
      _auditResult = CryoEngine.evaluateAudit(
        AuditInput(
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
          customSealsNote: _customAudSealCtrl.text.trim(),
          customCleanNote: _customAudCleanCtrl.text.trim(),
        ),
        lang: widget.lang.name,
      );
    });
  }

  Future<void> _printReportPdf() async {
    if (_result == null || _lastInput == null) return;
    final projFull = [
      _projectCtrl.text.trim(),
      if (_customCalcLineCtrl.text.trim().isNotEmpty) _customCalcLineCtrl.text.trim(),
      if (_customReportLineCtrl.text.trim().isNotEmpty) _customReportLineCtrl.text.trim(),
    ].where((s) => s.isNotEmpty).join(' | ');
    try {
      await PdfPrinterService.printEngineeringReport(
        lang: widget.lang,
        input: _lastInput!,
        result: _result!,
        client: _clientCtrl.text.trim(),
        project: projFull,
        engineer: _engCtrl.text.trim().isEmpty ? tr('dev_name') : _engCtrl.text.trim(),
      );
    } catch (e) {
      _showMsg('PDF: $e');
    }
  }

  Future<void> _printAuditPdf() async {
    if (_auditResult == null) return;
    final t0 = double.tryParse(_audT0Ctrl.text.trim()) ?? -10;
    final tSuc = double.tryParse(_audTsucCtrl.text.trim()) ?? -3;
    final tk = double.tryParse(_audTkCtrl.text.trim()) ?? 45;
    final tLiq = double.tryParse(_audTliqCtrl.text.trim()) ?? 40;
    try {
      await PdfPrinterService.printFieldAudit(
        lang: widget.lang,
        auditInput: AuditInput(
          t0: t0,
          tSuc: tSuc,
          tk: tk,
          tLiq: tLiq,
          tRoom: double.tryParse(_audTroomCtrl.text.trim()) ?? (t0 + 7),
          tDis: double.tryParse(_audTdisCtrl.text.trim()) ?? 82,
          p0Kw: double.tryParse(_audP0Ctrl.text.trim()) ?? (_result?.q0Kw ?? 5),
          pElecKw: double.tryParse(_audPelecCtrl.text.trim()) ?? (_result?.pElecKw ?? 2),
          seals: _audSeals,
          cleanliness: _audClean,
        ),
        auditResult: _auditResult!,
        client: _clientCtrl.text.trim(),
        project: _projectCtrl.text.trim(),
        engineer: _engCtrl.text.trim().isEmpty ? tr('dev_name') : _engCtrl.text.trim(),
      );
    } catch (e) {
      _showMsg('PDF: $e');
    }
  }

  Future<void> _copyReportText() async {
    if (_result == null || _lastInput == null) return;
    final r = _result!;
    final s = r.sizing;
    final customNotes = [
      if (_customCalcLineCtrl.text.trim().isNotEmpty) _customCalcLineCtrl.text.trim(),
      if (_customReportLineCtrl.text.trim().isNotEmpty) _customReportLineCtrl.text.trim(),
    ].join(' | ');
    final txt = '''
=== CryoCalc PRO ${CryoOwner.appVersion} ===
${tr("engineer")}: ${_engCtrl.text.trim().isEmpty ? tr("dev_name") : _engCtrl.text} | ${CryoOwner.groupCode}
${tr("client")}: ${_clientCtrl.text} | ${tr("project")}: ${_projectCtrl.text}
${customNotes.isNotEmpty ? "${tr("custom")}: $customNotes\n" : ""}${tr("kpi_q0")}: ${r.q0Kw} kW (${r.kcalH} kcal/h) | ${tr("kpi_vol")}: ${r.volume} m3
${tr("s_comp")}: ${r.recommendedUnit} | Vb=${s.reqSweptVolM3h} m3/h
${tr("s_txvbody")}: ${s.txvBody} -> ${s.txvOrificeNumber}
${tr("s_drier")}: ${s.filterDrierModel} | ${s.sightGlassModel}
${tr("s_oilmod")}: ${s.oilSeparatorModel}
${tr("s_recstd")}: ${s.receiverModel} (~${s.estTotalChargeKg} kg)
${tr("s_aclstd")}: ${s.aclModel}
${tr("s_elec")}: ${r.electrical.breakerRating} | ${r.electrical.cableSection}
''';
    await Clipboard.setData(ClipboardData(text: txt));
    _showMsg(tr('copied'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: th.appBar,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: th.primary.withAlpha(140), width: 1.2),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/icon.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: BoxDecoration(gradient: LinearGradient(colors: [th.primary, th.secondary])),
                  alignment: Alignment.center,
                  child: const Icon(Icons.ac_unit_rounded, color: Color(0xFF04101F), size: 19),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CryoCalc PRO', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900, color: _textMain)),
                  Text('${tr("dev_name")} • ${CryoOwner.groupCode}', style: TextStyle(fontSize: 9.5, color: _textMuted)),
                ],
              ),
            ),
            InkWell(
              onTap: _openThemeAndLangPicker,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: th.accent.withAlpha(32),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: th.accent),
                ),
                child: Text(
                  widget.lang.name.toUpperCase(),
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: th.accent),
                ),
              ),
            ),
            IconButton(
              tooltip: tr('themes_title'),
              onPressed: _openThemeAndLangPicker,
              icon: Icon(Icons.palette_rounded, color: th.accent, size: 21),
            ),
            IconButton(
              onPressed: _openDeveloperAndSecuritySheet,
              icon: Icon(Icons.verified_user_rounded, color: th.secondary, size: 20),
            ),
            InkWell(
              onTap: () => setState(() => _expertMode = !_expertMode),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _expertMode ? th.primary.withAlpha(35) : th.inputBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _expertMode ? th.primary : Colors.grey.withAlpha(70)),
                ),
                child: Text(
                  _expertMode ? tr('expert') : tr('basic'),
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: _expertMode ? th.primary : _textMain),
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
          _buildScientificSizingTab(),
          _buildAuditTab(),
          _buildReportTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: th.appBar,
        indicatorColor: th.primary.withAlpha(42),
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) {
          HapticFeedback.selectionClick();
          setState(() => _tabIndex = i);
        },
        destinations: [
          NavigationDestination(icon: const Icon(Icons.view_in_ar_outlined), selectedIcon: const Icon(Icons.view_in_ar), label: tr('tab_3d')),
          NavigationDestination(icon: const Icon(Icons.grid_view_outlined), selectedIcon: const Icon(Icons.grid_view_rounded), label: tr('tab_panels')),
          NavigationDestination(icon: const Icon(Icons.precision_manufacturing_outlined), selectedIcon: const Icon(Icons.precision_manufacturing), label: tr('tab_units')),
          NavigationDestination(icon: const Icon(Icons.science_outlined), selectedIcon: const Icon(Icons.science_rounded), label: tr('tab_sizing')),
          NavigationDestination(icon: const Icon(Icons.fact_check_outlined), selectedIcon: const Icon(Icons.fact_check_rounded), label: tr('tab_audit')),
          NavigationDestination(icon: const Icon(Icons.print_outlined), selectedIcon: const Icon(Icons.print_rounded), label: tr('tab_report')),
        ],
      ),
    );
  }

  /* ==================== TAB 1: ROOM & 3D ==================== */
  Widget _buildThermalAnd3DTab() {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr('room_params'), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: _textMain)),
              const SizedBox(height: 8),
              _settingsActionBar(
                onAuto: _autoFillRoom,
                onCustom: () => setState(() => _roomCustomOpen = !_roomCustomOpen),
                onReset: _resetAll,
                customActive: _roomCustomOpen,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _roomType,
                isExpanded: true,
                decoration: InputDecoration(labelText: tr('room_type')),
                items: [
                  DropdownMenuItem(value: 'positive', child: Text(tr('rt_pos'), overflow: TextOverflow.ellipsis)),
                  DropdownMenuItem(value: 'negative', child: Text(tr('rt_neg'), overflow: TextOverflow.ellipsis)),
                  DropdownMenuItem(value: 'corridor', child: Text(tr('rt_cor'), overflow: TextOverflow.ellipsis)),
                  DropdownMenuItem(value: 'tunnel', child: Text(tr('rt_tun'), overflow: TextOverflow.ellipsis)),
                  DropdownMenuItem(value: 'custom', child: Text(tr('custom'))),
                ],
                onChanged: (v) => setState(() => _roomType = v ?? 'positive'),
              ),
              if (_roomType == 'custom') ...[
                const SizedBox(height: 8),
                TextField(controller: _customRoomCtrl, decoration: InputDecoration(labelText: tr('custom'), hintText: tr('custom_room_hint'))),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _numInput(_lenCtrl, tr('len'), '6')),
                  const SizedBox(width: 8),
                  Expanded(child: _numInput(_widCtrl, tr('wid'), '4')),
                  const SizedBox(width: 8),
                  Expanded(child: _numInput(_heiCtrl, tr('hei'), '3')),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _numInput(_tInCtrl, tr('t_in'), '2')),
                  const SizedBox(width: 8),
                  Expanded(child: _numInput(_tAmbCtrl, tr('t_amb'), '38')),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _insOption,
                      isExpanded: true,
                      decoration: InputDecoration(labelText: tr('ins_pu')),
                      items: [
                        ...['60', '80', '100', '120', '140', '160', '180', '200'].map((v) => DropdownMenuItem(value: v, child: Text('$v mm'))),
                        DropdownMenuItem(value: 'custom', child: Text(tr('custom'))),
                      ],
                      onChanged: (v) => setState(() => _insOption = v ?? '80'),
                    ),
                  ),
                ],
              ),
              if (_insOption == 'custom') ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _numInput(_customInsMmCtrl, tr('custom_ins'), '150')),
                    const SizedBox(width: 8),
                    Expanded(child: _numInput(_customLambdaCtrl, 'λ (W/m·K)', '0.023')),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _productId,
                isExpanded: true,
                decoration: InputDecoration(labelText: tr('product')),
                items: CryoEngine.products
                    .map((p) => DropdownMenuItem(value: p.id, child: Text(p.nameFor(widget.lang.name), overflow: TextOverflow.ellipsis)))
                    .toList(),
                onChanged: (v) => setState(() => _productId = v ?? 'veg'),
              ),
              if (_productId == 'custom') ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _numInput(_customCpAboveCtrl, 'Cp+ (kJ/kg·K)', '3.5')),
                    const SizedBox(width: 8),
                    Expanded(child: _numInput(_customCpBelowCtrl, 'Cp- (kJ/kg·K)', '1.8')),
                    const SizedBox(width: 8),
                    Expanded(child: _numInput(_customLatentCtrl, 'Lf (kJ/kg)', '240')),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _numInput(_kgCtrl, tr('daily_kg'), '1500')),
                  const SizedBox(width: 8),
                  Expanded(child: _numInput(_tProdCtrl, tr('t_prod'), '20')),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _doorTraffic,
                      isExpanded: true,
                      decoration: InputDecoration(labelText: tr('door_tr')),
                      items: [
                        DropdownMenuItem(value: 'low', child: Text(tr('tr_low'))),
                        DropdownMenuItem(value: 'med', child: Text(tr('tr_med'))),
                        DropdownMenuItem(value: 'high', child: Text(tr('tr_high'))),
                        DropdownMenuItem(value: 'custom', child: Text(tr('custom'))),
                      ],
                      onChanged: (v) => setState(() => _doorTraffic = v ?? 'med'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _arch,
                      isExpanded: true,
                      decoration: InputDecoration(labelText: tr('unit_arch')),
                      items: [
                        DropdownMenuItem(value: 'split', child: Text(tr('arch_split'), overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'carrosse', child: Text(tr('arch_carrosse'), overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'monobloc', child: Text(tr('arch_mono'), overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'rack', child: Text(tr('arch_rack'), overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'evi', child: Text(tr('arch_evi'), overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'custom', child: Text(tr('custom'))),
                      ],
                      onChanged: (v) => setState(() => _arch = v ?? 'split'),
                    ),
                  ),
                ],
              ),
              if (_doorTraffic == 'custom' || _arch == 'custom') ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (_doorTraffic == 'custom') Expanded(child: _numInput(_customAirChgCtrl, tr('air_chg'), '10')),
                    if (_doorTraffic == 'custom' && _arch == 'custom') const SizedBox(width: 8),
                    if (_arch == 'custom') Expanded(child: TextField(controller: _customArchCtrl, decoration: InputDecoration(labelText: tr('custom_arch')))),
                  ],
                ),
              ],
              if (_expertMode || _roomCustomOpen) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _numInput(_tFloorCtrl, tr('t_floor'), '18')),
                    const SizedBox(width: 8),
                    Expanded(child: _numInput(_opHoursCtrl, tr('op_hours'), '16')),
                    const SizedBox(width: 8),
                    Expanded(child: _numInput(_pipeCtrl, tr('pipes_m'), '12')),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _numInput(_shCtrl, tr('sh_lbl'), '7')),
                    const SizedBox(width: 8),
                    Expanded(child: _numInput(_scCtrl, tr('sc_lbl'), '5')),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _defrostType,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: tr('defrost')),
                  items: [
                    DropdownMenuItem(value: 'auto', child: Text(tr('def_auto'))),
                    DropdownMenuItem(value: 'air', child: Text(tr('def_air'))),
                    DropdownMenuItem(value: 'electric', child: Text(tr('def_elec'))),
                    DropdownMenuItem(value: 'hotgas', child: Text(tr('def_hotgas'))),
                    DropdownMenuItem(value: 'custom', child: Text(tr('custom'))),
                  ],
                  onChanged: (v) => setState(() => _defrostType = v ?? 'auto'),
                ),
                if (_defrostType == 'custom') ...[
                  const SizedBox(height: 8),
                  _numInput(_customDefrostKwCtrl, tr('custom_def_kw'), '3.5'),
                ],
                const SizedBox(height: 10),
                TextField(
                  controller: _customCalcLineCtrl,
                  decoration: InputDecoration(
                    labelText: _l('تحديد مخصص / ملاحظة إعدادات الحساب', 'Spécification personnalisée / Note', 'Custom Calculation Specification'),
                    hintText: _l('مثال: غرفة في منطقة صحراوية أو شروط خاصة', 'Ex: Zone chaude / Conditions spéciales', 'Ex: High ambient / Special duty'),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: th.primary,
                    foregroundColor: th.isLight ? Colors.white : const Color(0xFF04101F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                  ),
                  onPressed: _runCalculation,
                  icon: const Icon(Icons.bolt_rounded),
                  label: Text(tr('calc_btn'), style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (_result == null || _lastInput == null)
          _emptyBox(Icons.calculate_outlined, tr('need_calc'))
        else ...[
          Row(
            children: [
              Expanded(child: _kpiCard(tr('kpi_q0'), '${_result!.q0Kw} kW', '${_result!.kcalH} kcal/h', th.secondary)),
              const SizedBox(width: 8),
              Expanded(child: _kpiCard(tr('kpi_vol'), '${_result!.volume} m³', '${_result!.areaFloor} m²', th.primary)),
              const SizedBox(width: 8),
              Expanded(child: _kpiCard(tr('kpi_temp'), '${_result!.t0}°C', 'Tk ${_result!.tk}°C', th.accent)),
            ],
          ),
          const SizedBox(height: 14),
          Room3DViewer(input: _lastInput!, result: _result!, lang: widget.lang),
          const SizedBox(height: 14),
          _buildAlertsCard(_result!.alerts),
        ],
      ],
    );
  }

  /* ==================== TAB 2: SANDWICH PANELS ==================== */
  Widget _buildPanelsTab() {
    if (_result == null || _lastInput == null) {
      return ListView(
        padding: const EdgeInsets.all(14),
        children: [
          _emptyBox(Icons.grid_view_rounded, tr('need_calc')),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => setState(() => _tabIndex = 0),
            icon: const Icon(Icons.view_in_ar_rounded),
            label: Text(_l('الانتقال إلى حساب الغرفة (3D)', 'Aller au calcul 3D', 'Go to 3D Room Calculator')),
          ),
        ],
      );
    }
    final r = _result!;
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_l('إعدادات ألواح الساندويتش', 'Paramètres Panneaux Sandwich', 'Sandwich Panel Settings'), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: _textMain)),
              const SizedBox(height: 8),
              _settingsActionBar(
                onAuto: () {
                  setState(() {
                    _panelWidthOpt = '1.15';
                    _floorPanelMode = 'auto';
                  });
                  _runCalculation();
                  _showMsg(tr('auto_filled'));
                },
                onCustom: () => setState(() => _panelWidthOpt = _panelWidthOpt == 'custom' ? '1.15' : 'custom'),
                onReset: () {
                  setState(() {
                    _panelWidthOpt = '1.15';
                    _floorPanelMode = 'auto';
                    _customPanelWCtrl.clear();
                  });
                  _runCalculation();
                  _showMsg(tr('reset'));
                },
                customActive: _panelWidthOpt == 'custom',
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _panelWidthOpt,
                      isExpanded: true,
                      decoration: InputDecoration(labelText: tr('panel_w')),
                      items: [
                        const DropdownMenuItem(value: '1.15', child: Text('1.15 m')),
                        const DropdownMenuItem(value: '1.12', child: Text('1.12 m')),
                        const DropdownMenuItem(value: '1.00', child: Text('1.00 m')),
                        DropdownMenuItem(value: 'custom', child: Text(tr('custom'))),
                      ],
                      onChanged: (v) {
                        setState(() => _panelWidthOpt = v ?? '1.15');
                        _runCalculation();
                      },
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _floorPanelMode,
                      isExpanded: true,
                      decoration: InputDecoration(labelText: tr('floor_pu')),
                      items: [
                        DropdownMenuItem(value: 'auto', child: Text(tr('def_auto'))),
                        DropdownMenuItem(value: 'yes', child: Text(tr('opt_yes'))),
                        DropdownMenuItem(value: 'no', child: Text(tr('opt_no'))),
                        DropdownMenuItem(value: 'custom', child: Text(tr('custom'))),
                      ],
                      onChanged: (v) {
                        setState(() => _floorPanelMode = v ?? 'auto');
                        _runCalculation();
                      },
                    ),
                  ),
                ],
              ),
              if (_panelWidthOpt == 'custom') ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _numInput(_customPanelWCtrl, tr('custom_pw'), '1.10')),
                    const SizedBox(width: 8),
                    FilledButton(onPressed: _runCalculation, child: Text(_l('تطبيق', 'Appliquer', 'Apply'))),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        _infoTile(tr('wall_p'), '${r.wallPanels} ${tr("pcs")} (H = ${_lastInput!.height} m)'),
        _infoTile(tr('roof_p'), '${r.roofPanels} ${tr("pcs")} (L = ${_lastInput!.length} m)'),
        _infoTile(tr('floor_p'), r.floorInsIncluded ? '${r.floorPanels} ${tr("pcs")}' : tr('not_inc')),
        _infoTile(tr('total_area'), '${r.totalPanelArea} m² (${_lastInput!.insMm.toInt()} mm)'),
        _infoTile(tr('u_rail'), '${r.uRailMeters} m'),
        _infoTile(tr('coving'), '${r.covingMeters} m'),
        _infoTile(tr('pu_foam'), '${r.puFoamCans} ${tr("cans")} (750 ml)'),
        _infoTile(tr('door_dim'), '${r.doorWidth} × ${r.doorHeight} m'),
      ],
    );
  }

  /* ==================== TAB 3: UNITS, INDUSTRIAL CALC & CROSS-REFERENCE ==================== */
  Widget _buildUnitsTab() {
    List<CompressorItem> xrefList;
    if (_xrefSourceId == 'custom') {
      final parsed = double.tryParse(_customXrefDispCtrl.text.trim());
      if (parsed == null || parsed <= 0) {
        xrefList = [];
      } else {
        final targetDisp = parsed.clamp(1.0, 200.0);
        xrefList = CryoEngine.compressors
            .where((c) => c.regime == _xrefCustomRegime && (c.dispM3h - targetDisp).abs() / targetDisp <= 0.28)
            .toList()
          ..sort((a, b) => (a.dispM3h - targetDisp).abs().compareTo((b.dispM3h - targetDisp).abs()));
      }
    } else {
      xrefList = CryoEngine.findCrossReference(_xrefSourceId);
    }

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: th.accent,
              foregroundColor: const Color(0xFF04101F),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => IndustrialCompressorScreen(
                    lang: widget.lang,
                    themePreset: th,
                    initialQ0Kw: _result?.q0Kw,
                    initialT0: _result?.t0,
                    initialTk: _result?.tk,
                    initialRef: _refrigerant,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.factory_rounded),
            label: Text(
              _l(
                'حاسبة الضواغط الصناعية (3–150 HP) + 16 قطعة للمجموعة',
                'Calculateur Industriel (3–150 HP) + 16 Pièces',
                'Industrial Compressor Calc (3–150 HP) + 16 Parts',
              ),
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_l('إعدادات اختيار المجموعة والغاز', 'Paramètres Groupe & Fluide', 'Unit & Refrigerant Settings'), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: _textMain)),
              const SizedBox(height: 8),
              _settingsActionBar(
                onAuto: () {
                  setState(() {
                    _refrigerant = 'R404A';
                    _brandFilter = 'ALL';
                    _voltageFilter = '400';
                    _selectedCompId = null;
                  });
                  if (_result != null) _runCalculation();
                  _showMsg(tr('auto_filled'));
                },
                onCustom: () => setState(() => _brandFilter = _brandFilter == 'custom' ? 'ALL' : 'custom'),
                onReset: _resetUnitsSettings,
                customActive: _brandFilter == 'custom',
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _refrigerant,
                      isExpanded: true,
                      decoration: InputDecoration(labelText: tr('ref_lbl')),
                      items: CryoEngine.refrigerants
                          .map((r) => DropdownMenuItem(value: r.id, child: Text(r.id == 'custom' ? tr('custom') : r.id)))
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
                      isExpanded: true,
                      decoration: InputDecoration(labelText: tr('brand_lbl')),
                      items: CryoEngine.allBrands
                          .map((b) => DropdownMenuItem(
                                value: b,
                                child: Text(b == 'custom' ? tr('custom') : (b == 'ALL' ? tr('all_brands') : b), overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: (v) {
                        setState(() => _brandFilter = v ?? 'ALL');
                        if (_result != null) _runCalculation();
                      },
                    ),
                  ),
                ],
              ),
              if (_refrigerant == 'custom') ...[
                const SizedBox(height: 8),
                TextField(controller: _customRefCtrl, decoration: InputDecoration(labelText: tr('custom_ref'), hintText: 'R452A')),
              ],
              if (_brandFilter == 'custom') ...[
                const SizedBox(height: 8),
                TextField(controller: _customCompModelCtrl, decoration: InputDecoration(labelText: tr('custom_comp'))),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _numInput(_customCompCapCtrl, 'Q₀ (kW)', '8.5')),
                    const SizedBox(width: 8),
                    Expanded(child: _numInput(_customCompElecCtrl, 'P_elec (kW)', '3.4')),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _voltageFilter,
                isExpanded: true,
                decoration: InputDecoration(labelText: tr('power_lbl')),
                items: [
                  const DropdownMenuItem(value: '400', child: Text('400V • 3Ph • 50Hz')),
                  const DropdownMenuItem(value: '230', child: Text('230V • 1Ph • 50Hz')),
                  const DropdownMenuItem(value: '440', child: Text('440V • 3Ph • 60Hz')),
                  DropdownMenuItem(value: 'custom', child: Text(tr('custom'))),
                ],
                onChanged: (v) {
                  setState(() => _voltageFilter = v ?? '400');
                  if (_result != null) _runCalculation();
                },
              ),
              if (_voltageFilter == 'custom') ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _numInput(_customVoltCtrl, tr('volt_lbl'), '380')),
                    const SizedBox(width: 8),
                    Expanded(child: _numInput(_customCosPhiCtrl, 'cos φ', '0.84')),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_result == null)
          _emptyBox(Icons.precision_manufacturing_rounded, tr('need_calc'))
        else ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(tr('tap_unit'), style: TextStyle(fontSize: 12, color: _textMuted)),
          ),
          ..._result!.candidates.map((sc) {
            final isSel = sc.item.id == _result!.selectedUnit.item.id;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedCompId = sc.item.id);
                _runCalculation();
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 9),
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: th.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isSel ? th.secondary : Colors.grey.withAlpha(55), width: isSel ? 2.0 : 1.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text('${sc.item.brand} • ${sc.item.model}', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900, color: _textMain))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: th.secondary.withAlpha(35), borderRadius: BorderRadius.circular(99)),
                          child: Text('${sc.coveragePct.toInt()}%', style: TextStyle(color: th.secondary, fontSize: 11, fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Q=${sc.adjustedCapKw} kW • P=${sc.item.pElecKw} kW (${sc.currentAmps} A) • Vb=${sc.item.dispM3h} m³/h • ${sc.item.tech}',
                      style: TextStyle(fontSize: 11.5, color: _textMuted),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
        const SizedBox(height: 10),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr('xref_title'), style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: _textMain)),
              const SizedBox(height: 8),
              _settingsActionBar(
                onAuto: () {
                  setState(() {
                    _xrefSourceId = _result != null ? _result!.selectedUnit.item.id : 'cp2';
                    if (!CryoEngine.compressors.any((c) => c.id == _xrefSourceId)) _xrefSourceId = 'cp2';
                  });
                  _showMsg(tr('auto_filled'));
                },
                onCustom: () => setState(() => _xrefSourceId = _xrefSourceId == 'custom' ? 'cp2' : 'custom'),
                onReset: () {
                  setState(() {
                    _xrefSourceId = 'cp2';
                    _xrefCustomRegime = 'MT';
                    _customXrefDispCtrl.clear();
                  });
                  _showMsg(tr('reset'));
                },
                customActive: _xrefSourceId == 'custom',
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _xrefSourceId,
                isExpanded: true,
                items: [
                  DropdownMenuItem(value: 'custom', child: Text('★ ${tr("custom")} (m³/h)')),
                  ...CryoEngine.compressors
                      .map((c) => DropdownMenuItem(value: c.id, child: Text('${c.brand} ${c.model} (${c.dispM3h} m³/h)', overflow: TextOverflow.ellipsis))),
                ],
                onChanged: (v) => setState(() => _xrefSourceId = v ?? 'cp2'),
              ),
              if (_xrefSourceId == 'custom') ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _customXrefDispCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(labelText: _l('الحجم الممسوح المخصص (m³/h)', 'Volume balayé (m³/h)', 'Custom Swept Vol (m³/h)'), hintText: '12.0'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _xrefCustomRegime,
                        decoration: InputDecoration(labelText: _l('النظام', 'Régime', 'Regime')),
                        items: const [
                          DropdownMenuItem(value: 'MT', child: Text('MT (+)')),
                          DropdownMenuItem(value: 'LT', child: Text('LT (-)')),
                        ],
                        onChanged: (v) => setState(() => _xrefCustomRegime = v ?? 'MT'),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              if (xrefList.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(_l('أدخل الحجم الممسوح (m³/h) لإظهار الضواغط المعادلة.', 'Saisissez le volume balayé (m³/h).', 'Enter swept volume (m³/h) to see matches.'), style: TextStyle(color: _textMuted, fontSize: 12)),
                )
              else
                ...xrefList.take(6).map((alt) => _infoTile('${alt.brand} ${alt.model}', '${alt.dispM3h} m³/h • ${alt.tech}')),
            ],
          ),
        ),
      ],
    );
  }

  /* ==================== TAB 4: SCIENTIFIC SIZING ==================== */
  Widget _buildScientificSizingTab() {
    final s = _directSizing ?? _result?.sizing;
    final el = _directElectrical ?? _result?.electrical;
    final dispT0 = _directSizing != null ? (_directT0 ?? -10.0) : (_result?.t0 ?? -10.0);
    final dispTk = _directSizing != null ? (_directTk ?? 45.0) : (_result?.tk ?? 45.0);

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_l('حساب مخصص مباشر للمكونات الـ 9', 'Calcul Direct (9 Composants)', 'Direct Component Sizing'), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: _textMain)),
              const SizedBox(height: 8),
              _settingsActionBar(
                onAuto: _autoFillDirectSizing,
                onCustom: () => setState(() => _sizingCustomOpen = !_sizingCustomOpen),
                onReset: () {
                  setState(() {
                    _dirQ0Ctrl.clear();
                    _dirT0Ctrl.clear();
                    _dirTkCtrl.clear();
                    _dirPipeCtrl.clear();
                    _dirCustomSpecCtrl.clear();
                    _sizingCustomOpen = false;
                    _directSizing = null;
                    _directElectrical = null;
                  });
                  _showMsg(tr('reset'));
                },
                customActive: _sizingCustomOpen,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _numInput(_dirQ0Ctrl, 'Q₀ (kW)', '6.5')),
                  const SizedBox(width: 8),
                  Expanded(child: _numInput(_dirT0Ctrl, 'T₀ (°C)', '-10')),
                  const SizedBox(width: 8),
                  Expanded(child: _numInput(_dirTkCtrl, 'Tk (°C)', '45')),
                ],
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _refrigerant,
                      isExpanded: true,
                      decoration: InputDecoration(labelText: tr('ref_lbl')),
                      items: CryoEngine.refrigerants
                          .map((r) => DropdownMenuItem(value: r.id, child: Text(r.id == 'custom' ? tr('custom') : r.id)))
                          .toList(),
                      onChanged: (v) => setState(() => _refrigerant = v ?? 'R404A'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: _numInput(_dirPipeCtrl, tr('pipes_m'), '10')),
                ],
              ),
              if (_sizingCustomOpen) ...[
                const SizedBox(height: 9),
                Row(
                  children: [
                    Expanded(child: _numInput(_shCtrl, tr('sh_lbl'), '7')),
                    const SizedBox(width: 8),
                    Expanded(child: _numInput(_scCtrl, tr('sc_lbl'), '5')),
                  ],
                ),
                const SizedBox(height: 9),
                TextField(
                  controller: _dirCustomSpecCtrl,
                  decoration: InputDecoration(
                    labelText: _l('تحديد مخصص لمكونات الدائرة', 'Spécification personnalisée circuit', 'Custom Circuit Specification'),
                    hintText: _l('مثال: خط سحب صاعد 6م أو ضاغط مزدوج', 'Ex: Colonne montante 6m / Bi-étagé', 'Ex: 6m riser / Two-stage'),
                  ),
                ),
              ],
              const SizedBox(height: 11),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 44,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(backgroundColor: th.primary, foregroundColor: th.isLight ? Colors.white : const Color(0xFF04101F)),
                        onPressed: () => _runDirectSizing(),
                        icon: const Icon(Icons.science_rounded, size: 19),
                        label: Text(_l('احسب المكونات الـ 9', 'Calculer 9 Composants', 'Calculate 9 Components'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () => setState(() => _tabIndex = 0),
                        child: Text(_l('من 3D', 'Via 3D', 'From 3D'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (s == null || el == null)
          _emptyBox(
            Icons.science_rounded,
            _l(
              'أدخل القيم في البطاقة أعلاه واضغط «احسب المكونات الـ 9» أو اضغط «تلقائي» لعرض كامل الحسابات العلمية هنا.',
              'Saisissez Q₀, T₀, Tk ci-dessus ou cliquez sur « Automatique » pour afficher les 9 composants.',
              'Enter Q₀, T₀, Tk above or tap "Auto" to display all 9 scientific components.',
            ),
          )
        else ...[
          Text(tr('sci_title'), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: th.primary)),
          if (_dirCustomSpecCtrl.text.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            _infoTile(_l('التحديد المخصص', 'Spécification', 'Custom Spec'), _dirCustomSpecCtrl.text.trim()),
          ],
          const SizedBox(height: 6),

          _sectionBanner(tr('sec_0')),
          _infoTile(tr('s_p0'), '${s.p0BarAbs} bar / ${s.p0BarRel} bar ($dispT0°C)'),
          _infoTile(tr('s_pk'), '${s.pkBarAbs} bar / ${s.pkBarRel} bar ($dispTk°C)'),
          _infoTile(tr('s_tau'), '${s.compressionRatio}'),
          _infoTile(tr('s_mdot'), '${s.dhEvapKjKg} kJ/kg  •  ${s.massFlowKgH} kg/h'),
          _infoTile(tr('s_vsuc'), '${s.suctionSpecVolM3Kg} m³/kg'),

          _sectionBanner(tr('sec_1')),
          _infoTile(tr('s_etav'), '${(s.volumetricEff * 100).toStringAsFixed(0)}% (${s.volumetricEff})'),
          _infoTile(tr('s_vb'), '${s.reqSweptVolM3h} m³/h'),
          _infoTile(tr('s_comp'), '${_directSizing != null ? _l("حساب مباشر مخصص", "Calcul direct", "Direct sizing") : _result!.recommendedUnit} • ${s.oilType}'),
          _infoTile(tr('s_tdis'), '${s.estDischargeTempC} °C'),

          _sectionBanner(tr('sec_2')),
          _infoTile(tr('s_evdt'), '${s.evapDeltaT1K} K  •  ${s.evapFinSpacingMm} mm'),
          _infoTile(tr('s_evarea'), '${s.evapSurfaceM2} m²'),
          _infoTile(tr('s_evair'), '${s.evapAirFlowM3h} m³/h  (${s.evapBrassageVolH} vol/h)'),
          _infoTile(tr('s_evdim'), '${_result != null && _directSizing == null ? "${_result!.evapDim} • ${_result!.airThrowM} m • " : ""}${s.defrostHeaterKw} kW'),

          _sectionBanner(tr('sec_3')),
          _infoTile(tr('s_qk'), '${s.condRejectionKw} kW'),
          _infoTile(tr('s_carea'), '${s.condSurfaceM2} m²  •  ΔTk = ${s.condDeltaTK} K'),
          _infoTile(tr('s_cair'), '${s.condAirFlowM3h} m³/h'),

          _sectionBanner(tr('sec_4')),
          _infoTile(tr('s_txvdp'), '${s.txvDeltaPBar} bar  •  Ksc = ${s.txvCorrFactorKsc} (SC ${s.txvSubcoolingK}K)'),
          _infoTile(tr('s_txvcap'), '${s.txvNominalCapKw} kW'),
          _infoTile(tr('s_txvbody'), s.txvBody),
          _infoTile(tr('s_orifice'), s.txvOrificeNumber),
          _infoTile(tr('s_mop'), s.txvMopNote),

          _sectionBanner(tr('sec_5')),
          _infoTile(tr('s_drier'), s.filterDrierModel),
          _infoTile(tr('s_sg'), s.sightGlassModel),

          _sectionBanner(tr('sec_6')),
          _infoTile(tr('s_oilmod'), '${s.oilSeparatorModel} • Ø ${s.dischargePipeInch}'),
          _infoTile(tr('s_oilvel'), '${s.dischargeVelocityMs} m/s  •  ${s.oilPreChargeL} L'),
          _infoTile(tr('s_oilreq'), s.oilSeparatorStatus),

          _sectionBanner(tr('sec_7')),
          _infoTile(tr('s_chg'), '~${s.estTotalChargeKg} kg (ρl = ${s.liquidDensityKgL} kg/L)'),
          _infoTile(tr('s_recmin'), '${s.receiverMinVolL} L'),
          _infoTile(tr('s_recstd'), s.receiverModel),

          _sectionBanner(tr('sec_8')),
          _infoTile(tr('s_aclmin'), '${s.aclMinVolL} L'),
          _infoTile(tr('s_aclstd'), s.aclModel),
          _infoTile(tr('s_aclbleed'), 'Ø ${s.aclConnInch}  •  ${s.aclBleedHoleMm}'),

          _sectionBanner(tr('sec_9')),
          _infoTile(tr('s_sol'), '${s.solenoidValve}  |  ${s.hpLpSwitch}'),
          _infoTile(tr('s_elec'), '${el.breakerRating} • ${el.contactorRating} • ${el.cableSection}'),
        ],
      ],
    );
  }

  /* ==================== TAB 5: FIELD AUDIT ==================== */
  Widget _buildAuditTab() {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr('audit_title'), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: _textMain)),
              const SizedBox(height: 8),
              _settingsActionBar(
                onAuto: _autoFillAudit,
                onCustom: () => setState(() {
                  _auditCustomOpen = !_auditCustomOpen;
                  if (_auditCustomOpen) {
                    _audSeals = 'custom';
                    _audClean = 'custom';
                  }
                }),
                onReset: _resetAll,
                customActive: _auditCustomOpen,
              ),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _numInput(_audT0Ctrl, 'T₀ (°C)', '-10')),
                const SizedBox(width: 8),
                Expanded(child: _numInput(_audTsucCtrl, tr('t_suc'), '-3')),
              ]),
              const SizedBox(height: 9),
              Row(children: [
                Expanded(child: _numInput(_audTkCtrl, 'Tk (°C)', '45')),
                const SizedBox(width: 8),
                Expanded(child: _numInput(_audTliqCtrl, tr('t_liq'), '40')),
              ]),
              const SizedBox(height: 9),
              Row(children: [
                Expanded(child: _numInput(_audTroomCtrl, tr('t_room'), '-2')),
                const SizedBox(width: 8),
                Expanded(child: _numInput(_audTdisCtrl, tr('t_dis'), '85')),
              ]),
              const SizedBox(height: 9),
              Row(children: [
                Expanded(child: _numInput(_audP0Ctrl, 'Q₀ (kW)', '8.5')),
                const SizedBox(width: 8),
                Expanded(child: _numInput(_audPelecCtrl, 'P_elec (kW)', '3.2')),
              ]),
              const SizedBox(height: 9),
              Row(children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _audSeals,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: tr('seals_lbl')),
                    items: [
                      DropdownMenuItem(value: 'good', child: Text(tr('st_good'))),
                      DropdownMenuItem(value: 'avg', child: Text(tr('st_avg'))),
                      DropdownMenuItem(value: 'bad', child: Text(tr('st_bad'))),
                      DropdownMenuItem(value: 'custom', child: Text(tr('custom'))),
                    ],
                    onChanged: (v) => setState(() => _audSeals = v ?? 'good'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _audClean,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: tr('clean_lbl')),
                    items: [
                      DropdownMenuItem(value: 'good', child: Text(tr('st_good'))),
                      DropdownMenuItem(value: 'avg', child: Text(tr('st_avg'))),
                      DropdownMenuItem(value: 'bad', child: Text(tr('st_bad'))),
                      DropdownMenuItem(value: 'custom', child: Text(tr('custom'))),
                    ],
                    onChanged: (v) => setState(() => _audClean = v ?? 'good'),
                  ),
                ),
              ]),
              if (_audSeals == 'custom' || _auditCustomOpen) ...[
                const SizedBox(height: 8),
                TextField(controller: _customAudSealCtrl, decoration: InputDecoration(labelText: '${tr("seals_lbl")} (${tr("custom")})')),
              ],
              if (_audClean == 'custom' || _auditCustomOpen) ...[
                const SizedBox(height: 8),
                TextField(controller: _customAudCleanCtrl, decoration: InputDecoration(labelText: '${tr("clean_lbl")} (${tr("custom")})')),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 46,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(backgroundColor: th.secondary, foregroundColor: const Color(0xFF04101F)),
                        onPressed: () => _runAudit(),
                        icon: const Icon(Icons.fact_check_rounded),
                        label: Text(tr('audit_btn'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(backgroundColor: th.primary, foregroundColor: th.isLight ? Colors.white : const Color(0xFF04101F)),
                        onPressed: _auditResult == null ? null : _printAuditPdf,
                        icon: const Icon(Icons.print_rounded, size: 18),
                        label: const Text('PDF', style: TextStyle(fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (_auditResult != null) ...[
          Row(children: [
            Expanded(child: _kpiCard('SH', '${_auditResult!.superheat} K', '5–10 K', th.primary)),
            const SizedBox(width: 8),
            Expanded(child: _kpiCard('SC', '${_auditResult!.subcooling} K', '4–8 K', th.accent)),
            const SizedBox(width: 8),
            Expanded(child: _kpiCard(tr('kpi_score'), '${_auditResult!.score}/100', 'COP ${_auditResult!.cop}', th.secondary)),
          ]),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _printAuditPdf,
              icon: const Icon(Icons.print_rounded),
              label: Text(tr('print_audit'), style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(height: 12),
          if (_result != null && _lastInput != null) ...[
            Room3DViewer(input: _lastInput!, result: _result!, audit: _auditResult, lang: widget.lang),
            const SizedBox(height: 12),
          ],
          _buildAlertsCard(_auditResult!.findings),
        ],
      ],
    );
  }

  /* ==================== TAB 6: REPORT ==================== */
  Widget _buildReportTab() {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr('report_title'), style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900, color: _textMain)),
              const SizedBox(height: 8),
              _settingsActionBar(
                onAuto: _autoFillReport,
                onCustom: () => setState(() => _reportCustomOpen = !_reportCustomOpen),
                onReset: _resetReportFields,
                customActive: _reportCustomOpen,
              ),
              const SizedBox(height: 10),
              TextField(controller: _clientCtrl, decoration: InputDecoration(labelText: tr('client'))),
              const SizedBox(height: 9),
              TextField(controller: _projectCtrl, decoration: InputDecoration(labelText: tr('project'))),
              const SizedBox(height: 9),
              TextField(controller: _engCtrl, decoration: InputDecoration(labelText: tr('engineer'), hintText: tr('dev_name'))),
              if (_reportCustomOpen) ...[
                const SizedBox(height: 9),
                TextField(
                  controller: _customReportLineCtrl,
                  decoration: InputDecoration(
                    labelText: _l('تحديد مخصص / ملاحظات التقرير', 'Ligne personnalisée / Remarques', 'Custom Report Line / Notes'),
                    hintText: _l('مثال: ضمان 12 شهراً أو ملاحظات التركيب', 'Ex: Garantie 12 mois / Notes', 'Ex: 12-month warranty / Notes'),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: th.secondary, foregroundColor: const Color(0xFF04101F)),
                      onPressed: _result == null ? null : _printReportPdf,
                      icon: const Icon(Icons.print_rounded),
                      label: Text(tr('print_report'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: th.primary, foregroundColor: th.isLight ? Colors.white : const Color(0xFF04101F)),
                      onPressed: _result == null ? null : _copyReportText,
                      icon: const Icon(Icons.copy_all_rounded),
                      label: Text(tr('copy_report'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (_result == null || _lastInput == null)
          _emptyBox(Icons.description_outlined, tr('need_calc'))
        else ...[
          _infoTile('${tr("kpi_q0")} / ${tr("kpi_vol")}', '${_result!.q0Kw} kW (${_result!.kcalH} kcal/h) • ${_result!.volume} m³'),
          _infoTile(tr('s_comp'), '${_result!.recommendedUnit} (Vb: ${_result!.sizing.reqSweptVolM3h} m³/h)'),
          _infoTile(tr('s_orifice'), '${_result!.sizing.txvBody} • ${_result!.sizing.txvOrificeNumber}'),
          _infoTile(tr('s_drier'), '${_result!.sizing.filterDrierModel} • ${_result!.sizing.oilSeparatorModel}'),
          _infoTile(tr('s_recstd'), '${_result!.sizing.receiverModel} • ${_result!.sizing.aclModel}'),
          _infoTile(tr('s_elec'), '${_result!.electrical.breakerRating} • ${_result!.electrical.cableSection}'),
        ],
      ],
    );
  }

  /* ==================== REUSABLE UI HELPERS ==================== */
  Widget _settingsActionBar({
    required VoidCallback onAuto,
    required VoidCallback onCustom,
    required VoidCallback onReset,
    bool customActive = false,
  }) {
    return Row(
      children: [
        _ctrlChip(Icons.auto_awesome_rounded, tr('mode_auto'), th.secondary, onAuto),
        const SizedBox(width: 6),
        _ctrlChip(Icons.tune_rounded, tr('mode_custom'), customActive ? th.primary : _textMuted, onCustom, active: customActive),
        const SizedBox(width: 6),
        _ctrlChip(Icons.restart_alt_rounded, tr('reset'), th.accent, onReset),
      ],
    );
  }

  Widget _ctrlChip(IconData icon, String label, Color col, VoidCallback onTap, {bool active = false}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
          decoration: BoxDecoration(
            color: active ? col.withAlpha(35) : th.inputBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: col.withAlpha(active ? 220 : 120)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: col),
              const SizedBox(width: 4),
              Flexible(
                child: Text(label, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10.8, fontWeight: FontWeight.w800, color: col)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: th.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: th.isLight ? Colors.black.withAlpha(20) : Colors.white.withAlpha(20)),
      ),
      child: child,
    );
  }

  Widget _sectionBanner(String title) {
    final isRtl = widget.lang == AppLang.ar;
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: th.primary.withAlpha(28),
        borderRadius: BorderRadius.circular(10),
        border: Border(
          right: isRtl ? BorderSide(color: th.primary, width: 3.5) : BorderSide.none,
          left: !isRtl ? BorderSide(color: th.primary, width: 3.5) : BorderSide.none,
        ),
      ),
      child: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: _textMain)),
    );
  }

  Widget _buildAlertsCard(List<EngineeringAlert> alerts) {
    final isRtl = widget.lang == AppLang.ar;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: alerts.map((a) {
          final col = a.level == 'bad'
              ? const Color(0xFFEF4444)
              : (a.level == 'warn' ? th.accent : th.secondary);
          return Container(
            margin: const EdgeInsets.only(bottom: 7),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: col.withAlpha(24),
              borderRadius: BorderRadius.circular(10),
              border: Border(
                right: isRtl ? BorderSide(color: col, width: 3.5) : BorderSide.none,
                left: !isRtl ? BorderSide(color: col, width: 3.5) : BorderSide.none,
              ),
            ),
            child: Text(a.text, style: TextStyle(fontSize: 12, color: _textMain, height: 1.45)),
          );
        }).toList(),
      ),
    );
  }

  Widget _emptyBox(IconData icon, String msg) {
    return _card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 22),
        child: Column(
          children: [
            Icon(icon, size: 40, color: th.primary),
            const SizedBox(height: 10),
            Text(msg, textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, color: _textMuted, height: 1.5)),
          ],
        ),
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: th.card,
        borderRadius: BorderRadius.circular(13),
        border: Border(top: BorderSide(color: accent, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 10.5, color: _textMuted)),
          const SizedBox(height: 3),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(main, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900, color: _textMain)),
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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: th.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: th.isLight ? Colors.black.withAlpha(18) : Colors.white.withAlpha(18)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(title, style: TextStyle(color: _textMuted, fontSize: 12))),
          const SizedBox(width: 8),
          Flexible(
            child: Text(value, textAlign: TextAlign.end, style: TextStyle(color: _textMain, fontWeight: FontWeight.w800, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
