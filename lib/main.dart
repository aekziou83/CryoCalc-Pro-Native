import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'engine/cryo_engine.dart';
import 'widgets/room_3d_viewer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const CryoCalcApp());
}

class CryoCalcApp extends StatelessWidget {
  const CryoCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CryoCalc Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF070D19),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF38BDF8),
          secondary: Color(0xFF22C55E),
          surface: Color(0xFF111D34),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF081121),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withAlpha(35)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withAlpha(30)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.6),
          ),
        ),
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: CryoHomeScreen(),
      ),
    );
  }
}

class CryoHomeScreen extends StatefulWidget {
  const CryoHomeScreen({super.key});

  @override
  State<CryoHomeScreen> createState() => _CryoHomeScreenState();
}

class _CryoHomeScreenState extends State<CryoHomeScreen> {
  int _tabIndex = 0;

  final _lenCtrl = TextEditingController(text: '6');
  final _widCtrl = TextEditingController(text: '4');
  final _heiCtrl = TextEditingController(text: '3');
  final _tInCtrl = TextEditingController(text: '2');
  final _tAmbCtrl = TextEditingController(text: '38');
  final _kgCtrl = TextEditingController(text: '1500');

  double _insMm = 80;
  String _arch = 'split';
  late CryoInput _input;
  late CryoResult _result;

  @override
  void initState() {
    super.initState();
    _recalculate(haptic: false);
  }

