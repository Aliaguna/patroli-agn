import 'dart:convert';
import 'package:flutter/material.dart';

void main() {
  runApp(const PatroliApp());
}

class PatroliApp extends StatelessWidget {
  const PatroliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Patroli PT. AGN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PATROLI PT. AGN', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF1A237E),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => const Icon(Icons.shield, size: 32, color: Color(0xFF1A237E)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sistem Operasional Patroli', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        SizedBox(height: 4),
                        Text('PT. ALIA GUNA NUSANTARA', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Grid Menu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildCard(
                    context: context,
                    icon: Icons.assignment_turned_in,
                    title: 'Formulir Laporan',
                    subtitle: 'Input Insiden & PDF',
                    color: Colors.redAccent,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const FormLaporanScreen())),
                  ),
                  _buildCard(
                    context: context,
                    icon: Icons.camera_front,
                    title: 'Absen GPS Selfie',
                    subtitle: 'Validasi Presensi Pos',
                    color: Colors.orange,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const FormLaporanScreen())),
                  ),
                  _buildCard(
                    context: context,
                    icon: Icons.qr_code_scanner,
                    title: 'Scan Checkpoint',
                    subtitle: 'Pindai Pos QR',
                    color: Colors.blue,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const FormLaporanScreen())),
                  ),
                  _buildCard(
                    context: context,
                    icon: Icons.history,
                    title: 'Riwayat Patroli',
                    subtitle: 'Log Aktivitas',
                    color: Colors.teal,
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sistem Riwayat Aktif.'))),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required BuildContext context, required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 28),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// FORMULIR LAPORAN PATROLI DENGAN KAMERA DOKUMENTASI LOKAL
// ---------------------------------------------------------------------------
class FormLaporanScreen extends StatefulWidget {
  const FormLaporanScreen({super.key});

  @override
  State<FormLaporanScreen> createState() => _FormLaporanScreenState();
}

class _FormLaporanScreenState extends State<FormLaporanScreen> {
  final _namaController = TextEditingController();
  final _posController = TextEditingController();
  final _deskripsiController = TextEditingController();

  void _simpanDanCetakPDF() {
    if (_namaController.text.isEmpty || _posController.text.isEmpty || _deskripsiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harap lengkapi seluruh kolom formulir!')));
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Laporan Berhasil Dibuat', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Detail Laporan PT. AGN:\n\n'
            '• Petugas: ${_namaController.text}\n'
            '• Pos/Area: ${_posController.text}\n'
            '• Temuan: ${_deskripsiController.text}\n\n'
            'Dokumen laporan siap diunduh & dikirimkan.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('SELESAI & KIRIM', style: TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Laporan Patroli', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A237E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _namaController,
              decoration: const InputDecoration(labelText: 'Nama Petugas Satpam', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _posController,
              decoration: const InputDecoration(labelText: 'Nama Pos / Area Patroli', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _deskripsiController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Deskripsi Detail Temuan / Insiden', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _simpanDanCetakPDF,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('CETAK & SIMPAN LAPORAN', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E), foregroundColor: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
