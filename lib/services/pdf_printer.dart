import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../engine/cryo_engine.dart';
import '../l10n/app_strings.dart';
import '../security/security_guard.dart';

class PdfPrinterService {
  static Future<pw.ThemeData?> _loadTheme() async {
    try {
      final regData = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
      final boldData = await rootBundle.load('assets/fonts/Cairo-Bold.ttf');
      return pw.ThemeData.withFont(
        base: pw.Font.ttf(regData),
        bold: pw.Font.ttf(boldData),
      );
    } catch (_) {
      return null;
    }
  }

  static pw.Widget _sectionHeader(String title) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 12, bottom: 6),
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: const pw.BoxDecoration(
        color: PdfColor.fromInt(0xFF0F2547),
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(color: PdfColors.white, fontSize: 11, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.Widget _kvTable(List<List<String>> rows) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.6),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.3),
        1: const pw.FlexColumnWidth(1.7),
      },
      children: rows.map((r) {
        return pw.TableRow(
          children: [
            pw.Container(
              color: PdfColors.grey100,
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(r[0], style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold)),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(r[1], style: const pw.TextStyle(fontSize: 9.5)),
            ),
          ],
        );
      }).toList(),
    );
  }

  static Future<void> printEngineeringReport({
    required AppLang lang,
    required CryoInput input,
    required CryoResult result,
    required String client,
    required String project,
    required String engineer,
  }) async {
    final theme = await _loadTheme();
    final isAr = lang == AppLang.ar && theme != null;
    final s = result.sizing;
    final el = result.electrical;
    final refName = input.refrigerant == 'custom' && input.customRefName.isNotEmpty
        ? input.customRefName
        : input.refrigerant;

    final doc = pw.Document(theme: theme);
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        textDirection: isAr ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        build: (ctx) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF070D19),
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  isAr ? 'التقرير الهندسي الرسمي — CryoCalc PRO ${CryoOwner.appVersion}' : 'CryoCalc PRO ${CryoOwner.appVersion} — Engineering Report',
                  style: pw.TextStyle(color: const PdfColor.fromInt(0xFF38BDF8), fontSize: 15, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  '${isAr ? CryoOwner.developerAr : CryoOwner.developerEn}  |  ${CryoOwner.groupCode}',
                  style: const pw.TextStyle(color: PdfColors.white, fontSize: 10),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Client: ${client.isEmpty ? "-" : client}   |   Project: ${project.isEmpty ? "Cold Room Study" : project}   |   Eng: $engineer',
                  style: const pw.TextStyle(color: PdfColors.grey300, fontSize: 9),
                ),
              ],
            ),
          ),
          _sectionHeader(isAr ? '1. معطيات الغرفة والأحمال الحرارية' : '1. Cold Room & Thermal Load'),
          _kvTable([
            [isAr ? 'الأبعاد والحجم' : 'Dimensions & Volume', '${input.length} x ${input.width} x ${input.height} m (${result.volume} m3)'],
            [isAr ? 'درجات الحرارة' : 'Temperatures', 'Inside: ${input.tInside} C | Ambient: ${input.tAmbient} C | T0: ${result.t0} C | Tk: ${result.tk} C'],
            [isAr ? 'العزل الحراري' : 'Insulation', 'PU ${input.insMm.toInt()} mm (lambda=${input.lambdaIns}) | U = ${result.uValue} W/m2.K'],
            [isAr ? 'الاستطاعة التبريدية Q0' : 'Cooling Capacity Q0', '${result.q0Kw} kW (${result.kcalH} kcal/h | ${result.btuH} BTU/h)'],
            [isAr ? 'ألواح الساندويتش' : 'Sandwich Panels', 'Walls: ${result.wallPanels} | Roof: ${result.roofPanels} | Total: ${result.totalPanelArea} m2 | Foam: ${result.puFoamCans}'],
          ]),
          _sectionHeader(isAr ? '2. الدورة الثرموديناميكية والضاغط والمبخر والمكثف' : '2. Thermodynamics, Compressor, Evaporator & Condenser'),
          _kvTable([
            [isAr ? 'وسيط التبريد والضغوط' : 'Refrigerant & Pressures', '$refName | P0=${s.p0BarAbs} bar (${s.p0BarRel} rel) | Pk=${s.pkBarAbs} bar (${s.pkBarRel} rel) | tau=${s.compressionRatio}'],
            [isAr ? 'التدفق الكتلي والحجم النوعي' : 'Mass Flow & Vapor Vol', 'm = ${s.massFlowKgH} kg/h | dh = ${s.dhEvapKjKg} kJ/kg | v\'\' = ${s.suctionSpecVolM3Kg} m3/kg'],
            [isAr ? 'الضاغط المقترح والـ Vb' : 'Compressor & Swept Vol', '${result.recommendedUnit} | eta_v=${s.volumetricEff} | Vb req=${s.reqSweptVolM3h} m3/h | T_dis=${s.estDischargeTempC} C'],
            [isAr ? 'حساب المبخر' : 'Evaporator Sizing', '${result.evapDim} (${result.evapFans} fans) | dT1=${s.evapDeltaT1K}K | Area=${s.evapSurfaceM2} m2 | Fins=${s.evapFinSpacingMm} mm | Air=${s.evapAirFlowM3h} m3/h'],
            [isAr ? 'حساب المكثف' : 'Condenser Sizing', 'Qk=${s.condRejectionKw} kW | dTk=${s.condDeltaTK}K | Area=${s.condSurfaceM2} m2 | Air=${s.condAirFlowM3h} m3/h | Dim: ${result.condDim}'],
          ]),
          _sectionHeader(isAr ? '3. المنظم + الأورفيس، الفلتر، فاصل الزيت، الخزان والـ ACL' : '3. TXV + Orifice, Drier, Oil Sep, Receiver & ACL'),
          _kvTable([
            [isAr ? 'صمام التمدد + الأورفيس' : 'TXV & Orifice', '${s.txvBody} -> ${s.txvOrificeNumber} (dP=${s.txvDeltaPBar} bar, Ksc=${s.txvCorrFactorKsc}, Qnom=${s.txvNominalCapKw} kW)'],
            [isAr ? 'الفلتر المجفف وزجاجة البيان' : 'Filter Drier & Sight Glass', '${s.filterDrierModel}  |  ${s.sightGlassModel}'],
            [isAr ? 'فاصل الزيت (Oil Separator)' : 'Oil Separator', '${s.oilSeparatorModel} | v_dis=${s.dischargeVelocityMs} m/s | Oil=${s.oilPreChargeL} L (${s.oilType})'],
            [isAr ? 'خزان السائل (EN 378 80%)' : 'Liquid Receiver (80% Rule)', '${s.receiverModel} | Min=${s.receiverMinVolL} L | Charge~${s.estTotalChargeKg} kg'],
            [isAr ? 'الزجاجة المضادة للطلق (ACL)' : 'Suction Accumulator (ACL)', '${s.aclModel} | Min=${s.aclMinVolL} L | Bleed=${s.aclBleedHoleMm}'],
            [isAr ? 'أنابيب النحاس والحماية' : 'Copper Pipes & Controls', 'Suc ${result.sucInch} / Liq ${result.liqInch} / Dis ${s.dischargePipeInch} | ${s.solenoidValve} | ${s.hpLpSwitch}'],
          ]),
          _sectionHeader(isAr ? '4. الخزانة الكهربائية (NF C 15-100)' : '4. Electrical Panel (NF C 15-100)'),
          _kvTable([
            [isAr ? 'التيار والقاطع' : 'Current & Breaker', 'I_nom=${el.nominalAmps} A | ${el.breakerRating}'],
            [isAr ? 'الكونتاكتور والريلي الحراري' : 'Contactor & Overload', '${el.contactorRating} | Relay: ${el.overloadRange}'],
            [isAr ? 'الكابل وسخانات الإذابة' : 'Cable & Defrost', '${el.cableSection} | Defrost Heater: ${el.defrostHeaterKw} kW'],
          ]),
          pw.SizedBox(height: 12),
          pw.Text(
            'Facebook: ${CryoOwner.facebookUrl}  |  Group: ${CryoOwner.facebookGroupUrl}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'CryoCalcPro_Report.pdf',
    );
  }

  static Future<void> printFieldAudit({
    required AppLang lang,
    required AuditInput auditInput,
    required AuditResult auditResult,
    required String client,
    required String project,
    required String engineer,
  }) async {
    final theme = await _loadTheme();
    final isAr = lang == AppLang.ar && theme != null;

    final doc = pw.Document(theme: theme);
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        textDirection: isAr ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        build: (ctx) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF070D19),
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  isAr ? 'تقرير التقييم الميداني والتشخيص — CryoCalc PRO' : 'CryoCalc PRO — Field Diagnostic & Audit Report',
                  style: pw.TextStyle(color: const PdfColor.fromInt(0xFF22C55E), fontSize: 15, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  '${isAr ? CryoOwner.developerAr : CryoOwner.developerEn} | ${CryoOwner.groupCode} | Score: ${auditResult.score}/100',
                  style: const pw.TextStyle(color: PdfColors.white, fontSize: 10),
                ),
                pw.Text(
                  'Client: ${client.isEmpty ? "-" : client} | Site: ${project.isEmpty ? "-" : project} | Tech: $engineer',
                  style: const pw.TextStyle(color: PdfColors.grey300, fontSize: 9),
                ),
              ],
            ),
          ),
          _sectionHeader(isAr ? '1. القياسات الميدانية المسجلة' : '1. Recorded Field Measurements'),
          _kvTable([
            ['T0 / T_suction', '${auditInput.t0} C  /  ${auditInput.tSuc} C'],
            ['Tk / T_liquid', '${auditInput.tk} C  /  ${auditInput.tLiq} C'],
            ['T_room / T_discharge', '${auditInput.tRoom} C  /  ${auditInput.tDis} C'],
            ['Q0 / P_elec', '${auditInput.p0Kw} kW  /  ${auditInput.pElecKw} kW'],
            [isAr ? 'التحميص SH / التبريد الدوني SC' : 'Superheat SH / Subcooling SC', 'SH = ${auditResult.superheat} K  |  SC = ${auditResult.subcooling} K'],
            [isAr ? 'فرق المبخر dT / معامل الأداء COP' : 'Evap dT / COP / Health Score', 'dT = ${auditResult.evapDeltaT} K | COP = ${auditResult.cop} | Score = ${auditResult.score}/100'],
          ]),
          _sectionHeader(isAr ? '2. التشخيص والتوصيات الفنية' : '2. Diagnostic Findings & Actions'),
          ...auditResult.findings.map((f) => pw.Container(
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
                child: pw.Text('[${f.level.toUpperCase()}] ${f.text}', style: const pw.TextStyle(fontSize: 9.5)),
              )),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'CryoCalcPro_Audit.pdf',
    );
  }
}
