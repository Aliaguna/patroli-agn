// --- APP BAR DENGAN LOGO RESMI AGN ---
appBar: AppBar(
  backgroundColor: const Color(0xFF1E1E1E),
  elevation: 3,
  centerTitle: true,
  title: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      // Memanggil logo fisik dari repositori GitHub
      Image.network(
        'https://raw.githubusercontent.com/Aliaguna/patroli-agn/main/logo.png',
        height: 38,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.shield, color: Color(0xFFFFD700), size: 28),
      ),
      const SizedBox(width: 10),
      const Text(
        'PATROLI PT. AGN',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.white,
          letterSpacing: 1.2,
        ),
      ),
    ],
  ),
),
