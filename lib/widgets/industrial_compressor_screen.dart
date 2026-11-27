import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../engine/industrial_compressor_engine.dart';
import '../l10n/app_strings.dart';
import '../security/security_guard.dart';

class IndustrialCompressorScreen extends StatefulWidget {
  final AppLang lang;
  final AppThemePreset themePreset;
  final double? initialQ0Kw;
  final double? initialT0;
  final double? initialTk;
  final String? initialRef;

  const IndustrialCompressorScreen({
    super.key,
    required this.lang,
    required this.themePreset,
    this.initialQ0Kw,
    this.initialT0,
    this.initialTk,
    this.initialRef,
  });

  @override
  State<IndustrialCompressorScreen> createState() => _IndustrialCompressorScreenState();
}

class _IndustrialCompressorScreenState extends State<IndustrialCompressorScreen> {
  String _inputMode = 'kw'; // kw | hp | vb
  String _refrigerant = 'R404A';
  String _brandFilter = 'ALL';
  String _techFilter = 'ALL';
  String? _selectedCompId;

  final _valCtrl = TextEditingController(text: '25');
  final _t0Ctrl = TextEditingController(text: '-10');
  final _tkCtrl = TextEditingController(text: '45');
  final _shCtrl = TextEditingController(text: '7');
  final _scCtrl = TextEditingController(text: '5');
  final _pipeCtrl = TextEditingController(text: '15');
  final _voltCtrl = TextEditingController(text: '400');
  final _customRefCtrl = TextEditingController(text: 'R452A');
  final _customNoteCtrl = TextEditingController();

  IndustrialCalcResult? _res;

  AppThemePreset get th => widget.themePreset;
  Color get _textMain => th.isLight ? const Color(0xFF0F172A) : Colors.white;
  Color get _textMuted => th.isLight ? const Color(0xFF475569) : const Color(0xFF94A3B8);

