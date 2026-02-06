import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../jobs/jobs_data.dart';
import '../jobs/job_details_page.dart';

class HomePage extends StatefulWidget {
  final void Function(int) onTapeChange;
  const HomePage({super.key, required this.onTapeChange});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<_GreetingData>? _greetingFuture;

  @override
  void initState() {
    super.initState();
    _greetingFuture = _loadGreeting();
  }

  Future<_GreetingData> _loadGreeting() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const _GreetingData(firstName: "", isFirstLogin: false);
    }

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    // petit helper pour récupérer un prénom par défaut
    String fallbackFirstName() {
      final dn = (user.displayName ?? '').trim();
      if (dn.isNotEmpty) {
        // prend le 1er mot du displayName
        final parts = dn.split(RegExp(r'\s+'));
        return parts.first;
      }
      final email = (user.email ?? '').trim();
      if (email.contains('@')) return email.split('@').first;
      return "there";
    }

    final result = await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(userRef);

      if (!snap.exists) {
        final firstName = fallbackFirstName();
        tx.set(userRef, {
          'firstName': firstName,
          'loginCount': 1,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
        return _GreetingData(firstName: firstName, isFirstLogin: true);
      }

      final data = snap.data() as Map<String, dynamic>;
      final firstName =
      (data['firstName'] ?? '').toString().trim().isNotEmpty
          ? data['firstName'].toString().trim()
          : fallbackFirstName();

      final loginCount = (data['loginCount'] is int) ? data['loginCount'] as int : 0;
      final isFirst = loginCount <= 0;

      tx.set(
        userRef,
        {
          'firstName': firstName,
          'loginCount': loginCount + 1,
          'lastLoginAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      return _GreetingData(firstName: firstName, isFirstLogin: isFirst);
    });

    return result;
  }

  Query<Map<String, dynamic>> _recentJobsQuery(User user) {
    return FirebaseFirestore.instance
        .collection('jobs')
        .where('takenBy', isEqualTo: user.uid);
  }

  Widget _recentJobCard(BuildContext context, JobItem job) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => JobDetailsPage(job: job)),
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
                    job.title.isEmpty ? "Job" : job.title,
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
                  const SizedBox(height: 6),
                  _StatusChip(job: job),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ===== Header =====
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 70,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: const [
                      Text(
                        'Job',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4B6BFB),
                        ),
                      ),
                      Text(
                        'Suche',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          FutureBuilder<_GreetingData>(
            future: _greetingFuture,
            builder: (context, snap) {
              final firstName = snap.data?.firstName ?? "";
              final isFirst = snap.data?.isFirstLogin ?? false;

              final title = isFirst ? "Welcome" : "Welcome back";
              final namePart = firstName.trim().isEmpty ? "" : " $firstName";

              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "$title$namePart",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Ready to find your next Job?',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // ===== Buttons =====
          Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => widget.onTapeChange(1),
                  child: Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.search,
                            size: 32,
                            color: Color(0xFF1D4ED8),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Find a Job',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Browse available Jobs',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => widget.onTapeChange(2),
                  child: Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.work_outline,
                            size: 32,
                            color: Color(0xFF059669),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'My Work',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'See your current tasks',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),

          const SizedBox(height: 32),

          // ===== Recent Jobs =====
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              Text(
                "Recent Jobs",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: Builder(
              builder: (context) {
                if (user == null) {
                  return const Center(
                    child: Text(
                      "Please login to see your recent jobs.",
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _recentJobsQuery(user).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Error:\n${snapshot.error}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "No recent jobs yet.\nConfirm a job to see it here!",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton(
                              onPressed: () => widget.onTapeChange(1),
                              child: const Text("Go to Jobs"),
                            ),
                          ],
                        ),
                      );
                    }

                    final recent = docs.take(3).toList();

                    final jobs = recent
                        .map((d) => JobItem.fromFirestore(d.id, d.data()))
                        .toList();

                    return ListView.separated(
                      itemCount: jobs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _recentJobCard(context, jobs[index]);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GreetingData {
  final String firstName;
  final bool isFirstLogin;
  const _GreetingData({required this.firstName, required this.isFirstLogin});
}

class _StatusChip extends StatelessWidget {
  final JobItem job;
  const _StatusChip({required this.job});

  @override
  Widget build(BuildContext context) {
    final s = job.status.toLowerCase();
    final isCompleted = s == "completed";
    final label = isCompleted ? "Completed" : "In progress";

    final bg =
    isCompleted ? const Color(0xFFD1FAE5) : const Color(0xFFEFF3FF);

    final fg =
    isCompleted ? const Color(0xFF059669) : const Color(0xFF1D4ED8);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}
