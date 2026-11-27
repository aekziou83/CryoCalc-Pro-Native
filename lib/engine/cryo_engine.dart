import 'dart:math' as math;

class CryoInput {
  final double length;
  final double width;
  final double height;
  final double insMm;
  final double tInside;
  final double tAmbient;
  final double dailyKg;
  final double tProdIn;
  final String arch; // split | monobloc | rack

  const CryoInput({
    this.length = 6.0,
    this.width = 4.0,
    this.height = 3.0,
    this.insMm = 80.0,
    this.tInside = 2.0,
    this.tAmbient = 38.0,
    this.dailyKg = 1500.0,
    this.tProdIn = 20.0,
    this.arch = 'split',
  });
}

class CryoResult {
  final double volume;
  final double areaFloor;
  final double q0Kw;
  final int kcalH;
  final double pElecKw;
  final double t0;
  final double tk;
  final String sucInch;
  final String liqInch;
  final String condDim;
  final String evapDim;
  final int evapFans;
  final int wallPanels;
  final int roofPanels;
  final bool floorInsRequired;
  final String recommendedUnit;

  const CryoResult({
    required this.volume,
    required this.areaFloor,
    required this.q0Kw,
    required this.kcalH,
    required this.pElecKw,
    required this.t0,
    required this.tk,
    required this.sucInch,
    required this.liqInch,
    required this.condDim,
    required this.evapDim,
    required this.evapFans,
    required this.wallPanels,
    required this.roofPanels,
    required this.floorInsRequired,
    required this.recommendedUnit,
  });
}

class CryoEngine {
  static CryoResult calculate(CryoInput inp) {
    final l = math.max(1.2, inp.length);
    final w = math.max(1.2, inp.width);
    final h = math.max(1.8, inp.height);
    final vol = l * w * h;
    final areaFloor = l * w;
    final areaWalls = 2 * (l + w) * h;

    // 1. Transmission Load (PU lambda = 0.023 W/m.K)
    final uVal = 0.023 / (inp.insMm / 1000.0);
    final dT = math.max(4.0, inp.tAmbient - inp.tInside);
    final qWallsW = (areaWalls + areaFloor) * uVal * dT;
    final qFloorW = areaFloor * uVal * math.max(2.0, 18.0 - inp.tInside);

    // 2. Product Load (Sensible + Latent Freezing)
    final isLT = inp.tInside <= -5.0;
    double qProdKj = 0;
    if (inp.dailyKg > 0 && inp.tProdIn > inp.tInside) {
      if (inp.tInside < -1.5 && inp.tProdIn > -1.5) {
        qProdKj = inp.dailyKg * (3.5 * (inp.tProdIn + 1.5) + 250.0 + 1.8 * (-1.5 - inp.tInside));
      } else {
        qProdKj = inp.dailyKg * (isLT ? 1.85 : 3.55) * (inp.tProdIn - inp.tInside);
      }
    }
    final qProdW = (qProdKj * 1000.0) / 86400.0;

    // 3. Infiltration + Internal Loads
    final qInfilW = vol * (isLT ? 18.0 : 12.5);
    final qMiscW = areaFloor * 14.0;

    // Total 24h with 10% safety factor -> 16h run time
    final q24W = (qWallsW + qFloorW + qProdW + qInfilW + qMiscW) * 1.10;
    final q0Kw = double.parse(((q24W * (24.0 / 16.0)) / 1000.0).toStringAsFixed(2));
    final kcalH = (q0Kw * 860).round();
    final pElecKw = double.parse((q0Kw / (isLT ? 1.85 : 2.75)).toStringAsFixed(2));

    // Pipe Sizing
    String suc = '5/8"', liq = '3/8"';
    if (q0Kw < 2.4) {
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

    // Physical Unit Dimensions (mm) & Recommended Model
    String condDim, evapDim, model;
    int fans;
    if (q0Kw < 3.5) {
      condDim = '860 × 480 × 620 mm';
      evapDim = '820 × 420 × 380 mm';
      fans = 1;
      model = isLT ? 'Copeland ZF13K4E' : 'Copeland ZB15KCE';
    } else if (q0Kw < 7.5) {
      condDim = '1100 × 620 × 820 mm';
      evapDim = '1240 × 480 × 440 mm';
      fans = 2;
      model = isLT ? 'Copeland ZF18K4E' : 'Bitzer 2EES-2Y';
    } else if (q0Kw < 14.0) {
      condDim = '1360 × 720 × 1000 mm';
      evapDim = '1720 × 540 × 490 mm';
      fans = 3;
      model = isLT ? 'Bitzer 4EES-4Y' : 'Copeland ZB45KCE';
    } else {
      condDim = '1880 × 940 × 1380 mm';
      evapDim = '2350 × 620 × 560 mm';
      fans = 4;
      model = isLT ? 'Copeland ZFI36KQE (EVI)' : 'Bitzer 4TES-9Y';
    }

    if (inp.arch == 'monobloc') condDim = '940 × 760 × 840 mm (Monobloc)';
    if (inp.arch == 'rack') condDim = '2100 × 1020 × 1620 mm (Multi-Rack)';

    return CryoResult(
      volume: double.parse(vol.toStringAsFixed(1)),
      areaFloor: double.parse(areaFloor.toStringAsFixed(1)),
      q0Kw: q0Kw,
      kcalH: kcalH,
      pElecKw: pElecKw,
      t0: inp.tInside - 7.0,
      tk: inp.tAmbient + 12.0,
      sucInch: suc,
      liqInch: liq,
      condDim: condDim,
      evapDim: evapDim,
      evapFans: fans,
      wallPanels: ((2 * (l + w)) / 1.15).ceil(),
      roofPanels: (w / 1.15).ceil(),
      floorInsRequired: inp.tInside <= 0,
      recommendedUnit: model,
    );
  }
}
