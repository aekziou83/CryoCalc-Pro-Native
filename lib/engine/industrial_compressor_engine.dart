import 'dart:math' as math;

class IndustrialRefProps {
  final String id;
  final String name;
  final double antoineA;
  final double antoineB;
  final double molarMass;
  final double dhRefKjKg;
  final double liquidDensityKgL;
  final String oilType;

  const IndustrialRefProps({
    required this.id,
    required this.name,
    required this.antoineA,
    required this.antoineB,
    required this.molarMass,
    required this.dhRefKjKg,
    required this.liquidDensityKgL,
    required this.oilType,
  });

  double satPressureBarAbs(double tempC) {
    final tk = (tempC + 273.15).clamp(185.0, 395.0);
    return math.exp(antoineA - (antoineB / tk));
  }
}

class IndustrialCompressor {
  final String id;
  final String brand;
  final String model;
  final String tech; // Semi-Hermetic | Screw | 2-Stage | Scroll EVI
  final String regime; // MT | LT | ULT
  final double hp;
  final double dispM3h;
  final double qMtKw; // ref -10 / +45 C
  final double qLtKw; // ref -30 / +45 C
  final double pElecKw;
  final double oilChargeL;
  final String sucInch;
  final String disInch;
  final String starterType; // DOL | Part-Winding | Star-Delta | VFD

  const IndustrialCompressor({
    required this.id,
    required this.brand,
    required this.model,
    required this.tech,
    required this.regime,
    required this.hp,
    required this.dispM3h,
    required this.qMtKw,
    required this.qLtKw,
    required this.pElecKw,
    required this.oilChargeL,
    required this.sucInch,
    required this.disInch,
    required this.starterType,
  });
}

class ScoredIndustrialComp {
  final IndustrialCompressor item;
  final double adjustedCapKw;
  final double coveragePct;
  final double amps400V;

  const ScoredIndustrialComp({
    required this.item,
    required this.adjustedCapKw,
    required this.coveragePct,
    required this.amps400V,
  });
}

class IndustrialPartItem {
  final int index;
  final String title;
  final String spec;
  final String details;
  final bool mandatory;

  const IndustrialPartItem({
    required this.index,
    required this.title,
    required this.spec,
    required this.details,
    this.mandatory = true,
  });
}

class IndustrialCalcInput {
  final String inputMode; // 'kw' | 'hp' | 'vb'
  final double targetValue;
  final double t0;
  final double tk;
  final double shK;
  final double scK;
  final double pipeLenM;
  final String refrigerant;
  final String customRefName;
  final String brandFilter;
  final String techFilter; // ALL | Semi-Hermetic | Screw | 2-Stage | Scroll EVI
  final double voltage;
  final double cosPhi;
  final String customNote;

  const IndustrialCalcInput({
    this.inputMode = 'kw',
    this.targetValue = 25.0,
    this.t0 = -10.0,
    this.tk = 45.0,
    this.shK = 7.0,
    this.scK = 5.0,
    this.pipeLenM = 15.0,
    this.refrigerant = 'R404A',
    this.customRefName = '',
    this.brandFilter = 'ALL',
    this.techFilter = 'ALL',
    this.voltage = 400.0,
    this.cosPhi = 0.85,
    this.customNote = '',
  });
}

class IndustrialCalcResult {
  final double q0Kw;
  final int kcalH;
  final double estHp;
  final double p0Abs;
  final double p0Rel;
  final double pkAbs;
  final double pkRel;
  final double tau;
  final double dhKjKg;
  final double massFlowKgH;
  final double vSucM3Kg;
  final double etaV;
  final double reqVbM3h;
  final double pElecEstKw;
  final double cop;
  final double qCondKw;
  final double tDisC;
  final bool isLT;
  final bool isULT;
  final String sucInch;
  final String liqInch;
  final String disInch;
  final List<ScoredIndustrialComp> matches;
  final ScoredIndustrialComp selected;
  final List<IndustrialPartItem> groupParts;
  final List<String> warnings;

  const IndustrialCalcResult({
    required this.q0Kw,
    required this.kcalH,
    required this.estHp,
    required this.p0Abs,
    required this.p0Rel,
    required this.pkAbs,
    required this.pkRel,
    required this.tau,
    required this.dhKjKg,
    required this.massFlowKgH,
    required this.vSucM3Kg,
    required this.etaV,
    required this.reqVbM3h,
    required this.pElecEstKw,
    required this.cop,
    required this.qCondKw,
    required this.tDisC,
    required this.isLT,
    required this.isULT,
    required this.sucInch,
    required this.liqInch,
    required this.disInch,
    required this.matches,
    required this.selected,
    required this.groupParts,
    required this.warnings,
  });
}

class IndustrialCompressorEngine {
  static String _p(String lang, String ar, String fr, String en) {
    if (lang == 'fr') return fr;
    if (lang == 'en') return en;
    return ar;
  }

  static const List<String> brands = [
    'ALL',
    'Bitzer',
    'Dorin',
    'Frascold',
    'Bock (GEA)',
    'Copeland',
    'Hanbell',
    'RefComp',
  ];

  static const List<String> techs = [
    'ALL',
    'Semi-Hermetic',
    'Screw',
    '2-Stage',
    'Scroll EVI',
  ];

