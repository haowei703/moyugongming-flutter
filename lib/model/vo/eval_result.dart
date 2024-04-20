class EvalResult {
  // 建议评分
  final double suggestedScore;
  // 整体流畅度
  final double pronAccuracy;
  // 整体流畅对度
  final double pronFluency;
  final List<Word> words;
  const EvalResult(
      {required this.suggestedScore,
      required this.pronAccuracy,
      required this.pronFluency,
      required this.words});

  factory EvalResult.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('SuggestedScore') ||
        !json.containsKey('PronAccuracy') ||
        !json.containsKey('PronFluency') ||
        !json.containsKey('Words')) {
      throw const FormatException('Invalid JSON format for EvalResult');
    }

    List<Word> words = [];
    if (json['Words'] is List<dynamic>) {
      words = (json['Words'] as List<dynamic>)
          .map((wordJson) => Word.fromJson(wordJson))
          .toList();
    }
    return EvalResult(
        suggestedScore: json['SuggestedScore'],
        pronAccuracy: json['PronAccuracy'],
        pronFluency: json['PronFluency'],
        words: words);
  }
}

class Word {
  // 单词精准度
  final double pronAccuracy;
  // 单词流利度
  final double pronFluency;
  // 音素精准度
  final double phoneInfos;

  const Word(
      {required this.pronAccuracy,
      required this.pronFluency,
      required this.phoneInfos});

  factory Word.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('PronAccuracy') ||
        !json.containsKey('PronFluency') ||
        !json.containsKey('PhoneInfos')) {
      throw const FormatException('Invalid JSON format for Word');
    }

    return Word(
        pronAccuracy: json['PronAccuracy'],
        pronFluency: json['PronFluency'],
        phoneInfos: json['PhoneInfos']);
  }
}
