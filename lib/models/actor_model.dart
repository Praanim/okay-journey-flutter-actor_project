import 'dart:convert';

class ActorModel {
  final String docId;
  final String name;
  final String imageUrl;
  ActorModel({
    required this.docId,
    required this.name,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'docId': docId,
      'name': name,
      'imageUrl': imageUrl,
    };
  }

  factory ActorModel.fromMap(Map<String, dynamic> map) {
    return ActorModel(
      docId: map['docId'] ?? '',
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}
