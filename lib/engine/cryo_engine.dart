import 'dart:math' as math;

class ProductItem {
  final String id;
  final String name;
  final double cpAbove;
  final double cpBelow;
  final double tFreeze;
  final double latentFreeze;
  final double respirationWPerTon;

  const ProductItem({
    required this.id,
    required this.name,
    required this.cpAbove,
    required this.cpBelow,
    required this.tFreeze,
    required this.latentFreeze,
    this.respirationWPerTon = 0,
  });
}

class CompressorItem {
  final String id;
  final String brand;
  final String model;
  final String tech;
  final String regime;
  final double dispM3h;
  final double qMtKw;
  final double qLtKw;
  final double pElecKw;
  final String volt;
  final List<int> dimMm;
  final List<String> refrigerants;

  const CompressorItem({
    required this.id,
    required this.brand,
    required this.model,
    required this.tech,
    required this.regime,
    required this.dispM3h,
    required this.qMtKw,
    required this.qLtKw,
    required this.pElecKw,
    required this.volt,
    required this.dimMm,
    required this.refrigerants,
  });
}

class ScoredCompressor {
  final CompressorItem item;
  final double adjustedCapKw;
  final double coveragePct;
  final double currentAmps;

  const ScoredCompressor({
    required this.item,
    required this.adjustedCapKw,
    required this.coveragePct,
    required this.currentAmps,
  });
}

class ElectricalSizing {
  final double nominalAmps;
  final String breakerRating;
  final String contactorRating;
  final String overloadRange;
  final String cableSection;
  final double defrostHeaterKw;

  const ElectricalSizing({
    required this.nominalAmps,
    required this.breakerRating,
    required this.contactorRating,
    required this.overloadRange,
    required this.cableSection,
    required this.defrostHeaterKw,
  });
}

class CircuitComponents {
  final String txvSpec;
  final String filterDrier;
  final String sightGlass;
  final String solenoidValve;
  final double receiverLiters;
  final double estChargeKg;
  final String hpLpSwitch;
  final String oilSeparator;

  const CircuitComponents({
    required this.txvSpec,
    required this.filterDrier,
    required this.sightGlass,
    required this.solenoidValve,
    required this.receiverLiters,
    required this.estChargeKg,
    required this.hpLpSwitch,
    required this.oilSeparator,
  });
}

class CryoInput {
  final String roomType;
  final double length;
  final double width;
  final double height;
  final double insMm;
  final double tInside;
  final double tAmbient;
  final double tFloor;
  final double opHours;
  final String productId;
  final double dailyKg;
  final double tProdIn;
  final String doorTraffic;
  final String arch;
  final double pipeLen;
  final String defrostType;
  final String refrigerant;
  final String brandFilter;
  final String voltageFilter;
  final double panelWidth;
  final String floorPanelMode;

  const CryoInput({
    this.roomType = 'positive',
    this.length = 6.0,
    this.width = 4.0,
    this.height = 3.0,
    this.insMm = 80.0,
    this.tInside = 2.0,
    this.tAmbient = 38.0,
    this.tFloor = 18.0,
    this.opHours = 16.0,
    this.productId = 'veg',
    this.dailyKg = 0.0,
    this.tProdIn = 20.0,
    this.doorTraffic = 'med',
    this.arch = 'split',
    this.pipeLen = 10.0,
    this.defrostType = 'auto',
    this.refrigerant = 'R404A',
    this.brandFilter = 'ALL',
    this.voltageFilter = '400',
    this.panelWidth = 1.15,
    this.floorPanelMode = 'auto',
  });
}

class EngineeringAlert {
  final String level;
  final String text;
  const EngineeringAlert(this.level, this.text);
}

class CryoResult {
  final double volume;
  final double areaFloor;
  final double areaWalls;
  final double uValue;
  final double qTransW;
  final double qProdW;
  final double qInfilW;
  final double qIntW;
  final double qTotal24W;
  final double q0Kw;
  final int kcalH;
  final int btuH;
  final double pElecKw;
  final double t0;
  final double tk;
  final bool isLT;
  final String sucInch;
  final String liqInch;
  final List<int> condDimMm;
  final List<int> evapDimMm;
  final int evapFans;
  final int airThrowM;
  final int wallPanels;
  final int roofPanels;
  final int floorPanels;
  final double totalPanelArea;
  final double uRailMeters;
  final double covingMeters;
  final int puFoamCans;
  final double doorWidth;
  final double doorHeight;
  final bool floorInsIncluded;
  final List<ScoredCompressor> candidates;
  final ScoredCompressor selectedUnit;
  final ElectricalSizing electrical;
  final CircuitComponents circuit;
  final List<EngineeringAlert> alerts;

