import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../engine/cryo_engine.dart';
import '../l10n/app_strings.dart';

class Room3DViewer extends StatefulWidget {
  final CryoInput input;
  final CryoResult result;
  final AuditResult? audit;
  final AppLang lang;

  const Room3DViewer({
    super.key,
    required this.input,
    required this.result,
    this.audit,
    this.lang = AppLang.ar,
  });

  @override
  State<Room3DViewer> createState() => _Room3DViewerState();
}

class _Room3DViewerState extends State<Room3DViewer> {
  double _rotY = -0.58;
  double _rotX = 0.36;
  double _zoom = 1.0;
  int _viewMode = 0;

  String tr(String key) => AppStrings.t(widget.lang, key);

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    final inp = widget.input;
    final isAudit = widget.audit != null;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF060C17),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF38BDF8).withAlpha(110)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withAlpha(42),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.view_in_ar_rounded, color: Color(0xFF38BDF8), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isAudit ? tr('v3d_audit') : tr('v3d_title'),
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ),
                    if (_viewMode <= 1 || isAudit) ...[
                      _miniIconBtn(Icons.add_rounded, () => setState(() => _zoom = (_zoom + 0.15).clamp(0.75, 1.65))),
                      const SizedBox(width: 4),
                      _miniIconBtn(Icons.remove_rounded, () => setState(() => _zoom = (_zoom - 0.15).clamp(0.75, 1.65))),
                      const SizedBox(width: 4),
                      _miniIconBtn(Icons.refresh_rounded, () => setState(() {
                            _rotY = -0.58;
                            _rotX = 0.36;
                            _zoom = 1.0;
                          })),
                    ],
                  ],
                ),
                if (!isAudit) ...[
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _modeChip(tr('v3d_cut'), 0),
                        const SizedBox(width: 6),
                        _modeChip(tr('v3d_closed'), 1),
                        const SizedBox(width: 6),
                        _modeChip(tr('v3d_2d'), 2),
                        const SizedBox(width: 6),
                        _modeChip(tr('v3d_circ'), 3),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          ClipRRect(
            child: SizedBox(
              height: 340,
              width: double.infinity,
              child: GestureDetector(
                onPanUpdate: (d) {
                  if (_viewMode > 1 && !isAudit) return;
                  setState(() {
                    _rotY += d.delta.dx * 0.011;
                    _rotX = (_rotX - d.delta.dy * 0.008).clamp(0.08, 1.18);
                  });
                },
                child: CustomPaint(
                  painter: _ShadedReal3DPainter(
                    input: inp,
                    result: r,
                    audit: widget.audit,
                    lang: widget.lang,
                    rotY: _rotY,
                    rotX: _rotX,
                    zoom: _zoom,
                    viewMode: isAudit ? 0 : _viewMode,
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF0C172B),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(17)),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _specChip(tr('v3d_sel'), '${r.selectedUnit.item.brand} ${r.selectedUnit.item.model}', const Color(0xFF22C55E)),
                _specChip(tr('v3d_cond'), '${r.condDimMm[0]} × ${r.condDimMm[1]} × ${r.condDimMm[2]} mm', const Color(0xFFF59E0B)),
                _specChip(tr('v3d_evap'), '${r.evapDimMm[0]} × ${r.evapDimMm[1]} × ${r.evapDimMm[2]} mm (${r.evapFans} ${tr("fans")})', const Color(0xFF38BDF8)),
                _specChip(tr('v3d_pipes'), '${r.sucInch}  /  ${r.liqInch}  (${inp.pipeLen.toInt()} m)', Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniIconBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFF111D34),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: Colors.white.withAlpha(25)),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFFCBD5E1)),
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
          color: active ? const Color(0xFF38BDF8).withAlpha(40) : const Color(0xFF101D34),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? const Color(0xFF38BDF8) : Colors.white.withAlpha(25)),
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
        color: const Color(0xFF13223D),
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
  _V3 operator -(_V3 o) => _V3(x - o.x, y - o.y, z - o.z);
}

