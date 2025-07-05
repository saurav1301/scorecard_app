class ScoreEntry {
  final String parameter;
  final dynamic score; // Can be int or List<int>
  final String? remark;

  ScoreEntry({required this.parameter, required this.score, this.remark});

  Map<String, dynamic> toJson() => {
    'parameter': parameter,
    'score': score,
    'remark': remark,
  };

  factory ScoreEntry.fromJson(Map<String, dynamic> json) {
    return ScoreEntry(
      parameter: json['parameter'],
      score: json['score'],
      remark: json['remark'],
    );
  }
}