  String get condDim => '${condDimMm[0]} × ${condDimMm[1]} × ${condDimMm[2]} mm';
  String get evapDim => '${evapDimMm[0]} × ${evapDimMm[1]} × ${evapDimMm[2]} mm';
  String get recommendedUnit => '${selectedUnit.item.brand} ${selectedUnit.item.model}';

  const CryoResult({
    required this.volume,
    required this.areaFloor,
    required this.areaWalls,
    required this.uValue,
    required this.qTransW,
    required this.qProdW,
    required this.qInfilW,
    required this.qIntW,
    required this.qTotal24W,
    required this.q0Kw,
    required this.kcalH,
    required this.btuH,
    required this.pElecKw,
    required this.t0,
    required this.tk,
    required this.isLT,
    required this.sucInch,
    required this.liqInch,
    required this.condDimMm,
    required this.evapDimMm,
    required this.evapFans,
    required this.airThrowM,
    required this.wallPanels,
    required this.roofPanels,
    required this.floorPanels,
    required this.totalPanelArea,
    required this.uRailMeters,
    required this.covingMeters,
    required this.puFoamCans,
    required this.doorWidth,
    required this.doorHeight,
    required this.floorInsIncluded,
    required this.candidates,
    required this.selectedUnit,
    required this.electrical,
    required this.circuit,
    required this.alerts,
  });
}

class AuditInput {
  final double t0;
  final double tSuc;
  final double tk;
  final double tLiq;
  final double tRoom;
  final double tDis;
  final double p0Kw;
  final double pElecKw;
  final String seals;
  final String cleanliness;

  const AuditInput({
    required this.t0,
    required this.tSuc,
    required this.tk,
    required this.tLiq,
    required this.tRoom,
    required this.tDis,
    required this.p0Kw,
    required this.pElecKw,
    this.seals = 'good',
    this.cleanliness = 'good',
  });
}

class AuditResult {
  final double superheat;
  final double subcooling;
  final double evapDeltaT;
  final double cop;
  final int score;
  final String evapStatus;
  final String compStatus;
  final String condStatus;
  final String txvStatus;
  final String doorStatus;
  final List<EngineeringAlert> findings;

  const AuditResult({
    required this.superheat,
    required this.subcooling,
    required this.evapDeltaT,
    required this.cop,
    required this.score,
    required this.evapStatus,
    required this.compStatus,
    required this.condStatus,
    required this.txvStatus,
    required this.doorStatus,
    required this.findings,
  });
}

class CryoEngine {
  static const List<ProductItem> products = [
    ProductItem(id: 'veg', name: 'خضر وفواكه طازجة (Fruits & Légumes)', cpAbove: 3.85, cpBelow: 1.95, tFreeze: -1.5, latentFreeze: 280, respirationWPerTon: 45),
    ProductItem(id: 'meat', name: 'لحوم حمراء طازجة (Viande fraîche)', cpAbove: 3.20, cpBelow: 1.70, tFreeze: -1.8, latentFreeze: 230),
    ProductItem(id: 'poultry', name: 'دواجن طازجة / مجمدة (Volaille)', cpAbove: 3.30, cpBelow: 1.75, tFreeze: -2.2, latentFreeze: 245),
    ProductItem(id: 'fish', name: 'أسماك ومأكولات بحرية (Poissons)', cpAbove: 3.55, cpBelow: 1.85, tFreeze: -2.0, latentFreeze: 265),
    ProductItem(id: 'dairy', name: 'ألبان وأجبان (Produits laitiers)', cpAbove: 3.60, cpBelow: 1.80, tFreeze: -1.0, latentFreeze: 250),
    ProductItem(id: 'potato', name: 'بطاطا وبصل (Pommes de terre)', cpAbove: 3.50, cpBelow: 1.80, tFreeze: -1.0, latentFreeze: 260, respirationWPerTon: 25),
    ProductItem(id: 'frozen', name: 'منتجات مجمدة مسبقاً (Surgelés)', cpAbove: 3.10, cpBelow: 1.75, tFreeze: -2.0, latentFreeze: 220),
    ProductItem(id: 'icecream', name: 'مثلجات (Crèmes glacées)', cpAbove: 3.15, cpBelow: 1.90, tFreeze: -5.5, latentFreeze: 210),
    ProductItem(id: 'pharma', name: 'أدوية ومستحضرات صيدلانية', cpAbove: 2.80, cpBelow: 1.50, tFreeze: -1.0, latentFreeze: 180),
  ];

