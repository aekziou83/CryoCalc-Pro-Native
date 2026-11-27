import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../engine/cryo_engine.dart';

class Room3DViewer extends StatefulWidget {
  final CryoInput input;
  final CryoResult result;
  final AuditResult? audit;

  const Room3DViewer({
    super.key,
    required this.input,
    required this.result,
    this.audit,
  });

  @override
  State<Room3DViewer> createState() => _Room3DViewerState();
}

class _Room3DViewerState extends State<Room3DViewer> {
  double _rotY = -0.60;
  double _rotX = 0.42;
  int _viewMode = 0; // 0: 3D Cutaway | 1: 3D Closed | 2: 2D Architectural Plan | 3: Circuit Schematic

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    final inp = widget.input;
    final isAudit = widget.audit != null;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF050B16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF38BDF8).withAlpha(105)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withAlpha(38),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header & View Mode Switcher
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.architecture_rounded, color: Color(0xFF38BDF8), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isAudit
                            ? 'مخطط التشخيص الميداني الحي على الغرفة والمجموعة'
                            : 'المخطط الهندسي الواقعي — اسحب بإصبعك للتدوير 360°',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ),
                    if (_viewMode <= 1)
                      InkWell(
                        onTap: () => setState(() {
                          _rotY = -0.60;
                          _rotX = 0.42;
                        }),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.refresh_rounded, color: Color(0xFF94A3B8), size: 20),
                        ),
                      ),
                  ],
                ),
                if (!isAudit) ...[
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _modeChip('منظور 3D داخلي', 0),
                        const SizedBox(width: 6),
                        _modeChip('3D جدران وألواح', 1),
                        const SizedBox(width: 6),
                        _modeChip('مسقط أفقي 2D بالأبعاد', 2),
                        const SizedBox(width: 6),
                        _modeChip('مخطط الدائرة التبريدية', 3),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // CAD Drawing Canvas
          SizedBox(
            height: 315,
            width: double.infinity,
            child: GestureDetector(
              onPanUpdate: (d) {
                if (_viewMode > 1 && !isAudit) return;
                setState(() {
                  _rotY += d.delta.dx * 0.01;
                  _rotX = (_rotX - d.delta.dy * 0.008).clamp(0.14, 1.15);
                });
              },
              child: CustomPaint(
                painter: _RealisticHvacCadPainter(
                  input: inp,
                  result: r,
                  audit: widget.audit,
                  rotY: _rotY,
                  rotX: _rotX,
                  viewMode: isAudit ? 0 : _viewMode,
                ),
              ),
            ),
          ),

          // Exact Physical Measurements Strip (Strict LTR for Dimensions)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF0B1527),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(17)),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _specChip('المجموعة المختارة', '${r.selectedUnit.item.brand} ${r.selectedUnit.item.model}', const Color(0xFF22C55E)),
                _specChip('أبعاد مجموعة التكثيف', '${r.condDimMm[0]} × ${r.condDimMm[1]} × ${r.condDimMm[2]} mm', const Color(0xFFF59E0B)),
                _specChip('أبعاد المبخر الداخلي', '${r.evapDimMm[0]} × ${r.evapDimMm[1]} × ${r.evapDimMm[2]} mm (${r.evapFans} مراوح)', const Color(0xFF38BDF8)),
                _specChip('أنابيب النحاس (سحب / سائل)', '${r.sucInch}  /  ${r.liqInch}  (${inp.pipeLen.toInt()} m)', Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeChip(String label, int index) {
    final active = _viewMode == index;
    return InkWell(
      onTap: () => setState(() => _viewMode = index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF38BDF8).withAlpha(38) : const Color(0xFF101C33),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? const Color(0xFF38BDF8) : Colors.white.withAlpha(24)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: active ? const Color(0xFF38BDF8) : const Color(0xFFCBD5E1),
          ),
        ),
      ),
    );
  }

  Widget _specChip(String label, String value, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF12203A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
          const SizedBox(height: 2),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(value, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: accent)),
          ),
        ],
      ),
    );
  }
}

class _V3 {
  final double x, y, z;
  const _V3(this.x, this.y, this.z);
}

