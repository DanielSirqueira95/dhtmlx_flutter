import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class GanttModel {
  final int id;
  final String text;
  final DateTime startDate;
  final DateTime endDate;
  final int duration;
  final double progress;
  final int parent;

  const GanttModel({
    required this.id,
    required this.text,
    required this.startDate,
    required this.endDate,
    required this.duration,
    required this.progress,
    required this.parent,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'text': text,
      'start_date': startDate.toString(),
      'end_date': endDate.toString(),
      'duration': duration,
      'progress': progress,
      'parent': parent,
    };
  }

  factory GanttModel.fromMap(Map<String, dynamic> map) {
    return GanttModel(
      id: map['id'],
      text: map['text'] as String,
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),
      duration: map['duration'],
      progress: double.parse(map['progress'].toString()),
      parent: map['parent'],
    );
  }

  String toJson() => json.encode(toMap());

  factory GanttModel.fromJson(String source) =>
      GanttModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