  static const List<CompressorItem> compressors = [
    CompressorItem(id: 'c1', brand: 'Tecumseh', model: 'TFH4524Z', tech: 'Hermetic', regime: 'MT', dispM3h: 4.3, qMtKw: 2.35, qLtKw: 0.95, pElecKw: 1.15, volt: '230', dimMm: [680, 460, 480], refrigerants: ['R404A', 'R449A', 'R407F']),
    CompressorItem(id: 'c2', brand: 'Copeland', model: 'ZB15KCE-TFD', tech: 'Scroll', regime: 'MT', dispM3h: 5.9, qMtKw: 3.45, qLtKw: 1.40, pElecKw: 1.45, volt: '400', dimMm: [860, 480, 620], refrigerants: ['R404A', 'R449A', 'R134a', 'R407F']),
    CompressorItem(id: 'c3', brand: 'Danfoss', model: 'MTZ028-4', tech: 'Reciprocating', regime: 'MT', dispM3h: 8.4, qMtKw: 4.65, qLtKw: 1.90, pElecKw: 1.95, volt: '400', dimMm: [920, 510, 680], refrigerants: ['R404A', 'R449A', 'R134a', 'R407F']),
    CompressorItem(id: 'c4', brand: 'Copeland', model: 'ZB26KCE-TFD', tech: 'Scroll', regime: 'MT', dispM3h: 9.9, qMtKw: 5.75, qLtKw: 2.40, pElecKw: 2.35, volt: '400', dimMm: [1020, 540, 760], refrigerants: ['R404A', 'R449A', 'R134a', 'R407F']),
    CompressorItem(id: 'c5', brand: 'Bitzer', model: '2EES-2Y', tech: 'Semi-Hermetic', regime: 'MT', dispM3h: 11.4, qMtKw: 6.45, qLtKw: 2.80, pElecKw: 2.65, volt: '400', dimMm: [1100, 620, 820], refrigerants: ['R404A', 'R449A', 'R134a', 'R407F', 'R290']),
    CompressorItem(id: 'c6', brand: 'Copeland', model: 'ZB38KCE-TFD', tech: 'Scroll', regime: 'MT', dispM3h: 14.4, qMtKw: 8.35, qLtKw: 3.55, pElecKw: 3.40, volt: '400', dimMm: [1220, 660, 920], refrigerants: ['R404A', 'R449A', 'R134a', 'R407F']),
    CompressorItem(id: 'c7', brand: 'Dorin', model: 'H380CC', tech: 'Semi-Hermetic', regime: 'MT', dispM3h: 16.4, qMtKw: 9.55, qLtKw: 4.10, pElecKw: 3.85, volt: '400', dimMm: [1280, 680, 960], refrigerants: ['R404A', 'R449A', 'R134a', 'R407F']),
    CompressorItem(id: 'c8', brand: 'Copeland', model: 'ZB45KCE-TFD', tech: 'Scroll', regime: 'MT', dispM3h: 17.1, qMtKw: 10.45, qLtKw: 4.45, pElecKw: 4.20, volt: '400', dimMm: [1320, 700, 980], refrigerants: ['R404A', 'R449A', 'R134a', 'R407F']),
    CompressorItem(id: 'c9', brand: 'Bitzer', model: '4FES-5Y', tech: 'Semi-Hermetic', regime: 'MT', dispM3h: 18.1, qMtKw: 11.20, qLtKw: 4.90, pElecKw: 4.45, volt: '400', dimMm: [1380, 740, 1020], refrigerants: ['R404A', 'R449A', 'R134a', 'R407F', 'R290']),
    CompressorItem(id: 'c10', brand: 'Frascold', model: 'D4-18.1Y', tech: 'Semi-Hermetic', regime: 'MT', dispM3h: 18.0, qMtKw: 11.00, qLtKw: 4.80, pElecKw: 4.40, volt: '400', dimMm: [1360, 720, 1000], refrigerants: ['R404A', 'R449A', 'R134a', 'R407F']),
    CompressorItem(id: 'c11', brand: 'Copeland', model: 'ZB76KQE-TFD', tech: 'Scroll', regime: 'MT', dispM3h: 28.8, qMtKw: 17.60, qLtKw: 7.50, pElecKw: 6.90, volt: '400', dimMm: [1680, 880, 1260], refrigerants: ['R404A', 'R449A', 'R134a', 'R407F']),
    CompressorItem(id: 'c12', brand: 'Bitzer', model: '4TES-9Y', tech: 'Semi-Hermetic', regime: 'MT', dispM3h: 41.3, qMtKw: 24.50, qLtKw: 10.80, pElecKw: 9.60, volt: '400', dimMm: [1920, 960, 1420], refrigerants: ['R404A', 'R449A', 'R134a', 'R407F']),
    CompressorItem(id: 'l1', brand: 'Danfoss', model: 'NTZ068-4', tech: 'Reciprocating LT', regime: 'LT', dispM3h: 11.8, qMtKw: 5.80, qLtKw: 2.45, pElecKw: 1.95, volt: '400', dimMm: [980, 540, 740], refrigerants: ['R404A', 'R449A', 'R407F']),
    CompressorItem(id: 'l2', brand: 'Copeland', model: 'ZF13K4E-TFD', tech: 'Scroll LT', regime: 'LT', dispM3h: 11.7, qMtKw: 6.20, qLtKw: 3.35, pElecKw: 2.45, volt: '400', dimMm: [1080, 580, 820], refrigerants: ['R404A', 'R449A', 'R407F']),
    CompressorItem(id: 'l3', brand: 'Copeland', model: 'ZF18K4E-TFD', tech: 'Scroll LT', regime: 'LT', dispM3h: 17.1, qMtKw: 9.00, qLtKw: 4.95, pElecKw: 3.55, volt: '400', dimMm: [1260, 680, 960], refrigerants: ['R404A', 'R449A', 'R407F']),
    CompressorItem(id: 'l4', brand: 'Bitzer', model: '4EES-4Y', tech: 'Semi-Hermetic LT', regime: 'LT', dispM3h: 22.7, qMtKw: 12.10, qLtKw: 6.15, pElecKw: 4.30, volt: '400', dimMm: [1420, 760, 1080], refrigerants: ['R404A', 'R449A', 'R407F', 'R290']),
    CompressorItem(id: 'l5', brand: 'Frascold', model: 'Q5-25.1Y', tech: 'Semi-Hermetic LT', regime: 'LT', dispM3h: 24.7, qMtKw: 13.00, qLtKw: 6.85, pElecKw: 4.85, volt: '400', dimMm: [1480, 780, 1120], refrigerants: ['R404A', 'R449A', 'R407F']),
    CompressorItem(id: 'l6', brand: 'Copeland', model: 'ZFI36KQE-TFD (EVI)', tech: 'Scroll EVI', regime: 'LT', dispM3h: 29.1, qMtKw: 16.50, qLtKw: 10.60, pElecKw: 6.40, volt: '400', dimMm: [1650, 860, 1280], refrigerants: ['R404A', 'R449A', 'R407F']),
    CompressorItem(id: 'l7', brand: 'Dorin', model: 'H1501CC', tech: 'Semi-Hermetic LT', regime: 'LT', dispM3h: 44.0, qMtKw: 23.00, qLtKw: 12.40, pElecKw: 8.60, volt: '400', dimMm: [1880, 940, 1380], refrigerants: ['R404A', 'R449A', 'R407F']),
    CompressorItem(id: 'l8', brand: 'Bitzer', model: '4PES-12Y', tech: 'Semi-Hermetic LT', regime: 'LT', dispM3h: 48.5, qMtKw: 26.00, qLtKw: 14.50, pElecKw: 9.80, volt: '400', dimMm: [1980, 980, 1480], refrigerants: ['R404A', 'R449A', 'R407F']),
  ];

