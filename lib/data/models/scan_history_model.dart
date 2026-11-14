class ScanHistory {
  final String id;
  final String userId;
  final String? imageUrl;
  final String plantType;
  final String disease;
  final double confidence;
  final String severity;
  final String? description;
  final String? recommendation;
  final String? prevention;
  final DateTime createdAt;

  ScanHistory({
    required this.id,
    required this.userId,
    this.imageUrl,
    required this.plantType,
    required this.disease,
    required this.confidence,
    required this.severity,
    this.description,
    this.recommendation,
    this.prevention,
    required this.createdAt,
  });

  bool get isHealthy {
    final d = disease.toLowerCase();
    return d == 'sehat' || d.contains('healthy');
  }

  factory ScanHistory.fromJson(Map<String, dynamic> json) {
    return ScanHistory(
      id: json['id'].toString(),
      userId: json['user_id'] ?? '',
      imageUrl: json['image_url'],
      plantType: json['plant_type'] ?? 'Tanaman',
      disease: json['disease'] ?? 'Tidak diketahui',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      severity: json['severity'] ?? '-',
      description: json['description'],
      recommendation: json['recommendation'],
      prevention: json['prevention'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'image_url': imageUrl,
        'plant_type': plantType,
        'disease': disease,
        'confidence': confidence,
        'severity': severity,
        'description': description,
        'recommendation': recommendation,
        'prevention': prevention,
        'created_at': createdAt.toIso8601String(),
      };
}