  static const List<IndustrialRefProps> refrigerants = [
    IndustrialRefProps(id: 'R404A', name: 'R404A', antoineA: 10.431, antoineB: 2358.0, molarMass: 97.6, dhRefKjKg: 118.0, liquidDensityKgL: 0.99, oilType: 'POE 32 / BSE32'),
    IndustrialRefProps(id: 'R449A', name: 'R449A (XP40)', antoineA: 10.765, antoineB: 2478.0, molarMass: 87.2, dhRefKjKg: 152.0, liquidDensityKgL: 1.07, oilType: 'POE 32 / BSE32'),
    IndustrialRefProps(id: 'R448A', name: 'R448A (N40)', antoineA: 10.780, antoineB: 2480.0, molarMass: 86.3, dhRefKjKg: 154.0, liquidDensityKgL: 1.06, oilType: 'POE 32 / BSE32'),
    IndustrialRefProps(id: 'R507A', name: 'R507A', antoineA: 10.417, antoineB: 2344.0, molarMass: 98.9, dhRefKjKg: 116.0, liquidDensityKgL: 0.99, oilType: 'POE 32 / BSE32'),
    IndustrialRefProps(id: 'R134a', name: 'R134a', antoineA: 10.839, antoineB: 2668.6, molarMass: 102.0, dhRefKjKg: 142.0, liquidDensityKgL: 1.17, oilType: 'POE 32 / BSE32'),
    IndustrialRefProps(id: 'R407F', name: 'R407F', antoineA: 10.805, antoineB: 2475.0, molarMass: 82.1, dhRefKjKg: 162.0, liquidDensityKgL: 1.05, oilType: 'POE 32'),
    IndustrialRefProps(id: 'R717', name: 'R717 (NH₃ Ammonia)', antoineA: 11.460, antoineB: 2770.0, molarMass: 17.03, dhRefKjKg: 1080.0, liquidDensityKgL: 0.59, oilType: 'Mineral / PAO 68'),
    IndustrialRefProps(id: 'R744', name: 'R744 (CO₂ Subcritical)', antoineA: 10.860, antoineB: 1995.0, molarMass: 44.01, dhRefKjKg: 195.0, liquidDensityKgL: 0.78, oilType: 'POE 68 / BSE85K'),
    IndustrialRefProps(id: 'R290', name: 'R290 (Propane)', antoineA: 9.869, antoineB: 2271.0, molarMass: 44.1, dhRefKjKg: 278.0, liquidDensityKgL: 0.48, oilType: 'POE / Mineral'),
    IndustrialRefProps(id: 'custom', name: 'Custom', antoineA: 10.600, antoineB: 2450.0, molarMass: 90.0, dhRefKjKg: 145.0, liquidDensityKgL: 1.05, oilType: 'POE 32 / 68'),
  ];