  static CryoResult calculate(CryoInput inp, {String? forcedCompId}) {
    final l = math.max(1.2, inp.length);
    final w = math.max(1.2, inp.width);
    final h = math.max(1.8, inp.height);
    final vol = l * w * h;
    final areaFloor = l * w;
    final areaWalls = 2 * (l + w) * h;

    final uVal = 0.023 / (inp.insMm / 1000.0);
    final dTWall = math.max(2.0, inp.tAmbient - inp.tInside);
    final dTFloor = math.max(2.0, inp.tFloor - inp.tInside);
    final floorInsIncluded = inp.floorPanelMode == 'yes' || (inp.floorPanelMode == 'auto' && inp.tInside <= 0);
    final qWallsW = (areaWalls + areaFloor) * uVal * dTWall;
    final qFloorW = areaFloor * uVal * dTFloor * (floorInsIncluded ? 0.90 : 1.45);
    final qTransW = qWallsW + qFloorW;

    final prod = products.firstWhere((p) => p.id == inp.productId, orElse: () => products.first);
    double qProdKj = 0;
    if (inp.dailyKg > 0 && inp.tProdIn > inp.tInside) {
      if (inp.tInside < prod.tFreeze && inp.tProdIn > prod.tFreeze) {
        qProdKj = inp.dailyKg *
            (prod.cpAbove * (inp.tProdIn - prod.tFreeze) +
                prod.latentFreeze +
                prod.cpBelow * (prod.tFreeze - inp.tInside));
      } else if (inp.tProdIn <= prod.tFreeze) {
        qProdKj = inp.dailyKg * prod.cpBelow * (inp.tProdIn - inp.tInside);
      } else {
        qProdKj = inp.dailyKg * prod.cpAbove * (inp.tProdIn - inp.tInside);
      }
    }
    final qRespW = (inp.tInside > 0 && prod.respirationWPerTon > 0)
        ? ((inp.dailyKg * 3.0) / 1000.0) * prod.respirationWPerTon
        : 0.0;
    final qProdW = (qProdKj * 1000.0) / 86400.0 + qRespW;

    final trMult = inp.doorTraffic == 'high' ? 1.55 : (inp.doorTraffic == 'low' ? 0.65 : 1.0);
    final airChanges = (vol < 30 ? 12.0 : vol < 100 ? 7.5 : 4.5) * trMult;
    final dH = dTWall * 1.45 + (inp.tInside < 0 ? 18.0 : 8.0);
    final qInfilW = (vol * airChanges * dH * 1000.0) / 86400.0;

    final qLightW = areaFloor * 9.0 * (4.0 / 24.0);
    final qStaffW = (vol > 50 ? 2 : 1) * 240.0 * (2.5 / 24.0);
    final isElecDefrost = inp.defrostType == 'electric' || (inp.defrostType == 'auto' && inp.tInside <= 2.0);
    final baseW = qTransW + qProdW + qInfilW + qLightW + qStaffW;
    final qFanDefW = baseW * (isElecDefrost ? 0.14 : 0.08);
    final qIntW = qLightW + qStaffW + qFanDefW;

    final qTotal24W = (qTransW + qProdW + qInfilW + qIntW) * 1.10;
    final opH = inp.opHours.clamp(10.0, 22.0).toDouble();
    final q0Kw = double.parse(((qTotal24W * (24.0 / opH)) / 1000.0).toStringAsFixed(2));
    final kcalH = (q0Kw * 860).round();
    final btuH = (q0Kw * 3412).round();

    final isLT = inp.tInside <= -5.0 || inp.roomType == 'negative' || inp.roomType == 'tunnel';
    final t0 = inp.roomType == 'tunnel' ? inp.tInside - 8.0 : inp.tInside - 7.0;
    final tk = inp.tAmbient + 12.0;

    final targetRegime = isLT ? 'LT' : 'MT';
    final list = compressors
        .where((c) =>
            c.refrigerants.contains(inp.refrigerant) &&
            (inp.brandFilter == 'ALL' || c.brand == inp.brandFilter))
        .map((c) {
      final rawCap = isLT ? c.qLtKw : c.qMtKw;
      final adjCap = double.parse((rawCap * (1.0 - (tk - 45.0) * 0.012)).toStringAsFixed(2));
      final ratio = adjCap / math.max(0.4, q0Kw);
      final amps = double.parse(
        ((c.pElecKw * 1000.0) / (c.volt == '400' ? (400 * 1.732 * 0.84) : (230 * 0.85))).toStringAsFixed(1),
      );
      final voltPenalty = c.volt == inp.voltageFilter ? 0.0 : 0.35;
      final regimePenalty = c.regime == targetRegime ? 0.0 : 0.75;
      final score = (ratio < 0.95 ? (1.2 - ratio) * 4.5 : (ratio - 1.12).abs()) + voltPenalty + regimePenalty;
      return _RankedComp(
        ScoredCompressor(
          item: c,
          adjustedCapKw: adjCap,
          coveragePct: double.parse((ratio * 100.0).toStringAsFixed(0)),
          currentAmps: amps,
        ),
        score,
      );
    }).toList()
      ..sort((a, b) => a.penalty.compareTo(b.penalty));

    final candidates = list.take(6).map((e) => e.sc).toList();
    final fallback = ScoredCompressor(
      item: compressors.first,
      adjustedCapKw: q0Kw,
      coveragePct: 100,
      currentAmps: double.parse((q0Kw * 0.9).toStringAsFixed(1)),
    );
    final selectedUnit = candidates.firstWhere(
      (c) => c.item.id == forcedCompId,
      orElse: () => candidates.isNotEmpty ? candidates.first : fallback,
    );

    var condDim = List<int>.from(selectedUnit.item.dimMm);
    if (inp.arch == 'monobloc') condDim = [940, 760, 840];
    if (inp.arch == 'rack') condDim = [math.max(1950, condDim[0] + 450), 1020, 1620];

    List<int> evapDim;
    int fans, throwM;
    if (q0Kw < 3.0) {
      evapDim = [820, 420, 380];
      fans = 1;
      throwM = 6;
    } else if (q0Kw < 7.5) {
      evapDim = [1240, 480, 440];
      fans = 2;
      throwM = 10;
    } else if (q0Kw < 15.0) {
      evapDim = [1720, 540, 490];
      fans = 3;
      throwM = 14;
    } else {
      evapDim = [2350, 620, 560];
      fans = 4;
      throwM = 19;
    }

    String suc = '5/8"', liq = '3/8"';
    if (q0Kw < 2.2) {
      suc = isLT ? '5/8"' : '1/2"';
    } else if (q0Kw < 5.5) {
      suc = isLT ? '7/8"' : '5/8"';
    } else if (q0Kw < 11.5) {
      suc = isLT ? '1-1/8"' : '7/8"';
      liq = '1/2"';
    } else if (q0Kw < 20.0) {
      suc = isLT ? '1-3/8"' : '1-1/8"';
      liq = '5/8"';
    } else {
      suc = isLT ? '1-5/8"' : '1-3/8"';
      liq = '7/8"';
    }

    // Electrical Panel Sizing (NF C 15-100 Industrial Standard)
    final iNom = selectedUnit.currentAmps;
    final is3Ph = selectedUnit.item.volt == '400';
    final breakerVal = iNom <= 6 ? 10 : iNom <= 10 ? 16 : iNom <= 16 ? 20 : iNom <= 22 ? 32 : 40;
    final contactorVal = iNom <= 9 ? 12 : iNom <= 16 ? 18 : iNom <= 24 ? 25 : 40;
    final cableMm2 = iNom <= 10 ? '2.5' : iNom <= 16 ? '4.0' : iNom <= 25 ? '6.0' : '10.0';
    final defrostKw = isElecDefrost ? double.parse((q0Kw * 0.42).clamp(1.2, 12.0).toStringAsFixed(1)) : 0.0;
    final electrical = ElectricalSizing(
      nominalAmps: iNom,
      breakerRating: '${is3Ph ? "3P+N" : "1P+N"} ${breakerVal}A (Courbe D)',
      contactorRating: 'LC1D$contactorVal (${contactorVal}A AC-3)',
      overloadRange: '${(iNom * 0.85).toStringAsFixed(1)} – ${(iNom * 1.25).toStringAsFixed(1)} A',
      cableSection: '${is3Ph ? "5G" : "3G"} $cableMm2 mm² (Cuivre RO2V)',
      defrostHeaterKw: defrostKw,
    );

    // 9-Component Refrigeration Circuit Sizing
    final txvOrifice = q0Kw < 2.5 ? 'Orifice 01' : q0Kw < 5.5 ? 'Orifice 02' : q0Kw < 10 ? 'Orifice 03' : q0Kw < 16 ? 'Orifice 04' : 'Orifice 05';
    final drierCode = liq == '3/8"' ? 'DML 083 / 163 (3/8")' : liq == '1/2"' ? 'DML 164 (1/2")' : 'DML 305 (5/8")';
    final receiverL = double.parse((q0Kw * 0.55 + inp.pipeLen * 0.08).clamp(2.0, 25.0).toStringAsFixed(1));
    final chargeKg = double.parse((receiverL * 0.65).toStringAsFixed(1));
    final circuit = CircuitComponents(
      txvSpec: 'Danfoss TES2 / Alco ($txvOrifice • ${inp.refrigerant})',
      filterDrier: drierCode,
      sightGlass: 'SGN $liq (مؤشر رطوبة)',
      solenoidValve: 'EVR ${q0Kw < 6 ? "3" : q0Kw < 14 ? "6" : "10"} ($liq • 230V)',
      receiverLiters: receiverL,
      estChargeKg: chargeKg,
      hpLpSwitch: 'KP15 مزدوج (HP: ${inp.refrigerant == "R134a" ? "18" : "26"} bar / LP: ${isLT ? "0.8" : "2.0"} bar)',
      oilSeparator: (isLT || inp.pipeLen > 15) ? 'مطلوب فاصل زيت (Séparateur d\'huile)' : 'غير إلزامي (مصيدة زيت فقط)',
    );

    final pw = inp.panelWidth;
    final doorW = w >= 3.2 ? 1.2 : 0.9;
    final doorH = h >= 2.5 ? 2.1 : 1.9;
    final wallPanels = ((2 * (l + w)) / pw).ceil();
    final roofPanels = (w / pw).ceil();
    final floorPanels = floorInsIncluded ? (w / pw).ceil() : 0;
    final totalPanelArea = double.parse(
      (areaWalls - (doorW * doorH) + areaFloor + (floorInsIncluded ? areaFloor : 0)).toStringAsFixed(1),
    );
    final uRailMeters = double.parse((2 * (l + w) - doorW).toStringAsFixed(1));
    final covingMeters = double.parse((2 * (l + w) * 2 + 4 * h).toStringAsFixed(1));
    final puFoamCans = math.max(4, (totalPanelArea / 14.0).ceil());

    final alerts = <EngineeringAlert>[];
    if (inp.tInside <= -25 && inp.insMm < 140) {
      alerts.add(EngineeringAlert('bad', 'سمك العزل (${inp.insMm.toInt()} mm) ضعيف لنفق التجميد (${inp.tInside}°C) — يوصى بـ 160 إلى 200 mm لتفادي التكثف.'));
    } else if (inp.tInside <= -15 && inp.insMm < 100) {
      alerts.add(EngineeringAlert('warn', 'غرفة سالبة (${inp.tInside}°C): يوصى بسمك بولي يوريثان 120 mm على الأقل (المختار ${inp.insMm.toInt()} mm).'));
    } else {
      alerts.add(EngineeringAlert('ok', 'سمك العزل (${inp.insMm.toInt()} mm) متوافق تماماً مع درجة الحرارة (${inp.tInside}°C) بمعامل U = ${uVal.toStringAsFixed(2)} W/m²·K.'));
    }

    if (inp.tInside <= -5) {
      alerts.add(const EngineeringAlert('warn', 'إلزامي للغرف السالبة: تركيب صمام موازنة الضغط (Soupape) + سخان إطار الباب + عزل أرضي مانع للتجمد.'));
    }
    if (throwM < l * 0.85) {
      alerts.add(EngineeringAlert('warn', 'طول الغرفة (${l.toStringAsFixed(1)} m) يتجاوز مدى دفع المبخر ($throwM m) — يفضل مبخر مزدوج التدفق أو مدى أطول.'));
    }
    if (inp.pipeLen > 20) {
      alerts.add(EngineeringAlert('warn', 'طول أنابيب النحاس (${inp.pipeLen.toInt()} m) كبير: يجب تركيب مصائد زيت (Pièges à huile) كل 3–4 أمتار صعوداً.'));
    }
    if (selectedUnit.coveragePct < 95) {
      alerts.add(EngineeringAlert('bad', 'أقرب وحدة في الفلتر (${selectedUnit.item.model}) تغطي ${selectedUnit.coveragePct.toInt()}% فقط من الحمل — اختر "كل العلامات" أو محطة Rack.'));
    }

    return CryoResult(
      volume: double.parse(vol.toStringAsFixed(1)),
      areaFloor: double.parse(areaFloor.toStringAsFixed(1)),
      areaWalls: double.parse(areaWalls.toStringAsFixed(1)),
      uValue: double.parse(uVal.toStringAsFixed(3)),
      qTransW: qTransW,
      qProdW: qProdW,
      qInfilW: qInfilW,
      qIntW: qIntW,
      qTotal24W: qTotal24W,
      q0Kw: q0Kw,
      kcalH: kcalH,
      btuH: btuH,
      pElecKw: selectedUnit.item.pElecKw,
      t0: t0,
      tk: tk,
      isLT: isLT,
      sucInch: suc,
      liqInch: liq,
      condDimMm: condDim,
      evapDimMm: evapDim,
      evapFans: fans,
      airThrowM: throwM,
      wallPanels: wallPanels,
      roofPanels: roofPanels,
      floorPanels: floorPanels,
      totalPanelArea: totalPanelArea,
      uRailMeters: uRailMeters,
      covingMeters: covingMeters,
      puFoamCans: puFoamCans,
      doorWidth: doorW,
      doorHeight: doorH,
      floorInsIncluded: floorInsIncluded,
      candidates: candidates,
      selectedUnit: selectedUnit,
      electrical: electrical,
      circuit: circuit,
      alerts: alerts,
    );
  }

