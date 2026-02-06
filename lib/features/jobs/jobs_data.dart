import 'package:flutter/material.dart';

class JobItem {
  final String id;

  final String title;
  final String location;
  final String type;
  final String category;

  final String hoursPerWeek;
  final String salaryPerMonth;
  final String salaryPerHour;

  final String descriptionTitle;
  final String description;

  final List<String> tasks;
  final List<String> skills;

  final String language;

  // ✅ pour gérer confirm déjà fait
  final String status; // "open" / "taken"
  final String? takenBy; // uid ou null

  const JobItem({
    required this.id,
    required this.title,
    required this.location,
    required this.type,
    required this.category,
    required this.hoursPerWeek,
    required this.salaryPerMonth,
    required this.salaryPerHour,
    required this.descriptionTitle,
    required this.description,
    required this.tasks,
    required this.skills,
    required this.language,
    required this.status,
    required this.takenBy,
  });

  factory JobItem.fromFirestore(String id, Map<String, dynamic> data) {
    // ✅ convert array -> List<String>
    List<String> toStringList(dynamic v) {
      if (v is List) return v.map((e) => e.toString()).toList();
      return <String>[];
    }

    final rawStatus = (data['status'] ?? 'open').toString().trim().toLowerCase();

    return JobItem(
      id: id,
      title: (data['title'] ?? '').toString(),
      location: (data['location'] ?? '').toString(),
      type: (data['type'] ?? '').toString(),
      category: (data['category'] ?? '').toString(),

      // ✅ IMPORTANT: il faut que ce champ existe dans Firestore
      // Si tu n’as pas encore hoursPerWeek dans tes jobs Firestore, ajoute-le.
      hoursPerWeek: (data['hoursPerWeek'] ?? '').toString(),

      salaryPerMonth: (data['salaryPerMonth'] ?? '').toString(),
      salaryPerHour: (data['salaryPerHour'] ?? '').toString(),

      // ✅ corrige descriptionTitle (tu avais descriptionTittle au début)
      descriptionTitle: (data['descriptionTitle'] ?? data['descriptionTittle'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),

      // ✅ accepte "tasks" (recommandé) + fallback "task"
      tasks: toStringList(data['tasks'] ?? data['task']),
      // ✅ accepte "skills" (recommandé) + fallback "skill"
      skills: toStringList(data['skills'] ?? data['skill']),

      language: (data['language'] ?? '').toString(),

      // ✅ status normalisé
      status: (rawStatus == 'taken') ? 'taken' : 'open',

      takenBy: data['takenBy'] == null ? null : data['takenBy'].toString(),
    );
  }
}
