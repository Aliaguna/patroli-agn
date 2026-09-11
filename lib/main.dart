import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

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
        title: const Text(
          'PATROLI PT. AGN',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Profil
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF1A237E),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Menu Utama Patroli', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            ),
            const SizedBox(height: 16),

            // Grid Menu Operasional
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
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const AbsenGpsScreen())),
                  ),
                  _buildCard(
                    context: context,
                    icon: Icons.qr_code_scanner,
                    title: 'Scan Checkpoint',
                    subtitle: 'Pindai Pos QR',
                    color: Colors.blue,
                    onTap: () => _showMsg(context, 'Fitur Scan Checkpoint siap diintegrasikan.'),
                  ),
                  _buildCard(
                    context: context,
                    icon: Icons.history,
                    title: 'Riwayat Patroli',
                    subtitle: 'Log Aktivitas',
                    color: Colors.teal,
                    onTap: () => _showMsg(context, 'Riwayat Laporan Hari Ini Tersimpan.'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildCard({required BuildContext context, required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
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

  static void _showMsg(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

// ---------------------------------------------------------------------------
// SCREEN FORMULIR LAPORAN KEJADIAN & EKSPOR PDF
// ---------------------------------------------------------------------------
class FormLaporanScreen extends StatefulWidget {
  const FormLaporanScreen({super.key});

  @override
  State<FormLaporanScreen> createState() => _FormLaporanScreenState();
}

class _FormLaporanScreenState extends State<FormLaporanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _posController = TextEditingController();
  final _deskripsiController = TextEditingController();
  
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (photo != null) {
      setState(() {
        _imageFile = File(photo.path);
      });
    }
  }

  Future<void> _generatePdf() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harap ambil foto bukti kejadian terlebih dahulu!')));
      return;
    }

    final pdf = pw.Document();
    final imageBytes = await _imageFile!.readAsBytes();
    final pdfImage = pw.MemoryImage(imageBytes);
    final tanggal = DateFormat('dd MMMM yyyy - HH:mm').format(DateTime.now());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              cross: pw.CrossAxisAlignment.start,
              children: [
                // Header PDF
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text('PT. ALIA GUNA NUSANTARA', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      pw.Text('LAPORAN HASIL PATROLI & KEJADIEN OPERASIONAL', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 4),
                      pw.Divider(),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),

                // Detail Isian
                pw.Text('Waktu Pelaporan : $tanggal'),
                pw.SizedBox(height: 6),
                pw.Text('Nama Petugas   : ${_namaController.text}'),
                pw.SizedBox(height: 6),
                pw.Text('Lokasi / Pos   : ${_posController.text}'),
                pw.SizedBox(height: 16),

                pw.Text('Deskripsi Kejadian / Temuan:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey)),
                  child: pw.Text(_deskripsiController.text, style: const pw.TextStyle(fontSize: 11)),
                ),
                pw.SizedBox(height: 20),

                // Dokumentasi Foto
                pw.Text('Dokumentasi Bukti Lapangan:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Container(
                    height: 220,
                    child: pw.Image(pdfImage),
                  ),
                ),
                pw.Spacer(),

                // Tanda Tangan Footer
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(children: [pw.Text('Petugas Pelapor'), pw.SizedBox(height: 40), pw.Text(_namaController.text)]),
                    pw.Column(children: [pw.Text('Mengetahui, Danru/HRD'), pw.SizedBox(height: 40), pw.Text('PT. AGN')]),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    // Buka Tampilan Cetak / Simpan PDF
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulir Laporan Kejadian', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A237E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Petugas Satpam', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _posController,
                decoration: const InputDecoration(labelText: 'Nama Pos / Area Patroli', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Area patroli wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deskripsiController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Deskripsi Detail Temuan / Insiden', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Deskripsi wajib diisi' : null,
              ),
              const SizedBox(height: 20),

              // Tombol Ambil Foto
              const Text('Dokumentasi Foto Kejadian:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _imageFile != null
                  ? Image.file(_imageFile!, height: 180, width: double.infinity, fit: BoxFit.cover)
                  : Container(
                      height: 120,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                    ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.camera),
                label: const Text('Ambil Foto Bukti (Kamera)'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E), foregroundColor: Colors.white),
              ),

              const SizedBox(height: 30),

              // Tombol Generate PDF
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _generatePdf,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('CETAK & DOWNLOAD LAPORAN PDF', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SCREEN ABSEN GPS & SELFIE
// ---------------------------------------------------------------------------
class AbsenGpsScreen extends StatefulWidget {
  const AbsenGpsScreen({super.key});

  @override
  State<AbsenGpsScreen> createState() => _AbsenGpsScreenState();
}

class _AbsenGpsScreenState extends State<AbsenGpsScreen> {
  String _locationText = "Tekan tombol untuk mengunci lokasi GPS.";
  File? _selfieFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _getLocationAndSelfie() async {
    // 1. Ambil Foto Selfie
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera, preferredCameraDevice: CameraDevice.front);
    if (photo == null) return;

    setState(() {
      _selfieFile = File(photo.path);
      _locationText = "Mencari koordinat GPS...";
    });

    // 2. Ambil Koordinat GPS
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _locationText = "Lat: ${pos.latitude}\nLong: ${pos.longitude}";
      });
    } catch (e) {
      setState(() {
        _locationText = "Gagal mengambil GPS: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Absen GPS Selfie', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A237E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _selfieFile != null
                ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_selfieFile!, height: 220, fit: BoxFit.cover))
                : Container(
                    height: 200,
                    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                    child: const Center(child: Icon(Icons.person, size: 80, color: Colors.grey)),
                  ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_locationText, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _getLocationAndSelfie,
                icon: const Icon(Icons.location_on),
                label: const Text('AMBIL SELFIE & KUNCI LOKASI GPS'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