  static List<CompressorItem> findCrossReference(String sourceId) {
    final src = compressors.firstWhere((c) => c.id == sourceId, orElse: () => compressors.first);
    return compressors
        .where((c) =>
            c.id != src.id &&
            c.regime == src.regime &&
            (c.dispM3h - src.dispM3h).abs() / src.dispM3h <= 0.22)
        .toList()
      ..sort((a, b) => (a.dispM3h - src.dispM3h).abs().compareTo((b.dispM3h - src.dispM3h).abs()));
  }

  static AuditResult evaluateAudit(AuditInput a) {
    final sh = double.parse((a.tSuc - a.t0).toStringAsFixed(1));
    final sc = double.parse((a.tk - a.tLiq).toStringAsFixed(1));
    final dt = double.parse((a.tRoom - a.t0).toStringAsFixed(1));
    final cop = a.pElecKw > 0 ? double.parse((a.p0Kw / a.pElecKw).toStringAsFixed(2)) : 0.0;

    int score = 100;
    final findings = <EngineeringAlert>[];

    String evapSt = 'ok';
    if (sh < 4.0) {
      evapSt = 'bad';
      score -= 22;
      findings.add(EngineeringAlert('bad', 'تحميص منخفض جداً ($sh K): خطر رجوع سائل التبريد للضاغط (Coup de liquide) — أغلق صمام التمدد قليلاً.'));
    } else if (sh > 13.0) {
      evapSt = 'warn';
      score -= 14;
      findings.add(EngineeringAlert('warn', 'تحميص مرتفع ($sh K): نقص تغذية المبخر أو نقص شحنة الغاز أو انسداد جزئي في الفلتر.'));
    } else {
      findings.add(EngineeringAlert('ok', 'التحميص عند السحب ($sh K) مثالي ويحمي الضاغط.'));
    }

    String txvSt = 'ok';
    if (sc < 2.5) {
      txvSt = 'warn';
      score -= 12;
      findings.add(EngineeringAlert('warn', 'التبريد الدوني منخفض ($sc K): احتمال وجود فقاعات غاز قبل صمام التمدد — افحص زجاجة البيان والشحنة.'));
    } else if (sc > 11.0) {
      txvSt = 'warn';
      score -= 10;
      findings.add(EngineeringAlert('warn', 'تبريد دوني مرتفع ($sc K): احتمال زيادة شحنة الوسيط في المكثف.'));
    }

    String condSt = 'ok';
    if (a.cleanliness == 'bad' || a.tk > 52.0) {
      condSt = 'bad';
      score -= 20;
      findings.add(EngineeringAlert('bad', 'ارتفاع ضغط/حرارة التكثيف (${a.tk}°C) أو اتساخ المكثف: يرفع الاستهلاك الكهربائي ويُتلف الضاغط — نظّف الزعانف فوراً.'));
    } else if (a.cleanliness == 'avg' || a.tk > 48.0) {
      condSt = 'warn';
      score -= 10;
      findings.add(EngineeringAlert('warn', 'حرارة التكثيف (${a.tk}°C) مرتفعة نسبياً — يُنصح بغسل المكثف وفحص تهوية المجموعة.'));
    }

    String compSt = 'ok';
    if (a.tDis > 110.0 || cop < 1.45) {
      compSt = 'bad';
      score -= 20;
      findings.add(EngineeringAlert('bad', 'حرارة الطرد مرتفعة (${a.tDis}°C) أو معامل أداء ضعيف (COP = $cop) — افحص صمامات الضاغط ونسبة الانضغاط.'));
    } else if (a.tDis > 95.0) {
      compSt = 'warn';
      score -= 10;
      findings.add(EngineeringAlert('warn', 'حرارة خط الطرد (${a.tDis}°C) عند الحد الأعلى المسموح.'));
    }

    String doorSt = 'ok';
    if (a.seals == 'bad') {
      doorSt = 'bad';
      score -= 16;
      findings.add(const EngineeringAlert('bad', 'تلف جوانات الباب أو العزل: يسبب دخول رطوبة وتراكم ثلج سريع على المبخر — استبدل الجوان فوراً.'));
    } else if (a.seals == 'avg') {
      doorSt = 'warn';
      score -= 8;
      findings.add(const EngineeringAlert('warn', 'جوانات الباب متوسطة الحالة — اضبط مفصلات الباب وافحص سخان الإطار.'));
    }

    return AuditResult(
      superheat: sh,
      subcooling: sc,
      evapDeltaT: dt,
      cop: cop,
      score: score.clamp(0, 100).toInt(),
      evapStatus: evapSt,
      compStatus: compSt,
      condStatus: condSt,
      txvStatus: txvSt,
      doorStatus: doorSt,
      findings: findings,
    );
  }
}

class _RankedComp {
  final ScoredCompressor sc;
  final double penalty;
  const _RankedComp(this.sc, this.penalty);
}
