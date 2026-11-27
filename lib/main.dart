import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'l10n/app_strings.dart';
import 'security/security_guard.dart';
import 'engine/cryo_engine.dart';
import 'services/pdf_printer.dart';
import 'widgets/room_3d_viewer.dart';

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
      title: 'CryoCalc Pro v5.0',
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
  final _scCtrl = TextEditingController(text: '5');
  final _shCtrl = TextEditingController(text: '7');

  final _customRoomCtrl = TextEditingController();
  final _customInsMmCtrl = TextEditingController(text: '150');
  final _customLambdaCtrl = TextEditingController(text: '0.023');
  final _customCpAboveCtrl = TextEditingController(text: '3.5');
  final _customCpBelowCtrl = TextEditingController(text: '1.8');
  final _customLatentCtrl = TextEditingController(text: '240');
  final _customAirChgCtrl = TextEditingController(text: '8');
  final _customArchCtrl = TextEditingController();
  final _customDefrostKwCtrl = TextEditingController(text: '3.0');
  final _customRefCtrl = TextEditingController(text: 'R452A');
  final _customCompModelCtrl = TextEditingController();
  final _customCompCapCtrl = TextEditingController();
  final _customCompElecCtrl = TextEditingController();
  final _customVoltCtrl = TextEditingController(text: '400');
  final _customCosPhiCtrl = TextEditingController(text: '0.84');
  final _customPanelWCtrl = TextEditingController(text: '1.10');
  final _customAudSealCtrl = TextEditingController();
  final _customAudCleanCtrl = TextEditingController();

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

  CryoInput? _lastInput;
  CryoResult? _result;

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

  final _clientCtrl = TextEditingController();
  final _projectCtrl = TextEditingController();
  final _engCtrl = TextEditingController(text: CryoOwner.developerAr);

  String tr(String key) => AppStrings.t(widget.lang, key);
  AppThemePreset get th => widget.themePreset;
  Color get _textMuted => th.isLight ? const Color(0xFF475569) : const Color(0xFF94A3B8);
  Color get _textMain => th.isLight ? const Color(0xFF0F172A) : Colors.white;

  @override
  void didUpdateWidget(covariant CryoHomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lang != widget.lang) {
      // Translate developer default name if untouched
      final defaults = [
        AppStrings.t(AppLang.ar, 'dev_name'),
        AppStrings.t(AppLang.fr, 'dev_name'),
        AppStrings.t(AppLang.en, 'dev_name'),
      ];
      if (defaults.contains(_engCtrl.text.trim())) {
        _engCtrl.text = tr('dev_name');
      }
      // Refresh localized alerts & findings immediately
      if (_lastInput != null) {
        _result = CryoEngine.calculate(_lastInput!, forcedCompId: _selectedCompId, lang: widget.lang.name);
      }
      if (_auditResult != null) {
        _runAudit(silent: true);
      }
    }
  }

  @override
  void dispose() {
    for (final c in [
      _lenCtrl, _widCtrl, _heiCtrl, _tInCtrl, _tAmbCtrl, _tFloorCtrl, _opHoursCtrl,
      _kgCtrl, _tProdCtrl, _pipeCtrl, _scCtrl, _shCtrl, _customRoomCtrl,
      _customInsMmCtrl, _customLambdaCtrl, _customCpAboveCtrl, _customCpBelowCtrl,
      _customLatentCtrl, _customAirChgCtrl, _customArchCtrl, _customDefrostKwCtrl,
      _customRefCtrl, _customCompModelCtrl, _customCompCapCtrl, _customCompElecCtrl,
      _customVoltCtrl, _customCosPhiCtrl, _customPanelWCtrl, _customAudSealCtrl,
      _customAudCleanCtrl, _audT0Ctrl, _audTsucCtrl, _audTkCtrl, _audTliqCtrl,
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

    setState(() {
      _lastInput = inp;
      _result = CryoEngine.calculate(inp, forcedCompId: _selectedCompId, lang: widget.lang.name);
    });
  }

  void _resetAll() {
    HapticFeedback.lightImpact();
    setState(() {
      for (final c in [
        _lenCtrl, _widCtrl, _heiCtrl, _tInCtrl, _tAmbCtrl, _tFloorCtrl,
        _opHoursCtrl, _kgCtrl, _tProdCtrl, _pipeCtrl, _audT0Ctrl,
        _audTsucCtrl, _audTkCtrl, _audTliqCtrl, _audTroomCtrl,
        _audTdisCtrl, _audP0Ctrl, _audPelecCtrl,
      ]) {
        c.clear();
      }
      _selectedCompId = null;
      _lastInput = null;
      _result = null;
      _auditResult = null;
    });
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
    try {
      await PdfPrinterService.printEngineeringReport(
        lang: widget.lang,
        input: _lastInput!,
        result: _result!,
        client: _clientCtrl.text.trim(),
        project: _projectCtrl.text.trim(),
        engineer: _engCtrl.text.trim(),
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
        engineer: _engCtrl.text.trim(),
      );
    } catch (e) {
      _showMsg('PDF: $e');
    }
  }

  Future<void> _copyReportText() async {
    if (_result == null || _lastInput == null) return;
    final r = _result!;
    final s = r.sizing;
    final txt = '''
=== CryoCalc PRO ${CryoOwner.appVersion} ===
${tr("engineer")}: ${_engCtrl.text} | ${CryoOwner.groupCode}
${tr("kpi_q0")}: ${r.q0Kw} kW (${r.kcalH} kcal/h) | ${tr("kpi_vol")}: ${r.volume} m3
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
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [th.primary, th.secondary]),
                borderRadius: BorderRadius.circular(9),
              ),
              alignment: Alignment.center,
              child: const Text('CC', style: TextStyle(color: Color(0xFF04101F), fontWeight: FontWeight.w900, fontSize: 12)),
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
            // Quick Language Badge Button
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

  Widget _buildThermalAnd3DTab() {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(tr('room_params'), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _textMain))),
                  TextButton.icon(
                    onPressed: _resetAll,
                    icon: Icon(Icons.restart_alt_rounded, size: 17, color: th.accent),
                    label: Text(tr('reset'), style: TextStyle(color: th.accent, fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
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
              if (_expertMode) ...[
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

  Widget _buildPanelsTab() {
    if (_result == null || _lastInput == null) {
      return ListView(padding: const EdgeInsets.all(14), children: [_emptyBox(Icons.grid_view_rounded, tr('need_calc'))]);
    }
    final r = _result!;
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        _card(
          child: Column(
            children: [
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
                _numInput(_customPanelWCtrl, tr('custom_pw'), '1.10'),
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

  Widget _buildUnitsTab() {
    final xrefList = CryoEngine.findCrossReference(_xrefSourceId);
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        _card(
          child: Column(
            children: [
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
                TextField(controller: _customRefCtrl, decoration: InputDecoration(labelText: tr('custom_ref'))),
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
              Text(tr('xref_title'), style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: _textMain)),
              const SizedBox(height: 9),
              DropdownButtonFormField<String>(
                value: _xrefSourceId,
                isExpanded: true,
                items: CryoEngine.compressors
                    .map((c) => DropdownMenuItem(value: c.id, child: Text('${c.brand} ${c.model} (${c.dispM3h} m³/h)', overflow: TextOverflow.ellipsis)))
                    .toList(),
                onChanged: (v) => setState(() => _xrefSourceId = v ?? 'cp2'),
              ),
              const SizedBox(height: 8),
              ...xrefList.take(5).map((alt) => _infoTile('${alt.brand} ${alt.model}', '${alt.dispM3h} m³/h • ${alt.tech}')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScientificSizingTab() {
    if (_result == null || _lastInput == null) {
      return ListView(padding: const EdgeInsets.all(14), children: [_emptyBox(Icons.science_rounded, tr('need_calc'))]);
    }
    final r = _result!;
    final s = r.sizing;
    final el = r.electrical;

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Text(tr('sci_title'), style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900, color: th.primary)),
        const SizedBox(height: 10),

        _sectionBanner(tr('sec_0')),
        _infoTile(tr('s_p0'), '${s.p0BarAbs} bar / ${s.p0BarRel} bar (${r.t0}°C)'),
        _infoTile(tr('s_pk'), '${s.pkBarAbs} bar / ${s.pkBarRel} bar (${r.tk}°C)'),
        _infoTile(tr('s_tau'), '${s.compressionRatio}'),
        _infoTile(tr('s_mdot'), '${s.dhEvapKjKg} kJ/kg  •  ${s.massFlowKgH} kg/h'),
        _infoTile(tr('s_vsuc'), '${s.suctionSpecVolM3Kg} m³/kg'),

        _sectionBanner(tr('sec_1')),
        _infoTile(tr('s_etav'), '${(s.volumetricEff * 100).toStringAsFixed(0)}% (${s.volumetricEff})'),
        _infoTile(tr('s_vb'), '${s.reqSweptVolM3h} m³/h'),
        _infoTile(tr('s_comp'), '${r.recommendedUnit} • ${s.oilType}'),
        _infoTile(tr('s_tdis'), '${s.estDischargeTempC} °C'),

        _sectionBanner(tr('sec_2')),
        _infoTile(tr('s_evdt'), '${s.evapDeltaT1K} K  •  ${s.evapFinSpacingMm} mm'),
        _infoTile(tr('s_evarea'), '${s.evapSurfaceM2} m²'),
        _infoTile(tr('s_evair'), '${s.evapAirFlowM3h} m³/h  (${s.evapBrassageVolH} vol/h)'),
        _infoTile(tr('s_evdim'), '${r.evapDim} • ${r.airThrowM} m • ${s.defrostHeaterKw} kW'),

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
    );
  }

  Widget _buildAuditTab() {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(tr('audit_title'), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _textMain))),
                  TextButton.icon(
                    onPressed: _resetAll,
                    icon: Icon(Icons.restart_alt_rounded, size: 17, color: th.accent),
                    label: Text(tr('reset'), style: TextStyle(color: th.accent, fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
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
              if (_audSeals == 'custom') ...[
                const SizedBox(height: 8),
                TextField(controller: _customAudSealCtrl, decoration: InputDecoration(labelText: tr('custom_note'))),
              ],
              if (_audClean == 'custom') ...[
                const SizedBox(height: 8),
                TextField(controller: _customAudCleanCtrl, decoration: InputDecoration(labelText: tr('custom_note'))),
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

  Widget _buildReportTab() {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr('report_title'), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _textMain)),
              const SizedBox(height: 10),
              TextField(controller: _clientCtrl, decoration: InputDecoration(labelText: tr('client'))),
              const SizedBox(height: 9),
              TextField(controller: _projectCtrl, decoration: InputDecoration(labelText: tr('project'))),
              const SizedBox(height: 9),
              TextField(controller: _engCtrl, decoration: InputDecoration(labelText: tr('engineer'))),
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
