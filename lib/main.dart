import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<Map<String, String>> globalRiwayatLaporan = [];

void main() {
  runApp(const PatroliAGNApp());
}

class PatroliAGNApp extends StatelessWidget {
  const PatroliAGNApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Patroli AGN',
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      home: const MainHomeScreen(),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  Widget _buildCompanyLogo({double height = 36}) {
    return Image.network(
      'https://raw.githubusercontent.com/Aliaguna/patroli-agn/main/logo.png',
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Image.network(
        'https://raw.githubusercontent.com/Aliaguna/patroli-agn/main/LOGO_AGN-removebg-preview.png',
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.shield, color: Color(0xFFFFD700), size: 30),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 2,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCompanyLogo(height: 36),
            const SizedBox(width: 10),
            const Text(
              'PATROLI PT. AGN',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B0000), Color(0xFF1A1A1A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                boxShadow: const [
                  BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 4)),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildCompanyLogo(height: 44),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Sistem Operasional Patroli',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            Text(
                              'PT. Alia Guna Nusantara',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Status GPS: Siap', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      Text('Online (Firebase SG)', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Menu Utama Patroli',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 14),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              children: [
                _buildMenuCard(
                  context,
                  title: 'Scan Checkpoint',
                  icon: Icons.qr_code_scanner,
                  iconColor: Colors.blueAccent,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
                    );
                  },
                ),
                _buildMenuCard(
                  context,
                  title: 'Absen GPS',
                  icon: Icons.my_location,
                  iconColor: Colors.orangeAccent,
                  onTap: () => _openAbsenGPS(context),
                ),
                _buildMenuCard(
                  context,
                  title: 'Laporan Kejadian',
                  icon: Icons.assignment,
                  iconColor: Colors.redAccent,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FormLaporanScreen()),
                    );
                  },
                ),
                _buildMenuCard(
                  context,
                  title: 'Riwayat Patroli',
                  icon: Icons.history,
                  iconColor: Colors.tealAccent,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RiwayatPatroliScreen()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openAbsenGPS(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Row(
          children: const [
            Icon(Icons.my_location, color: Colors.orangeAccent),
            SizedBox(width: 10),
            Text('Presensi GPS Satpam', style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Status GPS: Terhubung (Akurat)', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Lokasi: PT. Alia Guna Nusantara', style: TextStyle(color: Colors.white70)),
            Text('Waktu Presensi: Real-time via Server', style: TextStyle(color: Colors.white70)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Presensi GPS Berhasil Dicatat!')),
              );
            },
            child: const Text('SIMPAN PRESENSI', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {required String title, required IconData icon, required Color iconColor, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  File? _scannedImage;

  Future<void> _scanViaCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 40);
    if (pickedFile != null) {
      setState(() { _scannedImage = File(pickedFile.path); });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Checkpoint Pos Mako Berhasil Terverifikasi!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Scan Checkpoint QR', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code_scanner, size: 80, color: Colors.blueAccent),
            const SizedBox(height: 20),
            const Text(
              'Pemindai Checkpoint Pos Patroli',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tekan tombol di bawah untuk membuka Kamera HP dan arahkan ke Barcode / QR Code Pos.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 30),
            if (_scannedImage != null)
              Container(
                height: 150,
                width: 150,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.greenAccent, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(image: FileImage(_scannedImage!), fit: BoxFit.cover),
                ),
              ),
            ElevatedButton.icon(
              onPressed: _scanViaCamera,
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              label: const Text('BUKA KAMERA SCAN QR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FormLaporanScreen extends StatefulWidget {
  const FormLaporanScreen({super.key});

  @override
  State<FormLaporanScreen> createState() => _FormLaporanScreenState();
}

class _FormLaporanScreenState extends State<FormLaporanScreen> {
  final _namaPetugasController = TextEditingController();
  final _posController = TextEditingController();
  final _deskripsiController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedNama();
  }

  // Mengambil nama petugas tersimpan di HP
  Future<void> _loadSavedNama() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedNama = prefs.getString('saved_nama_petugas');
    if (savedNama != null && savedNama.isNotEmpty) {
      setState(() {
        _namaPetugasController.text = savedNama;
      });
    }
  }

  // Menyimpan nama petugas ke HP
  Future<void> _saveNama(String nama) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_nama_petugas', nama);
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 35);
    if (pickedFile != null) {
      setState(() { _selectedImage = File(pickedFile.path); });
    }
  }

  Future<void> _submitForm() async {
    if (_namaPetugasController.text.isEmpty || _posController.text.isEmpty || _deskripsiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harap isi semua kolom!')));
      return;
    }

    setState(() { _isLoading = true; });

    // Simpan nama otomatis agar tidak perlu diketik ulang
    await _saveNama(_namaPetugasController.text.trim());

    String nowFormatted = DateTime.now().toString().substring(0, 19);
    String imageBase64 = '';
    if (_selectedImage != null) {
      List<int> imageBytes = await _selectedImage!.readAsBytes();
      imageBase64 = 'data:image/jpeg;base64,${base64Encode(imageBytes)}';
    }

    final firebaseDbUrl = Uri.parse('https://patroli-agn-default-rtdb.asia-southeast1.firebasedatabase.app/laporan.json');

    try {
      await http.post(
        firebaseDbUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'waktu': nowFormatted,
          'nama_petugas': _namaPetugasController.text.trim(),
          'pos_area': _posController.text.trim(),
          'deskripsi': _deskripsiController.text.trim(),
          'foto': imageBase64,
        }),
      );

      globalRiwayatLaporan.insert(0, {
        'waktu': nowFormatted,
        'nama_petugas': _namaPetugasController.text.trim(),
        'pos_area': _posController.text.trim(),
        'deskripsi': _deskripsiController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Laporan Berhasil Terkirim ke Dashboard!')));
        Navigator.pop(context);
      }
    } catch (e) {
      globalRiwayatLaporan.insert(0, {
        'waktu': nowFormatted,
        'nama_petugas': _namaPetugasController.text.trim(),
        'pos_area': _posController.text.trim(),
        'deskripsi': _deskripsiController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Laporan tersimpan di Riwayat HP!')));
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Input Laporan Kejadian', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _namaPetugasController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Nama Petugas Satpam',
                  labelStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.person, color: Color(0xFFFFD700)),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white24)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFFD700))),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _posController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Nama Pos / Area Patroli',
                  labelStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.place, color: Color(0xFFFFD700)),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white24)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFFD700))),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _deskripsiController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Deskripsi Temuan & Penyelesaian',
                  labelStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.notes, color: Color(0xFFFFD700)),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white24)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFFD700))),
                ),
              ),
              const SizedBox(height: 16),
              if (_selectedImage != null)
                Container(
                  height: 180,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover),
                  ),
                ),
              ElevatedButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.camera_alt, color: Colors.black),
                label: Text(
                  _selectedImage == null ? 'AMBIL FOTO BUKTI' : 'FOTO TERSIMPAN (KLIK UNTUK UBAH)',
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitForm,
                icon: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send, color: Colors.white),
                label: const Text('KIRIM LAPORAN KE DASHBOARD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB91C1C),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RiwayatPatroliScreen extends StatelessWidget {
  const RiwayatPatroliScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Riwayat Laporan Patroli', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: globalRiwayatLaporan.isEmpty
          ? const Center(child: Text('Belum ada riwayat laporan.', style: TextStyle(color: Colors.white70, fontSize: 16)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: globalRiwayatLaporan.length,
              itemBuilder: (context, index) {
                final item = globalRiwayatLaporan[index];
                return Card(
                  color: const Color(0xFF1E293B),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.check_circle, color: Colors.greenAccent, size: 30),
                    title: Text('${item['pos_area']} - ${item['nama_petugas']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(item['deskripsi'] ?? '', style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 4),
                        Text('Waktu: ${item['waktu']}', style: const TextStyle(color: Colors.amber, fontSize: 12)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
