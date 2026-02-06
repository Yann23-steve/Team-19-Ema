import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../jobs/jobs_data.dart';
import 'hours_editor_page.dart';

class CompletedShiftsPage extends StatelessWidget {
  const CompletedShiftsPage({super.key});

  String _fmtDate(dynamic ts) {
    if (ts is! Timestamp) return "—";
    final d = ts.toDate();
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = d.year.toString();
    return "$dd/$mm/$yy";
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("No user logged in")));
    }

    final stream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('workHours')
        .orderBy('updatedAt', descending: true)
        .snapshots();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    "Work hours & salary",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                "Your saved work hour entries (you can edit anytime).",
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 18),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: stream,
                  builder: (context, snap) {
                    if (snap.hasError) {
                      return Center(
                        child: Text(
                          "Error:\n${snap.error}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snap.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Center(
                        child: Text(
                          "No hours saved yet.\nGo to Work Hours to add hours.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      );
                    }

                    double totalAll = 0.0;
                    double earningsAll = 0.0;

                    for (final d in docs) {
                      final data = d.data() as Map<String, dynamic>;
                      final th = (data['totalHours'] ?? 0);
                      final ee = (data['estimatedEarnings'] ?? 0);
                      totalAll += (th is num) ? th.toDouble() : 0.0;
                      earningsAll += (ee is num) ? ee.toDouble() : 0.0;
                    }

                    return Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F6FA),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.summarize, color: Color(0xFF059669)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Total: ${totalAll.toStringAsFixed(1)} h",
                                  style: const TextStyle(fontWeight: FontWeight.w900),
                                ),
                              ),
                              Text(
                                earningsAll > 0 ? "${earningsAll.toStringAsFixed(2)} €" : "—",
                                style: const TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        Expanded(
                          child: ListView.separated(
                            itemCount: docs.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final doc = docs[index];
                              final data = doc.data() as Map<String, dynamic>;

                              final title = (data['jobTitle'] ?? 'Job').toString();
                              final start = _fmtDate(data['startDate']);
                              final end = _fmtDate(data['endDate']);

                              final totalHours = data['totalHours'];
                              final th = (totalHours is num) ? totalHours.toDouble() : 0.0;

                              final estimated = data['estimatedEarnings'];
                              final ee = (estimated is num) ? estimated.toDouble() : 0.0;

                              return InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () async {
                                  final jobSnap = await FirebaseFirestore.instance
                                      .collection('jobs')
                                      .doc(doc.id)
                                      .get();

                                  if (!jobSnap.exists) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Job document not found (deleted)."),
                                        ),
                                      );
                                    }
                                    return;
                                  }

                                  final job = JobItem.fromFirestore(
                                    jobSnap.id,
                                    jobSnap.data() as Map<String, dynamic>,
                                  );

                                  if (context.mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => HoursEditorPage(job: job),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.access_time, color: Color(0xFF059669)),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              title,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              "$start → $end",
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "${th.toStringAsFixed(1)} h",
                                            style: const TextStyle(fontWeight: FontWeight.w900),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            ee > 0 ? "${ee.toStringAsFixed(2)} €" : "—",
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