  // Full industrial range: 3 HP up to 150 HP across 7 major industrial brands
  static const List<IndustrialCompressor> catalog = [
    // === BITZER SEMI-HERMETIC ECOLINE (3 HP -> 50 HP) ===
    IndustrialCompressor(id: 'bz_3', brand: 'Bitzer', model: '2CES-3Y', tech: 'Semi-Hermetic', regime: 'MT', hp: 3, dispM3h: 16.2, qMtKw: 9.4, qLtKw: 3.9, pElecKw: 3.8, oilChargeL: 1.5, sucInch: '7/8"', disInch: '5/8"', starterType: 'DOL'),
    IndustrialCompressor(id: 'bz_4', brand: 'Bitzer', model: '4FES-5Y', tech: 'Semi-Hermetic', regime: 'MT', hp: 5, dispM3h: 18.1, qMtKw: 11.2, qLtKw: 4.9, pElecKw: 4.5, oilChargeL: 2.0, sucInch: '1-1/8"', disInch: '7/8"', starterType: 'DOL'),
    IndustrialCompressor(id: 'bz_6', brand: 'Bitzer', model: '4EES-6Y', tech: 'Semi-Hermetic', regime: 'MT', hp: 6, dispM3h: 22.7, qMtKw: 13.8, qLtKw: 6.2, pElecKw: 5.5, oilChargeL: 2.0, sucInch: '1-1/8"', disInch: '7/8"', starterType: 'Part-Winding'),
    IndustrialCompressor(id: 'bz_75', brand: 'Bitzer', model: '4DES-7Y', tech: 'Semi-Hermetic', regime: 'MT', hp: 7.5, dispM3h: 26.8, qMtKw: 16.4, qLtKw: 7.3, pElecKw: 6.5, oilChargeL: 2.0, sucInch: '1-1/8"', disInch: '7/8"', starterType: 'Part-Winding'),
    IndustrialCompressor(id: 'bz_10', brand: 'Bitzer', model: '4TES-12Y', tech: 'Semi-Hermetic', regime: 'MT', hp: 12, dispM3h: 41.3, qMtKw: 24.8, qLtKw: 11.2, pElecKw: 9.8, oilChargeL: 2.6, sucInch: '1-3/8"', disInch: '1-1/8"', starterType: 'Part-Winding'),
    IndustrialCompressor(id: 'bz_15', brand: 'Bitzer', model: '4PES-15Y', tech: 'Semi-Hermetic', regime: 'MT', hp: 15, dispM3h: 48.5, qMtKw: 29.2, qLtKw: 13.4, pElecKw: 11.6, oilChargeL: 2.6, sucInch: '1-5/8"', disInch: '1-1/8"', starterType: 'Part-Winding'),
    IndustrialCompressor(id: 'bz_20', brand: 'Bitzer', model: '4NES-20Y', tech: 'Semi-Hermetic', regime: 'MT', hp: 20, dispM3h: 56.3, qMtKw: 34.4, qLtKw: 16.0, pElecKw: 13.8, oilChargeL: 2.6, sucInch: '1-5/8"', disInch: '1-1/8"', starterType: 'Part-Winding'),
    IndustrialCompressor(id: 'bz_25', brand: 'Bitzer', model: '6JE-25Y', tech: 'Semi-Hermetic', regime: 'LT', hp: 25, dispM3h: 95.3, qMtKw: 54.5, qLtKw: 25.8, pElecKw: 19.5, oilChargeL: 4.5, sucInch: '2-1/8"', disInch: '1-3/8"', starterType: 'Part-Winding'),
    IndustrialCompressor(id: 'bz_30', brand: 'Bitzer', model: '6HE-35Y', tech: 'Semi-Hermetic', regime: 'MT', hp: 35, dispM3h: 110.5, qMtKw: 65.0, qLtKw: 29.5, pElecKw: 25.5, oilChargeL: 4.5, sucInch: '2-1/8"', disInch: '1-3/8"', starterType: 'Part-Winding'),
    IndustrialCompressor(id: 'bz_40', brand: 'Bitzer', model: '6GE-40Y', tech: 'Semi-Hermetic', regime: 'MT', hp: 40, dispM3h: 126.8, qMtKw: 74.5, qLtKw: 34.2, pElecKw: 29.2, oilChargeL: 4.5, sucInch: '2-1/8"', disInch: '1-5/8"', starterType: 'Part-Winding'),
    IndustrialCompressor(id: 'bz_50', brand: 'Bitzer', model: '6FE-50Y', tech: 'Semi-Hermetic', regime: 'MT', hp: 50, dispM3h: 151.6, qMtKw: 89.0, qLtKw: 41.0, pElecKw: 35.0, oilChargeL: 4.75, sucInch: '2-1/8"', disInch: '1-5/8"', starterType: 'Part-Winding'),
    IndustrialCompressor(id: 'bz_60', brand: 'Bitzer', model: '8FE-70Y (8-Cyl)', tech: 'Semi-Hermetic', regime: 'MT', hp: 70, dispM3h: 221.0, qMtKw: 128.0, qLtKw: 58.0, pElecKw: 49.5, oilChargeL: 6.5, sucInch: '2-5/8"', disInch: '2-1/8"', starterType: 'Part-Winding'),

    // === BITZER 2-STAGE (ULT / BLAST TUNNELS -35..-45 C) ===
    IndustrialCompressor(id: 'bz_2s1', brand: 'Bitzer', model: 'S4T-5.2Y (2-Stage)', tech: '2-Stage', regime: 'ULT', hp: 5.5, dispM3h: 20.6, qMtKw: 11.5, qLtKw: 7.4, pElecKw: 5.2, oilChargeL: 2.6, sucInch: '1-1/8"', disInch: '7/8"', starterType: 'DOL'),
    IndustrialCompressor(id: 'bz_2s2', brand: 'Bitzer', model: 'S6J-16.2Y (2-Stage)', tech: '2-Stage', regime: 'ULT', hp: 16, dispM3h: 63.5, qMtKw: 34.0, qLtKw: 23.8, pElecKw: 14.8, oilChargeL: 4.5, sucInch: '1-5/8"', disInch: '1-1/8"', starterType: 'Part-Winding'),
    IndustrialCompressor(id: 'bz_2s3', brand: 'Bitzer', model: 'S6G-25.2Y (2-Stage)', tech: '2-Stage', regime: 'ULT', hp: 25, dispM3h: 84.5, qMtKw: 46.0, qLtKw: 32.5, pElecKw: 21.0, oilChargeL: 4.5, sucInch: '2-1/8"', disInch: '1-3/8"', starterType: 'Part-Winding'),
    IndustrialCompressor(id: 'bz_2s4', brand: 'Bitzer', model: 'S6F-30.2Y (2-Stage)', tech: '2-Stage', regime: 'ULT', hp: 30, dispM3h: 101.1, qMtKw: 56.0, qLtKw: 39.8, pElecKw: 25.8, oilChargeL: 4.75, sucInch: '2-1/8"', disInch: '1-3/8"', starterType: 'Part-Winding'),

    // === BITZER INDUSTRIAL SCREW (HSN / CSH — 25 HP -> 150 HP) ===
    IndustrialCompressor(id: 'bz_sc1', brand: 'Bitzer', model: 'HSN5363-30 (Screw LT)', tech: 'Screw', regime: 'LT', hp: 30, dispM3h: 118.0, qMtKw: 68.0, qLtKw: 33.5, pElecKw: 24.5, oilChargeL: 9.0, sucInch: '2-1/8"', disInch: '1-5/8"', starterType: 'Star-Delta'),
    IndustrialCompressor(id: 'bz_sc2', brand: 'Bitzer', model: 'HSN6461-40 (Screw LT)', tech: 'Screw', regime: 'LT', hp: 40, dispM3h: 165.0, qMtKw: 96.0, qLtKw: 48.0, pElecKw: 34.0, oilChargeL: 11.0, sucInch: '2-5/8"', disInch: '2-1/8"', starterType: 'Star-Delta'),
    IndustrialCompressor(id: 'bz_sc3', brand: 'Bitzer', model: 'CSH7573-90Y (Screw MT)', tech: 'Screw', regime: 'MT', hp: 90, dispM3h: 258.0, qMtKw: 158.0, qLtKw: 74.0, pElecKw: 61.0, oilChargeL: 15.0, sucInch: '3-1/8"', disInch: '2-1/8"', starterType: 'Star-Delta'),
    IndustrialCompressor(id: 'bz_sc4', brand: 'Bitzer', model: 'HSN8571-125 (Screw LT)', tech: 'Screw', regime: 'LT', hp: 125, dispM3h: 410.0, qMtKw: 242.0, qLtKw: 122.0, pElecKw: 89.0, oilChargeL: 20.0, sucInch: '3-1/8"', disInch: '2-5/8"', starterType: 'Star-Delta'),
    IndustrialCompressor(id: 'bz_sc5', brand: 'Bitzer', model: 'CSH9573-150Y (Screw MT)', tech: 'Screw', regime: 'MT', hp: 150, dispM3h: 535.0, qMtKw: 325.0, qLtKw: 154.0, pElecKw: 118.0, oilChargeL: 24.0, sucInch: '4-1/8"', disInch: '3-1/8"', starterType: 'Star-Delta / VFD'),

    // === DORIN SEMI-HERMETIC (4 HP -> 75 HP) ===
    IndustrialCompressor(id: 'dr_4', brand: 'Dorin', model: 'H401CC', tech: 'Semi-Hermetic', regime: 'MT', hp: 4, dispM3h: 16.4, qMtKw: 9.6, qLtKw: 4.1, pElecKw: 3.85, oilChargeL: 1.8, sucInch: '7/8"', disInch: '5/8"', starterType: 'DOL'),
    IndustrialCompressor(id: 'dr_75', brand: 'Dorin', model: 'H751CC', tech: 'Semi-Hermetic', regime: 'MT', hp: 7.5, dispM3h: 32.1, qMtKw: 19.1, qLtKw: 8.4, pElecKw: 7.45, oilChargeL: 2.5, sucInch: '1-3/8"', disInch: '1-1/8"', starterType: 'Part-Winding'),
    IndustrialCompressor(id: 'dr_15', brand: 'Dorin', model: 'H1501CC', tech: 'Semi-Hermetic', regime: 'LT', hp: 15, dispM3h: 51.0, qMtKw: 30.2, qLtKw: 14.5, pElecKw: 11.8, oilChargeL: 3.0, sucInch: '1-5/8"', disInch: '1-1/8"', starterType: 'Part-Winding'),
    IndustrialCompressor(id: 'dr_30', brand: 'Dorin', model: 'H3000CC (6-Cyl)', tech: 'Semi-Hermetic', regime: 'MT', hp: 30, dispM3h: 98.5, qMtKw: 58.2, qLtKw: 26.5, pElecKw: 22.8, oilChargeL: 4.5, sucInch: '2-1/8"', disInch: '1-3/8"', starterType: 'Part-Winding'),
    IndustrialCompressor(id: 'dr_50', brand: 'Dorin', model: 'H5000CS (6-Cyl)', tech: 'Semi-Hermetic', regime: 'MT', hp: 50, dispM3h: 154.0, qMtKw: 91.0, qLtKw: 41.5, pElecKw: 35.8, oilChargeL: 5.5, sucInch: '2-5/8"', disInch: '1-5/8"', starterType: 'Part-Winding'),
    IndustrialCompressor(id: 'dr_75h', brand: 'Dorin', model: 'H7500CS (8-Cyl)', tech: 'Semi-Hermetic', regime: 'MT', hp: 75, dispM3h: 230.0, qMtKw: 135.0, qLtKw: 62.0, pElecKw: 53.0, oilChargeL: 7.0, sucInch: '2-5/8"', disInch: '2-1/8"', starterType: 'Part-Winding'),

    // === FRASCOLD SEMI-HERMETIC & SCREW (5 HP -> 100 HP) ===
    IndustrialCompressor(id: 'fr_5', brand: 'Frascold', model: 'Q5-25.1Y', tech: 'Semi-Hermetic', regime: 'LT', hp: 5, dispM3h: 24.7, qMtKw: 13.8, qLtKw: 6.85, pElecKw: 5.1, oilChargeL: 1.8, sucInch: '1-1/8"', disInch: '7/8"', starterType: 'DOL'),
    IndustrialCompressor(id: 'fr_12', brand: 'Frascold', model: 'S12-42Y', tech: 'Semi-Hermetic', regime: 'MT', hp: 12, dispM3h: 41.8, qMtKw: 25.0, qLtKw: 11.4, pElecKw: 9.9, oilChargeL: 3.3, sucInch: '1-3/8"', disInch: '1-1/8"', starterType: 'Part-Winding'),
    IndustrialCompressor(id: 'fr_25', brand: 'Frascold', model: 'V25-84Y', tech: 'Semi-Hermetic', regime: 'MT', hp: 25, dispM3h: 83.8, qMtKw: 49.5, qLtKw: 22.8, pElecKw: 19.6, oilChargeL: 4.5, sucInch: '2-1/8"', disInch: '1-3/8"', starterType: 'Part-Winding'),
    IndustrialCompressor(id: 'fr_40', brand: 'Frascold', model: 'Z40-126Y (6-Cyl)', tech: 'Semi-Hermetic', regime: 'MT', hp: 40, dispM3h: 125.7, qMtKw: 74.0, qLtKw: 34.0, pElecKw: 29.0, oilChargeL: 5.2, sucInch: '2-1/8"', disInch: '1-5/8"', starterType: 'Part-Winding'),
    IndustrialCompressor(id: 'fr_sc60', brand: 'Frascold', model: 'CX02-60-210Y (Screw)', tech: 'Screw', regime: 'MT', hp: 60, dispM3h: 210.0, qMtKw: 126.0, qLtKw: 59.0, pElecKw: 48.0, oilChargeL: 12.0, sucInch: '2-5/8"', disInch: '2-1/8"', starterType: 'Star-Delta'),
    IndustrialCompressor(id: 'fr_sc100', brand: 'Frascold', model: 'CX04-100-340Y (Screw)', tech: 'Screw', regime: 'MT', hp: 100, dispM3h: 340.0, qMtKw: 205.0, qLtKw: 96.0, pElecKw: 77.0, oilChargeL: 18.0, sucInch: '3-1/8"', disInch: '2-5/8"', starterType: 'Star-Delta'),

    // === BOCK (GEA) SEMI-HERMETIC ===
    IndustrialCompressor(id: 'bk_10', brand: 'Bock (GEA)', model: 'HGX34e/380-4', tech: 'Semi-Hermetic', regime: 'MT', hp: 10, dispM3h: 33.1, qMtKw: 19.8, qLtKw: 8.8, pElecKw: 7.7, oilChargeL: 1.3, sucInch: '1-3/8"', disInch: '7/8"', starterType: 'Part-Winding'),
    IndustrialCompressor(id: 'bk_20', brand: 'Bock (GEA)', model: 'HGX44e/665-4', tech: 'Semi-Hermetic', regime: 'MT', hp: 20, dispM3h: 57.7, qMtKw: 35.0, qLtKw: 16.2, pElecKw: 14.0, oilChargeL: 2.3, sucInch: '1-5/8"', disInch: '1-1/8"', starterType: 'Part-Winding'),
    IndustrialCompressor(id: 'bk_35', brand: 'Bock (GEA)', model: 'HGX56e/1155-4', tech: 'Semi-Hermetic', regime: 'MT', hp: 35, dispM3h: 100.4, qMtKw: 59.8, qLtKw: 27.5, pElecKw: 23.4, oilChargeL: 3.1, sucInch: '2-1/8"', disInch: '1-3/8"', starterType: 'Part-Winding'),
    IndustrialCompressor(id: 'bk_60', brand: 'Bock (GEA)', model: 'HGX88e/2400-4 (8-Cyl)', tech: 'Semi-Hermetic', regime: 'MT', hp: 60, dispM3h: 208.5, qMtKw: 122.0, qLtKw: 56.0, pElecKw: 47.5, oilChargeL: 4.5, sucInch: '2-5/8"', disInch: '2-1/8"', starterType: 'Part-Winding'),

    // === COPELAND STREAM / DISCUS & EVI ===
    IndustrialCompressor(id: 'cp_15', brand: 'Copeland', model: '4MF-13X (Stream)', tech: 'Semi-Hermetic', regime: 'MT', hp: 15, dispM3h: 61.7, qMtKw: 36.8, qLtKw: 17.2, pElecKw: 14.2, oilChargeL: 3.3, sucInch: '1-5/8"', disInch: '1-1/8"', starterType: 'Part-Winding'),
    IndustrialCompressor(id: 'cp_30', brand: 'Copeland', model: '6MM-30X (Stream 6-Cyl)', tech: 'Semi-Hermetic', regime: 'MT', hp: 30, dispM3h: 120.5, qMtKw: 71.0, qLtKw: 32.8, pElecKw: 27.5, oilChargeL: 3.3, sucInch: '2-1/8"', disInch: '1-3/8"', starterType: 'Part-Winding'),
    IndustrialCompressor(id: 'cp_evi', brand: 'Copeland', model: 'ZFI50KQE-TFD (EVI)', tech: 'Scroll EVI', regime: 'LT', hp: 15, dispM3h: 40.2, qMtKw: 23.5, qLtKw: 15.2, pElecKw: 9.6, oilChargeL: 3.4, sucInch: '1-3/8"', disInch: '7/8"', starterType: 'DOL'),

    // === HANBELL & REFCOMP INDUSTRIAL SCREW ===
    IndustrialCompressor(id: 'hb_40', brand: 'Hanbell', model: 'RC2-140B (Screw)', tech: 'Screw', regime: 'MT', hp: 40, dispM3h: 140.0, qMtKw: 84.5, qLtKw: 39.5, pElecKw: 32.5, oilChargeL: 10.0, sucInch: '2-1/8"', disInch: '1-5/8"', starterType: 'Star-Delta'),
    IndustrialCompressor(id: 'hb_75', brand: 'Hanbell', model: 'RC2-300B (Screw)', tech: 'Screw', regime: 'MT', hp: 75, dispM3h: 301.0, qMtKw: 182.0, qLtKw: 85.0, pElecKw: 69.0, oilChargeL: 16.0, sucInch: '3-1/8"', disInch: '2-1/8"', starterType: 'Star-Delta'),
    IndustrialCompressor(id: 'hb_125', brand: 'Hanbell', model: 'RC2-470B (Screw)', tech: 'Screw', regime: 'MT', hp: 125, dispM3h: 470.0, qMtKw: 285.0, qLtKw: 135.0, pElecKw: 105.0, oilChargeL: 22.0, sucInch: '4-1/8"', disInch: '3-1/8"', starterType: 'Star-Delta / VFD'),
    IndustrialCompressor(id: 'rc_50', brand: 'RefComp', model: 'SW3L-5000 (Screw)', tech: 'Screw', regime: 'MT', hp: 50, dispM3h: 175.0, qMtKw: 105.0, qLtKw: 49.0, pElecKw: 40.5, oilChargeL: 12.0, sucInch: '2-5/8"', disInch: '2-1/8"', starterType: 'Star-Delta'),
  ];

