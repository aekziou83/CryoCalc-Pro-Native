import 'dart:math' as math;

class ProductItem {
  final String id;
  final String name;
  final double cpAbove;
  final double cpBelow;
  final double tFreeze;
  final double latentFreeze;
  final double respirationWPerTon;
  final int targetRhPct;

  const ProductItem({
    required this.id,
    required this.name,
    required this.cpAbove,
    required this.cpBelow,
    required this.tFreeze,
    required this.latentFreeze,
    this.respirationWPerTon = 0,
    this.targetRhPct = 85,
  });
}

class RefrigerantProps {
  final String id;
  final String name;
  final double antoineA; // ln(P_bar_abs) = A - B / T_K
  final double antoineB;
  final double molarMass; // kg/kmol
  final double dhRefKjKg; // approx delta h evap at MT (kJ/kg)
  final double liquidDensityKgL; // kg/L at ~35C
  final String oilType;
  final int gwp;

  const RefrigerantProps({
    required this.id,
    required this.name,
    required this.antoineA,
    required this.antoineB,
    required this.molarMass,
    required this.dhRefKjKg,
    required this.liquidDensityKgL,
    required this.oilType,
    required this.gwp,
  });

  double satPressureBarAbs(double tempC) {
    final tk = (tempC + 273.15).clamp(190.0, 390.0);
    return math.exp(antoineA - (antoineB / tk));
  }
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

class ScientificComponentSizing {
  // Thermodynamic Cycle
  final double p0BarAbs;
  final double p0BarRel;
  final double pkBarAbs;
  final double pkBarRel;
  final double compressionRatio;
  final double dhEvapKjKg;
  final double massFlowKgH;
  final double suctionSpecVolM3Kg;

  // 1. Compressor
  final double volumetricEff;
  final double reqSweptVolM3h;
  final double estDischargeTempC;
  final String oilType;

  // 2. Evaporator
  final double evapDeltaT1K;
  final double evapSurfaceM2;
  final double evapFinSpacingMm;
  final int evapAirFlowM3h;
  final int evapBrassageVolH;
  final double defrostHeaterKw;

  // 3. Condenser
  final double condRejectionKw;
  final double condDeltaTK;
  final double condSurfaceM2;
  final int condAirFlowM3h;

  // 4. TXV & Orifice
  final double txvDeltaPBar;
  final double txvSubcoolingK;
  final double txvCorrFactorKsc;
  final double txvNominalCapKw;
  final String txvBody;
  final String txvOrificeNumber;
  final String txvMopNote;

  // 5. Filter Drier & Sight Glass
  final String filterDrierModel;
  final String filterConnInch;
  final String sightGlassModel;

  // 6. Oil Separator
  final double dischargeVelocityMs;
  final String dischargePipeInch;
  final String oilSeparatorModel;
  final double oilPreChargeL;
  final bool oilSeparatorMandatory;

  // 7. Liquid Receiver (EN 378 80% Rule)
  final double estTotalChargeKg;
  final double liquidDensityKgL;
  final double receiverMinVolL;
  final double receiverStdVolL;
  final String receiverModel;

  // 8. Suction Line Accumulator / Bouteille Anti-Coup de Liquide (ACL)
  final double aclMinVolL;
  final double aclStdVolL;
  final String aclModel;
  final String aclConnInch;
  final String aclBleedHoleMm;

  // 9. Solenoid & HP/LP Protection
  final String solenoidValve;
  final String hpLpSwitch;

  const ScientificComponentSizing({
    required this.p0BarAbs,
    required this.p0BarRel,
    required this.pkBarAbs,
    required this.pkBarRel,
    required this.compressionRatio,
    required this.dhEvapKjKg,
    required this.massFlowKgH,
    required this.suctionSpecVolM3Kg,
    required this.volumetricEff,
    required this.reqSweptVolM3h,
    required this.estDischargeTempC,
    required this.oilType,
    required this.evapDeltaT1K,
    required this.evapSurfaceM2,
    required this.evapFinSpacingMm,
    required this.evapAirFlowM3h,
    required this.evapBrassageVolH,
    required this.defrostHeaterKw,
    required this.condRejectionKw,
    required this.condDeltaTK,
    required this.condSurfaceM2,
    required this.condAirFlowM3h,
    required this.txvDeltaPBar,
    required this.txvSubcoolingK,
    required this.txvCorrFactorKsc,
    required this.txvNominalCapKw,
    required this.txvBody,
    required this.txvOrificeNumber,
    required this.txvMopNote,
    required this.filterDrierModel,
    required this.filterConnInch,
    required this.sightGlassModel,
    required this.dischargeVelocityMs,
    required this.dischargePipeInch,
    required this.oilSeparatorModel,
    required this.oilPreChargeL,
    required this.oilSeparatorMandatory,
    required this.estTotalChargeKg,
    required this.liquidDensityKgL,
    required this.receiverMinVolL,
    required this.receiverStdVolL,
    required this.receiverModel,
    required this.aclMinVolL,
    required this.aclStdVolL,
    required this.aclModel,
    required this.aclConnInch,
    required this.aclBleedHoleMm,
    required this.solenoidValve,
    required this.hpLpSwitch,
  });
}

class CryoInput {
  final String roomType;
  final String customRoomLabel;
  final double length;
  final double width;
  final double height;
  final double insMm;
  final double lambdaIns; // W/m.K (default 0.023 for PU, customizable)
  final double tInside;
  final double tAmbient;
  final double tFloor;
  final double opHours;
  final String productId;
  final double customCpAbove;
  final double customCpBelow;
  final double customLatent;
  final double dailyKg;
  final double tProdIn;
  final String doorTraffic;
  final double? customAirChanges;
  final String arch;
  final double pipeLen;
  final String defrostType;
  final double? customDefrostKw;
  final String refrigerant;
  final String customRefName;
  final String brandFilter;
  final String customCompBrandModel;
  final double? customCompCapKw;
  final double? customCompElecKw;
  final String voltageFilter;
  final double customVolt;
  final double customCosPhi;
  final double panelWidth;
  final String floorPanelMode;
  final double subcoolingK;
  final double superheatK;

