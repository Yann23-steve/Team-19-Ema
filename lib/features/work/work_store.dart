import 'package:flutter/material.dart';
import '../jobs/jobs_data.dart';

/// ✅ My Shifts = jobs sélectionnés (à faire)
ValueNotifier<List<JobItem>> myAssignments = ValueNotifier<List<JobItem>>([]);

/// ✅ My Work Hours = jobs terminés (plus tard)
ValueNotifier<List<JobItem>> myWorkHours = ValueNotifier<List<JobItem>>([]);

void addToAssignments(JobItem job) {
  final current = List<JobItem>.from(myAssignments.value);

  final exists = current.any((j) =>
  j.title == job.title && j.location == job.location && j.type == job.type);

  if (!exists) {
    current.add(job);
    myAssignments.value = current;
  }
}

void removeFromAssignments(JobItem job) {
  final current = List<JobItem>.from(myAssignments.value);
  current.removeWhere((j) =>
  j.title == job.title && j.location == job.location && j.type == job.type);
  myAssignments.value = current;
}

/// (Optionnel pour plus tard) déplacer un job vers Work Hours
void markAsCompleted(JobItem job) {
  removeFromAssignments(job);

  final done = List<JobItem>.from(myWorkHours.value);
  final exists = done.any((j) =>
  j.title == job.title && j.location == job.location && j.type == job.type);

  if (!exists) {
    done.add(job);
    myWorkHours.value = done;
  }
}
