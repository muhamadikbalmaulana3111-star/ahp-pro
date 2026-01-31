import 'package:flutter/material.dart';
import '../models/ahp_model.dart';
import '../services/api_service.dart';
import 'comparison_screen.dart';

class SetupScreen extends StatefulWidget {
  final ApiService apiService;

  const SetupScreen({super.key, required this.apiService});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  // Data studi kasus Pabrik Tepung Tapioka - Muhammad Ikbal Maulana
  final List<Criterion> criteria = [
    Criterion(
      name: 'Derajat Putih',
      description: 'Tingkat kecerahan dan kebersihan tepung yang dihasilkan',
    ),
    Criterion(
      name: 'Pemakaian Air',
      description: 'Efisiensi penggunaan air dalam proses produksi',
    ),
    Criterion(
      name: 'Limbah Padat',
      description: 'Volume limbah padat yang dihasilkan dari proses',
    ),
    Criterion(
      name: 'Efisiensi Produksi',
      description: 'Kecepatan dan output produksi per satuan waktu',
    ),
  ];

  final List<Alternative> alternatives = [
    Alternative(
      name: 'Mesin Parut',
      description: 'Mesin untuk memarut singkong menjadi bubur',
    ),
    Alternative(
      name: 'Mesin Pencuci',
      description: 'Mesin pencuci singkong dan pemisah kotoran',
    ),
    Alternative(
      name: 'Mesin Ekstraksi',
      description: 'Mesin ekstraksi pati dari bubur singkong',
    ),
    Alternative(
      name: 'Mesin Pengering',
      description: 'Mesin dewatering untuk mengurangi kadar air',
    ),
    Alternative(
      name: 'Mesin Pengering Akhir',
      description: 'Mesin dryer untuk pengeringan tepung tapioka',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Kriteria & Alternatif'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Factory Info Card
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.factory,
                          color: Theme.of(context).colorScheme.primary,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pabrik Tepung Tapioka',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Muhammad Ikbal Maulana',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontStyle: FontStyle.italic,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      'Sistem pendukung keputusan untuk prioritas perbaikan mesin menggunakan metode AHP (Analytical Hierarchy Process).',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Criteria Section
            Text(
              'Kriteria Penilaian (${criteria.length})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Faktor-faktor yang akan digunakan untuk menilai prioritas perbaikan mesin:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
            const SizedBox(height: 12),

            ...criteria.asMap().entries.map((entry) {
              final index = entry.key;
              final criterion = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    child: Text('${index + 1}'),
                  ),
                  title: Text(
                    criterion.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(criterion.description),
                  trailing: Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 24),

            // Alternatives Section
            Text(
              'Alternatif Mesin (${alternatives.length})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mesin-mesin yang akan dibandingkan untuk menentukan prioritas perbaikan:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
            const SizedBox(height: 12),

            ...alternatives.asMap().entries.map((entry) {
              final index = entry.key;
              final alternative = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                    child: Text('M${index + 1}'),
                  ),
                  title: Text(
                    alternative.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(alternative.description),
                ),
              );
            }).toList(),

            const SizedBox(height: 32),

            // Next Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ComparisonScreen(
                        apiService: widget.apiService,
                        criteria: criteria,
                        alternatives: alternatives,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text(
                  'Mulai Perbandingan Berpasangan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
