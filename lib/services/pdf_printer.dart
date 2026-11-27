import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../engine/cryo_engine.dart';
import '../engine/industrial_compressor_engine.dart';
import '../l10n/app_strings.dart';
import '../security/security_guard.dart';

class PdfPrinterService {
  static String _p(AppLang lang, String ar, String fr, String en) {
    if (lang == AppLang.fr) return fr;
    if (lang == AppLang.en) return en;
    return ar;
  }

  /// Cleans special Unicode symbols that cause crossed boxes (tofu) in PDF fonts.
  static String clean(String input) {
    return input
        .replaceAll('—', '-')
        .replaceAll('–', '-')
        .replaceAll('•', '|')
        .replaceAll('Δ', 'd')
        .replaceAll('τ', 'tau')
        .replaceAll('η', 'eta')
        .replaceAll('ṁ', 'm')
        .replaceAll('ρ', 'rho')
        .replaceAll('λ', 'lambda')
        .replaceAll('Ø', 'Dia ')
        .replaceAll('≥', '>=')
        .replaceAll('≤', '<=')
        .replaceAll('≈', '~')
        .replaceAll('×', 'x')
        .replaceAll('°', ' ')
        .replaceAll('²', '2')
        .replaceAll('³', '3')
        .replaceAll('₀', '0')
        .replaceAll('₁', '1')
        .replaceAll('₂', '2')
        .replaceAll('✓', '[OK]')
        .replaceAll('⚠', '[!]')
        .replaceAll('★', '*')
        .replaceAll('É', 'E')
        .replaceAll('é', 'e');
  }

  static Future<pw.ThemeData?> _loadTheme() async {
    final pairs = [
      ['assets/fonts/Arabic-Regular.ttf', 'assets/fonts/Arabic-Bold.ttf'],
      ['assets/fonts/Cairo-Regular.ttf', 'assets/fonts/Cairo-Bold.ttf'],
    ];
    for (final pair in pairs) {
      try {
        final regData = await rootBundle.load(pair[0]);
        final boldData = await rootBundle.load(pair[1]);
        if (regData.lengthInBytes > 25000 && boldData.lengthInBytes > 25000) {
          final reg = pw.Font.ttf(regData);
          final bold = pw.Font.ttf(boldData);
          return pw.ThemeData.withFont(
            base: reg,
            bold: bold,
            fontFallback: [reg, bold],
          );
        }
      } catch (_) {}
    }
    return null;
  }

  static pw.Widget _sectionHeader(String title, bool isAr) {
    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(top: 10, bottom: 5),
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: const pw.BoxDecoration(
        color: PdfColor.fromInt(0xFF0F2547),
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Text(
        clean(title),
        textAlign: isAr ? pw.TextAlign.right : pw.TextAlign.left,
        style: pw.TextStyle(color: PdfColors.white, fontSize: 10.5, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.Widget _kvTable(List<List<String>> rows, bool isAr) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.6),
      columnWidths: isAr
          ? {
              0: const pw.FlexColumnWidth(1.7),
              1: const pw.FlexColumnWidth(1.3),
            }
          : {
              0: const pw.FlexColumnWidth(1.3),
              1: const pw.FlexColumnWidth(1.7),
            },
      children: rows.map((r) {
        final keyCell = pw.Container(
          color: PdfColors.grey100,
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
            clean(r[0]),
            textAlign: isAr ? pw.TextAlign.right : pw.TextAlign.left,
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
        );
        final valCell = pw.Container(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
            clean(r[1]),
            textAlign: isAr ? pw.TextAlign.right : pw.TextAlign.left,
            style: const pw.TextStyle(fontSize: 9),
          ),
        );
        return pw.TableRow(children: isAr ? [valCell, keyCell] : [keyCell, valCell]);
      }).toList(),
    );
  }