  static IndustrialCalcResult calculate(
    IndustrialCalcInput inp, {
    String? forcedId,
    String lang = 'ar',
  }) {
    final t0 = inp.t0.clamp(-50.0, 15.0);
    final tk = inp.tk.clamp(20.0, 62.0);
    final sh = inp.shK.clamp(3.0, 18.0);
    final sc = inp.scK.clamp(1.0, 18.0);
    final isULT = t0 <= -34.0;
    final isLT = t0 <= -15.0;

    final ref = refrigerants.firstWhere((r) => r.id == inp.refrigerant, orElse: () => refrigerants.first);
    final p0Abs = double.parse(ref.satPressureBarAbs(t0).toStringAsFixed(2));
    final pkAbs = double.parse(ref.satPressureBarAbs(tk).toStringAsFixed(2));
    final p0Rel = double.parse((p0Abs - 1.013).toStringAsFixed(2));
    final pkRel = double.parse((pkAbs - 1.013).toStringAsFixed(2));
    final tau = double.parse((pkAbs / math.max(0.45, p0Abs)).toStringAsFixed(2));

    final dh = double.parse(
      (ref.dhRefKjKg * (1.0 - (tk - 40.0) * 0.0075 + (sc - 4.0) * 0.009 - (isLT ? 0.07 : 0.0))).clamp(65.0, 1250.0).toStringAsFixed(1),
    );
    final tSucK = (t0 + sh) + 273.15;
    final vSuc = double.parse(((8.3145 * tSucK * 0.86) / (ref.molarMass * p0Abs * 100.0)).toStringAsFixed(4));

    // Volumetric efficiency varies by technology (Screw > 2-Stage > Reciprocating)
    final bool preferScrew = inp.techFilter == 'Screw' || (inp.inputMode == 'kw' && inp.targetValue >= 70) || (inp.inputMode == 'hp' && inp.targetValue >= 55);
    final double etaV = double.parse(
      (preferScrew
              ? (0.94 - 0.015 * tau)
              : (isULT ? (0.90 - 0.025 * math.sqrt(tau)) : (1.0 - 0.048 * tau)))
          .clamp(0.50, 0.92)
          .toStringAsFixed(2),
    );

    // Derive Q0 (kW) from whichever input mode the technician chose
    final copRef = isULT ? 1.35 : (isLT ? 1.85 : 2.65);
    double q0Kw;
    if (inp.inputMode == 'hp') {
      final pElecFromHp = inp.targetValue * 0.746;
      q0Kw = pElecFromHp * copRef;
    } else if (inp.inputMode == 'vb') {
      final mDotH = (inp.targetValue * etaV) / math.max(0.005, vSuc);
      q0Kw = (mDotH * dh) / 3600.0;
    } else {
      q0Kw = inp.targetValue;
    }
    q0Kw = double.parse(q0Kw.clamp(2.0, 500.0).toStringAsFixed(2));
    final kcalH = (q0Kw * 860).round();

    final mDotKgS = q0Kw / dh;
    final mDotKgH = double.parse((mDotKgS * 3600.0).toStringAsFixed(1));
    final reqVb = double.parse(((mDotKgH * vSuc) / etaV).toStringAsFixed(1));

    // Discharge temperature (polytropic compression; lower for 2-stage & oil-injected screw)
    final double expN = preferScrew ? 0.115 : (isULT ? 0.125 : 0.165);
    final tDisC = double.parse(((tSucK * math.pow(tau, expN)) - 273.15).clamp(58.0, 138.0).toStringAsFixed(1));

    final pElecEst = double.parse((q0Kw / copRef).toStringAsFixed(2));
    final estHp = double.parse((pElecEst / 0.746).toStringAsFixed(1));
    final cop = double.parse((q0Kw / math.max(0.3, pElecEst)).toStringAsFixed(2));
    final qCondKw = double.parse((q0Kw + pElecEst).toStringAsFixed(2));

    // Match industrial compressors from catalog
    final targetRegime = isULT ? 'ULT' : (isLT ? 'LT' : 'MT');
    final volt = inp.voltage.clamp(220.0, 690.0);
    final cosphi = inp.cosPhi.clamp(0.72, 0.98);

    double calcAmps(double pKw) => double.parse(((pKw * 1000.0) / (volt * 1.732 * cosphi)).toStringAsFixed(1));

    final filtered = catalog.where((c) {
      final bOk = inp.brandFilter == 'ALL' || c.brand == inp.brandFilter;
      final tOk = inp.techFilter == 'ALL' || c.tech == inp.techFilter;
      return bOk && tOk;
    }).toList();
    final pool = filtered.isNotEmpty ? filtered : catalog;

    final ranked = pool.map((c) {
      final baseQ = isLT ? c.qLtKw : c.qMtKw;
      final t0Ref = isLT ? -30.0 : -10.0;
      final adjQ = double.parse(
        (baseQ * (1.0 + (t0 - t0Ref) * 0.032) * (1.0 - (tk - 45.0) * 0.012)).clamp(1.0, 600.0).toStringAsFixed(2),
      );
      final ratio = adjQ / math.max(1.0, q0Kw);
      final regPen = (c.regime == targetRegime || (isULT && c.tech == '2-Stage')) ? 0.0 : 0.55;
      final capPen = ratio < 0.92 ? (1.15 - ratio) * 4.5 : (ratio - 1.12).abs();
      return _IndRank(
        ScoredIndustrialComp(
          item: c,
          adjustedCapKw: adjQ,
          coveragePct: double.parse((ratio * 100.0).toStringAsFixed(0)),
          amps400V: calcAmps(c.pElecKw),
        ),
        capPen + regPen,
      );
    }).toList()
      ..sort((a, b) => a.pen.compareTo(b.pen));

    final matches = ranked.take(10).map((e) => e.sc).toList();
    final selected = matches.firstWhere((m) => m.item.id == forcedId, orElse: () => matches.first);

    // Industrial piping sizes based on selected unit & Q0
    final suc = selected.item.sucInch;
    final dis = selected.item.disInch;
    String liq = '1/2"';
    if (q0Kw < 12) {
      liq = '1/2"';
    } else if (q0Kw < 26) {
      liq = '5/8"';
    } else if (q0Kw < 55) {
      liq = '7/8"';
    } else if (q0Kw < 110) {
      liq = '1-1/8"';
    } else if (q0Kw < 200) {
      liq = '1-3/8"';
    } else {
      liq = '1-5/8"';
    }

    // =========================================================================
    // FULL 16-COMPONENT INDUSTRIAL CONDENSING GROUP PARTS LIST
    // =========================================================================
    final sel = selected.item;
    final totalChargeKg = double.parse((q0Kw * 0.28 + qCondKw * 0.22 + inp.pipeLenM * 0.14).clamp(4.0, 280.0).toStringAsFixed(1));
    final recMinL = (totalChargeKg / (0.80 * ref.liquidDensityKgL)) * 1.20;
    final recStdL = [8, 12, 16, 20, 25, 35, 50, 75, 100, 150, 200, 300, 450, 600].firstWhere((v) => v >= recMinL, orElse: () => 600);
    final aclMinL = (totalChargeKg * 0.55) / (ref.liquidDensityKgL * 1.10);
    final aclStdL = [5, 7.5, 10, 15, 20, 30, 45, 65, 90, 130, 180, 250].firstWhere((v) => v >= aclMinL, orElse: () => 250);

    final condAirM3h = ((qCondKw * 3600.0) / (1.18 * 1.005 * 6.5)).round();
    final condAreaM2 = double.parse(((qCondKw * 1000.0) / (34.0 * 12.0)).toStringAsFixed(1));

    // Industrial Filter Drier (Replaceable Core DCR for >= 15 kW)
    final drierSpec = q0Kw < 15
        ? 'Danfoss DML 305 / Castel 4305 ($liq)'
        : (q0Kw < 45
            ? 'Danfoss DCR 048 ($liq) + 1× 48-DM Core'
            : (q0Kw < 100
                ? 'Danfoss DCR 096 ($liq) + 2× 48-DM Cores'
                : 'Danfoss DCR 144 ($liq) + 3× 48-DM Cores'));

    // Industrial TXV / EEV Sizing
    final dpEff = (pkAbs - p0Abs - 1.8).clamp(3.0, 22.0);
    final txvSpec = q0Kw < 18
        ? 'Danfoss TE5 / Alco TCLE ($liq) — Orifice 01–03'
        : (q0Kw < 45
            ? 'Danfoss TE12 / TE20 ($liq) — Orifice 05–08'
            : (q0Kw < 110
                ? 'Danfoss TE55 / Electronic EEV AKV 15 ($liq)'
                : 'Electronic EEV Danfoss AKV 20 / Carel E5V ($liq)'));

    // Industrial Oil Separator & Oil Management
    final oilSepSpec = sel.tech == 'Screw'
        ? 'Horizontal/Coalescent Oil Separator ($dis) — Bitzer OA/OS'
        : (q0Kw < 25
            ? 'Castel 5540/7 / Carly TURBOIL ($dis)'
            : (q0Kw < 70
                ? 'Castel 5540/9 / Henry S-5190 ($dis)'
                : 'Helical Oil Separator Henry S-5200 / Carly ($dis)'));

    final crankcaseW = sel.hp <= 10 ? 70 : (sel.hp <= 25 ? 140 : (sel.hp <= 60 ? 200 : 300));
    final hpCut = (pkAbs + 4.5).clamp(18.0, 31.0).toStringAsFixed(1);
    final lpCut = math.max(0.2, p0Rel - 0.5).toStringAsFixed(1);

    // Industrial Electrical Panel & Starter
    final iNom = selected.amps400V;
    final brkA = [16, 20, 25, 32, 40, 50, 63, 80, 100, 125, 160, 200, 250, 315].firstWhere((a) => a >= iNom * 1.35, orElse: () => 400);
    final kmA = [18, 25, 32, 40, 50, 65, 80, 95, 115, 150, 185, 225].firstWhere((a) => a >= (sel.starterType == 'DOL' ? iNom * 1.1 : iNom * 0.65), orElse: () => 265);
    final cableMm2 = iNom <= 16 ? '4' : iNom <= 25 ? '6' : iNom <= 36 ? '10' : iNom <= 50 ? '16' : iNom <= 70 ? '25' : iNom <= 95 ? '35' : iNom <= 130 ? '50' : iNom <= 170 ? '70' : '95';

    final parts = <IndustrialPartItem>[
      IndustrialPartItem(
        index: 1,
        title: _p(lang, 'الضاغط الصناعي والمحرك', 'Compresseur Industriel', 'Industrial Compressor'),
        spec: '${sel.brand} ${sel.model} (${sel.hp} HP • ${sel.tech})',
        details: 'Vb=${sel.dispM3h} m³/h • ${sel.oilChargeL} L (${ref.oilType}) • ${sel.sucInch} / ${sel.disInch}',
      ),
      IndustrialPartItem(
        index: 2,
        title: _p(lang, 'فاصل الزيت (Oil Separator)', 'Séparateur d\'huile', 'Oil Separator'),
        spec: oilSepSpec,
        details: _p(lang, 'يُركب مباشرة بعد الطرد مع خط رجوع زيت وعوامة أو صمام كهرومغناطيسي', 'À installer au refoulement avec retour d\'huile + flotteur', 'Install directly on discharge with oil return line'),
      ),
      IndustrialPartItem(
        index: 3,
        title: _p(lang, 'خزان ومنظم مستوى الزيت', 'Réservoir & Régulateur d\'huile', 'Oil Reservoir & Level Regulator'),
        spec: sel.hp >= 15 ? 'TraxOil OM3 / INT276 + Oil Reservoir (${(sel.oilChargeL * 1.5).toStringAsFixed(1)} L)' : _p(lang, 'اختياري لهذه القدرة (يكفي فاصل الزيت)', 'Optionnel (séparateur suffisant)', 'Optional for this capacity'),
        details: _p(lang, 'إلزامي في المجموعات المركزية والمصانع لضمان ثبات منسوب الزيت', 'Obligatoire sur centrales et groupes > 15 HP', 'Mandatory on racks & > 15 HP systems'),
        mandatory: sel.hp >= 15,
      ),
      IndustrialPartItem(
        index: 4,
        title: _p(lang, 'سخان كارتير الزيت (Crankcase Heater)', 'Résistance de carter', 'Crankcase Heater'),
        spec: '${crankcaseW} W • 230V AC',
        details: _p(lang, 'يعمل تلقائياً عند توقف الضاغط لمنع ذوبان الغاز في الزيت', 'Actif à l\'arrêt pour éviter la migration de liquide', 'Energized during off-cycle to prevent refrigerant migration'),
      ),
      IndustrialPartItem(
        index: 5,
        title: _p(lang, 'موانع الاهتزازات (Anacondas)', 'Éliminateurs de vibrations', 'Vibration Absorbers'),
        spec: 'Suc Ø $suc  +  Dis Ø $dis',
        details: _p(lang, 'تُركب أفقياً أو عمودياً بالتوازي مع محور العمود المرفقي', 'Montage parallèle à l\'axe du vilebrequin', 'Install parallel to crankshaft axis'),
      ),
      IndustrialPartItem(
        index: 6,
        title: _p(lang, 'صمام عدم الرجوع بالطرد (Check Valve)', 'Clapet anti-retour (NRV)', 'Discharge Check Valve (NRV)'),
        spec: 'Danfoss NRV / Castel 3132 (Ø $dis)',
        details: _p(lang, 'يمنع رجوع السائل المكثف إلى رأس الضاغط أثناء التوقف', 'Empêche le retour de condensats au compresseur', 'Prevents condensed refrigerant backflow to head'),
      ),
      IndustrialPartItem(
        index: 7,
        title: _p(lang, 'المكثف الصناعي ومراوح التكثيف', 'Condenseur Industriel', 'Industrial Condenser'),
        spec: 'Qk = $qCondKw kW  •  Air = $condAirM3h m³/h',
        details: 'Surface ≈ $condAreaM2 m² (ΔTk = 12 K) + ${_p(lang, "منظم ضغط التكثيف (مراوح متدرجة/VFD)", "Régulation HP ventilateurs", "Head pressure fan control")}',
      ),
      IndustrialPartItem(
        index: 8,
        title: _p(lang, 'خزان سائل التبريد + صمام الأمان', 'Réservoir Liquide + Soupape', 'Liquid Receiver + Relief Valve'),
        spec: 'Réservoir $recStdL L (PS 33 bar) + Soupape ${ (pkAbs + 6.5).clamp(24.0, 32.0).toStringAsFixed(0) } bar',
        details: 'Charge ≈ $totalChargeKg kg (EN 378 80% max fill) + ${_p(lang, "صمامي عزل Rotalock", "Vannes Rotalock", "Rotalock service valves")}',
      ),
      IndustrialPartItem(
        index: 9,
        title: _p(lang, 'الفلتر المجفف الصناعي (Replaceable Core)', 'Déshydrateur à cartouche', 'Replaceable Core Filter Drier'),
        spec: drierSpec,
        details: _p(lang, 'يُركب مع صمامي عزل (Ball Valves) لتغيير القلب دون تفريغ الغاز', 'Avec vannes d\'isolement pour remplacement facile', 'Install with ball valves for easy core replacement'),
      ),
      IndustrialPartItem(
        index: 10,
        title: _p(lang, 'مؤشر سائل التبريد والرطوبة', 'Voyant liquide & humidité', 'Liquid & Moisture Sight Glass'),
        spec: 'Danfoss SGN / Castel 3940 (Ø $liq)',
        details: _p(lang, 'فحص خلو السائل من الفقاعات ومؤشر الرطوبة الأخضر', 'Contrôle absence de bulles et taux d\'humidité', 'Monitor flash gas and moisture indicator'),
      ),
      IndustrialPartItem(
        index: 11,
        title: _p(lang, 'الصمام الكهرومغناطيسي (Pump-Down)', 'Électrovanne Liquide', 'Liquid Solenoid Valve'),
        spec: 'Danfoss ${q0Kw < 20 ? "EVR 10" : (q0Kw < 60 ? "EVR 20" : "EVRA 25")} (Ø $liq • 230V)',
        details: _p(lang, 'أساسي لنظام التفريغ التلقائي Pump-Down قبل توقف الضاغط', 'Indispensable pour tirage au vide (Pump-Down)', 'Essential for automatic Pump-Down cycle'),
      ),
      IndustrialPartItem(
        index: 12,
        title: _p(lang, 'صمام التمدد والأورفيس / EEV', 'Détendeur TXV / EEV', 'Expansion Valve (TXV / EEV)'),
        spec: txvSpec,
        details: 'ΔP ≈ ${dpEff.toStringAsFixed(1)} bar • SC = ${sc.toStringAsFixed(0)} K • ${isLT ? "MOP -15/-20°C" : "Standard"}',
      ),
      IndustrialPartItem(
        index: 13,
        title: _p(lang, 'الزجاجة المضادة للطلق (الأكيومليتور ACL)', 'Bouteille Anti-Coup de Liquide (ACL)', 'Suction Accumulator (ACL)'),
        spec: 'Carly LCY / Castel 5520 ($aclStdL L • Ø $suc)',
        details: _p(lang, 'تستوعب ≥55% من الشحنة مع أنبوب U وثقب رجوع زيت محمي بمصفاة', 'Capacité ≥55% charge + orifice retour huile', 'Holds ≥55% charge with U-tube oil return bleed'),
      ),
      IndustrialPartItem(
        index: 14,
        title: _p(lang, 'فلتر خط السحب المضاد للحموضة', 'Filtre Aspiration Anti-Acide', 'Suction Line Anti-Acid Filter'),
        spec: q0Kw < 25 ? 'Danfoss DAS / Castel 4316 ($suc)' : 'Danfoss DCR Suction + 48-DA Anti-Acid Core ($suc)',
        details: _p(lang, 'يُركب قبل الضاغط مباشرة مع منفذي قياس الضغط (Schrader) لفحص ΔP', 'Avec prises Schrader pour contrôle perte de charge', 'Install upstream of compressor with ΔP test ports'),
      ),
      IndustrialPartItem(
        index: 15,
        title: _p(lang, 'أجهزة الحماية (HP/LP + تفاضلي الزيت + التبريد)', 'Sécurités HP/LP, Huile & T° Refoul.', 'Industrial Safety Controls'),
        spec: 'KP15 (HP $hpCut / LP $lpCut bar) + ${sel.hp >= 7.5 ? "MP54/MP55 Oil Diff" : "INT69 Motor Guard"}',
        details: tDisC > 105
            ? _p(lang, 'تحذير: T_dis=$tDisC°C — إلزامي مروحة تبريد رأس الضاغط أو حقن سائل CIC + ثيرموستات طرد 120°C', 'Alerte T_dis=$tDisC°C : Ventilateur culasse ou injection CIC + thermostat 120°C', 'Alert T_dis=$tDisC°C: Mandatory head cooling fan or CIC liquid injection + 120°C Klixon')
            : _p(lang, 'ثيرموستات أمان طرد 120°C + حماية حرارة ملفات المحرك INT69', 'Thermostat refoulement 120°C + module INT69', '120°C discharge thermostat + INT69 motor protection'),
      ),
      IndustrialPartItem(
        index: 16,
        title: _p(lang, 'الخزانة الكهربائية ونظام الإقلاع الصناعي', 'Armoire & Démarrage Industriel', 'Electrical Panel & Starter'),
        spec: '${sel.starterType} • I_nom = $iNom A • Disj. 3P+N ${brkA}A (D)',
        details: 'KM: ${sel.starterType == "DOL" ? "1×" : (sel.starterType == "Part-Winding" ? "2×" : "3×")} LC1D$kmA • Cable 5G $cableMm2 mm² Cu',
      ),
    ];

    final warnings = <String>[];
    if (tau > 8.5 && sel.tech != '2-Stage' && sel.tech != 'Screw') {
      warnings.add(_p(
        lang,
        'نسبة الانضغاط عالية (τ = $tau): يُنصح بضاغط مرحلتين (2-Stage) أو حلزوني (Screw) أو حقن سائل.',
        'Taux de compression élevé (τ = $tau) : privilégiez un compresseur bi-étagé (2-Stage) ou à vis.',
        'High compression ratio (τ = $tau): a 2-Stage or Screw compressor is strongly recommended.',
      ));
    }
    if (tDisC > 105) {
      warnings.add(_p(
        lang,
        'حرارة الطرد التقديرية مرتفعة ($tDisC°C): ركّب مروحة تبريد رأس الضاغط أو نظام حقن السائل لحماية الزيت.',
        'Température de refoulement élevée ($tDisC°C) : ventilateur de culasse ou injection liquide obligatoire.',
        'High discharge temperature ($tDisC°C): install head cooling fan or liquid injection to protect oil.',
      ));
    }
    if (sel.hp >= 15) {
      warnings.add(_p(
        lang,
        'قدرة صناعية (${sel.hp} HP): يُمنع الإقلاع المباشر — استخدم إقلاع ${sel.starterType} مع مؤقت 0.5–1 ثانية.',
        'Puissance industrielle (${sel.hp} HP) : démarrage ${sel.starterType} obligatoire.',
        'Industrial motor (${sel.hp} HP): use ${sel.starterType} reduced-current starting.',
      ));
    }

    return IndustrialCalcResult(
      q0Kw: q0Kw,
      kcalH: kcalH,
      estHp: estHp,
      p0Abs: p0Abs,
      p0Rel: p0Rel,
      pkAbs: pkAbs,
      pkRel: pkRel,
      tau: tau,
      dhKjKg: dh,
      massFlowKgH: mDotKgH,
      vSucM3Kg: vSuc,
      etaV: etaV,
      reqVbM3h: reqVb,
      pElecEstKw: pElecEst,
      cop: cop,
      qCondKw: qCondKw,
      tDisC: tDisC,
      isLT: isLT,
      isULT: isULT,
      sucInch: suc,
      liqInch: liq,
      disInch: dis,
      matches: matches,
      selected: selected,
      groupParts: parts,
      warnings: warnings,
    );
  }
}

class _IndRank {
  final ScoredIndustrialComp sc;
  final double pen;
  const _IndRank(this.sc, this.pen);
}
