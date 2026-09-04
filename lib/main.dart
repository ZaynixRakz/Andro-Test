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
      const Center(child: Text('Zaynix Cloud Packages Empty', style: TextStyle(color: Colors.grey))),
      const Center(child: Text('Terminal Security Active', style: TextStyle(color: Colors.grey))),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0D0F18),
        selectedItemColor: const Color(0xFF00F2FE),
        unselectedItemColor: Colors.grey.withOpacity(0.6),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.layers_outlined), label: 'Workspace'),
          BottomNavigationBarItem(icon: Icon(Icons.folder_copy_outlined), label: 'Packages'),
          BottomNavigationBarItem(icon: Icon(Icons.tune_rounded), label: 'Terminal'),
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
          const Text('CORE ENVIRONMENT', style: TextStyle(color: Color(0xFF2F80ED), letterSpacing: 2, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Zaynix Files', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0D0F18),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isShizukuActive ? const Color(0xFF1F2235) : Colors.red.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                CircleAvatar(radius: 5, backgroundColor: isShizukuActive ? const Color(0xFF00E676) : Colors.redAccent),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isShizukuActive ? 'Access Bridge Active' : 'Access Bridge Restricted', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(isShizukuActive ? 'Otoritas sistem berhasil diverifikasi.' : 'Layanan eksternal belum diaktifkan.', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (!isShizukuActive)
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50), backgroundColor: const Color(0xFF2F80ED)),
              onPressed: onShizukuConnect, 
              child: const Text('Inisialisasi Akses Zaynix', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
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
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('WORKSPACE TARGET', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          if (!isShizukuActive)
            const Expanded(child: Center(child: Text('Workspace Terkunci. Aktifkan Shizuku di Dashboard.', style: TextStyle(color: Colors.grey))))
          else ...[
            ListTile(
              tileColor: const Color(0xFF11131F),
              leading: const Icon(Icons.gamepad_rounded, color: Colors.orangeAccent),
              title: const Text('Free Fire Standard'),
              subtitle: const Text('com.dts.freefireth'),
            ),
            const SizedBox(height: 10),
            ListTile(
              tileColor: const Color(0xFF11131F),
              leading: const Icon(Icons.gamepad_rounded, color: Colors.purpleAccent),
              title: const Text('Free Fire MAX'),
              subtitle: const Text('com.dts.freefiremax'),
            ),
          ]
        ],
      ),
    );
  }
}