  const CryoInput({
    this.roomType = 'positive',
    this.customRoomLabel = '',
    this.length = 6.0,
    this.width = 4.0,
    this.height = 3.0,
    this.insMm = 80.0,
    this.lambdaIns = 0.023,
    this.tInside = 2.0,
    this.tAmbient = 38.0,
    this.tFloor = 18.0,
    this.opHours = 16.0,
    this.productId = 'veg',
    this.customCpAbove = 3.5,
    this.customCpBelow = 1.8,
    this.customLatent = 240.0,
    this.dailyKg = 0.0,
    this.tProdIn = 20.0,
    this.doorTraffic = 'med',
    this.customAirChanges,
    this.arch = 'split',
    this.pipeLen = 10.0,
    this.defrostType = 'auto',
    this.customDefrostKw,
    this.refrigerant = 'R404A',
    this.customRefName = '',
    this.brandFilter = 'ALL',
    this.customCompBrandModel = '',
    this.customCompCapKw,
    this.customCompElecKw,
    this.voltageFilter = '400',
    this.customVolt = 400.0,
    this.customCosPhi = 0.84,
    this.panelWidth = 1.15,
    this.floorPanelMode = 'auto',
    this.subcoolingK = 5.0,
    this.superheatK = 7.0,
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
  final ScientificComponentSizing sizing;
  final List<EngineeringAlert> alerts;

  String get condDim => '${condDimMm[0]} × ${condDimMm[1]} × ${condDimMm[2]} mm';
  String get evapDim => '${evapDimMm[0]} × ${evapDimMm[1]} × ${evapDimMm[2]} mm';
  String get recommendedUnit => '${selectedUnit.item.brand} ${selectedUnit.item.model}';

  // Compatibility alias for room_3d_viewer.dart
  _CompatCircuit get circuit => _CompatCircuit(
        receiverLiters: sizing.receiverStdVolL,
        estChargeKg: sizing.estTotalChargeKg,
        txvSpec: '${sizing.txvBody} (${sizing.txvOrificeNumber})',
      );

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
    required this.sizing,
    required this.alerts,
  });
}

class _CompatCircuit {
  final double receiverLiters;
  final double estChargeKg;
  final String txvSpec;
  const _CompatCircuit({required this.receiverLiters, required this.estChargeKg, required this.txvSpec});
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
  final String customSealsNote;
  final String customCleanNote;

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
    this.customSealsNote = '',
    this.customCleanNote = '',
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
  static const List<String> allBrands = [
    'ALL',
    'Copeland',
    'Bitzer',
    'Dorin',
    'Frascold',
    'Danfoss',
    'Tecumseh',
    'L\'Unité Hermétique',
    'Bock (GEA)',
    'Embraco / Aspera',
    'Invotech',
    'Panasonic',
    'custom',
  ];

  static const List<RefrigerantProps> refrigerants = [
    RefrigerantProps(id: 'R404A', name: 'R404A (HFC Standard)', antoineA: 10.431, antoineB: 2358.0, molarMass: 97.6, dhRefKjKg: 118.0, liquidDensityKgL: 0.99, oilType: 'POE 32', gwp: 3922),
    RefrigerantProps(id: 'R449A', name: 'R449A (Opteon XP40)', antoineA: 10.765, antoineB: 2478.0, molarMass: 87.2, dhRefKjKg: 152.0, liquidDensityKgL: 1.07, oilType: 'POE 32', gwp: 1397),
    RefrigerantProps(id: 'R448A', name: 'R448A (Solstice N40)', antoineA: 10.780, antoineB: 2480.0, molarMass: 86.3, dhRefKjKg: 154.0, liquidDensityKgL: 1.06, oilType: 'POE 32', gwp: 1387),
    RefrigerantProps(id: 'R134a', name: 'R134a (MT / High Amb)', antoineA: 10.839, antoineB: 2668.6, molarMass: 102.0, dhRefKjKg: 142.0, liquidDensityKgL: 1.17, oilType: 'POE 32', gwp: 1430),
    RefrigerantProps(id: 'R407F', name: 'R407F (Performax LT)', antoineA: 10.805, antoineB: 2475.0, molarMass: 82.1, dhRefKjKg: 162.0, liquidDensityKgL: 1.05, oilType: 'POE 32', gwp: 1825),
    RefrigerantProps(id: 'R407C', name: 'R407C (MT Commercial)', antoineA: 10.881, antoineB: 2530.0, molarMass: 86.2, dhRefKjKg: 156.0, liquidDensityKgL: 1.09, oilType: 'POE 32', gwp: 1774),
    RefrigerantProps(id: 'R507A', name: 'R507A (Azeotropic LT)', antoineA: 10.417, antoineB: 2344.0, molarMass: 98.9, dhRefKjKg: 116.0, liquidDensityKgL: 0.99, oilType: 'POE 32', gwp: 3985),
    RefrigerantProps(id: 'R290', name: 'R290 (Propane Natural)', antoineA: 9.869, antoineB: 2271.0, molarMass: 44.1, dhRefKjKg: 278.0, liquidDensityKgL: 0.48, oilType: 'POE / Mineral', gwp: 3),
    RefrigerantProps(id: 'R744', name: 'R744 (CO₂ Subcritical)', antoineA: 10.860, antoineB: 1995.0, molarMass: 44.0, dhRefKjKg: 195.0, liquidDensityKgL: 0.78, oilType: 'POE 68 / PAG', gwp: 1),
    RefrigerantProps(id: 'custom', name: 'مخصص / Custom', antoineA: 10.600, antoineB: 2450.0, molarMass: 90.0, dhRefKjKg: 145.0, liquidDensityKgL: 1.05, oilType: 'POE 32', gwp: 1500),
  ];

  static const List<ProductItem> products = [
    ProductItem(id: 'veg', name: 'خضر وفواكه طازجة • Fruits & Légumes', cpAbove: 3.85, cpBelow: 1.95, tFreeze: -1.5, latentFreeze: 280, respirationWPerTon: 45, targetRhPct: 90),
    ProductItem(id: 'meat', name: 'لحوم حمراء طازجة • Fresh Meat', cpAbove: 3.20, cpBelow: 1.70, tFreeze: -1.8, latentFreeze: 230, targetRhPct: 85),
    ProductItem(id: 'poultry', name: 'دواجن طازجة / مجمدة • Poultry', cpAbove: 3.30, cpBelow: 1.75, tFreeze: -2.2, latentFreeze: 245, targetRhPct: 85),
    ProductItem(id: 'fish', name: 'أسماك ومأكولات بحرية • Seafood', cpAbove: 3.55, cpBelow: 1.85, tFreeze: -2.0, latentFreeze: 265, targetRhPct: 92),
    ProductItem(id: 'dairy', name: 'ألبان وأجبان • Dairy & Cheese', cpAbove: 3.60, cpBelow: 1.80, tFreeze: -1.0, latentFreeze: 250, targetRhPct: 82),
    ProductItem(id: 'potato', name: 'بطاطا وبصل • Potatoes & Onions', cpAbove: 3.50, cpBelow: 1.80, tFreeze: -1.0, latentFreeze: 260, respirationWPerTon: 25, targetRhPct: 88),
    ProductItem(id: 'frozen', name: 'منتجات مجمدة مسبقاً • Deep Frozen', cpAbove: 3.10, cpBelow: 1.75, tFreeze: -2.0, latentFreeze: 220, targetRhPct: 85),
    ProductItem(id: 'icecream', name: 'مثلجات • Ice Cream', cpAbove: 3.15, cpBelow: 1.90, tFreeze: -5.5, latentFreeze: 210, targetRhPct: 85),
    ProductItem(id: 'pharma', name: 'أدوية ومختبرات • Pharma', cpAbove: 2.80, cpBelow: 1.50, tFreeze: -1.0, latentFreeze: 180, targetRhPct: 65),
    ProductItem(id: 'custom', name: 'منتج مخصص • Custom Product', cpAbove: 3.50, cpBelow: 1.80, tFreeze: -1.5, latentFreeze: 240, targetRhPct: 85),
  ];