  void _recalculate({bool haptic = true}) {
    if (haptic) HapticFeedback.mediumImpact();
    setState(() {
      _input = CryoInput(
        length: double.tryParse(_lenCtrl.text) ?? 6.0,
        width: double.tryParse(_widCtrl.text) ?? 4.0,
        height: double.tryParse(_heiCtrl.text) ?? 3.0,
        insMm: _insMm,
        tInside: double.tryParse(_tInCtrl.text) ?? 2.0,
        tAmbient: double.tryParse(_tAmbCtrl.text) ?? 38.0,
        dailyKg: double.tryParse(_kgCtrl.text) ?? 1500.0,
        arch: _arch,
      );
      _result = CryoEngine.calculate(_input);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1324),
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0284C7), Color(0xFF38BDF8)]),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Text('CC', style: TextStyle(color: Color(0xFF04101F), fontWeight: FontWeight.w900)),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CryoCalc PRO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                Text('م. أحمد زينور 🇩🇿 • بدون نت • 0% إعلانات', style: TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8))),
              ],
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _tabIndex,
        children: [
          _buildMainThermalTab(),
          _buildPanelsTab(),
          _buildSpecsSummaryTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF0A1324),
        indicatorColor: const Color(0xFF38BDF8).withAlpha(45),
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) {
          HapticFeedback.selectionClick();
          setState(() => _tabIndex = i);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.view_in_ar_outlined), selectedIcon: Icon(Icons.view_in_ar), label: 'الغرفة و3D'),
          NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view_rounded), label: 'الساندويتش'),
          NavigationDestination(icon: Icon(Icons.settings_input_component_outlined), selectedIcon: Icon(Icons.settings_input_component), label: 'المجموعة'),
        ],
      ),
    );
  }

  Widget _buildMainThermalTab() {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        // Instant KPI Strip
        Row(
          children: [
            Expanded(child: _kpiCard('الاستطاعة Q₀', '${_result.q0Kw} kW', '${_result.kcalH} kcal/h', const Color(0xFF22C55E))),
            const SizedBox(width: 10),
            Expanded(child: _kpiCard('حجم الغرفة', '${_result.volume} m³', 'الأرضية ${_result.areaFloor} m²', const Color(0xFF38BDF8))),
            const SizedBox(width: 10),
            Expanded(child: _kpiCard('القدرة الكهربائية', '${_result.pElecKw} kW', 'T₀ ${_result.t0.toStringAsFixed(0)}°C', const Color(0xFFF59E0B))),
          ],
        ),
        const SizedBox(height: 14),

        // Interactive 3D CAD Cold Room + Unit Viewer
        Room3DViewer(input: _input, result: _result),
        const SizedBox(height: 14),

        // Engineering Input Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF111D34),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withAlpha(22)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('معطيات الغرفة ومجموعة التبريد', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _numField(_lenCtrl, 'الطول L (m)')),
                  const SizedBox(width: 10),
                  Expanded(child: _numField(_widCtrl, 'العرض W (m)')),
                  const SizedBox(width: 10),
                  Expanded(child: _numField(_heiCtrl, 'الارتفاع H (m)')),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _numField(_tInCtrl, 'الداخلية (°C)')),
                  const SizedBox(width: 10),
                  Expanded(child: _numField(_tAmbCtrl, 'الخارجية (°C)')),
                  const SizedBox(width: 10),
                  Expanded(child: _numField(_kgCtrl, 'الدخول (kg)')),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<double>(
                      value: _insMm,
                      decoration: const InputDecoration(labelText: 'سمك عزل PU'),
                      items: const [60, 80, 100, 120, 140, 160, 200]
                          .map((v) => DropdownMenuItem(value: v.toDouble(), child: Text('$v mm')))
                          .toList(),
                      onChanged: (v) => setState(() => _insMm = v ?? 80),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _arch,
                      decoration: const InputDecoration(labelText: 'نوع المجموعة'),
                      items: const [
                        DropdownMenuItem(value: 'split', child: Text('منفصلة Split')),
                        DropdownMenuItem(value: 'monobloc', child: Text('مدمجة Monobloc')),
                        DropdownMenuItem(value: 'rack', child: Text('مركزية Rack')),
                      ],
                      onChanged: (v) => setState(() => _arch = v ?? 'split'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF38BDF8),
                    foregroundColor: const Color(0xFF04101F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _recalculate,
                  icon: const Icon(Icons.bolt_rounded),
                  label: const Text('احسب وحدّث المجسم 3D والقياسات', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPanelsTab() {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        _infoTile('عدد ألواح الجدران (عرض 1.15m)', '${_result.wallPanels} لوح بارتفاع ${_input.height} m'),
        _infoTile('عدد ألواح السقف', '${_result.roofPanels} لوح بطول ${_input.length} m'),
        _infoTile('سمك البولي يوريثان المختار', '${_input.insMm.toInt()} mm'),
        _infoTile('عزل الأرضية', _result.floorInsRequired ? 'إلزامي (غرفة سالبة / صفرية)' : 'اختياري (غرفة موجبة)'),
      ],
    );
  }

  Widget _buildSpecsSummaryTab() {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        _infoTile('الضاغط / المجموعة المرشحة', _result.recommendedUnit),
        _infoTile('الأبعاد الفيزيائية لوحدة التكثيف', _result.condDim),
        _infoTile('الأبعاد الفيزيائية للمبخر الداخلي', '${_result.evapDim} (${_result.evapFans} مراوح)'),
        _infoTile('أقطار أنابيب النحاس (سحب / سائل)', '${_result.sucInch}  /  ${_result.liqInch}'),
        _infoTile('نظام التشغيل الحراري', 'التبخير T₀ = ${_result.t0.toStringAsFixed(1)}°C  •  التكثيف Tk = ${_result.tk.toStringAsFixed(1)}°C'),
      ],
    );
  }

  Widget _kpiCard(String title, String main, String sub, Color accent) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFF111D34),
        borderRadius: BorderRadius.circular(14),
        border: Border(top: BorderSide(color: accent, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8))),
          const SizedBox(height: 3),
          Text(main, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
          Text(sub, style: TextStyle(fontSize: 10, color: accent, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _numField(TextEditingController c, String label) {
    return TextField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _infoTile(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111D34),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(title, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13))),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13.5)),
        ],
      ),
    );
  }
}