class _Poly3D {
  final List<_V3> pts;
  final Color baseColor;
  final int alpha;
  final Color strokeColor;
  final double strokeWidth;
  final double depthBias;
  final bool shaded;

  const _Poly3D({
    required this.pts,
    required this.baseColor,
    this.alpha = 255,
    required this.strokeColor,
    this.strokeWidth = 1.0,
    this.depthBias = 0.0,
    this.shaded = true,
  });
}

class _ShadedReal3DPainter extends CustomPainter {
  final CryoInput input;
  final CryoResult result;
  final AuditResult? audit;
  final AppLang lang;
  final double rotY;
  final double rotX;
  final double zoom;
  final int viewMode;

  _ShadedReal3DPainter({
    required this.input,
    required this.result,
    required this.audit,
    required this.lang,
    required this.rotY,
    required this.rotX,
    required this.zoom,
    required this.viewMode,
  });

  String tr(String key) => AppStrings.t(lang, key);

  Color _auditCol(String? st, Color fallback) {
    if (st == 'ok') return const Color(0xFF22C55E);
    if (st == 'warn') return const Color(0xFFF59E0B);
    if (st == 'bad') return const Color(0xFFEF4444);
    return fallback;
  }

  _V3 _rotate(_V3 p) {
    final cy = math.cos(rotY), sy = math.sin(rotY);
    final cx = math.cos(rotX), sx = math.sin(rotX);
    final x1 = p.x * cy - p.z * sy;
    final z1 = p.x * sy + p.z * cy;
    final y2 = p.y * cx - z1 * sx;
    final z2 = p.y * sx + z1 * cx;
    return _V3(x1, y2, z2);
  }

  Offset _project(_V3 r, Offset center, double scale) {
    const camDist = 10.5;
    final factor = camDist / (camDist - r.z).clamp(2.0, 20.0);
    return Offset(center.dx + r.x * scale * factor, center.dy - r.y * scale * factor);
  }

  Color _applyLighting(Color base, int alpha, List<_V3> rotPts) {
    if (rotPts.length < 3) return base.withAlpha(alpha);
    final u = rotPts[1] - rotPts[0];
    final v = rotPts[2] - rotPts[0];
    final nx = u.y * v.z - u.z * v.y;
    final ny = u.z * v.x - u.x * v.z;
    final nz = u.x * v.y - u.y * v.x;
    final len = math.sqrt(nx * nx + ny * ny + nz * nz);
    if (len < 0.0001) return base.withAlpha(alpha);
    final dot = ((nx / len) * -0.35 + (ny / len) * 0.78 + (nz / len) * 0.52).abs();
    final factor = 0.68 + dot * 0.48;
    final hsl = HSLColor.fromColor(base);
    return hsl.withLightness((hsl.lightness * factor).clamp(0.08, 0.92)).toColor().withAlpha(alpha);
  }

