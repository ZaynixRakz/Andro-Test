import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:installed_apps/installed_apps.dart';
import 'dart:convert';
import 'dart:io';

void main() => runApp(const ZaynixApp());

class ZaynixApp extends StatelessWidget {
  const ZaynixApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zaynix Forsaken',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF040508),
        cardColor: const Color(0xFF0F111E),
        colorScheme: const ColorScheme.dark(primary: Color(0xFF00F2FE)),
      ),
      home: const ZaynixAuth(),
      debugShowCheckedModeBanner: false,
    );
  }
}
class ZaynixAuth extends StatefulWidget {
  const ZaynixAuth({super.key});
  @override
  State<ZaynixAuth> createState() => _ZaynixAuthState();
}

class _ZaynixAuthState extends State<ZaynixAuth> {
  final TextEditingController _ctrl = TextEditingController();
  String _msg = "Licensi Zaynix App"; 
  String _ip = "Menghubungkan...";
  bool _loading = false;

  final String _url = "https://raw.githubusercontent.com/ZaynixRakz/Andro-Test/refs/heads/main/keys.json";

  @override
  void initState() { 
    super.initState(); 
    _getIp(); 
    _checkSavedKey(); 
  }
  
  Future<void> _checkSavedKey() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedKey = prefs.getString('zaynix_saved_key');
    if (savedKey != null) { 
      _ctrl.text = savedKey; 
      _check(); 
    }
  }
    Future<void> _getIp() async {
    try {
      final res = await http.get(Uri.parse('https://1.1.1'));
      if (res.statusCode == 200) {
        final lines = res.body.split('\n');
        final ipLine = lines.firstWhere((line) => line.startsWith('ip='), orElse: () => '');
        if (ipLine.isNotEmpty) { 
          setState(() => _ip = ipLine.substring(3).trim()); 
          return; 
        }
      }
    } catch (_) {}
    setState(() => _ip = "Menghubungkan...");
  }

  String _getHWID() => "HWID-${Platform.localHostname.hashCode.abs().toString().substring(0, 6)}";
    Future<void> _check() async {
    String key = _ctrl.text.trim();
    if (key.isEmpty) { 
      setState(() => _msg = "❌ Key tidak boleh kosong!"); 
      return; 
    }
    setState(() { 
      _loading = true; 
      _msg = "Sinkronisasi Jaringan Cloud..."; 
    });
    try {
      final res = await http.get(Uri.parse(_url));
      if (res.statusCode == 200) {
        Map<String, dynamic> db = json.decode(res.body);
        if (db.containsKey(key)) {
          var data = db[key];
          if (data["status"] != "Active") { 
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('zaynix_saved_key');
            setState(() => _msg = "❌ LISENSI KEDALUWARSA / BANNED!"); 
            return; 
          }
                    final prefs = await SharedPreferences.getInstance();
          String? lockedHWID = prefs.getString('lock_$key');

          if (data["duration"] != "FREE") {
            if (lockedHWID == null) {
              await prefs.setString('lock_$key', _getHWID());
              await prefs.setString('ip_$key', _ip);
              
              int days = data["duration"] == "1DAY" ? 1 : data["duration"] == "3DAY" ? 3 : data["duration"] == "7DAY" ? 7 : data["duration"] == "14DAY" ? 14 : data["duration"] == "30DAY" ? 30 : data["duration"] == "60DAY" ? 60 : 99999;
              DateTime expireTime = DateTime.now().add(Duration(days: days));
              await prefs.setString('expire_$key', expireTime.toIso8601String());
            } else if (lockedHWID != _getHWID()) {
              setState(() => _msg = "❌ DEVICE LOCKED: Key terikat di HP lain!"); 
              return;
            }

            String? expireStr = prefs.getString('expire_$key');
            if (expireStr != null) {
              if (DateTime.now().isAfter(DateTime.parse(expireStr))) {
                await prefs.remove('zaynix_saved_key');
                setState(() => _msg = "❌ WAKTU HABIS: Masa sewa lisensi selesai!"); 
                return;
              }
            }
          }
          await prefs.setString('zaynix_saved_key', key);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => ZaynixHome(type: data["duration"], ip: _ip)));
        } else { 
          setState(() => _msg = "❌ Key tidak terdaftar di server!"); 
        }
      } else { 
        setState(() => _msg = "❌ Gagal membaca database cloud."); 
      }
    } catch (_) { 
      setState(() => _msg = "❌ Periksa jaringan internet Anda."); 
    } finally { 
      setState(() => _loading = false); 
    }
  }
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF00F2FE), width: 2), boxShadow: [BoxShadow(color: const Color(0xFF00F2FE).withOpacity(0.2), blurRadius: 20)]),
              child: const Icon(Icons.shield_rounded, size: 55, color: Color(0xFF00F2FE)),
            ),
            const SizedBox(height: 25),
            const Text('ZAYNIX FORSAKEN', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF00F2FE))),
            const SizedBox(height: 8),
            Text(_msg, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 35),
            TextField(controller: _ctrl, decoration: InputDecoration(hintText: 'Masukkan Serial Key Anda...', prefixIcon: const Icon(Icons.vpn_key_rounded, color: Color(0xFF00F2FE), size: 20), fillColor: const Color(0xFF0F111E), filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
            const SizedBox(height: 20),
            ElevatedButton(style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(52), backgroundColor: const Color(0xFF00F2FE)), onPressed: _loading ? null : _check, child: _loading ? const CircularProgressIndicator(color: Colors.black) : const Text('LOGIN', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }
}
class ZaynixHome extends StatefulWidget {
  final String type; 
  final String ip;
  const ZaynixHome({super.key, required this.type, required this.ip});
  @override
  State<ZaynixHome> createState() => _ZaynixHomeState();
}

class _ZaynixHomeState extends State<ZaynixHome> {
  int _tab = 0;
  bool _aim = false, _recoil = false, _easy = false, _sens = false, _dpi = false, _res = false, _opt = false, _ff = false, _ffMax = false;
  bool _rapid = false, _compact = false, _rog = false;
  double _vSlider = 0.5; 
  int _vDpi = 360, _w = 1080, _h = 2400;

  void _dialogInput(String title, bool isDpi) {
    TextEditingController c1 = TextEditingController();
    TextEditingController c2 = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF0B0D16),
      title: Text(title, style: const TextStyle(color: Color(0xFF00F2FE))),
      content: isDpi ? TextField(controller: c1, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Masukkan nilai DPI Virtual'))
                     : Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: c1, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Lebar (Width)')), TextField(controller: c2, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Tinggi (Height)'))]),
      actions: [TextButton(onPressed: () {
        setState(() {
          if (isDpi) { _vDpi = int.tryParse(c1.text) ?? _vDpi; _dpi = true; }
          else { _w = int.tryParse(c1.text) ?? _w; _h = int.tryParse(c2.text) ?? _h; _res = true; }
        });
        Navigator.pop(ctx);
      }, child: const Text('Terapkan', style: TextStyle(color: Color(0xFF00F2FE))))],
    ));
  }
    Future<void> _openFreeFireGame(String bundleId) async {
    bool isInstalled = await InstalledApps.isAppInstalled(bundleId) ?? false;
    if (isInstalled) { 
      InstalledApps.startApp(bundleId); 
    } else {
      showDialog(context: context, builder: (c) => AlertDialog(backgroundColor: const Color(0xFF0B0D16), title: const Text('Target Not Found', style: TextStyle(color: Colors.redAccent)), content: Text('Game $bundleId tidak terpasang di HP ini!'), actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK'))]));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF07090F), 
        title: const Text('ZAYNIX FORSAKEN', style: TextStyle(color: Color(0xFF00F2FE), fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          IconButton(icon: const Icon(Icons.terminal, color: Color(0xFF00F2FE)), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => Scaffold(backgroundColor: const Color(0xFF030508), appBar: AppBar(title: const Text('FORSAKEN SHELL')), body: const Center(child: Text('[INFO] Zaynix Terminal Shell Online.', style: TextStyle(color: Colors.green, fontFamily: 'monospace'))))))),
          IconButton(icon: const Icon(Icons.logout_rounded, color: Colors.redAccent), onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('zaynix_saved_key');
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const ZaynixAuth()));
          })
        ],
      ),
            body: IndexedStack(index: _tab, children: [
        Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF04181E), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF00F2FE)), boxShadow: [BoxShadow(color: const Color(0xFF00F2FE).withOpacity(0.15), blurRadius: 15)]), child: Column(children: const [
            Text('84.6 GIPS', style: TextStyle(color: Color(0xFF00F2FE), fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 4),
            Text('CPU Bias: 45.02 | GPU Persuasion: 52.44 | Thread Flux: 40.8\nZaynix Environment Core Architecture Active', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 10))
          ])),
          const SizedBox(height: 15),
          _buildGlowInfoCard('API Request', 'Shizuku API v2.0.0', Icons.android),
          _buildGlowInfoCard('Library Status', 'Zaynix Core Engine Active', Icons.gpp_good, color: Colors.green),
          _buildGlowInfoCard('Telemetry Connected IP', widget.ip, Icons.location_on),
          _buildGlowInfoCard('License Status', 'Multi-Device Share Lock Active [${widget.type}]', Icons.lock_outline)
        ])),
        ListView(padding: const EdgeInsets.all(16), children: [
          _buildGlowSwitchCard('Dynamic Sensitivity', '4,7kb', 'Sensitiviy', _sens, (v) => setState(() => _sens = v)),
          _buildGlowSwitchCard('AimDrag Path', '7,9kb', 'AimDrag', _aim, (v) => setState(() { _aim = v; if(v){ _sens = true; _recoil = true; _easy = true; } })),
          if (_aim) Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Row(children: [const Text('TacixSen  '), Expanded(child: Slider(value: _vSlider, activeColor: const Color(0xFF00F2FE), onChanged: (v) => setState(() => _vSlider = v))), Text('${_vSlider.toStringAsFixed(1)}F')])),
          _buildGlowSwitchCard('Recoil Controller', '14,5kb', 'Controller', _recoil, (v) => setState(() => _recoil = v)),
          _buildGlowSwitchCard('EasyDrag', '20,1kb', 'Function', _easy, (v) => setState(() => _easy = v)),
        ]),
               ListView(padding: const EdgeInsets.all(16), children: [
          GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.85, children: [
            GestureDetector(onTap: () => _dialogInput('Set DPI Virtual', true), child: _buildGlowGridCard('DPI-Manager', 'DPI', _dpi ? 'Active: $_vDpi vDPI' : 'Automatically change the DPI settings.', _dpi, (v) { if (v) _dialogInput('Set DPI Virtual', true); else setState(() => _dpi = false); })),
            GestureDetector(onTap: () => _dialogInput('Set Resolusi Virtual', false), child: _buildGlowGridCard('Resolusi Manager', 'libs', _res ? 'Active: ${_w}x$_h' : 'Automatically change the RESOLUSI settings.', _res, (v) { if (v) _dialogInput('Set Resolusi Virtual', false); else setState(() => _res = false); })),
          ]),
          const SizedBox(height: 12),
          _buildGlowSwitchCard('OptimizeGo', '15,1kb', 'Optimize', _opt, (v) => setState(() => _opt = v)),
          _buildGlowSwitchCard('RapidSync', 'Sync', 'Sync', _rapid, (v) => setState(() => _rapid = v)),
          _buildGlowSwitchCard('Compact Aim', 'Sync', 'Sync', _compact, (v) => setState(() => _compact = v)),
          _buildGlowSwitchCard('Rog Monitoring', 'Monitor', 'Monitor', _rog, (v) => setState(() => _rog = v)),
        ]),
                 ListView(padding: const EdgeInsets.all(16), children: [
          _buildGlowGameCard('Garena Free Fire Standard', 'com.dts.freefireth', Colors.orange, _ff, (v) {
            setState(() => _ff = v); if (v == true) { _openFreeFireGame('com.dts.freefireth'); }
          }),
          const SizedBox(height: 12),
          _buildGlowGameCard('Garena Free Fire MAX', 'com.dts.freefiremax', Colors.purple, _ffMax, (v) {
            setState(() => _ffMax = v); if (v == true) { _openFreeFireGame('com.dts.freefiremax'); }
          }),
        ]),
      ]),
      bottomNavigationBar: BottomNavigationBar(currentIndex: _tab, onTap: (i) => setState(() => _tab = i), type: BottomNavigationBarType.fixed, backgroundColor: const Color(0xFF07090F), selectedItemColor: const Color(0xFF00F2FE), unselectedItemColor: Colors.grey.withOpacity(0.4), items: const [BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'), BottomNavigationBarItem(icon: Icon(Icons.construction_rounded), label: 'ToolsX'), BottomNavigationBarItem(icon: Icon(Icons.settings_suggest_rounded), label: 'SettingsX'), BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Features')]),
    );
  }

  Widget _buildGlowInfoCard(String title, String sub, IconData i, {Color color = const Color(0xFF00F2FE)}) => Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF0F111E), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.withOpacity(0.1))), child: Row(children: [Icon(i, color: color), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)), Text(sub, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))]))]));
    Widget _buildGlowSwitchCard(String title, String subtitle, String description, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F111E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: value ? const Color(0xFF00F2FE) : Colors.grey.withOpacity(0.1)),
        boxShadow: value ? [BoxShadow(color: const Color(0xFF00F2FE).withOpacity(0.1), blurRadius: 10)] : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
              Switch(value: value, activeColor: const Color(0xFF00F2FE), onChanged: onChanged),
            ],
          ),
          const SizedBox(height: 6),
          Text(description, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildGlowGridCard(String title, String tag, String desc, bool state, ValueChanged<bool> onChange) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF0F111E), borderRadius: BorderRadius.circular(12), border: Border.all(color: state ? const Color(0xFF00F2FE) : Colors.grey.withOpacity(0.1))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.3)), Container(padding: const EdgeInsets.all(4), color: const Color(0xFF04181E), child: Text(tag, style: const TextStyle(color: Color(0xFF00F2FE), fontSize: 9)))]), Text(desc, style: const TextStyle(fontSize: 11, color: Colors.grey)), Align(alignment: Alignment.bottomRight, child: Switch(value: state, activeColor: const Color(0xFF00F2FE), onChanged: onChange))]));

  Widget _buildGlowGameCard(String title, String pkg, Color color, bool state, ValueChanged<bool> onChange) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFF0F111E), borderRadius: BorderRadius.circular(12), border: Border.all(color: state ? const Color(0xFF00F2FE) : Colors.grey.withOpacity(0.1))), child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [Icon(Icons.local_fire_department, color: color), const SizedBox(width: 10), Text(title, style: const TextStyle(fontWeight: FontWeight.bold))]), Switch(value: state, activeColor: const Color(0xFF00F2FE), onChanged: onChange)]), if (state) Padding(padding: const EdgeInsets.only(top: 10.0), child: ElevatedButton.icon(style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(40), backgroundColor: const Color(0xFF2F80ED)), icon: const Icon(Icons.play_arrow_rounded, color: Colors.white), label: const Text('Launch & Inject Target Game', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), onPressed: () => _openFreeFireGame(pkg)))]);
}
