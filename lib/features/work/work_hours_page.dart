import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../jobs/jobs_data.dart';
import 'hours_editor_page.dart';

class WorkHoursPage extends StatelessWidget {
  const WorkHoursPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("No user logged in")),
      );
    }

    final jobsStream = FirebaseFirestore.instance
        .collection('jobs')
        .where('takenBy', isEqualTo: user.uid)
        .where('status', isEqualTo: 'taken')
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
                    "Work Hours",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                "Select a job to enter your hours.",
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 18),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: jobsStream,
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
                          "No open shift.\nConfirm a job first to enter hours.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      );
                    }

                    final jobs = docs
                        .map((d) => JobItem.fromFirestore(
                      d.id,
                      d.data() as Map<String, dynamic>,
                    ))
                        .toList();

                    return ListView.separated(
                      itemCount: jobs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final job = jobs[index];

                        final hoursDocStream = FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .collection('workHours')
                            .doc(job.id)
                            .snapshots();

                        return StreamBuilder<DocumentSnapshot>(
                          stream: hoursDocStream,
                          builder: (context, hSnap) {
                            final hasHours = (hSnap.data?.exists ?? false);

                            String subtitle = "${job.location} • ${job.type}";
                            if (hasHours) {
                              final data = hSnap.data!.data() as Map<String, dynamic>;
                              final total = (data['totalHours'] ?? 0).toString();
                              subtitle = "$subtitle • $total h saved";
                            }

                            return InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => HoursEditorPage(job: job),
                                  ),
                                );
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
                                    const Icon(Icons.work_outline,
                                        size: 40, color: Color(0xFF1D4ED8)),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            job.title,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            subtitle,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      hasHours ? Icons.edit : Icons.add_circle_outline,
                                      color: hasHours ? const Color(0xFF059669) : Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
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
