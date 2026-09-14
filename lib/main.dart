import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

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
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const FormLaporanScreen(),
    );
  }
}

class FormLaporanScreen extends StatefulWidget {
  const FormLaporanScreen({super.key});

  @override
  State<FormLaporanScreen> createState() => _FormLaporanScreenState();
}

class _FormLaporanScreenState extends State<FormLaporanScreen> {
  final _namaController = TextEditingController();
  final _posController = TextEditingController();
  final _deskripsiController = TextEditingController();
  bool _isLoading = false;
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    if (photo != null) {
      setState(() {
        _imageFile = photo;
      });
    }
  }

  Future<void> _kirimKeFirebase() async {
    if (_namaController.text.isEmpty || _posController.text.isEmpty || _deskripsiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi semua kolom formulir!')),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      String base64Image = "";
      if (_imageFile != null) {
        List<int> imageBytes = await _imageFile!.readAsBytes();
        base64Image = "data:image/jpeg;base64,${base64Encode(imageBytes)}";
      }

      final url = Uri.parse('https://firestore.googleapis.com/v1/projects/patroli-agn/databases/(default)/documents/laporan_patroli');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "fields": {
            "nama": {"stringValue": _namaController.text},
            "pos": {"stringValue": _posController.text},
            "deskripsi": {"stringValue": _deskripsiController.text},
            "waktu": {"stringValue": DateTime.now().toString().substring(0, 16)},
            "fotoUrl": {"stringValue": base64Image},
            "timestamp": {"timestampValue": DateTime.now().toUtc().toIso8601String()}
          }
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Laporan Berhasil Terkirim ke Dashboard Admin!')),
        );
        _namaController.clear();
        _posController.clear();
        _deskripsiController.clear();
        setState(() { _imageFile = null; });
      } else {
        throw Exception("Gagal mengirim data");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal Terkoneksi: $e')),
      );
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Laporan Patroli AGN', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A237E),
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
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Deskripsi Temuan & Penyelesaian', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.camera_alt),
                label: Text(_imageFile == null ? 'AMBIL FOTO BUKTI' : 'FOTO TERAMBIL (UBAH)'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: _kirimKeFirebase,
                    icon: const Icon(Icons.send),
                    label: const Text('KIRIM LAPORAN KE DASHBOARD', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E), foregroundColor: Colors.white),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
