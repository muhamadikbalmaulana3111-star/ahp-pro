import 'package:flutter/material.dart';
import '../models/ahp_model.dart';
import '../services/api_service.dart';
import '../widgets/comparison_slider.dart';
import 'result_screen.dart';
import 'dart:math';

class ComparisonScreen extends StatefulWidget {
  final ApiService apiService;
  final List<Criterion> criteria;
  final List<Alternative> alternatives;

  const ComparisonScreen({
    super.key,
    required this.apiService,
    required this.criteria,
    required this.alternatives,
  });

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isCalculating = false;

  // Menyimpan semua perbandingan
  late Map<String, PairwiseComparison> _criteriaComparisons;
  late Map<String, Map<String, PairwiseComparison>> _alternativeComparisons;

  @override
  void initState() {
    super.initState();
    
    // Tab: 1 tab untuk kriteria + N tabs untuk alternatif (satu per kriteria)
    _tabController = TabController(
      length: 1 + widget.criteria.length,
      vsync: this,
    );

    // Initialize comparisons
    _initializeComparisons();
  }

  void _initializeComparisons() {
    // Criteria comparisons
    _criteriaComparisons = {};
    final criteriaNames = widget.criteria.map((c) => c.name).toList();
    for (int i = 0; i < criteriaNames.length; i++) {
      for (int j = i + 1; j < criteriaNames.length; j++) {
        final key = '${criteriaNames[i]}-${criteriaNames[j]}';
        _criteriaComparisons[key] = PairwiseComparison(
          item1: criteriaNames[i],
          item2: criteriaNames[j],
          value: 1.0,
        );
      }
    }

    // Alternative comparisons for each criterion
    _alternativeComparisons = {};
    final alternativeNames = widget.alternatives.map((a) => a.name).toList();
    
    for (final criterion in widget.criteria) {
      _alternativeComparisons[criterion.name] = {};
      
      for (int i = 0; i < alternativeNames.length; i++) {
        for (int j = i + 1; j < alternativeNames.length; j++) {
          final key = '${alternativeNames[i]}-${alternativeNames[j]}';
          _alternativeComparisons[criterion.name]![key] = PairwiseComparison(
            item1: alternativeNames[i],
            item2: alternativeNames[j],
            value: 1.0,
          );
        }
      }
    }
  }

  /// Build pairwise comparison matrix from comparisons map
  List<List<double>> _buildMatrix(List<String> items, Map<String, PairwiseComparison> comparisons) {
    final n = items.length;
    final matrix = List.generate(n, (_) => List<double>.filled(n, 1.0));

    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        if (i == j) {
          matrix[i][j] = 1.0;
        } else if (i < j) {
          final key = '${items[i]}-${items[j]}';
          matrix[i][j] = comparisons[key]?.value ?? 1.0;
          matrix[j][i] = 1.0 / matrix[i][j];
        }
      }
    }

    return matrix;
  }

  /// Calculate handler
  Future<void> _handleCalculate() async {
    setState(() {
      _isCalculating = true;
    });

    try {
      // Build matrices
      final criteriaNames = widget.criteria.map((c) => c.name).toList();
      final alternativeNames = widget.alternatives.map((a) => a.name).toList();

      final criteriaMatrix = _buildMatrix(criteriaNames, _criteriaComparisons);
      
      final alternativeMatrices = <String, List<List<double>>>{};
      for (final criterion in widget.criteria) {
        alternativeMatrices[criterion.name] = _buildMatrix(
          alternativeNames,
          _alternativeComparisons[criterion.name]!,
        );
      }

      // Create request
      final request = AHPRequest(
        criteria: criteriaNames,
        alternatives: alternativeNames,
        criteriaMatrix: criteriaMatrix,
        alternativeMatrices: alternativeMatrices,
      );

      // Send to API
      final result = await widget.apiService.calculateAHP(request);

      if (mounted) {
        setState(() {
          _isCalculating = false;
        });

        if (result.isSuccess) {
          // Navigate to result screen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ResultScreen(result: result),
            ),
          );
        } else {
          // Show error dialog
          _showErrorDialog(result.message);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCalculating = false;
        });
        _showErrorDialog('Terjadi kesalahan: ${e.toString()}');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Perhatian'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perbandingan Berpasangan'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            const Tab(text: 'Kriteria'),
            ...widget.criteria.map((c) => Tab(text: c.name)),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Criteria comparisons
              _buildComparisonTab(
                title: 'Perbandingan Antar Kriteria',
                description: 'Bandingkan tingkat kepentingan setiap kriteria',
                items: widget.criteria.map((c) => c.name).toList(),
                comparisons: _criteriaComparisons,
              ),
              
              // Tabs 2+: Alternative comparisons per criterion
              ...widget.criteria.map((criterion) {
                return _buildComparisonTab(
                  title: 'Alternatif untuk "${criterion.name}"',
                  description: 'Bandingkan mesin berdasarkan ${criterion.name.toLowerCase()}',
                  items: widget.alternatives.map((a) => a.name).toList(),
                  comparisons: _alternativeComparisons[criterion.name]!,
                );
              }),
            ],
          ),

          // Loading overlay
          if (_isCalculating)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Menghitung prioritas AHP...',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _isCalculating ? null : _handleCalculate,
            icon: const Icon(Icons.calculate),
            label: const Text(
              'Hitung Hasil AHP',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonTab({
    required String title,
    required String description,
    required List<String> items,
    required Map<String, PairwiseComparison> comparisons,
  }) {
    final comparisonsList = comparisons.values.toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(description),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.info_outline, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Geser slider untuk menentukan mana yang lebih penting',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Total ${comparisonsList.length} perbandingan',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),

          const SizedBox(height: 12),

          // Comparisons
          ...comparisonsList.asMap().entries.map((entry) {
            final index = entry.key;
            final comparison = entry.value;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                comparison.item1,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const Text(
                                'vs',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                comparison.item2,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ComparisonSlider(
                      comparison: comparison,
                      onChanged: (value) {
                        setState(() {
                          comparison.value = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          }).toList(),

          const SizedBox(height: 80), // Space for bottom button
        ],
      ),
    );
  }
}
