import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
        scaffoldBackgroundColor: const Color(0xFF030407),
        cardColor: const Color(0xFF0B0D16),
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
  String _msg = "SISTEM PROTEKSI TELEMETRY ZAYNIX";
  String _ip = "Loading IP...";
  bool _loading = false;

  // ⚠️ TEMPELKAN LINK URL RAW GIST ANDA YANG DIAMBIL DARI TAHAP 2 DI SINI
  final String _url = "https://raw.githubusercontent.com/ZaynixRakz/Andro-Test/refs/heads/main/keys.json";

  @override
  void initState() { super.initState(); _getIp(); }
  
    Future<void> _fetchUserIp() async {
    try {
      // Mengganti ke server Cloudflare yang jauh lebih stabil dan anti-error HTML
      final res = await http.get(Uri.parse('https://1.1.1'));
      if (res.statusCode == 200) {
        // Logika untuk menyaring teks agar hanya mengambil angka IP-nya saja
        final lines = res.body.split('\n');
        final ipLine = lines.firstWhere((line) => line.startsWith('ip='), orElse: () => '');
        if (ipLine.isNotEmpty) {
          setState(() => _userIpAddress = ipLine.substring(3).trim());
          return;
        }
      }
    } catch (_) {}
    
    // Jika internet pembeli sedang lag/mati, otomatis diarahkan ke IP lokal agar tidak error
    setState(() => _userIpAddress = "127.0.0.1 (Offline Mode)");
  }

  String _getHWID() => "HWID-${Platform.localHostname.hashCode.abs().toString().substring(0, 6)}";

  Future<void> _check() async {
    String key = _ctrl.text.trim();
    if (key.isEmpty) { setState(() => _msg = "❌ Kunci lisensi tidak boleh kosong!"); return; }
    setState(() { _loading = true; _msg = "Sinkronisasi HWID & IP Terhadap Cloud..."; });
    try {
      final res = await http.get(Uri.parse(_url));
      if (res.statusCode == 200) {
        Map<String, dynamic> db = json.decode(res.body);
        if (db.containsKey(key)) {
          var data = db[key];
          if (data["status"] != "Active") { setState(() => _msg = "❌ EXPIRED/BANNED: Akses lisensi dicabut!"); return; }
          if (data["duration"] != "FREE" && data["hwid"] != "" && data["hwid"] != _getHWID()) {
            setState(() => _msg = "❌ DEVICE LOCKED: Key terikat di perangkat lain!"); return;
          }
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => ZaynixHome(type: data["duration"], ip: _ip)));
        } else { setState(() => _msg = "❌ INVALID: Key tidak terdaftar di server!"); }
      } else { setState(() => _msg = "❌ SERVER ERROR: Gagal memuat database."); }
    } catch (_) { setState(() => _msg = "❌ NETWORK ERROR: Periksa koneksi internet."); }
    finally { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF00F2FE), width: 2), boxShadow: [BoxShadow(color: const Color(0xFF00F2FE).withOpacity(0.2), blurRadius: 15)]),
              child: const Icon(Icons.shield_rounded, size: 50, color: Color(0xFF00F2FE)),
            ),
            const SizedBox(height: 15),
            const Text('ZAYNIX FORSAKEN', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF00F2FE))),
            Text("HWID: ${_getHWID()} | IP: $_ip", style: const TextStyle(color: Colors.grey, fontSize: 11)),
            const SizedBox(height: 15),
            Text(_msg, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 20),
            TextField(controller: _ctrl, decoration: const InputDecoration(hintText: 'Masukkan Serial Key Premium...', fillColor: Color(0xFF0B0D16), filled: true)),
            const SizedBox(height: 20),
            ElevatedButton(style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50), backgroundColor: const Color(0xFF00F2FE)), onPressed: _loading ? null : _check, child: _loading ? const CircularProgressIndicator(color: Colors.black) : const Text('VERIFIKASI AKSES LISENSI', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }
}
class ZaynixHome extends StatefulWidget {
  final String type; final String ip;
  const ZaynixHome({super.key, required this.type, required this.ip});
  @override
  State<ZaynixHome> createState() => _ZaynixHomeState();
}