  void _addBox(
    List<_Poly3D> faces,
    double x1,
    double y1,
    double z1,
    double x2,
    double y2,
    double z2, {
    required Color color,
    required Color stroke,
    int alpha = 255,
    double sw = 1.0,
    double bias = 0.0,
  }) {
    final p000 = _V3(x1, y1, z1), p100 = _V3(x2, y1, z1);
    final p101 = _V3(x2, y1, z2), p001 = _V3(x1, y1, z2);
    final p010 = _V3(x1, y2, z1), p110 = _V3(x2, y2, z1);
    final p111 = _V3(x2, y2, z2), p011 = _V3(x1, y2, z2);

    faces.add(_Poly3D(pts: [p000, p100, p101, p001], baseColor: color, alpha: alpha, strokeColor: stroke, strokeWidth: sw, depthBias: bias));
    faces.add(_Poly3D(pts: [p000, p100, p110, p010], baseColor: color, alpha: alpha, strokeColor: stroke, strokeWidth: sw, depthBias: bias));
    faces.add(_Poly3D(pts: [p000, p001, p011, p010], baseColor: color, alpha: alpha, strokeColor: stroke, strokeWidth: sw, depthBias: bias));
    faces.add(_Poly3D(pts: [p001, p101, p111, p011], baseColor: color, alpha: alpha, strokeColor: stroke, strokeWidth: sw, depthBias: bias));
    faces.add(_Poly3D(pts: [p100, p101, p111, p110], baseColor: color, alpha: alpha, strokeColor: stroke, strokeWidth: sw, depthBias: bias));
    faces.add(_Poly3D(pts: [p010, p110, p111, p011], baseColor: color, alpha: alpha, strokeColor: stroke, strokeWidth: sw, depthBias: bias));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final bgRect = Offset.zero & size;
    canvas.drawRect(
      bgRect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0.0, -0.2),
          radius: 1.15,
          colors: [Color(0xFF0E1C36), Color(0xFF050A14)],
        ).createShader(bgRect),
    );
    final gridPaint = Paint()..color = const Color(0xFF38BDF8).withAlpha(14)..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 24) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (viewMode == 2) {
      _paint2DPlan(canvas, size);
      return;
    }
    if (viewMode == 3) {
      _paintCircuitSchematic(canvas, size);
      return;
    }
    _paintRealistic3D(canvas, size, cutaway: viewMode == 0);
  }

  void _paintRealistic3D(Canvas canvas, Size size, {required bool cutaway}) {
    final maxD = math.max(input.length, math.max(input.width, input.height));
    final lx = (input.length / maxD) * 2.55;
    final wz = (input.width / maxD) * 2.55;
    final hy = (input.height / maxD) * 2.05;
    final hx = lx / 2, hz = wz / 2;

    final scale = math.min(size.width, size.height) * 0.255 * zoom;
    final center = Offset(size.width * 0.44, size.height * 0.58);
    final faces = <_Poly3D>[];

    const pad = 0.25;
    faces.add(_Poly3D(
      pts: [_V3(-hx - pad, -0.16, -hz - pad), _V3(hx + 1.55, -0.16, -hz - pad), _V3(hx + 1.55, -0.16, hz + pad), _V3(-hx - pad, -0.16, hz + pad)],
      baseColor: const Color(0xFF02060F),
      alpha: 155,
      strokeColor: const Color(0xFF1E293B),
      strokeWidth: 0.8,
      depthBias: -8.0,
      shaded: false,
    ));

    final flH = result.floorInsIncluded ? 0.14 : 0.06;
    _addBox(faces, -hx, -flH, -hz, hx, 0.0, hz, color: result.floorInsIncluded ? const Color(0xFF64748B) : const Color(0xFF475569), stroke: const Color(0xFF94A3B8), bias: -2.0);

    const wallColor = Color(0xFFDCE6F2);
    const wallStroke = Color(0xFF64748B);
    const tWall = 0.07;

    _addBox(faces, -hx, 0, -hz - tWall, hx, hy, -hz, color: wallColor, stroke: wallStroke, sw: 0.9);
    _addBox(faces, -hx - tWall, 0, -hz, -hx, hy, hz, color: wallColor, stroke: wallStroke, sw: 0.9);

    if (cutaway) {
      faces.add(_Poly3D(pts: [_V3(-hx, 0, hz), _V3(hx, 0, hz), _V3(hx, hy, hz), _V3(-hx, hy, hz)], baseColor: const Color(0xFF7DD3FC), alpha: 34, strokeColor: const Color(0xFF38BDF8), strokeWidth: 1.1, depthBias: 3.0, shaded: false));
      faces.add(_Poly3D(pts: [_V3(hx, 0, -hz), _V3(hx, 0, hz), _V3(hx, hy, hz), _V3(hx, hy, -hz)], baseColor: const Color(0xFF38BDF8), alpha: 28, strokeColor: const Color(0xFF38BDF8), strokeWidth: 1.1, depthBias: 3.0, shaded: false));
      faces.add(_Poly3D(pts: [_V3(-hx, hy, -hz), _V3(hx, hy, -hz), _V3(hx, hy, hz), _V3(-hx, hy, hz)], baseColor: const Color(0xFFBAE6FD), alpha: 26, strokeColor: const Color(0xFF38BDF8), strokeWidth: 1.1, depthBias: 3.2, shaded: false));
    } else {
      _addBox(faces, -hx, 0, hz, hx, hy, hz + tWall, color: wallColor, stroke: wallStroke, sw: 0.9);
      _addBox(faces, hx, 0, -hz, hx + tWall, hy, hz, color: wallColor, stroke: wallStroke, sw: 0.9);
      _addBox(faces, -hx - tWall, hy, -hz - tWall, hx + tWall, hy + tWall, hz + tWall, color: const Color(0xFFE2E8F0), stroke: wallStroke, sw: 0.9);
    }

    final dW = (result.doorWidth / input.length).clamp(0.22, 0.45) * lx;
    final dH = (result.doorHeight / input.height).clamp(0.55, 0.84) * hy;
    final doorCol = _auditCol(audit?.doorStatus, const Color(0xFFF1F5F9));
    final gasketCol = input.tInside < 0 ? const Color(0xFFF59E0B) : const Color(0xFF1E293B);
    _addBox(faces, -dW / 2 - 0.05, 0, hz + 0.01, dW / 2 + 0.05, dH + 0.05, hz + 0.06, color: gasketCol, stroke: const Color(0xFF0F172A), bias: 3.5);
    _addBox(faces, -dW / 2, 0.02, hz + 0.05, dW / 2, dH, hz + 0.13, color: doorCol, stroke: const Color(0xFF475569), sw: 1.2, bias: 3.7);
    _addBox(faces, -dW * 0.36, dH * 0.42, hz + 0.13, -dW * 0.28, dH * 0.56, hz + 0.18, color: const Color(0xFF0284C7), stroke: Colors.white, sw: 0.9, bias: 3.9);

    if (input.tInside <= 0) {
      _addBox(faces, dW / 2 + 0.16, hy * 0.72, hz + 0.02, dW / 2 + 0.30, hy * 0.84, hz + 0.10, color: const Color(0xFFF59E0B), stroke: const Color(0xFF0F172A), bias: 3.6);
    }

    final evCol = _auditCol(audit?.evapStatus, const Color(0xFFE2E8F0));
    final evX1 = -hx + 0.12, evX2 = -hx + 0.52;
    final evZ1 = -hz * 0.66, evZ2 = hz * 0.66;
    final evY1 = hy * 0.71, evY2 = hy * 0.93;
    _addBox(faces, evX1, evY1, evZ1, evX2, evY2, evZ2, color: evCol, stroke: const Color(0xFF0284C7), sw: 1.3, bias: 0.4);
    _addBox(faces, evX1, evY1 - 0.05, evZ1, evX2, evY1, evZ2, color: const Color(0xFF0284C7), stroke: const Color(0xFF075985), bias: 0.45);

    final compCol = _auditCol(audit?.compStatus, const Color(0xFF1E3A8A));
    final condCol = _auditCol(audit?.condStatus, const Color(0xFFCBD5E1));
    final ux1 = hx + (input.arch == 'monobloc' ? 0.08 : 0.68);
    final uLen = input.arch == 'rack' ? 1.35 : (input.arch == 'monobloc' ? 0.65 : 1.02);
    final ux2 = ux1 + uLen;
    const uz1 = -0.42, uz2 = 0.42;
    final uy1 = input.arch == 'monobloc' ? hy * 0.40 : 0.0;
    final uHei = input.arch == 'rack' ? 1.15 : 0.84;
    final uy2 = uy1 + uHei;

    _addBox(faces, ux1 - 0.04, uy1 - 0.07, uz1 - 0.03, ux2 + 0.04, uy1, uz2 + 0.03, color: const Color(0xFF334155), stroke: const Color(0xFF0F172A));

    if (input.arch == 'carrosse' || input.arch == 'monobloc') {
      _addBox(faces, ux1, uy1, uz1, ux2, uy2, uz2, color: const Color(0xFFCBD5E1), stroke: const Color(0xFF475569), sw: 1.3, bias: 0.2);
      _addBox(faces, ux1 + uLen * 0.35, uy1 + 0.12, uz2, ux2 - 0.08, uy2 - 0.10, uz2 + 0.03, color: const Color(0xFF0F172A), stroke: const Color(0xFF38BDF8), bias: 0.4);
    } else {
      _addBox(faces, ux1 + uLen * 0.48, uy1 + 0.02, uz1 + 0.02, ux2 - 0.02, uy2, uz2 - 0.02, color: condCol, stroke: const Color(0xFF475569), sw: 1.2, bias: 0.15);
      _addBox(faces, ux1 + uLen * 0.52, uy1 + 0.08, uz2 - 0.01, ux2 - 0.06, uy2 - 0.06, uz2 + 0.02, color: const Color(0xFF1E293B), stroke: const Color(0xFFFB923C), sw: 1.1, bias: 0.35);
      _addBox(faces, ux1 + 0.06, uy1 + 0.02, uz1 + 0.10, ux1 + uLen * 0.36, uy1 + uHei * 0.56, uz2 - 0.10, color: compCol, stroke: const Color(0xFF38BDF8), sw: 1.3, bias: 0.25);
      _addBox(faces, ux1 + 0.11, uy1 + uHei * 0.56, uz1 + 0.16, ux1 + uLen * 0.31, uy1 + uHei * 0.67, uz2 - 0.16, color: const Color(0xFF0F172A), stroke: const Color(0xFF38BDF8), bias: 0.3);
      _addBox(faces, ux1 + uLen * 0.37, uy1 + 0.02, uz1 + 0.06, ux1 + uLen * 0.47, uy1 + uHei * 0.78, uz1 + 0.26, color: const Color(0xFF0369A1), stroke: const Color(0xFF7DD3FC), sw: 1.1, bias: 0.2);
      _addBox(faces, ux1 + 0.06, uy1 + uHei * 0.62, uz1 + 0.03, ux1 + uLen * 0.32, uy1 + uHei * 0.92, uz1 + 0.18, color: const Color(0xFF94A3B8), stroke: const Color(0xFF0F172A), bias: 0.25);
    }

    final sorted = faces.map((f) {
      final rPts = f.pts.map(_rotate).toList();
      final avgZ = rPts.fold<double>(0, (s, p) => s + p.z) / rPts.length;
      return _RenderFace(f, rPts, avgZ + f.depthBias * 0.08);
    }).toList()
      ..sort((a, b) => a.sortZ.compareTo(b.sortZ));

    for (final rf in sorted) {
      final path = Path();
      final p0 = _project(rf.rotPts[0], center, scale);
      path.moveTo(p0.dx, p0.dy);
      for (int i = 1; i < rf.rotPts.length; i++) {
        final pi = _project(rf.rotPts[i], center, scale);
        path.lineTo(pi.dx, pi.dy);
      }
      path.close();
      final fillColor = rf.face.shaded ? _applyLighting(rf.face.baseColor, rf.face.alpha, rf.rotPts) : rf.face.baseColor.withAlpha(rf.face.alpha);
      canvas.drawPath(path, Paint()..color = fillColor..style = PaintingStyle.fill);
      canvas.drawPath(path, Paint()..color = rf.face.strokeColor..style = PaintingStyle.stroke..strokeWidth = rf.face.strokeWidth);
    }

    final seamPaint = Paint()..color = const Color(0xFF94A3B8).withAlpha(110)..strokeWidth = 0.9;
    final nSeam = result.wallPanels.clamp(3, 9);
    for (int i = 1; i < nSeam; i++) {
      final px = -hx + (lx * i) / nSeam;
      canvas.drawLine(_project(_rotate(_V3(px, 0, -hz)), center, scale), _project(_rotate(_V3(px, hy, -hz)), center, scale), seamPaint);
    }

    for (int f = 0; f < result.evapFans; f++) {
      final fz = evZ1 + ((evZ2 - evZ1) * (f + 0.5)) / result.evapFans;
      final fc = _project(_rotate(_V3(evX2 + 0.02, (evY1 + evY2) / 2, fz)), center, scale);
      final fanR = scale * 0.085;
      canvas.drawCircle(fc, fanR, Paint()..color = const Color(0xFF082F49));
      canvas.drawCircle(fc, fanR, Paint()..color = const Color(0xFF38BDF8)..style = PaintingStyle.stroke..strokeWidth = 1.4);
      final airEnd = _project(_rotate(_V3(hx * 0.72, (evY1 + evY2) / 2 - 0.16, fz)), center, scale);
      canvas.drawLine(fc, airEnd, Paint()..color = const Color(0xFF38BDF8).withAlpha(190)..strokeWidth = 1.8);
    }

    final fanCenter = _project(_rotate(_V3(ux1 + uLen * 0.74, (uy1 + uy2) / 2, uz2 + 0.03)), center, scale);
    final cFanR = scale * 0.25;
    canvas.drawCircle(fanCenter, cFanR, Paint()..color = const Color(0xFF070D19));
    canvas.drawCircle(fanCenter, cFanR, Paint()..color = const Color(0xFFFB923C)..style = PaintingStyle.stroke..strokeWidth = 2.0);
    canvas.drawCircle(fanCenter, cFanR * 0.58, Paint()..color = const Color(0xFF64748B)..style = PaintingStyle.stroke..strokeWidth = 1.0);
    for (int b = 0; b < 5; b++) {
      final a = b * (math.pi * 2 / 5);
      canvas.drawLine(fanCenter, Offset(fanCenter.dx + math.cos(a) * cFanR * 0.85, fanCenter.dy + math.sin(a) * cFanR * 0.85), Paint()..color = const Color(0xFFCBD5E1)..strokeWidth = 2.2..strokeCap = StrokeCap.round);
    }
    canvas.drawCircle(fanCenter, cFanR * 0.16, Paint()..color = const Color(0xFFFB923C));

    if (input.arch != 'monobloc') {
      final pEvap = _project(_rotate(_V3(hx, hy * 0.78, -0.05)), center, scale);
      final pDrop = _project(_rotate(_V3(ux1 + 0.20, hy * 0.78, -0.05)), center, scale);
      final pComp = _project(_rotate(_V3(ux1 + 0.20, uy1 + uHei * 0.65, -0.05)), center, scale);

      final sucPath = Path()..moveTo(pEvap.dx, pEvap.dy)..lineTo(pDrop.dx, pDrop.dy)..lineTo(pComp.dx, pComp.dy);
      canvas.drawPath(sucPath, Paint()..color = const Color(0xFF0F172A)..strokeWidth = 6.2..style = PaintingStyle.stroke..strokeJoin = StrokeJoin.round);
      canvas.drawPath(sucPath, Paint()..color = const Color(0xFF38BDF8)..strokeWidth = 2.6..style = PaintingStyle.stroke..strokeJoin = StrokeJoin.round);

      final liqPath = Path()..moveTo(pEvap.dx, pEvap.dy + 9)..lineTo(pDrop.dx - 7, pDrop.dy + 9)..lineTo(pComp.dx - 7, pComp.dy + 12);
      canvas.drawPath(liqPath, Paint()..color = const Color(0xFFEA580C)..strokeWidth = 2.6..style = PaintingStyle.stroke..strokeJoin = StrokeJoin.round);

      final mid = Offset((pEvap.dx + pDrop.dx) / 2, pEvap.dy + 9);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: mid, width: 18, height: 8), const Radius.circular(3)), Paint()..color = const Color(0xFF22C55E));
    }

    _tag(canvas, _project(_rotate(_V3(0, -0.28, hz + 0.34)), center, scale), 'L = ${input.length.toStringAsFixed(1)} m', const Color(0xFF38BDF8));
    _tag(canvas, _project(_rotate(_V3(-hx - 0.44, hy * 0.52, hz)), center, scale), 'H = ${input.height.toStringAsFixed(1)} m', const Color(0xFF38BDF8));
    _tag(canvas, _project(_rotate(_V3(hx + 0.30, -0.28, 0)), center, scale), 'W = ${input.width.toStringAsFixed(1)} m', const Color(0xFF38BDF8));
    _tag(canvas, _project(_rotate(_V3((ux1 + ux2) / 2, uy2 + 0.32, 0)), center, scale), '${result.q0Kw} kW • ${input.refrigerant}', const Color(0xFF22C55E));
    _tag(canvas, _project(_rotate(_V3(0, hy + 0.22, 0)), center, scale), 'PU ${input.insMm.toInt()} mm • ${input.tInside}°C', const Color(0xFFFBBF24));
  }

  void _paint2DPlan(Canvas canvas, Size size) {
    const padL = 55.0, padT = 46.0;
    final maxW = size.width * 0.48;
    final maxH = size.height - 96.0;
    final sc = math.min(maxW / input.length, maxH / input.width);
    final rw = input.length * sc;
    final rh = input.width * sc;

    final roomRect = Rect.fromLTWH(padL, padT, rw, rh);
    final wallThick = (input.insMm / 20.0).clamp(5.0, 12.0);
    canvas.drawRect(roomRect.inflate(wallThick), Paint()..color = const Color(0xFF0284C7).withAlpha(65));
    canvas.drawRect(roomRect.inflate(wallThick), Paint()..color = const Color(0xFF38BDF8)..style = PaintingStyle.stroke..strokeWidth = 2.0);
    canvas.drawRect(roomRect, Paint()..color = const Color(0xFF0B192E));

    final evRect = Rect.fromLTWH(padL + 10, padT + rh * 0.2, 24, rh * 0.6);
    canvas.drawRect(evRect, Paint()..color = const Color(0xFF164E63));
    canvas.drawRect(evRect, Paint()..color = const Color(0xFF38BDF8)..style = PaintingStyle.stroke..strokeWidth = 1.6);

    final doorPx = (result.doorWidth / input.length) * rw;
    final doorX = padL + (rw - doorPx) / 2;
    canvas.drawLine(Offset(doorX, padT + rh + wallThick / 2), Offset(doorX + doorPx, padT + rh + wallThick / 2), Paint()..color = const Color(0xFFF59E0B)..strokeWidth = 5);

    final unitRect = Rect.fromLTWH(padL + rw + 62, padT + rh * 0.22, 118, 82);
    canvas.drawRRect(RRect.fromRectAndRadius(unitRect, const Radius.circular(8)), Paint()..color = const Color(0xFF132542));
    canvas.drawRRect(RRect.fromRectAndRadius(unitRect, const Radius.circular(8)), Paint()..color = const Color(0xFFF59E0B)..style = PaintingStyle.stroke..strokeWidth = 2.0);

    canvas.drawLine(Offset(evRect.right, evRect.center.dy - 6), Offset(unitRect.left, unitRect.center.dy - 6), Paint()..color = const Color(0xFF38BDF8)..strokeWidth = 3.0);
    canvas.drawLine(Offset(evRect.right, evRect.center.dy + 6), Offset(unitRect.left, unitRect.center.dy + 6), Paint()..color = const Color(0xFFFB923C)..strokeWidth = 2.2);

    _tag(canvas, Offset(padL + rw / 2, padT - 18), 'L = ${input.length} m (${result.wallPanels} ${tr("pcs")})', const Color(0xFF38BDF8));
    _tag(canvas, Offset(padL - 26, padT + rh / 2), 'W = ${input.width} m', const Color(0xFF38BDF8));
    _tag(canvas, Offset(unitRect.center.dx, unitRect.top - 15), '${result.condDimMm[0]}×${result.condDimMm[1]}mm', const Color(0xFFFBBF24));
    _tag(canvas, Offset(unitRect.center.dx, unitRect.bottom + 18), 'Ø ${result.sucInch} / ${result.liqInch}', const Color(0xFF22C55E));
  }

  void _paintCircuitSchematic(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final box = Rect.fromLTWH(38, 42, w - 76, h - 84);
    final hpPaint = Paint()..color = const Color(0xFFFB923C)..strokeWidth = 3.0..style = PaintingStyle.stroke;
    final lpPaint = Paint()..color = const Color(0xFF38BDF8)..strokeWidth = 3.2..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(box.left + 45, box.top), Offset(box.right, box.top), hpPaint);
    canvas.drawLine(Offset(box.right, box.top), Offset(box.right, box.bottom), hpPaint);
    canvas.drawLine(Offset(box.right, box.bottom), Offset(box.left, box.bottom), lpPaint);
    canvas.drawLine(Offset(box.left, box.bottom), Offset(box.left, box.top + 35), lpPaint);

    void node(Offset c, String title, String sub, Color col) {
      final r = RRect.fromRectAndRadius(Rect.fromCenter(center: c, width: 118, height: 48), const Radius.circular(9));
      canvas.drawRRect(r, Paint()..color = const Color(0xFF0E1B33));
      canvas.drawRRect(r, Paint()..color = col..style = PaintingStyle.stroke..strokeWidth = 1.8);
      _rawText(canvas, Offset(c.dx, c.dy - 9), title, col, 10.2);
      _rawText(canvas, Offset(c.dx, c.dy + 8), sub, Colors.white, 9.0);
    }

    node(Offset(box.left + 28, box.top + 22), tr('n_comp'), result.selectedUnit.item.model, const Color(0xFF22C55E));
    node(Offset(box.center.dx, box.top), tr('n_cond'), 'Tk = ${result.tk.toStringAsFixed(0)}°C', const Color(0xFFFB923C));
    node(Offset(box.right, box.top + 56), tr('n_rec'), '${result.circuit.receiverLiters} L', const Color(0xFFFB923C));
    node(Offset(box.right, box.bottom - 56), tr('n_fd'), 'FD + SG • ${result.liqInch}', const Color(0xFFFBBF24));
    node(Offset(box.center.dx + 42, box.bottom), tr('n_txv'), 'TXV (${input.refrigerant})', const Color(0xFF38BDF8));
    node(Offset(box.left + 44, box.bottom), tr('n_evap'), 'T₀ ${result.t0.toStringAsFixed(0)}°C • ${result.sucInch}', const Color(0xFF38BDF8));
  }

  void _tag(Canvas canvas, Offset pos, String text, Color color) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900)),
      textDirection: TextDirection.ltr,
    )..layout();
    final rect = Rect.fromCenter(center: pos, width: tp.width + 10, height: tp.height + 5);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), Paint()..color = const Color(0xFF060C18).withAlpha(230));
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  void _rawText(Canvas canvas, Offset pos, String text, Color color, double sz) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: sz, fontWeight: FontWeight.w800)),
      textDirection: lang == AppLang.ar ? TextDirection.rtl : TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _ShadedReal3DPainter old) => true;
}

class _RenderFace {
  final _Poly3D face;
  final List<_V3> rotPts;
  final double sortZ;
  const _RenderFace(this.face, this.rotPts, this.sortZ);
}
