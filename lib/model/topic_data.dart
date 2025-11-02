import 'package:learning_cyber_security/model/subtopic_data.dart';

class TopicData {
  final String collectionName;
  final List<SubtopicData> documents;

  TopicData({
    required this.collectionName,
    required this.documents,
  });
}