class _ZaynixHomeState extends State<ZaynixHome> {
  int _tab = 0;
  bool _aim = false, _recoil = false, _easy = false, _sens = false, _dpi = false, _res = false, _opt = false, _ff = false, _ffMax = false;
  double _vSlider = 0.5; int _vDpi = 360, _w = 1080, _h = 2400;

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
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xFF07090F), title: Text('ZAYNIX - RANK: ${widget.type}'), actions: [IconButton(icon: const Icon(Icons.terminal, color: Color(0xFF00F2FE)), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => Scaffold(backgroundColor: const Color(0xFF030508), appBar: AppBar(title: const Text('FORSAKEN COMMAND SHELL')), body: const Center(child: Text('[INFO] Zaynix Terminal Shell Online.', style: TextStyle(color: Colors.green, fontFamily: 'monospace')))))))]),
      body: IndexedStack(index: _tab, children: [
        Padding(padding: const EdgeInsets.all(16), child: Column(children: [Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF04181E), border: Border.all(color: const Color(0xFF00F2FE)), boxShadow: [BoxShadow(color: const Color(0xFF00F2FE).withOpacity(0.1), blurRadius: 10)]), child: const Center(child: Text('84.6 GIPS | CYBER CORE ENVIRONMENT', style: TextStyle(color: Color(0xFF00F2FE), fontWeight: FontWeight.bold)))), ListTile(title: const Text('Telemetry Connected IP'), subtitle: Text(widget.ip)), ListTile(title: const Text('Device Security Status'), subtitle: const Text('Secure Multi-Device Anti-Share Guard Active'))])),
        ListView(padding: const EdgeInsets.all(16), children: [
          SwitchListTile(title: const Text('Dynamic Sensitivity'), value: _sens, activeColor: const Color(0xFF00F2FE), onChanged: (v) => setState(() => _sens = v)),
          SwitchListTile(title: const Text('AimDrag Path'), subtitle: const Text('Otomatis mengaktifkan fitur pendukung saat ON'), value: _aim, activeColor: const Color(0xFF00F2FE), onChanged: (v) => setState(() { _aim = v; if(v){ _sens = true; _recoil = true; _easy = true; } })),
          if (_aim) Slider(value: _vSlider, activeColor: const Color(0xFF00F2FE), onChanged: (v) => setState(() => _vSlider = v)),
          SwitchListTile(title: const Text('Recoil Controller'), value: _recoil, activeColor: const Color(0xFF00F2FE), onChanged: (v) => setState(() => _recoil = v)),
        ]),
        ListView(padding: const EdgeInsets.all(16), children: [
          ListTile(title: const Text('DPI Manager'), subtitle: Text(_dpi ? 'Active Virtual: $_vDpi vDPI' : 'Kelincinan Layar Kustom Tanpa Ubah DPI Asli'), onTap: () => _dialogInput('Set DPI Virtual', true)),
          ListTile(title: const Text('Resolution Manager'), subtitle: Text(_res ? 'Active Virtual: ${_w}x$_h' : 'Rasio Resolusi Layar Virtual'), onTap: () => _dialogInput('Set Resolusi Virtual', false)),
          SwitchListTile(title: const Text('OptimizeGo'), value: _opt, activeColor: const Color(0xFF00F2FE), onChanged: (v) => setState(() => _opt = v)),
        ]),
        ListView(padding: const EdgeInsets.all(16), children: [
          SwitchListTile(secondary: const Icon(Icons.local_fire_department, color: Colors.orange), title: const Text('Garena Free Fire Standard'), value: _ff, activeColor: const Color(0xFF00F2FE), onChanged: (v) => setState(() => _ff = v)),
          SwitchListTile(secondary: const Icon(Icons.local_fire_department, color: Colors.purple), title: const Text('Garena Free Fire MAX'), value: _ffMax, activeColor: const Color(0xFF00F2FE), onChanged: (v) => setState(() => _ffMax = v)),
        ]),
      ]),
      bottomNavigationBar: BottomNavigationBar(currentIndex: _tab, onTap: (i) => setState(() => _tab = i), type: BottomNavigationBarType.fixed, selectedItemColor: const Color(0xFF00F2FE), unselectedItemColor: Colors.grey.withOpacity(0.4), items: const [BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: 'Dashboard'), BottomNavigationBarItem(icon: Icon(Icons.tune), label: 'ModulX'), BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'SystemX'), BottomNavigationBarItem(icon: Icon(Icons.gamepad), label: 'Executor')]),
    );
  }
}