  static const List<String> _stdRefs = ['R404A', 'R449A', 'R448A', 'R407F', 'R507A', 'R134a', 'R407C', 'custom'];

  static const List<CompressorItem> compressors = [
    // --- EMBRACO / ASPERA ---
    CompressorItem(id: 'em1', brand: 'Embraco / Aspera', model: 'NT6222GK', tech: 'Hermetic Recip', regime: 'MT', dispM3h: 3.0, qMtKw: 1.65, qLtKw: 0.65, pElecKw: 0.85, volt: '230', dimMm: [600, 420, 420], refrigerants: _stdRefs),
    CompressorItem(id: 'em2', brand: 'Embraco / Aspera', model: 'NJ9232GK', tech: 'Hermetic Recip', regime: 'MT', dispM3h: 4.5, qMtKw: 2.55, qLtKw: 1.05, pElecKw: 1.25, volt: '230', dimMm: [680, 460, 480], refrigerants: _stdRefs),
    CompressorItem(id: 'em3', brand: 'Embraco / Aspera', model: 'NJ2212GK', tech: 'Hermetic LT', regime: 'LT', dispM3h: 5.9, qMtKw: 3.10, qLtKw: 1.35, pElecKw: 1.20, volt: '230', dimMm: [720, 480, 520], refrigerants: _stdRefs),

    // --- L'UNITE HERMETIQUE ---
    CompressorItem(id: 'uh1', brand: 'L\'Unité Hermétique', model: 'CAJ4519Z', tech: 'Hermetic', regime: 'MT', dispM3h: 5.9, qMtKw: 3.15, qLtKw: 1.25, pElecKw: 1.55, volt: '230', dimMm: [740, 480, 540], refrigerants: _stdRefs),
    CompressorItem(id: 'uh2', brand: 'L\'Unité Hermétique', model: 'TAJ4519Z', tech: 'Hermetic 3Ph', regime: 'MT', dispM3h: 6.0, qMtKw: 3.25, qLtKw: 1.30, pElecKw: 1.50, volt: '400', dimMm: [760, 490, 560], refrigerants: _stdRefs),
    CompressorItem(id: 'uh3', brand: 'L\'Unité Hermétique', model: 'TFH2511Z', tech: 'Hermetic LT', regime: 'LT', dispM3h: 12.9, qMtKw: 6.40, qLtKw: 2.75, pElecKw: 2.35, volt: '400', dimMm: [980, 540, 740], refrigerants: _stdRefs),

    // --- TECUMSEH ---
    CompressorItem(id: 'tc1', brand: 'Tecumseh', model: 'TFH4524Z', tech: 'Hermetic', regime: 'MT', dispM3h: 4.3, qMtKw: 2.35, qLtKw: 0.95, pElecKw: 1.15, volt: '230', dimMm: [680, 460, 480], refrigerants: _stdRefs),
    CompressorItem(id: 'tc2', brand: 'Tecumseh', model: 'TAG4561Z', tech: 'Hermetic', regime: 'MT', dispM3h: 19.6, qMtKw: 10.60, qLtKw: 4.50, pElecKw: 4.45, volt: '400', dimMm: [1320, 700, 980], refrigerants: _stdRefs),
    CompressorItem(id: 'tc3', brand: 'Tecumseh', model: 'TAG2522Z', tech: 'Hermetic LT', regime: 'LT', dispM3h: 23.4, qMtKw: 11.80, qLtKw: 5.10, pElecKw: 4.20, volt: '400', dimMm: [1380, 720, 1020], refrigerants: _stdRefs),

    // --- COPELAND ---
    CompressorItem(id: 'cp1', brand: 'Copeland', model: 'ZB15KCE-TFD', tech: 'Scroll', regime: 'MT', dispM3h: 5.9, qMtKw: 3.45, qLtKw: 1.40, pElecKw: 1.45, volt: '400', dimMm: [860, 480, 620], refrigerants: _stdRefs),
    CompressorItem(id: 'cp2', brand: 'Copeland', model: 'ZB26KCE-TFD', tech: 'Scroll', regime: 'MT', dispM3h: 9.9, qMtKw: 5.75, qLtKw: 2.40, pElecKw: 2.35, volt: '400', dimMm: [1020, 540, 760], refrigerants: _stdRefs),
    CompressorItem(id: 'cp3', brand: 'Copeland', model: 'ZB38KCE-TFD', tech: 'Scroll', regime: 'MT', dispM3h: 14.4, qMtKw: 8.35, qLtKw: 3.55, pElecKw: 3.40, volt: '400', dimMm: [1220, 660, 920], refrigerants: _stdRefs),
    CompressorItem(id: 'cp4', brand: 'Copeland', model: 'ZB45KCE-TFD', tech: 'Scroll', regime: 'MT', dispM3h: 17.1, qMtKw: 10.45, qLtKw: 4.45, pElecKw: 4.20, volt: '400', dimMm: [1320, 700, 980], refrigerants: _stdRefs),
    CompressorItem(id: 'cp5', brand: 'Copeland', model: 'ZB76KQE-TFD', tech: 'Scroll', regime: 'MT', dispM3h: 28.8, qMtKw: 17.60, qLtKw: 7.50, pElecKw: 6.90, volt: '400', dimMm: [1680, 880, 1260], refrigerants: _stdRefs),
    CompressorItem(id: 'cp6', brand: 'Copeland', model: 'ZF13K4E-TFD', tech: 'Scroll LT', regime: 'LT', dispM3h: 11.7, qMtKw: 6.20, qLtKw: 3.35, pElecKw: 2.45, volt: '400', dimMm: [1080, 580, 820], refrigerants: _stdRefs),
    CompressorItem(id: 'cp7', brand: 'Copeland', model: 'ZF18K4E-TFD', tech: 'Scroll LT', regime: 'LT', dispM3h: 17.1, qMtKw: 9.00, qLtKw: 4.95, pElecKw: 3.55, volt: '400', dimMm: [1260, 680, 960], refrigerants: _stdRefs),
    CompressorItem(id: 'cp8', brand: 'Copeland', model: 'ZFI36KQE-TFD (EVI)', tech: 'Scroll EVI', regime: 'LT', dispM3h: 29.1, qMtKw: 16.50, qLtKw: 10.60, pElecKw: 6.40, volt: '400', dimMm: [1650, 860, 1280], refrigerants: _stdRefs),

    // --- DANFOSS / MANEUROP ---
    CompressorItem(id: 'df1', brand: 'Danfoss', model: 'MTZ028-4', tech: 'Reciprocating', regime: 'MT', dispM3h: 8.4, qMtKw: 4.65, qLtKw: 1.90, pElecKw: 1.95, volt: '400', dimMm: [920, 510, 680], refrigerants: _stdRefs),
    CompressorItem(id: 'df2', brand: 'Danfoss', model: 'MTZ040-4', tech: 'Reciprocating', regime: 'MT', dispM3h: 11.8, qMtKw: 6.65, qLtKw: 2.75, pElecKw: 2.75, volt: '400', dimMm: [1080, 580, 800], refrigerants: _stdRefs),
    CompressorItem(id: 'df3', brand: 'Danfoss', model: 'MTZ064-4', tech: 'Reciprocating', regime: 'MT', dispM3h: 18.7, qMtKw: 10.90, qLtKw: 4.55, pElecKw: 4.40, volt: '400', dimMm: [1340, 710, 990], refrigerants: _stdRefs),
    CompressorItem(id: 'df4', brand: 'Danfoss', model: 'NTZ068-4', tech: 'Reciprocating LT', regime: 'LT', dispM3h: 11.8, qMtKw: 5.80, qLtKw: 2.45, pElecKw: 1.95, volt: '400', dimMm: [980, 540, 740], refrigerants: _stdRefs),
    CompressorItem(id: 'df5', brand: 'Danfoss', model: 'NTZ136-4', tech: 'Reciprocating LT', regime: 'LT', dispM3h: 23.6, qMtKw: 11.80, qLtKw: 5.30, pElecKw: 4.10, volt: '400', dimMm: [1420, 740, 1060], refrigerants: _stdRefs),

    // --- BITZER ---
    CompressorItem(id: 'bz1', brand: 'Bitzer', model: '2EES-2Y', tech: 'Semi-Hermetic', regime: 'MT', dispM3h: 11.4, qMtKw: 6.45, qLtKw: 2.80, pElecKw: 2.65, volt: '400', dimMm: [1100, 620, 820], refrigerants: [..._stdRefs, 'R290']),
    CompressorItem(id: 'bz2', brand: 'Bitzer', model: '4FES-5Y', tech: 'Semi-Hermetic', regime: 'MT', dispM3h: 18.1, qMtKw: 11.20, qLtKw: 4.90, pElecKw: 4.45, volt: '400', dimMm: [1380, 740, 1020], refrigerants: [..._stdRefs, 'R290']),
    CompressorItem(id: 'bz3', brand: 'Bitzer', model: '4EES-4Y', tech: 'Semi-Hermetic LT', regime: 'LT', dispM3h: 22.7, qMtKw: 12.10, qLtKw: 6.15, pElecKw: 4.30, volt: '400', dimMm: [1420, 760, 1080], refrigerants: [..._stdRefs, 'R290']),
    CompressorItem(id: 'bz4', brand: 'Bitzer', model: '4TES-9Y', tech: 'Semi-Hermetic', regime: 'MT', dispM3h: 41.3, qMtKw: 24.50, qLtKw: 10.80, pElecKw: 9.60, volt: '400', dimMm: [1920, 960, 1420], refrigerants: [..._stdRefs, 'R290']),
    CompressorItem(id: 'bz5', brand: 'Bitzer', model: '4PES-12Y', tech: 'Semi-Hermetic LT', regime: 'LT', dispM3h: 48.5, qMtKw: 26.00, qLtKw: 14.50, pElecKw: 9.80, volt: '400', dimMm: [1980, 980, 1480], refrigerants: [..._stdRefs, 'R290']),
    CompressorItem(id: 'bz6', brand: 'Bitzer', model: '6GE-34Y', tech: 'Semi-Hermetic 6-Cyl', regime: 'MT', dispM3h: 126.8, qMtKw: 68.50, qLtKw: 31.20, pElecKw: 26.50, volt: '400', dimMm: [2400, 1250, 1750], refrigerants: [..._stdRefs, 'R744']),

    // --- DORIN ---
    CompressorItem(id: 'dr1', brand: 'Dorin', model: 'H380CC', tech: 'Semi-Hermetic', regime: 'MT', dispM3h: 16.4, qMtKw: 9.55, qLtKw: 4.10, pElecKw: 3.85, volt: '400', dimMm: [1280, 680, 960], refrigerants: _stdRefs),
    CompressorItem(id: 'dr2', brand: 'Dorin', model: 'H751CC', tech: 'Semi-Hermetic', regime: 'MT', dispM3h: 32.1, qMtKw: 19.10, qLtKw: 8.40, pElecKw: 7.45, volt: '400', dimMm: [1720, 880, 1280], refrigerants: _stdRefs),
    CompressorItem(id: 'dr3', brand: 'Dorin', model: 'H1501CC', tech: 'Semi-Hermetic LT', regime: 'LT', dispM3h: 44.0, qMtKw: 23.00, qLtKw: 12.40, pElecKw: 8.60, volt: '400', dimMm: [1880, 940, 1380], refrigerants: _stdRefs),

    // --- FRASCOLD ---
    CompressorItem(id: 'fr1', brand: 'Frascold', model: 'A1.5-7Y', tech: 'Semi-Hermetic', regime: 'MT', dispM3h: 6.9, qMtKw: 3.90, qLtKw: 1.65, pElecKw: 1.60, volt: '400', dimMm: [900, 500, 660], refrigerants: _stdRefs),
    CompressorItem(id: 'fr2', brand: 'Frascold', model: 'D4-18.1Y', tech: 'Semi-Hermetic', regime: 'MT', dispM3h: 18.0, qMtKw: 11.00, qLtKw: 4.80, pElecKw: 4.40, volt: '400', dimMm: [1360, 720, 1000], refrigerants: _stdRefs),
    CompressorItem(id: 'fr3', brand: 'Frascold', model: 'Q5-25.1Y', tech: 'Semi-Hermetic LT', regime: 'LT', dispM3h: 24.7, qMtKw: 13.00, qLtKw: 6.85, pElecKw: 4.85, volt: '400', dimMm: [1480, 780, 1120], refrigerants: _stdRefs),

    // --- BOCK (GEA) ---
    CompressorItem(id: 'bk1', brand: 'Bock (GEA)', model: 'HGX22e/190-4', tech: 'Semi-Hermetic', regime: 'MT', dispM3h: 16.5, qMtKw: 9.80, qLtKw: 4.25, pElecKw: 3.90, volt: '400', dimMm: [1300, 690, 970], refrigerants: [..._stdRefs, 'R290', 'R744']),
    CompressorItem(id: 'bk2', brand: 'Bock (GEA)', model: 'HGX34e/315-4', tech: 'Semi-Hermetic', regime: 'MT', dispM3h: 27.3, qMtKw: 16.40, qLtKw: 7.20, pElecKw: 6.45, volt: '400', dimMm: [1620, 840, 1220], refrigerants: [..._stdRefs, 'R290']),
    CompressorItem(id: 'bk3', brand: 'Bock (GEA)', model: 'HGX44e/565-4', tech: 'Semi-Hermetic LT', regime: 'LT', dispM3h: 49.0, qMtKw: 26.50, qLtKw: 14.80, pElecKw: 9.90, volt: '400', dimMm: [1990, 990, 1490], refrigerants: [..._stdRefs, 'R290']),

    // --- INVOTECH ---
    CompressorItem(id: 'iv1', brand: 'Invotech', model: 'YM49E1G', tech: 'Scroll', regime: 'MT', dispM3h: 8.8, qMtKw: 5.10, qLtKw: 2.15, pElecKw: 2.10, volt: '400', dimMm: [960, 520, 720], refrigerants: _stdRefs),
    CompressorItem(id: 'iv2', brand: 'Invotech', model: 'YM86E1G', tech: 'Scroll', regime: 'MT', dispM3h: 14.9, qMtKw: 8.65, qLtKw: 3.70, pElecKw: 3.55, volt: '400', dimMm: [1240, 660, 930], refrigerants: _stdRefs),
    CompressorItem(id: 'iv3', brand: 'Invotech', model: 'YF25E1G', tech: 'Scroll LT', regime: 'LT', dispM3h: 16.6, qMtKw: 8.80, qLtKw: 4.80, pElecKw: 3.45, volt: '400', dimMm: [1250, 670, 950], refrigerants: _stdRefs),

    // --- PANASONIC ---
    CompressorItem(id: 'pn1', brand: 'Panasonic', model: 'C-SB303H8A', tech: 'Scroll', regime: 'MT', dispM3h: 11.2, qMtKw: 6.40, qLtKw: 2.65, pElecKw: 2.60, volt: '400', dimMm: [1060, 560, 790], refrigerants: _stdRefs),
    CompressorItem(id: 'pn2', brand: 'Panasonic', model: 'C-SB453H8A', tech: 'Scroll', regime: 'MT', dispM3h: 17.4, qMtKw: 10.50, qLtKw: 4.40, pElecKw: 4.25, volt: '400', dimMm: [1330, 700, 980], refrigerants: _stdRefs),
  ];