class _RealisticHvacCadPainter extends CustomPainter {
  final CryoInput input;
  final CryoResult result;
  final AuditResult? audit;
  final double rotY;
  final double rotX;
  final int viewMode;

  _RealisticHvacCadPainter({
    required this.input,
    required this.result,
    required this.audit,
    required this.rotY,
    required this.rotX,
    required this.viewMode,
  });

  Color _statusCol(String? st, Color fallback) {
    if (st == 'ok') return const Color(0xFF22C55E);
    if (st == 'warn') return const Color(0xFFF59E0B);
    if (st == 'bad') return const Color(0xFFEF4444);
    return fallback;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Engineering Grid Background
    final gridMinor = Paint()..color = const Color(0xFF38BDF8).withAlpha(12)..strokeWidth = 1;
    final gridMajor = Paint()..color = const Color(0xFF38BDF8).withAlpha(24)..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), (x % 100 == 0) ? gridMajor : gridMinor);
    }
    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), (y % 100 == 0) ? gridMajor : gridMinor);
    }

    if (viewMode == 2) {
      _paint2DPlan(canvas, size);
    } else if (viewMode == 3) {
      _paintCircuitSchematic(canvas, size);
    } else {
      _paint3DRealistic(canvas, size, cutaway: viewMode == 0);
    }
  }

  /* -------------------- VIEW 0 & 1: REALISTIC 3D COLD ROOM & UNIT -------------------- */
  void _paint3DRealistic(Canvas canvas, Size size, {required bool cutaway}) {
    final maxD = math.max(input.length, math.max(input.width, input.height));
    final lx = (input.length / maxD) * 2.45;
    final wz = (input.width / maxD) * 2.45;
    final hy = (input.height / maxD) * 2.15;
    final scale = math.min(size.width, size.height) * 0.265;
    final center = Offset(size.width * 0.42, size.height * 0.56);

    Offset proj(_V3 p) {
      final cosY = math.cos(rotY), sinY = math.sin(rotY);
      final cosX = math.cos(rotX), sinX = math.sin(rotX);
      final x1 = p.x * cosY - p.z * sinY;
      final z1 = p.x * sinY + p.z * cosY;
      final y2 = p.y * cosX - z1 * sinX;
      return Offset(center.dx + x1 * scale, center.dy - y2 * scale);
    }

    void poly(List<_V3> pts, Color fill, Color stroke, {double sw = 1.4}) {
      final path = Path()..moveTo(proj(pts[0]).dx, proj(pts[0]).dy);
      for (int i = 1; i < pts.length; i++) {
        final pi = proj(pts[i]);
        path.lineTo(pi.dx, pi.dy);
      }
      path.close();
      canvas.drawPath(path, Paint()..color = fill..style = PaintingStyle.fill);
      canvas.drawPath(path, Paint()..color = stroke..style = PaintingStyle.stroke..strokeWidth = sw);
    }

    final hx = lx / 2, hz = wz / 2;
    final b00 = _V3(-hx, 0, -hz), b10 = _V3(hx, 0, -hz);
    final b11 = _V3(hx, 0, hz), b01 = _V3(-hx, 0, hz);
    final t00 = _V3(-hx, hy, -hz), t10 = _V3(hx, hy, -hz);
    final t11 = _V3(hx, hy, hz), t01 = _V3(-hx, hy, hz);

    // Insulated Floor Slab Edge (PU Core Thickness)
    final flThick = result.floorInsIncluded ? 0.14 : 0.06;
    poly([b01, b11, _V3(hx, -flThick, hz), _V3(-hx, -flThick, hz)],
        result.floorInsIncluded ? const Color(0xFF0284C7) : const Color(0xFF334155), const Color(0xFF0F172A));
    poly([b11, b10, _V3(hx, -flThick, -hz), _V3(hx, -flThick, hz)],
        result.floorInsIncluded ? const Color(0xFF0369A1) : const Color(0xFF1E293B), const Color(0xFF0F172A));

    // Interior Non-Slip Floor
    poly([b00, b10, b11, b01], const Color(0xFF0E203C), const Color(0xFF38BDF8), sw: 1.5);

    // Back Insulated Walls + Sandwich Panel Joint Lines
    poly([b00, b10, t10, t00], const Color(0xFF182D4F), const Color(0xFF64748B));
    poly([b00, b01, t01, t00], const Color(0xFF132440), const Color(0xFF64748B));

    final seamPaint = Paint()..color = const Color(0xFF475569).withAlpha(140)..strokeWidth = 1.0;
    final nPanelsL = result.wallPanels.clamp(2, 10);
    for (int i = 1; i < nPanelsL; i++) {
      final px = -hx + (lx * i) / nPanelsL;
      canvas.drawLine(proj(_V3(px, 0, -hz)), proj(_V3(px, hy, -hz)), seamPaint);
    }

    // Ceiling Indoor Evaporator (Finned Coil + Multi-Fan Shrouds + Cold Airflow)
    final evCol = _statusCol(audit?.evapStatus, const Color(0xFF38BDF8));
    final evX1 = -hx + 0.12, evX2 = -hx + 0.50;
    final evZ1 = -hz * 0.68, evZ2 = hz * 0.68;
    final evY1 = hy * 0.72, evY2 = hy * 0.92;

    poly([_V3(evX2, evY1, evZ1), _V3(evX2, evY1, evZ2), _V3(evX2, evY2, evZ2), _V3(evX2, evY2, evZ1)],
        const Color(0xFF0C3559), evCol, sw: 1.8);
    poly([_V3(evX1, evY2, evZ1), _V3(evX2, evY2, evZ1), _V3(evX2, evY2, evZ2), _V3(evX1, evY2, evZ2)],
        const Color(0xFF1A4B75), evCol);
    poly([_V3(evX1, evY1, evZ2), _V3(evX2, evY1, evZ2), _V3(evX2, evY2, evZ2), _V3(evX1, evY2, evZ2)],
        const Color(0xFF0A2742), evCol);

    // Evaporator Fan Grilles + Airflow Vectors
    final fanCount = result.evapFans;
    for (int f = 0; f < fanCount; f++) {
      final fz = evZ1 + ((evZ2 - evZ1) * (f + 0.5)) / fanCount;
      final fc = proj(_V3(evX2 + 0.01, (evY1 + evY2) / 2, fz));
      canvas.drawCircle(fc, scale * 0.085, Paint()..color = const Color(0xFF04111F));
      canvas.drawCircle(fc, scale * 0.085, Paint()..color = evCol..style = PaintingStyle.stroke..strokeWidth = 1.4);

      final airEnd = proj(_V3(hx * 0.72, (evY1 + evY2) / 2 - 0.14, fz));
      canvas.drawLine(
        fc,
        airEnd,
        Paint()..color = const Color(0xFF38BDF8).withAlpha(185)..strokeWidth = 1.6,
      );
    }

    // Front Walls (Cutaway vs Solid Panels)
    final alpha = cutaway ? 34 : 195;
    poly([b01, b11, t11, t01], const Color(0xFF38BDF8).withAlpha(alpha), const Color(0xFF64748B));
    poly([b10, b11, t11, t10], const Color(0xFF0EA5E9).withAlpha(alpha), const Color(0xFF64748B));
    poly([t00, t10, t11, t01], const Color(0xFF38BDF8).withAlpha(cutaway ? 22 : 165), const Color(0xFF38BDF8));

    // Insulated Door with Frame, Hinges & Handle
    final dW = lx * 0.28, dH = hy * 0.76;
    final doorCol = _statusCol(audit?.doorStatus, input.tInside < 0 ? const Color(0xFFF59E0B) : const Color(0xFF22C55E));
    poly(
      [_V3(-dW / 2, 0, hz), _V3(dW / 2, 0, hz), _V3(dW / 2, dH, hz), _V3(-dW / 2, dH, hz)],
      const Color(0xFF1E293B).withAlpha(225),
      doorCol,
      sw: 2.3,
    );
    final handlePt = proj(_V3(-dW * 0.32, dH * 0.48, hz + 0.02));
    canvas.drawCircle(handlePt, 3.5, Paint()..color = Colors.white);

    // Outdoor Condensing Unit (Realistic Chassis + Fan + Compressor + Receiver)
    final compCol = _statusCol(audit?.compStatus, const Color(0xFF38BDF8));
    final condCol = _statusCol(audit?.condStatus, const Color(0xFFFB923C));
    final ux1 = hx + (input.arch == 'monobloc' ? 0.03 : 0.65);
    final ux2 = ux1 + 0.92;
    final uz1 = -0.38, uz2 = 0.38;
    final uy1 = input.arch == 'monobloc' ? hy * 0.38 : 0.0;
    final uy2 = uy1 + 0.82;

    // Steel Base Rails
    poly([_V3(ux1 - 0.04, uy1 - 0.06, uz2), _V3(ux2 + 0.04, uy1 - 0.06, uz2), _V3(ux2 + 0.04, uy1, uz2), _V3(ux1 - 0.04, uy1, uz2)],
        const Color(0xFF334155), const Color(0xFF64748B), sw: 1.0);
    // Unit Housing
    poly([_V3(ux1, uy1, uz2), _V3(ux2, uy1, uz2), _V3(ux2, uy2, uz2), _V3(ux1, uy2, uz2)],
        const Color(0xFF11213B), condCol, sw: 1.9);
    poly([_V3(ux1, uy2, uz1), _V3(ux2, uy2, uz1), _V3(ux2, uy2, uz2), _V3(ux1, uy2, uz2)],
        const Color(0xFF1A3359), condCol, sw: 1.5);
    poly([_V3(ux2, uy1, uz1), _V3(ux2, uy1, uz2), _V3(ux2, uy2, uz2), _V3(ux2, uy2, uz1)],
        const Color(0xFF0C182D), condCol, sw: 1.5);

    // Multi-Blade Condenser Fan Grille
    final fanC = proj(_V3(ux1 + (ux2 - ux1) * 0.62, (uy1 + uy2) / 2, uz2 + 0.01));
    final fanR = scale * 0.25;
    canvas.drawCircle(fanC, fanR, Paint()..color = const Color(0xFF050B16));
    canvas.drawCircle(fanC, fanR, Paint()..color = condCol..style = PaintingStyle.stroke..strokeWidth = 2.0);
    canvas.drawCircle(fanC, fanR * 0.62, Paint()..color = condCol.withAlpha(120)..style = PaintingStyle.stroke..strokeWidth = 1.0);
    for (int b = 0; b < 4; b++) {
      final ang = b * math.pi / 4;
      canvas.drawLine(
        Offset(fanC.dx + math.cos(ang) * fanR * 0.9, fanC.dy + math.sin(ang) * fanR * 0.9),
        Offset(fanC.dx - math.cos(ang) * fanR * 0.9, fanC.dy - math.sin(ang) * fanR * 0.9),
        Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 1.6,
      );
    }

    // Compressor & Liquid Receiver Silhouette inside left section
    final compBox = proj(_V3(ux1 + 0.20, uy1 + 0.32, uz2 + 0.01));
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: compBox, width: scale * 0.22, height: scale * 0.34), const Radius.circular(6)),
      Paint()..color = compCol.withAlpha(55),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: compBox, width: scale * 0.22, height: scale * 0.34), const Radius.circular(6)),
      Paint()..color = compCol..style = PaintingStyle.stroke..strokeWidth = 1.6,
    );

    // Insulated Copper Piping (Suction + Liquid + Filter Drier/Sight Glass)
    if (input.arch != 'monobloc') {
      final pWall = proj(_V3(hx, hy * 0.76, 0));
      final pKnee = proj(_V3(ux1 + 0.18, hy * 0.76, 0));
      final pUnit = proj(_V3(ux1 + 0.18, uy2, 0));

      final sucPath = Path()..moveTo(pWall.dx, pWall.dy)..lineTo(pKnee.dx, pKnee.dy)..lineTo(pUnit.dx, pUnit.dy);
      canvas.drawPath(sucPath, Paint()..color = const Color(0xFF38BDF8)..strokeWidth = 3.8..style = PaintingStyle.stroke);

      final liqPath = Path()
        ..moveTo(pWall.dx, pWall.dy + 7)
        ..lineTo(pKnee.dx - 6, pKnee.dy + 7)
        ..lineTo(pUnit.dx - 6, pUnit.dy);
      canvas.drawPath(liqPath, Paint()..color = const Color(0xFFFB923C)..strokeWidth = 2.2..style = PaintingStyle.stroke);
    }

    // Dimension Callouts
    _tag(canvas, proj(_V3(0, -0.22, hz + 0.30)), 'L = ${input.length.toStringAsFixed(1)} m', const Color(0xFF38BDF8));
    _tag(canvas, proj(_V3(-hx - 0.38, hy * 0.5, hz)), 'H = ${input.height.toStringAsFixed(1)} m', const Color(0xFF38BDF8));
    _tag(canvas, proj(_V3(hx + 0.28, -0.22, 0)), 'W = ${input.width.toStringAsFixed(1)} m', const Color(0xFF38BDF8));
    _tag(canvas, proj(_V3((ux1 + ux2) / 2, uy2 + 0.28, 0)), '${result.q0Kw} kW (${input.refrigerant})', const Color(0xFF22C55E));
  }

  /* -------------------- VIEW 2: 2D ARCHITECTURAL TOP PLAN VIEW -------------------- */
  void _paint2DPlan(Canvas canvas, Size size) {
    final padL = 55.0, padT = 44.0;
    final maxW = size.width * 0.48;
    final maxH = size.height - 95.0;
    final sc = math.min(maxW / input.length, maxH / input.width);
    final rw = input.length * sc;
    final rh = input.width * sc;

    final roomRect = Rect.fromLTWH(padL, padT, rw, rh);
    // Outer PU Wall Thickness
    final wallThick = (input.insMm / 20.0).clamp(5.0, 12.0);
    canvas.drawRect(
      roomRect.inflate(wallThick),
      Paint()..color = const Color(0xFF0284C7).withAlpha(65),
    );
    canvas.drawRect(
      roomRect.inflate(wallThick),
      Paint()..color = const Color(0xFF38BDF8)..style = PaintingStyle.stroke..strokeWidth = 2.0,
    );
    canvas.drawRect(
      roomRect,
      Paint()..color = const Color(0xFF0B192E),
    );

    // Evaporator inside left wall
    final evRect = Rect.fromLTWH(padL + 10, padT + rh * 0.2, 24, rh * 0.6);
    canvas.drawRect(evRect, Paint()..color = const Color(0xFF164E63));
    canvas.drawRect(evRect, Paint()..color = const Color(0xFF38BDF8)..style = PaintingStyle.stroke..strokeWidth = 1.6);

    // Door opening on bottom wall
    final doorPx = (result.doorWidth / input.length) * rw;
    final doorX = padL + (rw - doorPx) / 2;
    canvas.drawLine(
      Offset(doorX, padT + rh + wallThick / 2),
      Offset(doorX + doorPx, padT + rh + wallThick / 2),
      Paint()..color = const Color(0xFFF59E0B)..strokeWidth = 5,
    );

    // Condensing Unit Box on Right
    final unitRect = Rect.fromLTWH(padL + rw + 65, padT + rh * 0.22, 115, 78);
    canvas.drawRRect(
      RRect.fromRectAndRadius(unitRect, const Radius.circular(8)),
      Paint()..color = const Color(0xFF132542),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(unitRect, const Radius.circular(8)),
      Paint()..color = const Color(0xFFF59E0B)..style = PaintingStyle.stroke..strokeWidth = 2.0,
    );

    // Copper Lines
    canvas.drawLine(
      Offset(evRect.right, evRect.center.dy - 6),
      Offset(unitRect.left, unitRect.center.dy - 6),
      Paint()..color = const Color(0xFF38BDF8)..strokeWidth = 3.0,
    );
    canvas.drawLine(
      Offset(evRect.right, evRect.center.dy + 6),
      Offset(unitRect.left, unitRect.center.dy + 6),
      Paint()..color = const Color(0xFFFB923C)..strokeWidth = 2.0,
    );

    // Dimension Lines
    _tag(canvas, Offset(padL + rw / 2, padT - 18), 'L = ${input.length} m (${result.wallPanels} ألواح)', const Color(0xFF38BDF8));
    _tag(canvas, Offset(padL - 26, padT + rh / 2), 'W = ${input.width} m', const Color(0xFF38BDF8));
    _tag(canvas, Offset(unitRect.center.dx, unitRect.top - 15), 'Groupe: ${result.condDimMm[0]}×${result.condDimMm[1]}mm', const Color(0xFFFBBF24));
    _tag(canvas, Offset(unitRect.center.dx, unitRect.bottom + 18), 'Ø ${result.sucInch} / ${result.liqInch}', const Color(0xFF22C55E));
  }

  /* -------------------- VIEW 3: REFRIGERATION CIRCUIT SCHEMATIC -------------------- */
  void _paintCircuitSchematic(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final box = Rect.fromLTWH(38, 42, w - 76, h - 84);

    // High Pressure Red/Orange Top & Right, Low Pressure Cyan Bottom & Left
    final hpPaint = Paint()..color = const Color(0xFFFB923C)..strokeWidth = 3.0..style = PaintingStyle.stroke;
    final lpPaint = Paint()..color = const Color(0xFF38BDF8)..strokeWidth = 3.2..style = PaintingStyle.stroke;

    // Top Discharge & Liquid Line
    canvas.drawLine(Offset(box.left + 45, box.top), Offset(box.right, box.top), hpPaint);
    canvas.drawLine(Offset(box.right, box.top), Offset(box.right, box.bottom), hpPaint);
    // Bottom & Left Suction Line
    canvas.drawLine(Offset(box.right, box.bottom), Offset(box.left, box.bottom), lpPaint);
    canvas.drawLine(Offset(box.left, box.bottom), Offset(box.left, box.top + 35), lpPaint);

    void node(Offset c, String title, String sub, Color col) {
      final r = RRect.fromRectAndRadius(Rect.fromCenter(center: c, width: 112, height: 48), const Radius.circular(9));
      canvas.drawRRect(r, Paint()..color = const Color(0xFF0E1B33));
      canvas.drawRRect(r, Paint()..color = col..style = PaintingStyle.stroke..strokeWidth = 1.8);
      _rawText(canvas, Offset(c.dx, c.dy - 9), title, col, 10.5);
      _rawText(canvas, Offset(c.dx, c.dy + 8), sub, Colors.white, 9.5);
    }

    node(Offset(box.left + 25, box.top + 22), '1. الضاغط', result.selectedUnit.item.model, const Color(0xFF22C55E));
    node(Offset(box.center.dx, box.top), '2. المكثف (Condenseur)', 'Tk = ${result.tk.toStringAsFixed(0)}°C', const Color(0xFFFB923C));
    node(Offset(box.right, box.top + 55), '3. خزان السائل', 'Réservoir HP', const Color(0xFFFB923C));
    node(Offset(box.right, box.bottom - 55), '4. مجفف + زجاجة', 'FD + SG • ${result.liqInch}', const Color(0xFFFBBF24));
    node(Offset(box.center.dx + 45, box.bottom), '5. صمام التمدد (TXV)', 'Détendeur', const Color(0xFF38BDF8));
    node(Offset(box.left + 45, box.bottom), '6. المبخر (Évaporateur)', 'T₀ = ${result.t0.toStringAsFixed(0)}°C • ${result.sucInch}', const Color(0xFF38BDF8));
  }

  void _tag(Canvas canvas, Offset pos, String text, Color color) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900)),
      textDirection: TextDirection.ltr,
    )..layout();
    final rect = Rect.fromCenter(center: pos, width: tp.width + 10, height: tp.height + 5);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), Paint()..color = const Color(0xFF060C18).withAlpha(225));
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  void _rawText(Canvas canvas, Offset pos, String text, Color color, double sz) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: sz, fontWeight: FontWeight.w800)),
      textDirection: TextDirection.rtl,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _RealisticHvacCadPainter old) => true;
}
