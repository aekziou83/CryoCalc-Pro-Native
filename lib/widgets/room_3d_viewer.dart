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
  double _rotY = -0.56;
  double _rotX = 0.36;
  double _zoom = 1.0;
  int _viewMode = 0; // 0: 3D Cutaway | 1: 3D Exterior | 2: 2D Plan | 3: 9-Comp Circuit

  String tr(String key) => AppStrings.t(widget.lang, key);

  String _l(String ar, String fr, String en) {
    if (widget.lang == AppLang.fr) return fr;
    if (widget.lang == AppLang.en) return en;
    return ar;
  }

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
          // Header & Mode Selector
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
                      _miniIconBtn(Icons.add_rounded, () => setState(() => _zoom = (_zoom + 0.14).clamp(0.75, 1.55))),
                      const SizedBox(width: 4),
                      _miniIconBtn(Icons.remove_rounded, () => setState(() => _zoom = (_zoom - 0.14).clamp(0.75, 1.55))),
                      const SizedBox(width: 4),
                      _miniIconBtn(Icons.refresh_rounded, () => setState(() {
                            _rotY = -0.56;
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
                        _modeChip(_l('مخطط الدائرة (9 قطع)', 'Schéma Circuit (9)', '9-Part Circuit'), 3),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Viewport Canvas (Strictly Clipped & Responsive)
          ClipRect(
            child: SizedBox(
              height: _viewMode == 3 && !isAudit ? 390 : 350,
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

          // Cycle Sequence Legend Strip (1 -> 9 -> 1)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            color: const Color(0xFF091224),
            child: Text(
              _l(
                'المسار: 1 ضاغط ← 2 فاصل زيت ← 3 مكثف ← 4 خزان سائل ← 5 فلتر ← 6 مؤشر سائل ← 7 منظم ← 8 مبخر ← 9 أكيومليتور ← 1',
                'Cycle : 1 Comp → 2 Sép. huile → 3 Cond → 4 Réservoir → 5 Déshy → 6 Voyant → 7 TXV → 8 Évap → 9 ACL → 1',
                'Cycle: 1 Comp → 2 Oil Sep → 3 Cond → 4 Receiver → 5 Drier → 6 Sight Glass → 7 TXV → 8 Evap → 9 ACL → 1',
              ),
              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF93C5FD), height: 1.45),
            ),
          ),

          // Exact Measurements Strip
          Container(
            width: double.infinity,
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
                _specChip(tr('v3d_pipes'), '${r.sucInch} / ${r.liqInch} (${inp.pipeLen.toInt()} m)', Colors.white),
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

  String _l(String ar, String fr, String en) {
    if (lang == AppLang.fr) return fr;
    if (lang == AppLang.en) return en;
    return ar;
  }

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
    const camDist = 11.2;
    final factor = camDist / (camDist - r.z).clamp(2.5, 22.0);
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

  /* =========================================================================
     1) REALISTIC 3D VIEW — EXACT 9-COMPONENT REFRIGERATION ORDER
        1:Comp -> 2:Oil Sep -> 3:Cond -> 4:Receiver -> 5:Filter Drier ->
        6:Sight Glass -> 7:TXV -> 8:Evaporator -> 9:Accumulator (ACL) -> 1
     ========================================================================= */
  void _paintRealistic3D(Canvas canvas, Size size, {required bool cutaway}) {
    final maxD = math.max(input.length, math.max(input.width, input.height));
    final lx = (input.length / maxD) * 2.15;
    final wz = (input.width / maxD) * 2.15;
    final hy = (input.height / maxD) * 1.80;
    final hx = lx / 2, hz = wz / 2;

    // Fit cleanly on both narrow phones & tablets
    final scale = math.min(size.width * 0.195, size.height * 0.255) * zoom;
    final center = Offset(size.width * 0.40, size.height * 0.58);
    final faces = <_Poly3D>[];

    // Condensing skid coordinates on the right of the cold room
    final ux1 = hx + (input.arch == 'monobloc' ? 0.08 : 0.70);
    final uLen = input.arch == 'rack' ? 1.48 : (input.arch == 'monobloc' ? 0.68 : 1.24);
    final ux2 = ux1 + uLen;
    const uz1 = -0.50, uz2 = 0.50;
    final uy1 = input.arch == 'monobloc' ? hy * 0.36 : 0.0;
    final uHei = input.arch == 'rack' ? 1.08 : 0.88;
    final uy2 = uy1 + uHei;

    // Ground shadow plane
    const pad = 0.22;
    faces.add(_Poly3D(
      pts: [
        _V3(-hx - pad, -0.16, -hz - pad),
        _V3(ux2 + pad, -0.16, -hz - pad),
        _V3(ux2 + pad, -0.16, hz + pad),
        _V3(-hx - pad, -0.16, hz + pad),
      ],
      baseColor: const Color(0xFF02060F),
      alpha: 155,
      strokeColor: const Color(0xFF1E293B),
      strokeWidth: 0.8,
      depthBias: -8.0,
      shaded: false,
    ));

    // Insulated Floor Slab
    final flH = result.floorInsIncluded ? 0.13 : 0.06;
    _addBox(faces, -hx, -flH, -hz, hx, 0.0, hz,
        color: result.floorInsIncluded ? const Color(0xFF64748B) : const Color(0xFF475569),
        stroke: const Color(0xFF94A3B8),
        bias: -2.0);

    // Cold Room Sandwich Panels
    const wallColor = Color(0xFFDCE6F2);
    const wallStroke = Color(0xFF64748B);
    const tWall = 0.065;
    _addBox(faces, -hx, 0, -hz - tWall, hx, hy, -hz, color: wallColor, stroke: wallStroke, sw: 0.9);
    _addBox(faces, -hx - tWall, 0, -hz, -hx, hy, hz, color: wallColor, stroke: wallStroke, sw: 0.9);

    if (cutaway) {
      faces.add(_Poly3D(pts: [_V3(-hx, 0, hz), _V3(hx, 0, hz), _V3(hx, hy, hz), _V3(-hx, hy, hz)], baseColor: const Color(0xFF7DD3FC), alpha: 30, strokeColor: const Color(0xFF38BDF8), strokeWidth: 1.1, depthBias: 3.0, shaded: false));
      faces.add(_Poly3D(pts: [_V3(hx, 0, -hz), _V3(hx, 0, hz), _V3(hx, hy, hz), _V3(hx, hy, -hz)], baseColor: const Color(0xFF38BDF8), alpha: 24, strokeColor: const Color(0xFF38BDF8), strokeWidth: 1.1, depthBias: 3.0, shaded: false));
      faces.add(_Poly3D(pts: [_V3(-hx, hy, -hz), _V3(hx, hy, -hz), _V3(hx, hy, hz), _V3(-hx, hy, hz)], baseColor: const Color(0xFFBAE6FD), alpha: 22, strokeColor: const Color(0xFF38BDF8), strokeWidth: 1.1, depthBias: 3.2, shaded: false));
    } else {
      _addBox(faces, -hx, 0, hz, hx, hy, hz + tWall, color: wallColor, stroke: wallStroke, sw: 0.9);
      _addBox(faces, hx, 0, -hz, hx + tWall, hy, hz, color: wallColor, stroke: wallStroke, sw: 0.9);
      _addBox(faces, -hx - tWall, hy, -hz - tWall, hx + tWall, hy + tWall, hz + tWall, color: const Color(0xFFE2E8F0), stroke: wallStroke, sw: 0.9);
    }

    // Cold Room Door + Gasket + Handle + Pressure Relief Valve
    final dW = (result.doorWidth / input.length).clamp(0.24, 0.45) * lx;
    final dH = (result.doorHeight / input.height).clamp(0.55, 0.82) * hy;
    final doorCol = _auditCol(audit?.doorStatus, const Color(0xFFF1F5F9));
    final gasketCol = input.tInside < 0 ? const Color(0xFFF59E0B) : const Color(0xFF1E293B);
    _addBox(faces, -dW / 2 - 0.04, 0, hz + 0.01, dW / 2 + 0.04, dH + 0.04, hz + 0.05, color: gasketCol, stroke: const Color(0xFF0F172A), bias: 3.5);
    _addBox(faces, -dW / 2, 0.02, hz + 0.05, dW / 2, dH, hz + 0.12, color: doorCol, stroke: const Color(0xFF475569), sw: 1.1, bias: 3.7);
    _addBox(faces, -dW * 0.36, dH * 0.42, hz + 0.12, -dW * 0.28, dH * 0.56, hz + 0.17, color: const Color(0xFF0284C7), stroke: Colors.white, sw: 0.9, bias: 3.9);
    if (input.tInside <= 0) {
      _addBox(faces, dW / 2 + 0.12, hy * 0.72, hz + 0.02, dW / 2 + 0.25, hy * 0.84, hz + 0.09, color: const Color(0xFFF59E0B), stroke: const Color(0xFF0F172A), bias: 3.6);
    }

    // [8] Evaporator inside Cold Room + Drain Pan
    final evCol = _auditCol(audit?.evapStatus, const Color(0xFFE2E8F0));
    final evX1 = -hx + 0.10, evX2 = -hx + 0.46;
    final evZ1 = -hz * 0.64, evZ2 = hz * 0.64;
    final evY1 = hy * 0.70, evY2 = hy * 0.92;
    _addBox(faces, evX1, evY1, evZ1, evX2, evY2, evZ2, color: evCol, stroke: const Color(0xFF0284C7), sw: 1.3, bias: 0.4);
    _addBox(faces, evX1, evY1 - 0.05, evZ1, evX2, evY1, evZ2, color: const Color(0xFF0284C7), stroke: const Color(0xFF075985), bias: 0.45);

    // [7] Expansion Valve (TXV) at Evaporator Liquid Inlet
    final txvCol = _auditCol(audit?.txvStatus, const Color(0xFFF59E0B));
    final txvX = evX2 + 0.04, txvY = evY1 + 0.04, txvZ = evZ2 - 0.08;
    _addBox(faces, txvX, txvY, txvZ - 0.06, txvX + 0.11, txvY + 0.13, txvZ + 0.06, color: txvCol, stroke: Colors.white, sw: 1.0, bias: 0.55);

    // Outdoor Condensing Skid Base Chassis
    final compCol = _auditCol(audit?.compStatus, const Color(0xFF1D4ED8)); // [1] Compressor Blue
    final condCol = _auditCol(audit?.condStatus, const Color(0xFFCBD5E1)); // [3] Condenser Steel
    _addBox(faces, ux1 - 0.04, uy1 - 0.07, uz1 - 0.03, ux2 + 0.04, uy1, uz2 + 0.03, color: const Color(0xFF334155), stroke: const Color(0xFF0F172A));

    // Exact component anchor points for piping & numbered badges
    final p1Comp = _V3(ux1 + uLen * 0.18, uy1 + uHei * 0.52, 0.24);
    final p2OilSep = _V3(ux1 + uLen * 0.45, uy1 + uHei * 0.68, 0.22);
    final p3Cond = _V3(ux1 + uLen * 0.78, uy1 + uHei * 0.52, 0.0);
    final p4Rec = _V3(ux1 + uLen * 0.46, uy1 + uHei * 0.36, -0.26);
    final p9Acl = _V3(ux1 + uLen * 0.16, uy1 + uHei * 0.62, -0.26);

    if (input.arch == 'carrosse' || input.arch == 'monobloc') {
      _addBox(faces, ux1, uy1, uz1, ux2, uy2, uz2, color: const Color(0xFFCBD5E1), stroke: const Color(0xFF475569), sw: 1.3, bias: 0.2);
      _addBox(faces, ux1 + uLen * 0.35, uy1 + 0.10, uz2, ux2 - 0.08, uy2 - 0.10, uz2 + 0.03, color: const Color(0xFF0F172A), stroke: const Color(0xFF38BDF8), bias: 0.4);
    } else {
      // [1] Compressor — Front-Left
      _addBox(faces, ux1 + 0.05, uy1 + 0.02, 0.06, ux1 + uLen * 0.31, uy1 + uHei * 0.50, 0.42,
          color: compCol, stroke: const Color(0xFF60A5FA), sw: 1.3, bias: 0.35);
      _addBox(faces, ux1 + 0.09, uy1 + uHei * 0.50, 0.11, ux1 + uLen * 0.27, uy1 + uHei * 0.62, 0.37,
          color: const Color(0xFF0F172A), stroke: const Color(0xFF60A5FA), sw: 1.0, bias: 0.38);

      // [2] Oil Separator — Vertical Cylinder immediately after Compressor (Front-Center)
      _addBox(faces, ux1 + uLen * 0.37, uy1 + 0.02, 0.10, ux1 + uLen * 0.53, uy1 + uHei * 0.82, 0.34,
          color: const Color(0xFFEA580C), stroke: const Color(0xFFFDBA74), sw: 1.2, bias: 0.32);

      // [3] Condenser Finned Block — Right Side
      _addBox(faces, ux1 + uLen * 0.58, uy1 + 0.02, uz1 + 0.02, ux2 - 0.02, uy2, uz2 - 0.02,
          color: condCol, stroke: const Color(0xFF475569), sw: 1.2, bias: 0.20);
      _addBox(faces, ux1 + uLen * 0.61, uy1 + 0.08, uz2 - 0.01, ux2 - 0.06, uy2 - 0.06, uz2 + 0.02,
          color: const Color(0xFF1E293B), stroke: const Color(0xFFFB923C), sw: 1.1, bias: 0.38);

      // [4] Liquid Receiver — Back-Center directly from Condenser Outlet
      _addBox(faces, ux1 + uLen * 0.34, uy1 + 0.02, -0.40, ux1 + uLen * 0.56, uy1 + uHei * 0.58, -0.12,
          color: const Color(0xFF0369A1), stroke: const Color(0xFF7DD3FC), sw: 1.2, bias: 0.18);

      // [9] Suction Accumulator (ACL) — Back-Left directly before Compressor Suction
      _addBox(faces, ux1 + 0.05, uy1 + 0.02, -0.40, ux1 + uLen * 0.26, uy1 + uHei * 0.78, -0.14,
          color: const Color(0xFF0E7490), stroke: const Color(0xFF67E8F9), sw: 1.2, bias: 0.22);
    }

    // Z-Sort Painter's Algorithm
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

    // Sandwich Panel Vertical Seams
    final seamPaint = Paint()..color = const Color(0xFF94A3B8).withAlpha(105)..strokeWidth = 0.85;
    final nSeam = result.wallPanels.clamp(3, 8);
    for (int i = 1; i < nSeam; i++) {
      final px = -hx + (lx * i) / nSeam;
      canvas.drawLine(_project(_rotate(_V3(px, 0, -hz)), center, scale), _project(_rotate(_V3(px, hy, -hz)), center, scale), seamPaint);
    }

    // [8] Evaporator Fan Grilles & Cold Air Arrows
    for (int f = 0; f < result.evapFans; f++) {
      final fz = evZ1 + ((evZ2 - evZ1) * (f + 0.5)) / result.evapFans;
      final fc = _project(_rotate(_V3(evX2 + 0.02, (evY1 + evY2) / 2, fz)), center, scale);
      final fanR = scale * 0.082;
      canvas.drawCircle(fc, fanR, Paint()..color = const Color(0xFF082F49));
      canvas.drawCircle(fc, fanR, Paint()..color = const Color(0xFF38BDF8)..style = PaintingStyle.stroke..strokeWidth = 1.3);
      final airEnd = _project(_rotate(_V3(hx * 0.72, (evY1 + evY2) / 2 - 0.14, fz)), center, scale);
      canvas.drawLine(fc, airEnd, Paint()..color = const Color(0xFF38BDF8).withAlpha(185)..strokeWidth = 1.6);
    }

    // [3] Condenser Fan Blades on Front Face
    final fanCenter = _project(_rotate(_V3(ux1 + uLen * 0.78, (uy1 + uy2) / 2, uz2 + 0.03)), center, scale);
    final cFanR = scale * 0.22;
    canvas.drawCircle(fanCenter, cFanR, Paint()..color = const Color(0xFF070D19));
    canvas.drawCircle(fanCenter, cFanR, Paint()..color = const Color(0xFFFB923C)..style = PaintingStyle.stroke..strokeWidth = 1.9);
    for (int b = 0; b < 5; b++) {
      final a = b * (math.pi * 2 / 5);
      canvas.drawLine(
        fanCenter,
        Offset(fanCenter.dx + math.cos(a) * cFanR * 0.84, fanCenter.dy + math.sin(a) * cFanR * 0.84),
        Paint()..color = const Color(0xFFCBD5E1)..strokeWidth = 2.0..strokeCap = StrokeCap.round,
      );
    }
    canvas.drawCircle(fanCenter, cFanR * 0.16, Paint()..color = const Color(0xFFFB923C));

    // Exact Piping Path in True Cycle Sequence (1->2->3->4->5->6->7->8->9->1)
    if (input.arch != 'monobloc') {
      final hpGas = Paint()..color = const Color(0xFFEF4444)..strokeWidth = 2.6..style = PaintingStyle.stroke..strokeJoin = StrokeJoin.round;
      final hpLiq = Paint()..color = const Color(0xFFF59E0B)..strokeWidth = 2.5..style = PaintingStyle.stroke..strokeJoin = StrokeJoin.round;
      final lpIns = Paint()..color = const Color(0xFF0F172A)..strokeWidth = 5.4..style = PaintingStyle.stroke..strokeJoin = StrokeJoin.round;
      final lpSuc = Paint()..color = const Color(0xFF38BDF8)..strokeWidth = 2.4..style = PaintingStyle.stroke..strokeJoin = StrokeJoin.round;

      if (input.arch != 'carrosse') {
        // 1 -> 2 -> 3 (Hot Discharge Gas)
        final o1 = _project(_rotate(_V3(p1Comp.x, uy1 + uHei * 0.64, p1Comp.z)), center, scale);
        final o2 = _project(_rotate(_V3(p2OilSep.x, uy1 + uHei * 0.84, p2OilSep.z)), center, scale);
        final o3 = _project(_rotate(_V3(ux1 + uLen * 0.62, uy1 + uHei * 0.82, 0.12)), center, scale);
        canvas.drawPath(Path()..moveTo(o1.dx, o1.dy)..lineTo(o2.dx, o2.dy)..lineTo(o3.dx, o3.dy), hpGas);

        // 3 -> 4 (Condenser Outlet -> Liquid Receiver)
        final o3Out = _project(_rotate(_V3(ux1 + uLen * 0.60, uy1 + uHei * 0.25, -0.22)), center, scale);
        final o4In = _project(_rotate(_V3(p4Rec.x, uy1 + uHei * 0.56, p4Rec.z)), center, scale);
        canvas.drawLine(o3Out, o4In, hpLiq);
      }

      // 4 -> 5 (Filter Drier) -> 6 (Sight Glass) -> 7 (TXV at Evaporator)
      final liqStart = _project(_rotate(_V3(p4Rec.x, uy1 + uHei * 0.58, p4Rec.z)), center, scale);
      final liqUp = _project(_rotate(_V3(ux1 + 0.12, hy * 0.72, -0.18)), center, scale);
      final liqWall = _project(_rotate(_V3(hx, hy * 0.72, -0.18)), center, scale);
      final liqTxv = _project(_rotate(_V3(txvX + 0.05, txvY + 0.06, txvZ)), center, scale);
      canvas.drawPath(
        Path()..moveTo(liqStart.dx, liqStart.dy)..lineTo(liqUp.dx, liqUp.dy)..lineTo(liqWall.dx, liqWall.dy)..lineTo(liqTxv.dx, liqTxv.dy),
        hpLiq,
      );

      // [5] Filter Drier (Green cylinder) & [6] Sight Glass (Yellow circle) inline between Receiver and Wall
      final p5 = Offset.lerp(liqUp, liqWall, 0.32)!;
      final p6 = Offset.lerp(liqUp, liqWall, 0.68)!;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: p5, width: 16, height: 8), const Radius.circular(3)), Paint()..color = const Color(0xFF16A34A));
      canvas.drawCircle(p6, 5.2, Paint()..color = const Color(0xFFFACC15));
      canvas.drawCircle(p6, 2.4, Paint()..color = const Color(0xFF0EA5E9));

      // 8 (Evaporator Outlet) -> 9 (Accumulator ACL) -> 1 (Compressor Suction)
      final sucEvap = _project(_rotate(_V3(evX2, evY2 - 0.04, -0.10)), center, scale);
      final sucWall = _project(_rotate(_V3(hx, hy * 0.86, -0.10)), center, scale);
      final sucDrop = _project(_rotate(_V3(p9Acl.x, hy * 0.86, p9Acl.z)), center, scale);
      final sucAcl = _project(_rotate(_V3(p9Acl.x, uy1 + uHei * 0.78, p9Acl.z)), center, scale);
      final sucComp = _project(_rotate(_V3(p1Comp.x, uy1 + uHei * 0.56, p1Comp.z)), center, scale);
      final sucPath = Path()
        ..moveTo(sucEvap.dx, sucEvap.dy)
        ..lineTo(sucWall.dx, sucWall.dy)
        ..lineTo(sucDrop.dx, sucDrop.dy)
        ..lineTo(sucAcl.dx, sucAcl.dy)
        ..lineTo(sucComp.dx, sucComp.dy);
      canvas.drawPath(sucPath, lpIns);
      canvas.drawPath(sucPath, lpSuc);

      // Small Numbered Pins on 3D Components (1..9)
      if (input.arch != 'carrosse') {
        _numPin(canvas, _project(_rotate(p1Comp), center, scale), '1', const Color(0xFF22C55E));
        _numPin(canvas, _project(_rotate(p2OilSep), center, scale), '2', const Color(0xFFEA580C));
        _numPin(canvas, _project(_rotate(p3Cond), center, scale), '3', const Color(0xFFFB923C));
        _numPin(canvas, _project(_rotate(p4Rec), center, scale), '4', const Color(0xFF0284C7));
        _numPin(canvas, Offset(p5.dx, p5.dy - 11), '5', const Color(0xFF16A34A));
        _numPin(canvas, Offset(p6.dx, p6.dy - 11), '6', const Color(0xFFEAB308));
        _numPin(canvas, _project(_rotate(_V3(txvX + 0.05, txvY + 0.22, txvZ)), center, scale), '7', const Color(0xFFF59E0B));
        _numPin(canvas, _project(_rotate(_V3((evX1 + evX2) / 2, evY2 + 0.12, 0)), center, scale), '8', const Color(0xFF38BDF8));
        _numPin(canvas, _project(_rotate(p9Acl), center, scale), '9', const Color(0xFF06B6D4));
      }
    }

    // Strictly Clamped Dimension Tags (Never Clip Outside Screen!)
    _tag(canvas, _project(_rotate(_V3(0, -0.26, hz + 0.30)), center, scale), 'L = ${input.length.toStringAsFixed(1)} m', const Color(0xFF38BDF8), size);
    _tag(canvas, _project(_rotate(_V3(-hx - 0.36, hy * 0.50, hz)), center, scale), 'H = ${input.height.toStringAsFixed(1)} m', const Color(0xFF38BDF8), size);
    _tag(canvas, _project(_rotate(_V3(hx + 0.22, -0.26, 0)), center, scale), 'W = ${input.width.toStringAsFixed(1)} m', const Color(0xFF38BDF8), size);
    _tag(canvas, _project(_rotate(_V3((ux1 + ux2) / 2, uy2 + 0.30, 0)), center, scale), '${result.q0Kw} kW • ${input.refrigerant}', const Color(0xFF22C55E), size);
    _tag(canvas, _project(_rotate(_V3(0, hy + 0.20, 0)), center, scale), 'PU ${input.insMm.toInt()} mm • ${input.tInside}°C', const Color(0xFFFBBF24), size);
  }

  /* =========================================================================
     2) RESPONSIVE 2D PLAN VIEW — ZERO CLIPPING + ALL 9 NUMBERED PARTS
     ========================================================================= */
  void _paint2DPlan(Canvas canvas, Size size) {
    const padX = 12.0;
    const padTop = 36.0;
    const padBot = 36.0;
    final usableW = size.width - padX * 2;
    final usableH = size.height - padTop - padBot;

    // Split horizontal space proportionally: Room (47%) | Piping (17%) | Skid (36%)
    final roomZoneW = usableW * 0.46;
    final skidW = (usableW * 0.35).clamp(102.0, 160.0);
    final gap = usableW - roomZoneW - skidW;

    final sc = math.min((roomZoneW - 14) / input.length, (usableH - 14) / input.width);
    final rw = input.length * sc;
    final rh = input.width * sc;

    final roomX = padX + (roomZoneW - rw) / 2 + 4;
    final roomY = padTop + (usableH - rh) / 2;
    final roomRect = Rect.fromLTWH(roomX, roomY, rw, rh);
    final wallThick = (input.insMm / 24.0).clamp(4.0, 9.0);

    // Insulated Room Walls
    canvas.drawRect(roomRect.inflate(wallThick), Paint()..color = const Color(0xFF0284C7).withAlpha(65));
    canvas.drawRect(roomRect.inflate(wallThick), Paint()..color = const Color(0xFF38BDF8)..style = PaintingStyle.stroke..strokeWidth = 2.0);
    canvas.drawRect(roomRect, Paint()..color = const Color(0xFF0B192E));

    // [8] Evaporator inside Left Wall + [7] TXV
    final evRect = Rect.fromLTWH(roomX + 8, roomY + rh * 0.18, math.min(22.0, rw * 0.18), rh * 0.64);
    canvas.drawRect(evRect, Paint()..color = const Color(0xFF164E63));
    canvas.drawRect(evRect, Paint()..color = const Color(0xFF38BDF8)..style = PaintingStyle.stroke..strokeWidth = 1.6);
    _numPin(canvas, evRect.center, '8', const Color(0xFF38BDF8));

    final txvPt = Offset(evRect.right + 10, evRect.center.dy + 12);
    _numPin(canvas, txvPt, '7', const Color(0xFFF59E0B));

    // Door on Bottom Wall
    final doorPx = (result.doorWidth / input.length).clamp(0.18, 0.45) * rw;
    final doorX = roomX + (rw - doorPx) / 2;
    canvas.drawLine(
      Offset(doorX, roomRect.bottom + wallThick / 2),
      Offset(doorX + doorPx, roomRect.bottom + wallThick / 2),
      Paint()..color = const Color(0xFFF59E0B)..strokeWidth = 5,
    );

    // Condensing Skid on the Right (Guaranteed Inside Viewport!)
    final skidH = math.min(usableH * 0.72, 146.0).clamp(112.0, 146.0);
    final skidX = size.width - padX - skidW;
    final skidY = padTop + (usableH - skidH) / 2;
    final unitRect = Rect.fromLTWH(skidX, skidY, skidW, skidH);
    canvas.drawRRect(RRect.fromRectAndRadius(unitRect, const Radius.circular(10)), Paint()..color = const Color(0xFF132542));
    canvas.drawRRect(RRect.fromRectAndRadius(unitRect, const Radius.circular(10)), Paint()..color = const Color(0xFFF59E0B)..style = PaintingStyle.stroke..strokeWidth = 1.8);

    // Internal Skid Layout in Exact Sequence: 1 -> 2 -> 3 -> 4 (and 9 -> 1)
    final p1 = Offset(unitRect.left + skidW * 0.24, unitRect.top + skidH * 0.27);
    final p2 = Offset(unitRect.left + skidW * 0.54, unitRect.top + skidH * 0.27);
    final p3 = Offset(unitRect.right - skidW * 0.16, unitRect.center.dy);
    final p4 = Offset(unitRect.left + skidW * 0.54, unitRect.bottom - skidH * 0.27);
    final p9 = Offset(unitRect.left + skidW * 0.24, unitRect.bottom - skidH * 0.27);

    // Internal Skid Pipes (1->2->3->4 and 9->1)
    canvas.drawLine(p1, p2, Paint()..color = const Color(0xFFEF4444)..strokeWidth = 2.4);
    canvas.drawLine(p2, Offset(p3.dx, p2.dy), Paint()..color = const Color(0xFFFB923C)..strokeWidth = 2.4);
    canvas.drawLine(Offset(p3.dx, p2.dy), Offset(p3.dx, p4.dy), Paint()..color = const Color(0xFFFB923C)..strokeWidth = 2.4);
    canvas.drawLine(Offset(p3.dx, p4.dy), p4, Paint()..color = const Color(0xFFF59E0B)..strokeWidth = 2.4);
    canvas.drawLine(p9, p1, Paint()..color = const Color(0xFF38BDF8)..strokeWidth = 2.6);

    // Connecting Suction (8 -> 9) & Liquid (4 -> 5 -> 6 -> 7) Lines
    final sucY = evRect.center.dy - 12;
    final liqY = evRect.center.dy + 12;
    canvas.drawPath(
      Path()..moveTo(evRect.right, sucY)..lineTo(unitRect.left - 8, sucY)..lineTo(unitRect.left - 8, p9.dy)..lineTo(p9.dx, p9.dy),
      Paint()..color = const Color(0xFF38BDF8)..strokeWidth = 2.6..style = PaintingStyle.stroke,
    );
    canvas.drawPath(
      Path()..moveTo(p4.dx, p4.dy)..lineTo(p4.dx, unitRect.bottom + 8)..lineTo(unitRect.left - 14, unitRect.bottom + 8)..lineTo(unitRect.left - 14, liqY)..lineTo(txvPt.dx, liqY),
      Paint()..color = const Color(0xFFF59E0B)..strokeWidth = 2.2..style = PaintingStyle.stroke,
    );

    // Inline [5] Filter Drier & [6] Sight Glass on Liquid Line in the Gap
    final p5 = Offset(roomRect.right + gap * 0.62, liqY);
    final p6 = Offset(roomRect.right + gap * 0.28, liqY);
    _numPin(canvas, p5, '5', const Color(0xFF16A34A));
    _numPin(canvas, p6, '6', const Color(0xFFEAB308));

    // Skid Component Pins
    _numPin(canvas, p1, '1', const Color(0xFF22C55E));
    _numPin(canvas, p2, '2', const Color(0xFFEA580C));
    _numPin(canvas, p3, '3', const Color(0xFFFB923C));
    _numPin(canvas, p4, '4', const Color(0xFF0284C7));
    _numPin(canvas, p9, '9', const Color(0xFF06B6D4));

    // Clamped Labels (Guaranteed Zero Overflow!)
    _tag(canvas, Offset(roomRect.center.dx, roomRect.top - 18), 'L = ${input.length.toStringAsFixed(1)} m (${result.wallPanels})', const Color(0xFF38BDF8), size);
    _tag(canvas, Offset(roomRect.left + 32, roomRect.bottom - 14), 'W = ${input.width.toStringAsFixed(1)} m', const Color(0xFF38BDF8), size, fontSize: 10);
    _tag(canvas, Offset(unitRect.center.dx, unitRect.top - 16), '${result.condDimMm[0]}×${result.condDimMm[1]} mm', const Color(0xFFFBBF24), size, fontSize: 10);
    _tag(canvas, Offset(unitRect.center.dx, unitRect.bottom + 20), 'Ø ${result.sucInch} / ${result.liqInch}', const Color(0xFF22C55E), size, fontSize: 10);
  }

  /* =========================================================================
     3) COMPLETE 9-COMPONENT CIRCUIT SCHEMATIC — STRICTLY INSIDE BOUNDS
        1 Comp -> 2 Oil Sep -> 3 Cond -> 4 Receiver -> 5 Filter Drier ->
        6 Sight Glass -> 7 TXV -> 8 Evaporator -> 9 Accumulator (ACL) -> 1
     ========================================================================= */
  void _paintCircuitSchematic(Canvas canvas, Size size) {
    const padX = 8.0;
    const padY = 12.0;
    const gapX = 12.0;
    const gapY = 18.0;

    final boxW = (size.width - padX * 2 - gapX * 2) / 3;
    final boxH = ((size.height - padY * 2 - gapY * 3) / 4).clamp(44.0, 62.0);
    final rowStep = (size.height - padY * 2 - boxH) / 3;

    final c0 = padX + boxW / 2;
    final c1 = padX + boxW + gapX + boxW / 2;
    final c2 = padX + (boxW + gapX) * 2 + boxW / 2;

    final r0 = padY + boxH / 2;
    final r1 = r0 + rowStep;
    final r2 = r0 + rowStep * 2;
    final r3 = r0 + rowStep * 3;
    final rMidLeft = (r1 + r2) / 2;

    final p1 = Offset(c0, r0); // 1. Compressor
    final p2 = Offset(c1, r0); // 2. Oil Separator
    final p3 = Offset(c2, r0); // 3. Condenser
    final p4 = Offset(c2, r1); // 4. Liquid Receiver
    final p5 = Offset(c2, r2); // 5. Filter Drier
    final p6 = Offset(c2, r3); // 6. Sight Glass
    final p7 = Offset(c1, r3); // 7. TXV
    final p8 = Offset(c0, r3); // 8. Evaporator
    final p9 = Offset(c0, rMidLeft); // 9. Accumulator (ACL)

    final hw = boxW / 2;
    final hh = boxH / 2;

    // Color-coded Flow Arrows in Exact Refrigeration Order
    _drawArrow(canvas, Offset(p1.dx + hw, p1.dy), Offset(p2.dx - hw, p2.dy), const Color(0xFFEF4444)); // 1->2 HP Gas
    _drawArrow(canvas, Offset(p2.dx + hw, p2.dy), Offset(p3.dx - hw, p3.dy), const Color(0xFFFB923C)); // 2->3 HP Gas
    _drawArrow(canvas, Offset(p3.dx, p3.dy + hh), Offset(p4.dx, p4.dy - hh), const Color(0xFFFB923C)); // 3->4 HP Liq
    _drawArrow(canvas, Offset(p4.dx, p4.dy + hh), Offset(p5.dx, p5.dy - hh), const Color(0xFFF59E0B)); // 4->5 HP Liq
    _drawArrow(canvas, Offset(p5.dx, p5.dy + hh), Offset(p6.dx, p6.dy - hh), const Color(0xFFFBBF24)); // 5->6 HP Liq
    _drawArrow(canvas, Offset(p6.dx - hw, p6.dy), Offset(p7.dx + hw, p7.dy), const Color(0xFFFBBF24)); // 6->7 Subcooled Liq
    _drawArrow(canvas, Offset(p7.dx - hw, p7.dy), Offset(p8.dx + hw, p8.dy), const Color(0xFF38BDF8)); // 7->8 LP Mix
    _drawArrow(canvas, Offset(p8.dx, p8.dy - hh), Offset(p9.dx, p9.dy + hh), const Color(0xFF0EA5E9)); // 8->9 LP Suction
    _drawArrow(canvas, Offset(p9.dx, p9.dy - hh), Offset(p1.dx, p1.dy + hh), const Color(0xFF22C55E)); // 9->1 Dry Suction

    // Oil Return Line from [2] Oil Separator back to [1] Compressor Crankcase
    final oilY = r0 + hh + 12;
    final oilPath = Path()
      ..moveTo(p2.dx, p2.dy + hh)
      ..lineTo(p2.dx, oilY)
      ..lineTo(p1.dx + hw * 0.45, oilY)
      ..lineTo(p1.dx + hw * 0.45, p1.dy + hh);
    canvas.drawPath(oilPath, Paint()..color = const Color(0xFFF59E0B).withAlpha(170)..strokeWidth = 1.5..style = PaintingStyle.stroke);

    // Center Thermodynamic Info Badge
    final centerRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(c1, rMidLeft), width: boxW * 1.04, height: 64),
      const Radius.circular(10),
    );
    canvas.drawRRect(centerRect, Paint()..color = const Color(0xFF0B172B));
    canvas.drawRRect(centerRect, Paint()..color = const Color(0xFF38BDF8).withAlpha(70)..style = PaintingStyle.stroke..strokeWidth = 1.1);
    _drawBoxText(canvas, Offset(c1, rMidLeft - 16), input.refrigerant, const Color(0xFF38BDF8), 11.5, boxW, rtl: false);
    _drawBoxText(canvas, Offset(c1, rMidLeft + 2), 'HP ${result.sizing.pkBarRel} bar', const Color(0xFFFB923C), 9.2, boxW, rtl: false);
    _drawBoxText(canvas, Offset(c1, rMidLeft + 17), 'LP ${result.sizing.p0BarRel} bar', const Color(0xFF22C55E), 9.2, boxW, rtl: false);

    // Draw the 9 Component Boxes
    void drawNode(Offset c, String title, String sub, Color col) {
      final r = RRect.fromRectAndRadius(Rect.fromCenter(center: c, width: boxW, height: boxH), const Radius.circular(9));
      canvas.drawRRect(r, Paint()..color = const Color(0xFF0E1B33));
      canvas.drawRRect(r, Paint()..color = col..style = PaintingStyle.stroke..strokeWidth = 1.7);
      _drawBoxText(canvas, Offset(c.dx, c.dy - 9), title, col, 9.6, boxW - 6, rtl: lang == AppLang.ar);
      _drawBoxText(canvas, Offset(c.dx, c.dy + 9), sub, Colors.white, 8.6, boxW - 6, rtl: false);
    }

    final orificeShort = result.sizing.txvOrificeNumber.split('(').first.trim();

    drawNode(p1, _l('1. الضاغط', '1. Compresseur', '1. Compressor'), result.selectedUnit.item.model, const Color(0xFF22C55E));
    drawNode(p2, _l('2. فاصل الزيت', '2. Sép. huile', '2. Oil Sep.'), 'Ø ${result.sizing.dischargePipeInch}', const Color(0xFFEA580C));
    drawNode(p3, _l('3. المكثف', '3. Condenseur', '3. Condenser'), 'Tk ${result.tk.toStringAsFixed(0)}°C', const Color(0xFFFB923C));
    drawNode(p4, _l('4. خزان السائل', '4. Réservoir', '4. Receiver'), '${result.sizing.receiverStdVolL} L', const Color(0xFFF59E0B));
    drawNode(p5, _l('5. الفلتر المجفف', '5. Déshydrateur', '5. Filter Drier'), 'FD • ${result.liqInch}', const Color(0xFFEAB308));
    drawNode(p6, _l('6. مؤشر السائل', '6. Voyant liq.', '6. Sight Glass'), 'SG • ${result.liqInch}', const Color(0xFFFACC15));
    drawNode(p7, _l('7. المنظم TXV', '7. Détendeur', '7. TXV Valve'), orificeShort, const Color(0xFF38BDF8));
    drawNode(p8, _l('8. المبخر', '8. Évaporateur', '8. Evaporator'), 'T₀ ${result.t0.toStringAsFixed(0)}°C • ${result.sucInch}', const Color(0xFF0EA5E9));
    drawNode(p9, _l('9. الأكيومليتور', '9. Bouteille ACL', '9. Accumulator'), 'ACL ${result.sizing.aclStdVolL} L', const Color(0xFF06B6D4));
  }

  void _drawArrow(Canvas canvas, Offset a, Offset b, Color color) {
    final p = Paint()..color = color..strokeWidth = 2.6..strokeCap = StrokeCap.round;
    canvas.drawLine(a, b, p);
    final angle = math.atan2(b.dy - a.dy, b.dx - a.dx);
    const sz = 6.5;
    final tip = Offset(b.dx - math.cos(angle) * 1.5, b.dy - math.sin(angle) * 1.5);
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(tip.dx - sz * math.cos(angle - 0.52), tip.dy - sz * math.sin(angle - 0.52))
      ..lineTo(tip.dx - sz * math.cos(angle + 0.52), tip.dy - sz * math.sin(angle + 0.52))
      ..close();
    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.fill);
  }

  void _numPin(Canvas canvas, Offset pos, String numStr, Color col) {
    canvas.drawCircle(pos, 7.5, Paint()..color = const Color(0xFF050A14));
    canvas.drawCircle(pos, 7.5, Paint()..color = col..style = PaintingStyle.stroke..strokeWidth = 1.5);
    final tp = TextPainter(
      text: TextSpan(text: numStr, style: TextStyle(color: col, fontSize: 8.8, fontWeight: FontWeight.w900)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  void _tag(Canvas canvas, Offset pos, String text, Color color, Size size, {double fontSize = 10.5}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.w900)),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: size.width - 20);

    const padX = 5.0;
    const padY = 2.5;
    final halfW = tp.width / 2 + padX;
    final halfH = tp.height / 2 + padY;
    final cx = pos.dx.clamp(halfW + 4, size.width - halfW - 4);
    final cy = pos.dy.clamp(halfH + 4, size.height - halfH - 4);
    final rect = Rect.fromCenter(center: Offset(cx, cy), width: tp.width + padX * 2, height: tp.height + padY * 2);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), Paint()..color = const Color(0xFF060C18).withAlpha(235));
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  void _drawBoxText(Canvas canvas, Offset pos, String text, Color color, double sz, double maxW, {required bool rtl}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: sz, fontWeight: FontWeight.w800)),
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: math.max(20.0, maxW));
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
