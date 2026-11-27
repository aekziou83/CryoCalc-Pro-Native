import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../engine/cryo_engine.dart';

class Room3DViewer extends StatefulWidget {
  final CryoInput input;
  final CryoResult result;

  const Room3DViewer({super.key, required this.input, required this.result});

  @override
  State<Room3DViewer> createState() => _Room3DViewerState();
}

class _Room3DViewerState extends State<Room3DViewer> {
  double _rotY = -0.62;
  double _rotX = 0.42;
  bool _cutaway = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF050B16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF38BDF8).withAlpha(90)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withAlpha(35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top CAD Control Strip
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            child: Row(
              children: [
                const Icon(Icons.view_in_ar_rounded, color: Color(0xFF38BDF8), size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'مجسم 3D تفاعلي — اسحب بإصبعك للتدوير',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
                InkWell(
                  onTap: () => setState(() => _cutaway = !_cutaway),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111D34),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF38BDF8).withAlpha(110)),
                    ),
                    child: Text(
                      _cutaway ? 'منظور داخلي' : 'جدران مغلقة',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8)),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () => setState(() {
                    _rotY = -0.62;
                    _rotX = 0.42;
                  }),
                  child: const Icon(Icons.refresh_rounded, color: Color(0xFF94A3B8), size: 20),
                ),
              ],
            ),
          ),

          // Interactive 3D Canvas
          SizedBox(
            height: 290,
            width: double.infinity,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _rotY += details.delta.dx * 0.01;
                  _rotX = (_rotX - details.delta.dy * 0.008).clamp(0.12, 1.15);
                });
              },
              child: CustomPaint(
                painter: _ColdRoom3DPainter(
                  input: widget.input,
                  result: widget.result,
                  rotY: _rotY,
                  rotX: _rotX,
                  cutaway: _cutaway,
                ),
              ),
            ),
          ),

          // Live Measurements Bar under 3D Model
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF0C1629),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(17)),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _specChip('المجموعة المقترحة', widget.result.recommendedUnit, const Color(0xFF22C55E)),
                _specChip('أبعاد المجموعة', widget.result.condDim, const Color(0xFFF59E0B)),
                _specChip('أبعاد المبخر', widget.result.evapDim, const Color(0xFF38BDF8)),
                _specChip('النحاس (سحب / سائل)', '${widget.result.sucInch} / ${widget.result.liqInch}', Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _specChip(String label, String value, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF13223D),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: accent)),
        ],
      ),
    );
  }
}

class _Vec3 {
  final double x, y, z;
  const _Vec3(this.x, this.y, this.z);
}

class _ColdRoom3DPainter extends CustomPainter {
  final CryoInput input;
  final CryoResult result;
  final double rotY;
  final double rotX;
  final bool cutaway;