  String _l(String ar, String fr, String en) {
    if (widget.lang == AppLang.fr) return fr;
    if (widget.lang == AppLang.en) return en;
    return ar;
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialQ0Kw != null && widget.initialQ0Kw! > 0) {
      _valCtrl.text = widget.initialQ0Kw!.toStringAsFixed(1);
    }
    if (widget.initialT0 != null) _t0Ctrl.text = widget.initialT0!.toStringAsFixed(1);
    if (widget.initialTk != null) _tkCtrl.text = widget.initialTk!.toStringAsFixed(1);
    if (widget.initialRef != null && IndustrialCompressorEngine.refrigerants.any((r) => r.id == widget.initialRef)) {
      _refrigerant = widget.initialRef!;
    }
    _calculate();
  }

  @override
  void dispose() {
    for (final c in [_valCtrl, _t0Ctrl, _tkCtrl, _shCtrl, _scCtrl, _pipeCtrl, _voltCtrl, _customRefCtrl, _customNoteCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  void _msg(String s) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s), backgroundColor: th.card));
  }

  void _calculate() {
    final val = double.tryParse(_valCtrl.text.trim());
    final t0 = double.tryParse(_t0Ctrl.text.trim());
    final tk = double.tryParse(_tkCtrl.text.trim());
    if (val == null || val <= 0 || t0 == null || tk == null) {
      _msg(_l('أدخل القيمة ودرجتي التبخير والتكثيف بشكل صحيح.', 'Veuillez saisir des valeurs valides.', 'Please enter valid numbers.'));
      return;
    }
    HapticFeedback.mediumImpact();
    final inp = IndustrialCalcInput(
      inputMode: _inputMode,
      targetValue: val,
      t0: t0,
      tk: tk,
      shK: double.tryParse(_shCtrl.text.trim()) ?? 7.0,
      scK: double.tryParse(_scCtrl.text.trim()) ?? 5.0,
      pipeLenM: double.tryParse(_pipeCtrl.text.trim()) ?? 15.0,
      refrigerant: _refrigerant,
      customRefName: _customRefCtrl.text.trim(),
      brandFilter: _brandFilter,
      techFilter: _techFilter,
      voltage: double.tryParse(_voltCtrl.text.trim()) ?? 400.0,
      customNote: _customNoteCtrl.text.trim(),
    );
    setState(() {
      _res = IndustrialCompressorEngine.calculate(inp, forcedId: _selectedCompId, lang: widget.lang.name);
    });
  }

  void _reset() {
    HapticFeedback.lightImpact();
    setState(() {
      _inputMode = 'kw';
      _refrigerant = 'R404A';
      _brandFilter = 'ALL';
      _techFilter = 'ALL';
      _selectedCompId = null;
      _valCtrl.text = '25';
      _t0Ctrl.text = '-10';
      _tkCtrl.text = '45';
      _shCtrl.text = '7';
      _scCtrl.text = '5';
      _pipeCtrl.text = '15';
      _voltCtrl.text = '400';
      _customNoteCtrl.clear();
    });
    _calculate();
    _msg(_l('تمت إعادة التعيين', 'Réinitialisé', 'Reset complete'));
  }

  Future<void> _copySummary() async {
    if (_res == null) return;
    final r = _res!;
    final sb = StringBuffer()
      ..writeln('=== CryoCalc PRO ${CryoOwner.appVersion} — Industrial Compressor & Group ===')
      ..writeln('${_l("الضاغط المختار", "Compresseur", "Selected")}: ${r.selected.item.brand} ${r.selected.item.model} (${r.selected.item.hp} HP)')
      ..writeln('Q0=${r.q0Kw} kW (${r.kcalH} kcal/h) | Vb req=${r.reqVbM3h} m3/h | tau=${r.tau} | T_dis=${r.tDisC} C');
    if (_customNoteCtrl.text.trim().isNotEmpty) {
      sb.writeln('Note: ${_customNoteCtrl.text.trim()}');
    }
    sb.writeln('\n--- 16 Industrial Group Components ---');
    for (final p in r.groupParts) {
      sb.writeln('${p.index}. ${p.title}: ${p.spec} (${p.details})');
    }
    await Clipboard.setData(ClipboardData(text: sb.toString()));
    _msg(_l('تم نسخ دراسة الضاغط وقطع المجموعة', 'Étude copiée', 'Study copied'));
  }

  Future<void> _printPdf() async {
    if (_res == null) return;
    final r = _res!;
    pw.ThemeData? pdfTheme;
    try {
      final reg = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
      final bold = await rootBundle.load('assets/fonts/Cairo-Bold.ttf');
      pdfTheme = pw.ThemeData.withFont(base: pw.Font.ttf(reg), bold: pw.Font.ttf(bold));
    } catch (_) {}

    final isAr = widget.lang == AppLang.ar && pdfTheme != null;
    final doc = pw.Document(theme: pdfTheme);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(22),
        textDirection: isAr ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        build: (_) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF070D19),
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  isAr ? 'دراسة الضاغط الصناعي وقطع المجموعة — CryoCalc PRO' : 'CryoCalc PRO — Industrial Compressor & Group Sizing',
                  style: pw.TextStyle(color: const PdfColor.fromInt(0xFF38BDF8), fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  '${isAr ? CryoOwner.developerAr : CryoOwner.developerEn} | ${CryoOwner.groupCode} | ${r.selected.item.brand} ${r.selected.item.model} (${r.selected.item.hp} HP)',
                  style: const pw.TextStyle(color: PdfColors.white, fontSize: 9.5),
                ),
                if (_customNoteCtrl.text.trim().isNotEmpty)
                  pw.Text(_customNoteCtrl.text.trim(), style: const pw.TextStyle(color: PdfColors.grey300, fontSize: 8.5)),
              ],
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.6),
            children: [
              _pdfRow('Q0 / kcal/h / HP', '${r.q0Kw} kW  |  ${r.kcalH} kcal/h  |  ~${r.estHp} HP'),
              _pdfRow('P0 / Pk / tau', '${r.p0Abs} bar (${r.p0Rel} rel)  |  ${r.pkAbs} bar (${r.pkRel} rel)  |  tau = ${r.tau}'),
              _pdfRow('Mass Flow / Vb req / eta_v', '${r.massFlowKgH} kg/h  |  Vb = ${r.reqVbM3h} m3/h  |  eta_v = ${(r.etaV * 100).toInt()}%'),
              _pdfRow('P_elec / COP / Qk / T_dis', '${r.pElecEstKw} kW  |  COP ${r.cop}  |  Qk ${r.qCondKw} kW  |  T_dis ${r.tDisC} C'),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            isAr ? 'قائمة القطع الخاصة بالمجموعة الصناعية (16 قطعة)' : 'Industrial Condensing Group Parts List (16 Components)',
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(1.2),
              1: const pw.FlexColumnWidth(1.8),
            },
            children: r.groupParts
                .map((p) => _pdfRow('${p.index}. ${p.title}', '${p.spec}\n${p.details}'))
                .toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (_) async => doc.save(), name: 'CryoCalcPro_Industrial_Group.pdf');
  }

  pw.TableRow _pdfRow(String k, String v) {
    return pw.TableRow(children: [
      pw.Container(
        color: PdfColors.grey100,
        padding: const pw.EdgeInsets.all(5),
        child: pw.Text(k, style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
      ),
      pw.Container(
        padding: const pw.EdgeInsets.all(5),
        child: pw.Text(v, style: const pw.TextStyle(fontSize: 8.5)),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final r = _res;
    return Scaffold(
      backgroundColor: th.bg,
      appBar: AppBar(
        backgroundColor: th.appBar,
        elevation: 0,
        title: Text(
          _l('حاسبة الضاغط الصناعي وقطع المجموعة', 'Compresseur Industriel & Accessoires', 'Industrial Compressor & Group'),
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: _textMain),
        ),
        actions: [
          IconButton(onPressed: _copySummary, icon: Icon(Icons.copy_all_rounded, color: th.primary)),
          IconButton(onPressed: _printPdf, icon: Icon(Icons.print_rounded, color: th.secondary)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // 1. INPUT PARAMETERS CARD
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _l('معطيات حساب الضاغط الصناعي (3–150 HP)', 'Paramètres Compresseur (3–150 HP)', 'Industrial Compressor Inputs (3–150 HP)'),
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: _textMain),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _reset,
                      icon: Icon(Icons.restart_alt_rounded, size: 17, color: th.accent),
                      label: Text(_l('إعادة تعيين', 'Réinit.', 'Reset'), style: TextStyle(color: th.accent, fontWeight: FontWeight.w800, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Input Mode Selector: Q0 (kW) | Power (HP) | Swept Volume (m3/h)
                Row(
                  children: [
                    _modePill('kw', _l('حسب kW', 'Par kW', 'By kW')),
                    const SizedBox(width: 6),
                    _modePill('hp', _l('حسب الحصان HP', 'Par CV / HP', 'By HP')),
                    const SizedBox(width: 6),
                    _modePill('vb', _l('حسب m³/h', 'Par m³/h', 'By m³/h')),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _numField(
                        _valCtrl,
                        _inputMode == 'kw'
                            ? _l('الاستطاعة Q₀ (kW)', 'Puissance Q₀ (kW)', 'Capacity Q₀ (kW)')
                            : (_inputMode == 'hp' ? _l('القدرة (HP)', 'Puissance (HP)', 'Power (HP)') : 'Vb (m³/h)'),
                        '25',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: _numField(_t0Ctrl, 'T₀ (°C)', '-10')),
                    const SizedBox(width: 8),
                    Expanded(child: _numField(_tkCtrl, 'Tk (°C)', '45')),
                  ],
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _refrigerant,
                        isExpanded: true,
                        decoration: InputDecoration(labelText: _l('وسيط التبريد', 'Fluide', 'Refrigerant')),
                        items: IndustrialCompressorEngine.refrigerants
                            .map((rf) => DropdownMenuItem(value: rf.id, child: Text(rf.name, overflow: TextOverflow.ellipsis)))
                            .toList(),
                        onChanged: (v) {
                          setState(() => _refrigerant = v ?? 'R404A');
                          _calculate();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _techFilter,
                        isExpanded: true,
                        decoration: InputDecoration(labelText: _l('نوع الضاغط', 'Technologie', 'Technology')),
                        items: IndustrialCompressorEngine.techs
                            .map((t) => DropdownMenuItem(
                                  value: t,
                                  child: Text(t == 'ALL' ? _l('الكل (مكبسي/حلزوني)', 'Tous types', 'All Types') : t, overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (v) {
                          setState(() {
                            _techFilter = v ?? 'ALL';
                            _selectedCompId = null;
                          });
                          _calculate();
                        },
                      ),
                    ),
                  ],
                ),
                if (_refrigerant == 'custom') ...[
                  const SizedBox(height: 8),
                  TextField(controller: _customRefCtrl, decoration: InputDecoration(labelText: _l('وسيط مخصص', 'Fluide personnalisé', 'Custom Refrigerant'))),
                ],
                const SizedBox(height: 9),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _brandFilter,
                        isExpanded: true,
                        decoration: InputDecoration(labelText: _l('الماركة الصناعية', 'Marque', 'Brand')),
                        items: IndustrialCompressorEngine.brands
                            .map((b) => DropdownMenuItem(
                                  value: b,
                                  child: Text(b == 'ALL' ? _l('كل الماركات (7)', 'Toutes (7)', 'All Brands (7)') : b, overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (v) {
                          setState(() {
                            _brandFilter = v ?? 'ALL';
                            _selectedCompId = null;
                          });
                          _calculate();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: _numField(_pipeCtrl, _l('النحاس (m)', 'Tuyaux (m)', 'Pipes (m)'), '15')),
                    const SizedBox(width: 8),
                    Expanded(child: _numField(_voltCtrl, 'Volt (V)', '400')),
                  ],
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    Expanded(child: _numField(_shCtrl, 'SH (K)', '7')),
                    const SizedBox(width: 8),
                    Expanded(child: _numField(_scCtrl, 'SC (K)', '5')),
                  ],
                ),
                const SizedBox(height: 9),
                TextField(
                  controller: _customNoteCtrl,
                  decoration: InputDecoration(
                    labelText: _l('تحديد مخصص للمجموعة الصناعية', 'Spécification personnalisée', 'Custom Industrial Specification'),
                    hintText: _l('مثال: نفق تجميد 10 طن أو غرفة تبريد مركزي', 'Ex: Tunnel 10T / Centrale', 'Ex: 10T Blast Tunnel / Rack'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: th.primary,
                      foregroundColor: th.isLight ? Colors.white : const Color(0xFF04101F),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _calculate,
                    icon: const Icon(Icons.calculate_rounded),
                    label: Text(
                      _l('احسب الضاغط وقطع المجموعة الصناعية', 'Calculer Compresseur & Pièces', 'Calculate Compressor & Group Parts'),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (r != null) ...[
            const SizedBox(height: 12),
            // 2. THERMODYNAMIC KPI ROW
            Row(
              children: [
                Expanded(child: _kpi('Q₀ / HP', '${r.q0Kw} kW', '~${r.estHp} HP', th.secondary)),
                const SizedBox(width: 8),
                Expanded(child: _kpi('Vb req', '${r.reqVbM3h} m³/h', 'ηv ${(r.etaV * 100).toInt()}%', th.primary)),
                const SizedBox(width: 8),
                Expanded(child: _kpi('τ / T_dis', 'τ ${r.tau}', '${r.tDisC}°C', th.accent)),
              ],
            ),
            const SizedBox(height: 10),
            _infoTile(_l('الضغوط (P₀ / Pk)', 'Pressions (P₀ / Pk)', 'Pressures (P₀ / Pk)'), '${r.p0Rel} bar  /  ${r.pkRel} bar (rel)'),
            _infoTile(_l('التدفق الكتلي / القدرة / COP', 'Débit / P_elec / COP', 'Mass Flow / Power / COP'), '${r.massFlowKgH} kg/h • ${r.pElecEstKw} kW • COP ${r.cop}'),

            // Warnings
            if (r.warnings.isNotEmpty) ...[
              const SizedBox(height: 6),
              ...r.warnings.map((w) => Container(
                    margin: const EdgeInsets.only(bottom: 7),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: th.accent.withAlpha(28),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: th.accent.withAlpha(120)),
                    ),
                    child: Text('⚠ $w', style: TextStyle(fontSize: 12, color: _textMain, height: 1.4)),
                  )),
            ],

            // 3. MATCHED INDUSTRIAL COMPRESSORS (ALL POWERS)
            _banner(_l('الضواغط الصناعية المناسبة (اضغط لاختيار واحد وتحديث القطع)', 'Compresseurs Industriels Adaptés (Touchez pour choisir)', 'Matched Industrial Compressors (Tap to select)')),
            ...r.matches.map((sc) {
              final sel = sc.item.id == r.selected.item.id;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedCompId = sc.item.id);
                  _calculate();
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: th.card,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: sel ? th.secondary : Colors.grey.withAlpha(55), width: sel ? 2.0 : 1.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${sc.item.brand} ${sc.item.model}',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: _textMain),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: th.primary.withAlpha(32), borderRadius: BorderRadius.circular(99)),
                            child: Text('${sc.item.hp} HP', style: TextStyle(color: th.primary, fontWeight: FontWeight.w900, fontSize: 11)),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: th.secondary.withAlpha(32), borderRadius: BorderRadius.circular(99)),
                            child: Text('${sc.coveragePct.toInt()}%', style: TextStyle(color: th.secondary, fontWeight: FontWeight.w900, fontSize: 11)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Q=${sc.adjustedCapKw} kW • Vb=${sc.item.dispM3h} m³/h • ${sc.item.tech} (${sc.item.regime}) • ${sc.amps400V} A • ${sc.item.starterType}',
                        style: TextStyle(fontSize: 11.2, color: _textMuted),
                      ),
                    ],
                  ),
                ),
              );
            }),

            // 4. COMPLETE 16 INDUSTRIAL GROUP PARTS LIST
            _banner(_l('القطع الـ 16 الخاصة بالمجموعة الصناعية (${r.selected.item.brand} ${r.selected.item.model})', '16 Pièces du Groupe Industriel (${r.selected.item.model})', '16 Industrial Condensing Group Parts (${r.selected.item.model})')),
            ...r.groupParts.map((part) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: th.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: (part.mandatory ? th.primary : Colors.grey).withAlpha(55)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: th.primary.withAlpha(35), shape: BoxShape.circle),
                            child: Text('${part.index}', style: TextStyle(color: th.primary, fontWeight: FontWeight.w900, fontSize: 11)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(part.title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: _textMain))),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(part.spec, style: TextStyle(fontSize: 12.2, fontWeight: FontWeight.w800, color: th.secondary)),
                      ),
                      const SizedBox(height: 3),
                      Text(part.details, style: TextStyle(fontSize: 11.2, color: _textMuted, height: 1.4)),
                    ],
                  ),
                )),

            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: th.secondary, foregroundColor: const Color(0xFF04101F)),
                    onPressed: _printPdf,
                    icon: const Icon(Icons.print_rounded),
                    label: Text(_l('طباعة PDF', 'Imprimer PDF', 'Print PDF'), style: const TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _copySummary,
                    icon: const Icon(Icons.copy_all_rounded),
                    label: Text(_l('نسخ الدراسة', 'Copier', 'Copy'), style: const TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _modePill(String id, String label) {
    final active = _inputMode == id;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => _inputMode = id);
          _calculate();
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? th.primary : th.inputBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: active ? th.primary : Colors.grey.withAlpha(65)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
              color: active ? (th.isLight ? Colors.white : const Color(0xFF04101F)) : _textMain,
            ),
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: th.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: th.isLight ? Colors.black.withAlpha(20) : Colors.white.withAlpha(20)),
        ),
        child: child,
      );

  Widget _banner(String title) => Container(
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        decoration: BoxDecoration(
          color: th.primary.withAlpha(28),
          borderRadius: BorderRadius.circular(10),
          border: Border(
            right: widget.lang == AppLang.ar ? BorderSide(color: th.primary, width: 3.5) : BorderSide.none,
            left: widget.lang != AppLang.ar ? BorderSide(color: th.primary, width: 3.5) : BorderSide.none,
          ),
        ),
        child: Text(title, style: TextStyle(fontSize: 12.8, fontWeight: FontWeight.w900, color: _textMain)),
      );

  Widget _numField(TextEditingController ctrl, String label, String hint) => TextField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
        decoration: InputDecoration(labelText: label, hintText: hint),
      );

  Widget _kpi(String title, String main, String sub, Color accent) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: th.card,
          borderRadius: BorderRadius.circular(12),
          border: Border(top: BorderSide(color: accent, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 10.5, color: _textMuted)),
            const SizedBox(height: 3),
            Directionality(textDirection: TextDirection.ltr, child: Text(main, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: _textMain))),
            Directionality(textDirection: TextDirection.ltr, child: Text(sub, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: accent))),
          ],
        ),
      );

  Widget _infoTile(String k, String v) => Container(
        margin: const EdgeInsets.only(bottom: 7),
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: th.card,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: Colors.grey.withAlpha(35)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(k, style: TextStyle(fontSize: 11.8, color: _textMuted))),
            const SizedBox(width: 8),
            Directionality(textDirection: TextDirection.ltr, child: Text(v, style: TextStyle(fontSize: 11.8, fontWeight: FontWeight.w800, color: _textMain))),
          ],
        ),
      );
}
