class Criterion {
  final String name;
  final String description;

  Criterion({
    required this.name,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }

  factory Criterion.fromJson(Map<String, dynamic> json) {
    return Criterion(
      name: json['name'],
      description: json['description'],
    );
  }
}

class Alternative {
  final String name;
  final String description;

  Alternative({
    required this.name,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }

  factory Alternative.fromJson(Map<String, dynamic> json) {
    return Alternative(
      name: json['name'],
      description: json['description'],
    );
  }
}

class PairwiseComparison {
  final String item1;
  final String item2;
  double value; // 1-9 scale

  PairwiseComparison({
    required this.item1,
    required this.item2,
    this.value = 1.0,
  });

  String get label {
    if (value == 1) return 'Sama penting';
    if (value <= 3) return 'Sedikit lebih penting';
    if (value <= 5) return 'Lebih penting';
    if (value <= 7) return 'Sangat lebih penting';
    return 'Mutlak lebih penting';
  }

  String get direction {
    if (value == 1) return 'Sama';
    if (value > 1) return item1;
    return item2;
  }
}

class AHPRequest {
  final List<String> criteria;
  final List<String> alternatives;
  final List<List<double>> criteriaMatrix;
  final Map<String, List<List<double>>> alternativeMatrices;

  AHPRequest({
    required this.criteria,
    required this.alternatives,
    required this.criteriaMatrix,
    required this.alternativeMatrices,
  });

  Map<String, dynamic> toJson() {
    return {
      'criteria': criteria,
      'alternatives': alternatives,
      'criteria_matrix': criteriaMatrix,
      'alternative_matrices': alternativeMatrices,
    };
  }
}

class AHPResult {
  final String status;
  final String message;
  final List<String>? criteria;
  final List<double>? criteriaWeights;
  final double? criteriaCR;
  final List<String>? alternatives;
  final Map<String, List<double>>? alternativeWeights;
  final List<double>? globalScores;
  final List<String>? ranking;
  final List<double>? rankedScores;
  final bool? isConsistent;
  final String? recommendation;

  AHPResult({
    required this.status,
    required this.message,
    this.criteria,
    this.criteriaWeights,
    this.criteriaCR,
    this.alternatives,
    this.alternativeWeights,
    this.globalScores,
    this.ranking,
    this.rankedScores,
    this.isConsistent,
    this.recommendation,
  });

  factory AHPResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    
    return AHPResult(
      status: json['status'],
      message: json['message'],
      criteria: data != null ? List<String>.from(data['criteria'] ?? []) : null,
      criteriaWeights: data != null && data['criteria_weights'] != null
          ? List<double>.from(data['criteria_weights'].map((x) => x.toDouble()))
          : null,
      criteriaCR: data != null ? (data['criteria_cr'] as num?)?.toDouble() : null,
      alternatives: data != null ? List<String>.from(data['alternatives'] ?? []) : null,
      alternativeWeights: data != null && data['alternative_weights'] != null
          ? Map<String, List<double>>.from(
              data['alternative_weights'].map(
                (k, v) => MapEntry(k, List<double>.from(v.map((x) => x.toDouble()))),
              ),
            )
          : null,
      globalScores: data != null && data['global_scores'] != null
          ? List<double>.from(data['global_scores'].map((x) => x.toDouble()))
          : null,
      ranking: data != null ? List<String>.from(data['ranking'] ?? []) : null,
      rankedScores: data != null && data['ranked_scores'] != null
          ? List<double>.from(data['ranked_scores'].map((x) => x.toDouble()))
          : null,
      isConsistent: data != null ? data['is_consistent'] as bool? : null,
      recommendation: data?['recommendation'],
    );
  }

  bool get isSuccess => status == 'success';
}