  _ColdRoom3DPainter({
    required this.input,
    required this.result,
    required this.rotY,
    required this.rotX,
    required this.cutaway,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw subtle CAD Grid
    final gridPaint = Paint()..color = const Color(0xFF38BDF8).withAlpha(14)..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 24) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Normalize Room Proportions into 3D Scene Units
    final maxD = math.max(input.length, math.max(input.width, input.height));
    final lx = (input.length / maxD) * 2.4;
    final wz = (input.width / maxD) * 2.4;
    final hy = (input.height / maxD) * 2.2;
    final scale = math.min(size.width, size.height) * 0.27;
    final center = Offset(size.width * 0.43, size.height * 0.56);

    Offset proj(_Vec3 p) {
      final cosY = math.cos(rotY), sinY = math.sin(rotY);
      final cosX = math.cos(rotX), sinX = math.sin(rotX);
      final x1 = p.x * cosY - p.z * sinY;
      final z1 = p.x * sinY + p.z * cosY;
      final y2 = p.y * cosX - z1 * sinX;
      return Offset(center.dx + x1 * scale, center.dy - y2 * scale);
    }

    void drawPoly(List<_Vec3> pts, Color fill, Color stroke, {double sw = 1.4}) {
      final path = Path();
      final p0 = proj(pts[0]);
      path.moveTo(p0.dx, p0.dy);
      for (int i = 1; i < pts.length; i++) {
        final pi = proj(pts[i]);
        path.lineTo(pi.dx, pi.dy);
      }
      path.close();
      canvas.drawPath(path, Paint()..color = fill..style = PaintingStyle.fill);
      canvas.drawPath(path, Paint()..color = stroke..style = PaintingStyle.stroke..strokeWidth = sw);
    }

    final hx = lx / 2, hz = wz / 2;
    // Room 8 Corners (centered horizontally, y from 0 to hy)
    final b00 = _Vec3(-hx, 0, -hz), b10 = _Vec3(hx, 0, -hz);
    final b11 = _Vec3(hx, 0, hz), b01 = _Vec3(-hx, 0, hz);
    final t00 = _Vec3(-hx, hy, -hz), t10 = _Vec3(hx, hy, -hz);
    final t11 = _Vec3(hx, hy, hz), t01 = _Vec3(-hx, hy, hz);

    // 1. Floor Slab
    drawPoly([b00, b10, b11, b01], const Color(0xFF102340), const Color(0xFF38BDF8), sw: 1.6);

    // 2. Back Walls
    drawPoly([b00, b10, t10, t00], const Color(0xFF182C4D), const Color(0xFF64748B));
    drawPoly([b00, b01, t01, t00], const Color(0xFF142542), const Color(0xFF64748B));

    // 3. Indoor Evaporator near ceiling (inside room)
    final evX1 = -hx + 0.14, evX2 = -hx + 0.52;
    final evZ1 = -hz * 0.65, evZ2 = hz * 0.65;
    final evY1 = hy * 0.72, evY2 = hy * 0.92;
    drawPoly(
      [_Vec3(evX2, evY1, evZ1), _Vec3(evX2, evY1, evZ2), _Vec3(evX2, evY2, evZ2), _Vec3(evX2, evY2, evZ1)],
      const Color(0xFF0E3A5D),
      const Color(0xFF38BDF8),
      sw: 1.8,
    );
    drawPoly(
      [_Vec3(evX1, evY2, evZ1), _Vec3(evX2, evY2, evZ1), _Vec3(evX2, evY2, evZ2), _Vec3(evX1, evY2, evZ2)],
      const Color(0xFF1A4B73),
      const Color(0xFF38BDF8),
    );

    // Cold Airflow Lines
    final airPaint = Paint()..color = const Color(0xFF38BDF8).withAlpha(190)..strokeWidth = 1.6;
    for (int i = -1; i <= 1; i++) {
      final a1 = proj(_Vec3(evX2 + 0.04, (evY1 + evY2) / 2, i * hz * 0.35));
      final a2 = proj(_Vec3(hx * 0.68, (evY1 + evY2) / 2 - 0.15, i * hz * 0.35));
      canvas.drawLine(a1, a2, airPaint);
    }

    // 4. Front Translucent Walls + Insulated Door
    final wallAlpha = cutaway ? 38 : 185;
    drawPoly([b01, b11, t11, t01], const Color(0xFF38BDF8).withAlpha(wallAlpha), const Color(0xFF64748B));
    drawPoly([b10, b11, t11, t10], const Color(0xFF0EA5E9).withAlpha(wallAlpha), const Color(0xFF64748B));
    drawPoly([t00, t10, t11, t01], const Color(0xFF38BDF8).withAlpha(cutaway ? 24 : 155), const Color(0xFF38BDF8));

    // Door on Front Wall (z = hz)
    final dW = lx * 0.28, dH = hy * 0.74;
    final doorCol = input.tInside < 0 ? const Color(0xFFF59E0B) : const Color(0xFF22C55E);
    drawPoly(
      [_Vec3(-dW / 2, 0, hz), _Vec3(dW / 2, 0, hz), _Vec3(dW / 2, dH, hz), _Vec3(-dW / 2, dH, hz)],
      const Color(0xFF1E293B).withAlpha(210),
      doorCol,
      sw: 2.2,
    );

    // 5. Outdoor Condensing Unit positioned next to Room (x = hx + 0.55..1.45)
    final ux1 = hx + (input.arch == 'monobloc' ? 0.04 : 0.62);
    final ux2 = ux1 + 0.85;
    final uz1 = -0.35, uz2 = 0.35;
    final uy1 = input.arch == 'monobloc' ? hy * 0.35 : 0.0;
    final uy2 = uy1 + 0.78;

    drawPoly([_Vec3(ux1, uy1, uz2), _Vec3(ux2, uy1, uz2), _Vec3(ux2, uy2, uz2), _Vec3(ux1, uy2, uz2)],
        const Color(0xFF142642), const Color(0xFFF59E0B), sw: 2.0);
    drawPoly([_Vec3(ux1, uy2, uz1), _Vec3(ux2, uy2, uz1), _Vec3(ux2, uy2, uz2), _Vec3(ux1, uy2, uz2)],
        const Color(0xFF1E3A5F), const Color(0xFFF59E0B), sw: 1.6);
    drawPoly([_Vec3(ux2, uy1, uz1), _Vec3(ux2, uy1, uz2), _Vec3(ux2, uy2, uz2), _Vec3(ux2, uy2, uz1)],
        const Color(0xFF0E1D33), const Color(0xFFF59E0B), sw: 1.6);

    // Condenser Fan Circle
    final fanCenter = proj(_Vec3((ux1 + ux2) / 2, (uy1 + uy2) / 2, uz2 + 0.01));
    canvas.drawCircle(fanCenter, scale * 0.24, Paint()..color = const Color(0xFF050B16));
    canvas.drawCircle(
      fanCenter,
      scale * 0.24,
      Paint()..color = const Color(0xFFFB923C)..style = PaintingStyle.stroke..strokeWidth = 2,
    );

    // 6. Copper Suction (Cyan) & Liquid (Orange) Piping
    if (input.arch != 'monobloc') {
      final pWall = proj(_Vec3(hx, hy * 0.75, 0));
      final pMid = proj(_Vec3(ux1 + 0.2, hy * 0.75, 0));
      final pUnit = proj(_Vec3(ux1 + 0.2, uy2, 0));
      final sucPaint = Paint()..color = const Color(0xFF38BDF8)..strokeWidth = 3.5..style = PaintingStyle.stroke;
      final liqPaint = Paint()..color = const Color(0xFFFB923C)..strokeWidth = 2.2..style = PaintingStyle.stroke;

      final p1 = Path()..moveTo(pWall.dx, pWall.dy)..lineTo(pMid.dx, pMid.dy)..lineTo(pUnit.dx, pUnit.dy);
      canvas.drawPath(p1, sucPaint);

      final p2 = Path()
        ..moveTo(pWall.dx, pWall.dy + 7)
        ..lineTo(pMid.dx - 5, pMid.dy + 7)
        ..lineTo(pUnit.dx - 5, pUnit.dy);
      canvas.drawPath(p2, liqPaint);
    }

    // 7. Dynamic Dimension Labels
    _drawLabel(canvas, proj(_Vec3(0, -0.22, hz + 0.28)), 'L = ${input.length.toStringAsFixed(1)} m', const Color(0xFF38BDF8));
    _drawLabel(canvas, proj(_Vec3(-hx - 0.36, hy * 0.5, hz)), 'H = ${input.height.toStringAsFixed(1)} m', const Color(0xFF38BDF8));
    _drawLabel(canvas, proj(_Vec3(hx + 0.26, -0.22, 0)), 'W = ${input.width.toStringAsFixed(1)} m', const Color(0xFF38BDF8));
    _drawLabel(canvas, proj(_Vec3((ux1 + ux2) / 2, uy2 + 0.28, 0)), '${result.q0Kw} kW', const Color(0xFF22C55E));
  }

  void _drawLabel(Canvas canvas, Offset pos, String text, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w900),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final bg = Rect.fromCenter(center: pos, width: tp.width + 10, height: tp.height + 4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bg, const Radius.circular(6)),
      Paint()..color = const Color(0xFF070D19).withAlpha(215),
    );
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _ColdRoom3DPainter old) =>
      old.rotY != rotY || old.rotX != rotX || old.cutaway != cutaway || old.result.q0Kw != result.q0Kw;
}
