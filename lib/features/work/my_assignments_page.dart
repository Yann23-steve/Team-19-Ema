import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../jobs/jobs_data.dart';
import '../jobs/job_details_page.dart';

class MyAssignmentsPage extends StatelessWidget {
  const MyAssignmentsPage({super.key});

  Future<void> _cancelJob(
      BuildContext context,
      String jobId,
      ) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final jobRef =
    FirebaseFirestore.instance.collection('jobs').doc(jobId);
    final assignmentRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('assignments')
        .doc(jobId);

    try {
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final jobSnap = await tx.get(jobRef);
        if (!jobSnap.exists) {
          throw Exception("Job not found");
        }

        tx.update(jobRef, {
          'status': 'open',
          'takenBy': null,
          'takenAt': null,
        });

        tx.delete(assignmentRef);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Shift cancelled")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not cancel shift")),
      );
    }
  }

  Widget _jobCard(BuildContext context, JobItem job) {
    return Container(
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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF3FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.work_outline,
              color: Color(0xFF1D4ED8),
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${job.location} • ${job.type}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(Icons.close, color: Colors.redAccent),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Cancel shift"),
                  content: const Text(
                    "Are you sure you want to cancel this shift?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("No"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _cancelJob(context, job.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      child: const Text("Yes, cancel"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text("Not logged in")),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Header =====
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    "My Shifts",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .collection('assignments')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final docs = snapshot.data!.docs;

                    if (docs.isEmpty) {
                      return const Center(
                        child: Text(
                          "No shifts yet.\nGo to Jobs and apply for one!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    final jobs = docs.map((d) {
                      return JobItem.fromFirestore(
                        d.id,
                        d.data() as Map<String, dynamic>,
                      );
                    }).toList();

                    return ListView.separated(
                      itemCount: jobs.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _jobCard(context, jobs[index]);
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
