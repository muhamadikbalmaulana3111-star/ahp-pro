import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/ahp_model.dart';

class ResultScreen extends StatelessWidget {
  final AHPResult result;

  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    if (!result.isSuccess || result.ranking == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Hasil Error'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.red),
                const SizedBox(height: 24),
                Text(
                  result.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Kembali'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final ranking = result.ranking!;
    final rankedScores = result.rankedScores!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Analisis AHP'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            tooltip: 'Kembali ke Awal',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Consistency badge
            Card(
              color: result.isConsistent == true
                  ? Colors.green[50]
                  : Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      result.isConsistent == true
                          ? Icons.check_circle
                          : Icons.warning,
                      color: result.isConsistent == true
                          ? Colors.green
                          : Colors.red,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            result.isConsistent == true
                                ? 'Penilaian Konsisten ✓'
                                : 'Penilaian Tidak Konsisten',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: result.isConsistent == true
                                  ? Colors.green[800]
                                  : Colors.red[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Consistency Ratio: ${(result.criteriaCR! * 100).toStringAsFixed(2)}%',
                            style: TextStyle(
                              fontSize: 14,
                              color: result.isConsistent == true
                                  ? Colors.green[700]
                                  : Colors.red[700],
                            ),
                          ),
                          if (result.criteriaCR != null)
                            Text(
                              result.criteriaCR! < 0.1
                                  ? 'CR < 10% (Sangat Baik)'
                                  : 'CR ≥ 10% (Perlu Revisi)',
                              style: const TextStyle(fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Recommendation card
            if (result.recommendation != null)
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
                            Icons.lightbulb_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Rekomendasi',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        result.recommendation!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Chart title
            Text(
              'Prioritas Perbaikan Mesin',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 16),

            // Bar chart
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 300,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: rankedScores[0] * 1.2,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) => Colors.blueGrey,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${ranking[group.x.toInt()]}\n',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                TextSpan(
                                  text: '${(rankedScores[group.x.toInt()] * 100).toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    color: Colors.yellow,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= ranking.length) return const Text('');
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  '#${value.toInt() + 1}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                            reservedSize: 30,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${(value * 100).toInt()}%',
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                            reservedSize: 40,
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 0.1,
                      ),
                      barGroups: List.generate(
                        ranking.length,
                        (index) => BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: rankedScores[index],
                              color: _getBarColor(context, index),
                              width: 40,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Ranking list
            Text(
              'Peringkat Detail',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 12),

            ...ranking.asMap().entries.map((entry) {
              final index = entry.key;
              final machine = entry.value;
              final score = rankedScores[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: index == 0 ? Colors.amber[50] : null,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getBarColor(context, index),
                    foregroundColor: Colors.white,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(child: Text(machine, style: const TextStyle(fontWeight: FontWeight.bold))),
                      if (index == 0)
                        const Icon(Icons.stars, color: Colors.amber, size: 20),
                    ],
                  ),
                  subtitle: LinearProgressIndicator(
                    value: score / rankedScores[0],
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(_getBarColor(context, index)),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${(score * 100).toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getBarColor(context, index),
                        ),
                      ),
                      const Text(
                        'Prioritas',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 32),

            // Criteria weights section
            if (result.criteriaWeights != null && result.criteria != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bobot Kriteria',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ...result.criteria!.asMap().entries.map((entry) {
                    final index = entry.key;
                    final criterion = entry.value;
                    final weight = result.criteriaWeights![index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          Icons.check_circle_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(criterion),
                        trailing: Text(
                          '${(weight * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),

            const SizedBox(height: 32),

            // Start over button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.restart_alt),
                label: const Text(
                  'Mulai Analisis Baru',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Color _getBarColor(BuildContext context, int index) {
    final colors = [
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[index % colors.length];
  }
}