  /* ==================== 1. ENGINEERING REPORT PDF ==================== */
  static Future<void> printEngineeringReport({
    required AppLang lang,
    required CryoInput input,
    required CryoResult result,
    required String client,
    required String project,
    required String engineer,
  }) async {
    final theme = await _loadTheme();
    final isAr = lang == AppLang.ar;
    final s = result.sizing;
    final el = result.electrical;
    final refName = input.refrigerant == 'custom' && input.customRefName.isNotEmpty
        ? input.customRefName
        : input.refrigerant;

    final doc = pw.Document(theme: theme);
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(22),
        textDirection: isAr ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        build: (ctx) => [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(13),
            decoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF070D19),
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: isAr ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  clean(_p(
                    lang,
                    'التقرير الهندسي الرسمي - CryoCalc PRO ${CryoOwner.appVersion}',
                    'Rapport d\'Ingenierie Officiel - CryoCalc PRO ${CryoOwner.appVersion}',
                    'Official Engineering Report - CryoCalc PRO ${CryoOwner.appVersion}',
                  )),
                  style: pw.TextStyle(color: const PdfColor.fromInt(0xFF38BDF8), fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  clean('${_p(lang, CryoOwner.developerAr, "Ing. Ahmed Zinnour", CryoOwner.developerEn)}  |  ${CryoOwner.groupCode}'),
                  style: const pw.TextStyle(color: PdfColors.white, fontSize: 9.5),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  clean(_p(
                    lang,
                    'الزبون: ${client.isEmpty ? "-" : client}  |  المشروع: ${project.isEmpty ? "دراسة غرفة تبريد" : project}  |  المهندس: $engineer',
                    'Client: ${client.isEmpty ? "-" : client}  |  Projet: ${project.isEmpty ? "Etude chambre froide" : project}  |  Ingenieur: $engineer',
                    'Client: ${client.isEmpty ? "-" : client}  |  Project: ${project.isEmpty ? "Cold Room Study" : project}  |  Engineer: $engineer',
                  )),
                  style: const pw.TextStyle(color: PdfColors.grey300, fontSize: 8.8),
                ),
              ],
            ),
          ),
          _sectionHeader(_p(lang, '1. معطيات الغرفة والأحمال الحرارية', '1. Chambre Froide et Bilan Thermique', '1. Cold Room & Thermal Load'), isAr),
          _kvTable([
            [_p(lang, 'الأبعاد والحجم', 'Dimensions et Volume', 'Dimensions & Volume'), '${input.length} x ${input.width} x ${input.height} m (${result.volume} m3)'],
            [
              _p(lang, 'درجات الحرارة', 'Temperatures', 'Temperatures'),
              _p(
                lang,
                'الداخلية: ${input.tInside} C | الخارجية: ${input.tAmbient} C | التبخير: ${result.t0} C | التكثيف: ${result.tk} C',
                'Interieure: ${input.tInside} C | Ambiante: ${input.tAmbient} C | Evap: ${result.t0} C | Cond: ${result.tk} C',
                'Inside: ${input.tInside} C | Ambient: ${input.tAmbient} C | Evap: ${result.t0} C | Cond: ${result.tk} C',
              ),
            ],
            [
              _p(lang, 'العزل الحراري', 'Isolation Thermique', 'Thermal Insulation'),
              'PU ${input.insMm.toInt()} mm (lambda=${input.lambdaIns}) | U = ${result.uValue} W/m2.K',
            ],
            [
              _p(lang, 'الاستطاعة التبريدية المطلوبة Q0', 'Puissance Frigorifique Q0', 'Cooling Capacity Q0'),
              '${result.q0Kw} kW (${result.kcalH} kcal/h | ${result.btuH} BTU/h)',
            ],
            [
              _p(lang, 'ألواح الساندويتش', 'Panneaux Sandwich', 'Sandwich Panels'),
              _p(
                lang,
                'الجدران: ${result.wallPanels} | السقف: ${result.roofPanels} | المساحة: ${result.totalPanelArea} m2 | فوم: ${result.puFoamCans}',
                'Murs: ${result.wallPanels} | Plafond: ${result.roofPanels} | Surface: ${result.totalPanelArea} m2 | Mousse: ${result.puFoamCans}',
                'Walls: ${result.wallPanels} | Roof: ${result.roofPanels} | Area: ${result.totalPanelArea} m2 | Foam: ${result.puFoamCans}',
              ),
            ],
          ], isAr),
          _sectionHeader(_p(lang, '2. الدورة الثرموديناميكية والضاغط والمبخر والمكثف', '2. Cycle, Compresseur, Evaporateur et Condenseur', '2. Cycle, Compressor, Evaporator & Condenser'), isAr),
          _kvTable([
            [_p(lang, 'وسيط التبريد والضغوط', 'Fluide et Pressions', 'Refrigerant & Pressures'), '$refName | P0=${s.p0BarAbs} bar (${s.p0BarRel} rel) | Pk=${s.pkBarAbs} bar (${s.pkBarRel} rel) | tau=${s.compressionRatio}'],
            [_p(lang, 'التدفق الكتلي والحجم النوعي', 'Debit Massique et Volume', 'Mass Flow & Vapor Vol'), 'm = ${s.massFlowKgH} kg/h | dh = ${s.dhEvapKjKg} kJ/kg | v\'\' = ${s.suctionSpecVolM3Kg} m3/kg'],
            [_p(lang, 'الضاغط المقترح والحجم الممسوح', 'Compresseur et Volume Balaye', 'Compressor & Swept Volume'), '${result.recommendedUnit} | eta_v=${(s.volumetricEff * 100).toInt()}% | Vb=${s.reqSweptVolM3h} m3/h | T_dis=${s.estDischargeTempC} C'],
            [_p(lang, 'حساب المبخر', 'Dimensionnement Evaporateur', 'Evaporator Sizing'), '${result.evapDim} (${result.evapFans}) | dT1=${s.evapDeltaT1K}K | ${s.evapSurfaceM2} m2 | ${s.evapFinSpacingMm} mm | ${s.evapAirFlowM3h} m3/h'],
            [_p(lang, 'حساب المكثف', 'Dimensionnement Condenseur', 'Condenser Sizing'), 'Qk=${s.condRejectionKw} kW | dTk=${s.condDeltaTK}K | ${s.condSurfaceM2} m2 | ${s.condAirFlowM3h} m3/h | ${result.condDim}'],
          ], isAr),
          _sectionHeader(_p(lang, '3. المنظم + الأورفيس، الفلتر، فاصل الزيت، الخزان والأكيومليتور', '3. Detendeur, Deshydrateur, Separateur, Reservoir et ACL', '3. TXV + Orifice, Drier, Oil Sep, Receiver & ACL'), isAr),
          _kvTable([
            [_p(lang, 'صمام التمدد + رقم الأورفيس', 'Detendeur et Numero de Buse', 'TXV & Orifice Number'), '${s.txvBody} -> ${s.txvOrificeNumber} (dP=${s.txvDeltaPBar} bar, Ksc=${s.txvCorrFactorKsc}, Qnom=${s.txvNominalCapKw} kW)'],
            [_p(lang, 'الفلتر المجفف ومؤشر السائل', 'Deshydrateur et Voyant Liquide', 'Filter Drier & Sight Glass'), '${s.filterDrierModel} | ${s.sightGlassModel}'],
            [_p(lang, 'فاصل الزيت', 'Separateur d\'huile', 'Oil Separator'), '${s.oilSeparatorModel} | v=${s.dischargeVelocityMs} m/s | ${s.oilPreChargeL} L (${s.oilType})'],
            [_p(lang, 'خزان سائل التبريد (80% EN 378)', 'Reservoir Liquide (80% EN 378)', 'Liquid Receiver (80% EN 378)'), '${s.receiverModel} | Min=${s.receiverMinVolL} L | ~${s.estTotalChargeKg} kg'],
            [_p(lang, 'الأكيومليتور (Bouteille ACL)', 'Bouteille ACL (Accumulateur)', 'Suction Accumulator (ACL)'), '${s.aclModel} | Min=${s.aclMinVolL} L | ${s.aclBleedHoleMm}'],
            [_p(lang, 'أنابيب النحاس والحماية', 'Tuyauterie Cuivre et Controle', 'Copper Pipes & Controls'), '${result.sucInch} / ${result.liqInch} / ${s.dischargePipeInch} | ${s.solenoidValve} | ${s.hpLpSwitch}'],
          ], isAr),
          _sectionHeader(_p(lang, '4. الخزانة الكهربائية (NF C 15-100)', '4. Armoire Electrique (NF C 15-100)', '4. Electrical Panel (NF C 15-100)'), isAr),
          _kvTable([
            [_p(lang, 'التيار الاسمي والقاطع', 'Courant et Disjoncteur', 'Current & Breaker'), 'I_nom=${el.nominalAmps} A | ${el.breakerRating}'],
            [_p(lang, 'الكونتاكتور والريلي الحراري', 'Contacteur et Relais Thermique', 'Contactor & Overload'), '${el.contactorRating} | ${el.overloadRange}'],
            [_p(lang, 'مقطع الكابل وسخانات الإذابة', 'Cable et Resistances Degivrage', 'Cable & Defrost Heaters'), '${el.cableSection} | ${el.defrostHeaterKw} kW'],
          ], isAr),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (_) async => doc.save(), name: 'CryoCalcPro_Report.pdf');
  }

  /* ==================== 2. FIELD AUDIT PDF ==================== */
  static Future<void> printFieldAudit({
    required AppLang lang,
    required AuditInput auditInput,
    required AuditResult auditResult,
    required String client,
    required String project,
    required String engineer,
  }) async {
    final theme = await _loadTheme();
    final isAr = lang == AppLang.ar;

    final doc = pw.Document(theme: theme);
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(22),
        textDirection: isAr ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        build: (ctx) => [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(13),
            decoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF070D19),
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: isAr ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  clean(_p(
                    lang,
                    'تقرير التقييم الميداني والتشخيص - CryoCalc PRO',
                    'Rapport d\'Audit Terrain et Diagnostic - CryoCalc PRO',
                    'Field Audit & Diagnostic Report - CryoCalc PRO',
                  )),
                  style: pw.TextStyle(color: const PdfColor.fromInt(0xFF22C55E), fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  clean('${_p(lang, CryoOwner.developerAr, "Ing. Ahmed Zinnour", CryoOwner.developerEn)} | ${CryoOwner.groupCode} | ${_p(lang, "التقييم", "Score", "Score")}: ${auditResult.score}/100'),
                  style: const pw.TextStyle(color: PdfColors.white, fontSize: 9.5),
                ),
                pw.Text(
                  clean(_p(
                    lang,
                    'الزبون: ${client.isEmpty ? "-" : client} | الموقع: ${project.isEmpty ? "-" : project} | الفني: $engineer',
                    'Client: ${client.isEmpty ? "-" : client} | Site: ${project.isEmpty ? "-" : project} | Technicien: $engineer',
                    'Client: ${client.isEmpty ? "-" : client} | Site: ${project.isEmpty ? "-" : project} | Tech: $engineer',
                  )),
                  style: const pw.TextStyle(color: PdfColors.grey300, fontSize: 8.8),
                ),
              ],
            ),
          ),
          _sectionHeader(_p(lang, '1. القياسات الميدانية المسجلة', '1. Mesures Terrain Enregistrees', '1. Recorded Field Measurements'), isAr),
          _kvTable([
            [_p(lang, 'حرارة التبخير / حرارة السحب', 'T0 Evaporation / T Aspiration', 'Evap T0 / Suction Temp'), '${auditInput.t0} C  /  ${auditInput.tSuc} C'],
            [_p(lang, 'حرارة التكثيف / حرارة السائل', 'Tk Condensation / T Liquide', 'Cond Tk / Liquid Temp'), '${auditInput.tk} C  /  ${auditInput.tLiq} C'],
            [_p(lang, 'حرارة الغرفة / حرارة الطرد', 'T Chambre / T Refoulement', 'Room Temp / Discharge Temp'), '${auditInput.tRoom} C  /  ${auditInput.tDis} C'],
            [_p(lang, 'الاستطاعة التبريدية / الكهربائية', 'Puissance Frigo / Electrique', 'Cooling Q0 / Electric Power'), '${auditInput.p0Kw} kW  /  ${auditInput.pElecKw} kW'],
            [_p(lang, 'التحميص SH / التبريد الدوني SC', 'Surchauffe SH / Sous-refroid. SC', 'Superheat SH / Subcooling SC'), 'SH = ${auditResult.superheat} K  |  SC = ${auditResult.subcooling} K'],
            [_p(lang, 'فرق المبخر / معامل الأداء / التقييم', 'Ecart dT / COP / Score Global', 'Evap dT / COP / Health Score'), 'dT = ${auditResult.evapDeltaT} K | COP = ${auditResult.cop} | ${auditResult.score}/100'],
          ], isAr),
          _sectionHeader(_p(lang, '2. نتائج التشخيص والتوصيات الفنية', '2. Diagnostic et Recommandations Techniques', '2. Diagnostic Findings & Actions'), isAr),
          ...auditResult.findings.map((f) => pw.Container(
                width: double.infinity,
                margin: const pw.EdgeInsets.only(bottom: 5),
                padding: const pw.EdgeInsets.all(7),
                decoration: pw.BoxDecoration(
                  color: f.level == 'bad'
                      ? PdfColors.red50
                      : (f.level == 'warn' ? PdfColors.amber50 : PdfColors.green50),
                  border: pw.Border.all(
                    color: f.level == 'bad'
                        ? PdfColors.red400
                        : (f.level == 'warn' ? PdfColors.amber600 : PdfColors.green600),
                  ),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Text(
                  clean(f.text),
                  textAlign: isAr ? pw.TextAlign.right : pw.TextAlign.left,
                  style: const pw.TextStyle(fontSize: 9.2),
                ),
              )),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (_) async => doc.save(), name: 'CryoCalcPro_Audit.pdf');
  }

  /* ==================== 3. INDUSTRIAL COMPRESSOR & 16 PARTS PDF ==================== */
  static Future<void> printIndustrialReport({
    required AppLang lang,
    required IndustrialCalcResult result,
    required String refrigerant,
    required String customNote,
  }) async {
    final theme = await _loadTheme();
    final isAr = lang == AppLang.ar;
    final sel = result.selected.item;

    final doc = pw.Document(theme: theme);
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(22),
        textDirection: isAr ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        build: (_) => [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(13),
            decoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF070D19),
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: isAr ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  clean(_p(
                    lang,
                    'دراسة الضاغط الصناعي وقطع المجموعة - CryoCalc PRO',
                    'Etude Compresseur Industriel et Groupe - CryoCalc PRO',
                    'Industrial Compressor & Group Sizing - CryoCalc PRO',
                  )),
                  style: pw.TextStyle(color: const PdfColor.fromInt(0xFF38BDF8), fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  clean('${_p(lang, CryoOwner.developerAr, "Ing. Ahmed Zinnour", CryoOwner.developerEn)} | ${CryoOwner.groupCode} | ${sel.brand} ${sel.model} (${sel.hp} HP)'),
                  style: const pw.TextStyle(color: PdfColors.white, fontSize: 9.5),
                ),
                if (customNote.trim().isNotEmpty) ...[
                  pw.SizedBox(height: 3),
                  pw.Text(clean(customNote), style: const pw.TextStyle(color: PdfColors.grey300, fontSize: 8.8)),
                ],
              ],
            ),
          ),
          _sectionHeader(_p(lang, '1. الحسابات الثرموديناميكية للضاغط الصناعي', '1. Calculs Thermodynamiques du Compresseur', '1. Industrial Compressor Thermodynamic Results'), isAr),
          _kvTable([
            [_p(lang, 'الاستطاعة التبريدية والقدرة التقديرية', 'Puissance Frigo et Puissance CV', 'Cooling Capacity & Est. HP'), '${result.q0Kw} kW | ${result.kcalH} kcal/h | ~${result.estHp} HP ($refrigerant)'],
            [_p(lang, 'ضغط التبخير / التكثيف / نسبة الانضغاط', 'Pressions P0 / Pk / Taux tau', 'Pressures P0 / Pk / Ratio tau'), 'P0=${result.p0Abs} bar (${result.p0Rel} rel) | Pk=${result.pkAbs} bar (${result.pkRel} rel) | tau=${result.tau}'],
            [_p(lang, 'التدفق الكتلي / الحجم الممسوح / المردود', 'Debit / Volume Balaye / Rendement', 'Mass Flow / Swept Vol / Vol Eff'), '${result.massFlowKgH} kg/h | Vb=${result.reqVbM3h} m3/h | eta_v=${(result.etaV * 100).toInt()}%'],
            [_p(lang, 'القدرة الكهربائية / COP / المكثف / الطرد', 'P_elec / COP / Condenseur / Refoul.', 'Electric Power / COP / Cond / Disch'), '${result.pElecEstKw} kW | COP ${result.cop} | Qk ${result.qCondKw} kW | T_dis ${result.tDisC} C'],
          ], isAr),
          _sectionHeader(_p(lang, '2. قائمة القطع الـ 16 الخاصة بمجموعة التبريد الصناعي', '2. Liste des 16 Pieces du Groupe Industriel', '2. Industrial Condensing Group Parts List (16 Components)'), isAr),
          _kvTable(
            result.groupParts.map((p) => ['${p.index}. ${p.title}', '${p.spec}\n${p.details}']).toList(),
            isAr,
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (_) async => doc.save(), name: 'CryoCalcPro_Industrial_Group.pdf');
  }
}