  static CryoResult calculate(CryoInput inp, {String? forcedCompId}) {
    final l = math.max(1.2, inp.length);
    final w = math.max(1.2, inp.width);
    final h = math.max(1.8, inp.height);
    final vol = l * w * h;
    final areaFloor = l * w;
    final areaWalls = 2 * (l + w) * h;

    final insM = math.max(0.03, inp.insMm / 1000.0);
    final uVal = inp.lambdaIns.clamp(0.015, 0.060) / insM;
    final dTWall = math.max(2.0, inp.tAmbient - inp.tInside);
    final dTFloor = math.max(2.0, inp.tFloor - inp.tInside);
    final floorInsIncluded = inp.floorPanelMode == 'yes' ||
        inp.floorPanelMode == 'custom' ||
        (inp.floorPanelMode == 'auto' && inp.tInside <= 0);
    final qWallsW = (areaWalls + areaFloor) * uVal * dTWall;
    final qFloorW = areaFloor * uVal * dTFloor * (floorInsIncluded ? 0.90 : 1.45);
    final qTransW = qWallsW + qFloorW;

    final prodBase = products.firstWhere((p) => p.id == inp.productId, orElse: () => products.first);
    final cpA = inp.productId == 'custom' ? inp.customCpAbove : prodBase.cpAbove;
    final cpB = inp.productId == 'custom' ? inp.customCpBelow : prodBase.cpBelow;
    final lat = inp.productId == 'custom' ? inp.customLatent : prodBase.latentFreeze;

    double qProdKj = 0;
    if (inp.dailyKg > 0 && inp.tProdIn > inp.tInside) {
      if (inp.tInside < prodBase.tFreeze && inp.tProdIn > prodBase.tFreeze) {
        qProdKj = inp.dailyKg *
            (cpA * (inp.tProdIn - prodBase.tFreeze) +
                lat +
                cpB * (prodBase.tFreeze - inp.tInside));
      } else if (inp.tProdIn <= prodBase.tFreeze) {
        qProdKj = inp.dailyKg * cpB * (inp.tProdIn - inp.tInside);
      } else {
        qProdKj = inp.dailyKg * cpA * (inp.tProdIn - inp.tInside);
      }
    }
    final qRespW = (inp.tInside > 0 && prodBase.respirationWPerTon > 0)
        ? ((inp.dailyKg * 3.0) / 1000.0) * prodBase.respirationWPerTon
        : 0.0;
    final qProdW = (qProdKj * 1000.0) / 86400.0 + qRespW;

    final trMult = inp.doorTraffic == 'high' ? 1.55 : (inp.doorTraffic == 'low' ? 0.65 : 1.0);
    final airChanges = (inp.doorTraffic == 'custom' && inp.customAirChanges != null && inp.customAirChanges! > 0)
        ? inp.customAirChanges!
        : (vol < 30 ? 12.0 : vol < 100 ? 7.5 : 4.5) * trMult;
    final dH = dTWall * 1.45 + (inp.tInside < 0 ? 18.0 : 8.0);
    final qInfilW = (vol * airChanges * dH * 1000.0) / 86400.0;

    final qLightW = areaFloor * 9.0 * (4.0 / 24.0);
    final qStaffW = (vol > 50 ? 2 : 1) * 240.0 * (2.5 / 24.0);
    final isElecDefrost = inp.defrostType == 'electric' ||
        inp.defrostType == 'custom' ||
        (inp.defrostType == 'auto' && inp.tInside <= 2.0);
    final baseW = qTransW + qProdW + qInfilW + qLightW + qStaffW;
    final qFanDefW = baseW * (isElecDefrost ? 0.14 : 0.08);
    final qIntW = qLightW + qStaffW + qFanDefW;

    final qTotal24W = (qTransW + qProdW + qInfilW + qIntW) * 1.10;
    final opH = inp.opHours.clamp(10.0, 22.0).toDouble();
    final q0Kw = double.parse(((qTotal24W * (24.0 / opH)) / 1000.0).toStringAsFixed(2));
    final kcalH = (q0Kw * 860).round();
    final btuH = (q0Kw * 3412).round();

    final isLT = inp.tInside <= -5.0 || inp.roomType == 'negative' || inp.roomType == 'tunnel';
    final evapDt1 = inp.roomType == 'tunnel'
        ? 8.0
        : (prodBase.targetRhPct >= 90 ? 5.5 : (isLT ? 6.5 : 7.0));
    final t0 = double.parse((inp.tInside - evapDt1).toStringAsFixed(1));
    final condDt = inp.tAmbient >= 40 ? 11.0 : 12.0;
    final tk = double.parse((inp.tAmbient + condDt).toStringAsFixed(1));

    // --- Compressor Selection & Custom Brand Support ---
    final targetRegime = isLT ? 'LT' : 'MT';
    final vNom = inp.voltageFilter == 'custom'
        ? inp.customVolt.clamp(110.0, 690.0)
        : (inp.voltageFilter == '230' ? 230.0 : (inp.voltageFilter == '440' ? 440.0 : 400.0));
    final is3Ph = vNom >= 350.0;
    final cosPhi = inp.customCosPhi.clamp(0.7, 0.98);

    double calcAmps(double pKw, double volt) {
      final three = volt >= 350.0;
      return double.parse(((pKw * 1000.0) / (three ? (volt * 1.732 * cosPhi) : (volt * 0.85))).toStringAsFixed(1));
    }

    List<ScoredCompressor> candidates;
    if (inp.brandFilter == 'custom') {
      final cap = (inp.customCompCapKw != null && inp.customCompCapKw! > 0) ? inp.customCompCapKw! : q0Kw * 1.1;
      final pEl = (inp.customCompElecKw != null && inp.customCompElecKw! > 0) ? inp.customCompElecKw! : q0Kw / (isLT ? 1.8 : 2.6);
      final nameStr = inp.customCompBrandModel.trim().isEmpty ? 'Custom Unit' : inp.customCompBrandModel.trim();
      final customItem = CompressorItem(
        id: 'custom_unit',
        brand: 'Custom',
        model: nameStr,
        tech: isLT ? 'Custom LT' : 'Custom MT',
        regime: targetRegime,
        dispM3h: double.parse((cap * (isLT ? 3.5 : 1.7)).toStringAsFixed(1)),
        qMtKw: cap,
        qLtKw: cap,
        pElecKw: double.parse(pEl.toStringAsFixed(2)),
        volt: vNom.toInt().toString(),
        dimMm: [1200, 650, 900],
        refrigerants: [inp.refrigerant],
      );
      candidates = [
        ScoredCompressor(
          item: customItem,
          adjustedCapKw: double.parse(cap.toStringAsFixed(2)),
          coveragePct: double.parse(((cap / math.max(0.4, q0Kw)) * 100.0).toStringAsFixed(0)),
          currentAmps: calcAmps(pEl, vNom),
        ),
      ];
    } else {
      final list = compressors
          .where((c) =>
              (c.refrigerants.contains(inp.refrigerant) || inp.refrigerant == 'custom') &&
              (inp.brandFilter == 'ALL' || c.brand == inp.brandFilter))
          .map((c) {
        final rawCap = isLT ? c.qLtKw : c.qMtKw;
        final adjCap = double.parse((rawCap * (1.0 - (tk - 45.0) * 0.012)).toStringAsFixed(2));
        final ratio = adjCap / math.max(0.4, q0Kw);
        final cVolt = double.tryParse(c.volt) ?? 400.0;
        final amps = calcAmps(c.pElecKw, cVolt);
        final voltPenalty = (inp.voltageFilter == 'custom' || c.volt == inp.voltageFilter) ? 0.0 : 0.35;
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
      candidates = list.take(8).map((e) => e.sc).toList();
    }

    final fallback = ScoredCompressor(
      item: compressors.first,
      adjustedCapKw: q0Kw,
      coveragePct: 100,
      currentAmps: calcAmps(q0Kw * 0.42, vNom),
    );
    final selectedUnit = candidates.firstWhere(
      (c) => c.item.id == forcedCompId,
      orElse: () => candidates.isNotEmpty ? candidates.first : fallback,
    );

    // --- Physical Dimensions ---
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

    // --- Piping Diameters ---
    String suc = '5/8"', liq = '3/8"', dis = '1/2"';
    if (q0Kw < 2.2) {
      suc = isLT ? '5/8"' : '1/2"';
      dis = '3/8"';
    } else if (q0Kw < 5.5) {
      suc = isLT ? '7/8"' : '5/8"';
      dis = '1/2"';
    } else if (q0Kw < 11.5) {
      suc = isLT ? '1-1/8"' : '7/8"';
      liq = '1/2"';
      dis = '5/8"';
    } else if (q0Kw < 20.0) {
      suc = isLT ? '1-3/8"' : '1-1/8"';
      liq = '5/8"';
      dis = '7/8"';
    } else {
      suc = isLT ? '1-5/8"' : '1-3/8"';
      liq = '7/8"';
      dis = '1-1/8"';
    }

    // =========================================================================
    // SCIENTIFIC THERMODYNAMIC SIZING OF ALL 9 REFRIGERATION COMPONENTS
    // =========================================================================
    final refProps = refrigerants.firstWhere((r) => r.id == inp.refrigerant, orElse: () => refrigerants.first);
    final p0Abs = double.parse(refProps.satPressureBarAbs(t0).toStringAsFixed(2));
    final pkAbs = double.parse(refProps.satPressureBarAbs(tk).toStringAsFixed(2));
    final p0Rel = double.parse((p0Abs - 1.013).toStringAsFixed(2));
    final pkRel = double.parse((pkAbs - 1.013).toStringAsFixed(2));
    final tau = double.parse((pkAbs / math.max(0.5, p0Abs)).toStringAsFixed(2));

    // Enthalpy difference adjusted for subcooling & evaporating temp
    final sc = inp.subcoolingK.clamp(1.0, 15.0);
    final sh = inp.superheatK.clamp(3.0, 15.0);
    final dhEvap = double.parse(
      (refProps.dhRefKjKg * (1.0 - (tk - 40.0) * 0.008 + (sc - 4.0) * 0.009 - (isLT ? 0.08 : 0.0))).clamp(65.0, 320.0).toStringAsFixed(1),
    );
    // Mass flow rate: m_dot = Q0 / delta_h
    final mDotKgS = q0Kw / dhEvap;
    final mDotKgH = double.parse((mDotKgS * 3600.0).toStringAsFixed(1));

    // Real-gas suction vapor specific volume v'' = (R * T_suc * Z) / (M * P0)
    final tSucK = (t0 + sh) + 273.15;
    final vSuc = double.parse(((8.3145 * tSucK * 0.86) / (refProps.molarMass * p0Abs * 100.0)).toStringAsFixed(4));

    // 1. Compressor: Volumetric efficiency & Required swept volume Vb
    final etaV = double.parse((1.0 - 0.05 * tau).clamp(0.52, 0.90).toStringAsFixed(2));
    final reqVb = double.parse(((mDotKgH * vSuc) / etaV).toStringAsFixed(2));
    // Polytropic discharge temp estimation: T_dis = T_suc * tau^((n-1)/n)
    final tDisC = double.parse(((tSucK * math.pow(tau, 0.165)) - 273.15).clamp(55.0, 132.0).toStringAsFixed(1));

    // 2. Evaporator: Surface Area, Fin Spacing, Airflow & Brassage
    final kEvap = isLT ? 24.0 : 28.0; // W/(m2.K) forced convection finned coil
    final evapAreaM2 = double.parse(((q0Kw * 1000.0) / (kEvap * evapDt1)).toStringAsFixed(1));
    final finMm = inp.roomType == 'tunnel' ? 9.0 : (isLT ? 7.0 : 4.5);
    final brassage = inp.roomType == 'tunnel' ? 90 : (isLT ? 50 : 40);
    final evapAirFlow = math.max((vol * brassage).round(), (q0Kw * 680).round());
    final defrostKw = (inp.defrostType == 'custom' && inp.customDefrostKw != null)
        ? inp.customDefrostKw!
        : (isElecDefrost ? double.parse((q0Kw * 0.42).clamp(1.2, 16.0).toStringAsFixed(1)) : 0.0);

    // 3. Condenser: Heat Rejection Qk = Q0 + P_elec & Airflow
    final qCondKw = double.parse((q0Kw + selectedUnit.item.pElecKw).toStringAsFixed(2));
    final condAreaM2 = double.parse(((qCondKw * 1000.0) / (32.0 * condDt)).toStringAsFixed(1));
    // V_air = Qk * 3600 / (rho_air * cp_air * dT_air) with dT_air = 6.5 K
    final condAirFlow = ((qCondKw * 3600.0) / (1.18 * 1.005 * 6.5)).round();

    // 4. TXV & Orifice Calculation (Danfoss TES2 / TEX2 / TE5 Method)
    final dpLineAndDist = 1.6 + (inp.pipeLen * 0.03);
    final dpEff = double.parse((pkAbs - p0Abs - dpLineAndDist).clamp(2.5, 22.0).toStringAsFixed(1));
    final kSc = double.parse((1.0 + (sc - 4.0) * 0.014).clamp(0.90, 1.20).toStringAsFixed(2));
    // Normalize Q0 to standard deltaP = 6 bar (MT) or 8 bar (LT)
    final refDp = isLT ? 8.0 : 6.0;
    final dpFactor = math.sqrt(dpEff / refDp);
    final txvNomKw = double.parse((q0Kw / (kSc * dpFactor)).toStringAsFixed(2));

    String txvBody = isLT ? 'Danfoss TES2 / Alco TI' : 'Danfoss TEX2 / TES2';
    String orifice = 'Orifice 01';
    if (txvNomKw < 1.2) {
      orifice = 'Orifice 0X (0.6–1.2 kW)';
    } else if (txvNomKw < 2.2) {
      orifice = 'Orifice 00 (1.2–2.2 kW)';
    } else if (txvNomKw < 3.6) {
      orifice = 'Orifice 01 (2.2–3.6 kW)';
    } else if (txvNomKw < 5.2) {
      orifice = 'Orifice 02 (3.6–5.2 kW)';
    } else if (txvNomKw < 7.6) {
      orifice = 'Orifice 03 (5.2–7.6 kW)';
    } else if (txvNomKw < 10.5) {
      orifice = 'Orifice 04 (7.6–10.5 kW)';
    } else if (txvNomKw < 14.2) {
      orifice = 'Orifice 05 (10.5–14.2 kW)';
    } else if (txvNomKw < 18.5) {
      orifice = 'Orifice 06 (14.2–18.5 kW)';
    } else {
      txvBody = 'Danfoss TE5 / Alco TCLE';
      orifice = txvNomKw < 26 ? 'TE5 Orifice 01' : (txvNomKw < 36 ? 'TE5 Orifice 02' : 'TE5 Orifice 03');
    }
    final mopNote = isLT ? 'MOP -15°C / -20°C لحماية الضاغط عند الإقلاع' : 'بدون MOP (أو MOP +15°C)';

    // 5. Filter Drier & Sight Glass
    final drierModel = liq == '3/8"'
        ? (q0Kw < 3.5 ? 'Danfoss DML 083 (3/8")' : 'Danfoss DML 163 (3/8")')
        : (liq == '1/2"' ? 'Danfoss DML 164 (1/2")' : (liq == '5/8"' ? 'Danfoss DML 305 (5/8")' : 'Danfoss DML 417 (7/8")'));
    final sightGlass = 'Danfoss SGN / Castel 3940 ($liq)';

    // 6. Oil Separator (Séparateur d'huile)
    final disIdMm = dis == '3/8"' ? 7.9 : dis == '1/2"' ? 10.9 : dis == '5/8"' ? 13.8 : dis == '7/8"' ? 20.2 : 26.0;
    final vDisGas = (8.3145 * (tDisC + 273.15) * 0.90) / (refProps.molarMass * pkAbs * 100.0);
    final pipeAreaM2 = math.pi * math.pow((disIdMm / 1000.0) / 2.0, 2);
    final disVel = double.parse(((mDotKgS * vDisGas) / pipeAreaM2).clamp(3.0, 24.0).toStringAsFixed(1));
    final oilSepMandatory = isLT || inp.pipeLen > 15.0 || inp.arch == 'rack';
    final oilSepModel = q0Kw < 5
        ? 'Castel 5540/4 ($dis)'
        : q0Kw < 12
            ? 'Castel 5540/5 ($dis)'
            : q0Kw < 22
                ? 'Castel 5540/7 ($dis)'
                : 'Castel 5540/9 ($dis)';
    final oilPreCharge = q0Kw < 5 ? 0.45 : (q0Kw < 15 ? 0.65 : 1.0);

    // 7. Liquid Receiver (Réservoir liquide — EN 378 80% Max Fill Rule)
    final chargeEvap = q0Kw * 0.22;
    final chargeCond = qCondKw * 0.20;
    final chargePiping = inp.pipeLen * (liq == '3/8"' ? 0.055 : liq == '1/2"' ? 0.10 : 0.16);
    final totalChargeKg = double.parse((chargeEvap + chargeCond + chargePiping).clamp(1.2, 65.0).toStringAsFixed(2));
    final recMinL = double.parse(((totalChargeKg / (0.80 * refProps.liquidDensityKgL)) * 1.20).toStringAsFixed(1));
    final stdReceivers = [2.3, 3.9, 5.6, 8.0, 10.0, 12.0, 16.0, 20.0, 25.0, 35.0, 50.0, 75.0];
    final recStdL = stdReceivers.firstWhere((v) => v >= recMinL, orElse: () => 75.0);
    final recModel = 'Carly / Castel Réservoir ${recStdL}L (PS 33 bar)';

    // 8. Suction Line Accumulator / Bouteille Anti-Coup de Liquide (ACL)
    // Standard rule: holds >= 55% of total refrigerant charge at T0 liquid density
    final rhoLiqT0 = refProps.liquidDensityKgL * 1.12;
    final aclMinL = double.parse(((totalChargeKg * 0.55) / rhoLiqT0).clamp(1.0, 45.0).toStringAsFixed(1));
    final stdAcls = [1.5, 2.3, 3.5, 5.0, 7.5, 10.0, 14.0, 20.0, 30.0, 45.0];
    final aclStdL = stdAcls.firstWhere((v) => v >= aclMinL, orElse: () => 45.0);
    final aclModel = 'Carly LCY / Castel 5520 (${aclStdL}L • $suc)';
    final aclBleed = q0Kw < 6 ? '1.5 mm' : (q0Kw < 15 ? '2.0 mm' : '2.5 mm');

    // 9. Solenoid & HP/LP Switch
    final solValve = 'Danfoss EVR ${q0Kw < 6 ? "3" : q0Kw < 14 ? "6" : "10"} ($liq • 230V)';
    final hpCut = (pkAbs + 4.5).clamp(16.0, 30.0).toStringAsFixed(1);
    final lpCut = math.max(0.3, p0Rel - 0.6).toStringAsFixed(1);
    final hpLp = 'Danfoss KP15 (HP: $hpCut bar / LP: $lpCut bar)';

    final sizing = ScientificComponentSizing(
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
      evapAirFlowM3h: evapAirFlow,
      evapBrassageVolH: brassage,
      defrostHeaterKw: defrostKw,
      condRejectionKw: qCondKw,
      condDeltaTK: condDt,
      condSurfaceM2: condAreaM2,
      condAirFlowM3h: condAirFlow,
      txvDeltaPBar: dpEff,
      txvSubcoolingK: sc,
      txvCorrFactorKsc: kSc,
      txvNominalCapKw: txvNomKw,
      txvBody: txvBody,
      txvOrificeNumber: orifice,
      txvMopNote: mopNote,
      filterDrierModel: drierModel,
      filterConnInch: liq,
      sightGlassModel: sightGlass,
      dischargeVelocityMs: disVel,
      dischargePipeInch: dis,
      oilSeparatorModel: oilSepModel,
      oilPreChargeL: oilPreCharge,
      oilSeparatorMandatory: oilSepMandatory,
      estTotalChargeKg: totalChargeKg,
      liquidDensityKgL: refProps.liquidDensityKgL,
      receiverMinVolL: recMinL,
      receiverStdVolL: recStdL,
      receiverModel: recModel,
      aclMinVolL: aclMinL,
      aclStdVolL: aclStdL,
      aclModel: aclModel,
      aclConnInch: suc,
      aclBleedHoleMm: aclBleed,
      solenoidValve: solValve,
      hpLpSwitch: hpLp,
    );

    // Electrical Sizing
    final iNom = selectedUnit.currentAmps;
    final breakerVal = iNom <= 6 ? 10 : iNom <= 10 ? 16 : iNom <= 16 ? 20 : iNom <= 22 ? 32 : iNom <= 32 ? 40 : 63;
    final contactorVal = iNom <= 9 ? 12 : iNom <= 16 ? 18 : iNom <= 24 ? 25 : iNom <= 38 ? 40 : 65;
    final cableMm2 = iNom <= 10 ? '2.5' : iNom <= 16 ? '4.0' : iNom <= 25 ? '6.0' : iNom <= 36 ? '10.0' : '16.0';
    final electrical = ElectricalSizing(
      nominalAmps: iNom,
      breakerRating: '${is3Ph ? "3P+N" : "1P+N"} ${breakerVal}A (Courbe D)',
      contactorRating: 'LC1D$contactorVal (${contactorVal}A AC-3)',
      overloadRange: '${(iNom * 0.85).toStringAsFixed(1)} – ${(iNom * 1.25).toStringAsFixed(1)} A',
      cableSection: '${is3Ph ? "5G" : "3G"} $cableMm2 mm² (Cu RO2V)',
      defrostHeaterKw: defrostKw,
    );

    // Panels BOM
    final pw = inp.panelWidth.clamp(0.5, 2.0);
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
      alerts.add(EngineeringAlert('bad', 'PU ${inp.insMm.toInt()} mm < 140 mm (Tunnel ${inp.tInside}°C) — يوصى بـ 160–200 mm.'));
    } else if (inp.tInside <= -15 && inp.insMm < 100) {
      alerts.add(EngineeringAlert('warn', 'PU ${inp.insMm.toInt()} mm < 120 mm (${inp.tInside}°C) — يفضل 120 mm على الأقل.'));
    } else {
      alerts.add(EngineeringAlert('ok', 'PU ${inp.insMm.toInt()} mm (U = ${uVal.toStringAsFixed(2)} W/m²·K) متوافق مع ${inp.tInside}°C.'));
    }
    if (tau > 8.0) {
      alerts.add(EngineeringAlert('warn', 'نسبة الانضغاط مرتفعة (τ = $tau > 8): يوصى بضاغط EVI أو مرحلتين + فاصل زيت + زجاجة ACL.'));
    }
    if (inp.tInside <= -5) {
      alerts.add(const EngineeringAlert('warn', 'غرفة سالبة: إلزامي صمام موازنة الضغط (Soupape) + سخان إطار الباب + عزل أرضي + ACL.'));
    }
    if (throwM < l * 0.85) {
      alerts.add(EngineeringAlert('warn', 'طول الغرفة (${l.toStringAsFixed(1)} m) أكبر من مدى دفع المبخر ($throwM m).'));
    }
    if (inp.pipeLen > 18) {
      alerts.add(EngineeringAlert('warn', 'طول النحاس (${inp.pipeLen.toInt()} m): ركّب مصائد زيت (Pièges à huile) + فاصل زيت.'));
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
      sizing: sizing,
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
      findings.add(EngineeringAlert('bad', 'SH = $sh K (<4K): خطر ضربة السائل (Coup de liquide) — أغلق المنظم TXV قليلاً وتأكد من وجود ACL.'));
    } else if (sh > 13.0) {
      evapSt = 'warn';
      score -= 14;
      findings.add(EngineeringAlert('warn', 'SH = $sh K (>13K): نقص تغذية المبخر أو شحنة الغاز أو انسداد الفلتر/الأورفيس.'));
    } else {
      findings.add(EngineeringAlert('ok', 'التحميص SH = $sh K مثالي (5–10 K).'));
    }

    String txvSt = 'ok';
    if (sc < 2.5) {
      txvSt = 'warn';
      score -= 12;
      findings.add(EngineeringAlert('warn', 'SC = $sc K (<2.5K): تبريد دوني منخفض — افحص زجاجة البيان وشحنة الغاز.'));
    } else if (sc > 11.0) {
      txvSt = 'warn';
      score -= 10;
      findings.add(EngineeringAlert('warn', 'SC = $sc K (>11K): احتمال زيادة شحنة الوسيط في المكثف.'));
    } else {
      findings.add(EngineeringAlert('ok', 'التبريد الدوني SC = $sc K سليم (4–8 K).'));
    }

    String condSt = 'ok';
    if (a.cleanliness == 'bad' || a.tk > 52.0) {
      condSt = 'bad';
      score -= 20;
      findings.add(EngineeringAlert('bad', 'Tk = ${a.tk}°C / المكثف متسخ: نظّف الزعانف وافحص المراوح فوراً.'));
    } else if (a.cleanliness == 'avg' || a.tk > 48.0) {
      condSt = 'warn';
      score -= 10;
      findings.add(EngineeringAlert('warn', 'Tk = ${a.tk}°C مرتفعة نسبياً — يُنصح بغسل المكثف.'));
    }
    if (a.cleanliness == 'custom' && a.customCleanNote.isNotEmpty) {
      findings.add(EngineeringAlert('warn', 'ملاحظة المكثف المخصصة: ${a.customCleanNote}'));
    }

    String compSt = 'ok';
    if (a.tDis > 110.0 || cop < 1.45) {
      compSt = 'bad';
      score -= 20;
      findings.add(EngineeringAlert('bad', 'T_dis = ${a.tDis}°C / COP = $cop: إجهاد حراري للضاغط — افحص الصمامات ونسبة الانضغاط.'));
    } else if (a.tDis > 95.0) {
      compSt = 'warn';
      score -= 10;
      findings.add(EngineeringAlert('warn', 'T_dis = ${a.tDis}°C قريبة من الحد الأقصى.'));
    }

    String doorSt = 'ok';
    if (a.seals == 'bad') {
      doorSt = 'bad';
      score -= 16;
      findings.add(const EngineeringAlert('bad', 'تلف جوانات الباب: تسرب رطوبة وتراكم جليد سريع — استبدل الجوان فوراً.'));
    } else if (a.seals == 'avg') {
      doorSt = 'warn';
      score -= 8;
      findings.add(const EngineeringAlert('warn', 'جوانات الباب متوسطة — اضبط المفصلات وسخان الإطار.'));
    }
    if (a.seals == 'custom' && a.customSealsNote.isNotEmpty) {
      findings.add(EngineeringAlert('warn', 'ملاحظة الجوانات المخصصة: ${a.customSealsNote}'));
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
