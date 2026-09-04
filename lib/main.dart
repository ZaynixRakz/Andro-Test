import 'package:flutter/material.dart';

void main() {
  runApp(const ZaynixFilesApp());
}

class ZaynixFilesApp extends StatelessWidget {
  const ZaynixFilesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zaynix Files',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF08090E), 
        cardColor: const Color(0xFF11131F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2F80ED), 
          secondary: Color(0xFF00F2FE), 
          surface: Color(0xFF11131F),
        ),
      ),
      home: const ZaynixMainWorkspace(),
      debugShowCheckedModeBanner: false,
    );
  }
}
class ZaynixMainWorkspace extends StatefulWidget {
  const ZaynixMainWorkspace({super.key});
  @override
  State<ZaynixMainWorkspace> createState() => _ZaynixMainWorkspaceState();
}

class _ZaynixMainWorkspaceState extends State<ZaynixMainWorkspace> {
  int _selectedIndex = 0;
  bool _isShizukuActive = false; 

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      ZaynixHomeTab(
        isShizukuActive: _isShizukuActive,
        onShizukuConnect: () => setState(() => _isShizukuActive = true),
      ),
      ZaynixInjectTab(isShizukuActive: _isShizukuActive),
      const Center(child: Text('Zaynix Cloud Empty')),
      const Center(child: Text('Terminal Active')),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0D0F18),
        selectedItemColor: const Color(0xFF00F2FE),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.layers), label: 'Workspace'),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Packages'),
          BottomNavigationBarItem(icon: Icon(Icons.tune), label: 'Terminal'),
        ],
      ),
    );
  }
}
class ZaynixHomeTab extends StatelessWidget {
  final bool isShizukuActive;
  final VoidCallback onShizukuConnect;
  const ZaynixHomeTab({super.key, required this.isShizukuActive, required this.onShizukuConnect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Zaynix Files', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF11131F), borderRadius: BorderRadius.circular(12)),
            child: Text(isShizukuActive ? 'Access Bridge Active (Android/iOS)' : 'Shizuku/Bypass belum aktif.'),
          ),
          const SizedBox(height: 20),
          if (!isShizukuActive)
            ElevatedButton(onPressed: onShizukuConnect, child: const Text('Inisialisasi Akses Zaynix')),
        ],
      ),
    );
  }
}

class ZaynixInjectTab extends StatelessWidget {
  final bool isShizukuActive;
  const ZaynixInjectTab({super.key, required this.isShizukuActive});
  @override
  Widget build(BuildContext context) {
    return Center(child: Text(isShizukuActive ? 'Target: Free Fire Ready' : 'Workspace Terkunci'));
  }
}

