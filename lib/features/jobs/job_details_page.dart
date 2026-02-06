import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'jobs_data.dart';

class JobDetailsPage extends StatelessWidget {
  final JobItem job;
  const JobDetailsPage({super.key, required this.job});

  Future<void> _confirmJob(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final ref = FirebaseFirestore.instance.collection('jobs').doc(job.id);

      // ✅ re-check serveur
      final snap = await ref.get();
      final data = snap.data() as Map<String, dynamic>?;

      final status = (data?['status'] ?? 'open').toString().toLowerCase();
      final takenBy =
      data?['takenBy'] == null ? null : data?['takenBy'].toString();

      // déjà pris
      if (status == 'taken') {
        if (context.mounted) {
          if (takenBy == user.uid) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("You already confirmed this job ✅")),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("This job is no longer available.")),
            );
          }
        }
        return;
      }

      await ref.update({
        'status': 'taken',
        'takenBy': user.uid,
        'takenAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Job confirmed ✅")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  Future<void> _cancelJob(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Cancel this job?"),
        content: const Text(
          "Are you sure you want to cancel? The job will become available again for everyone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes, cancel"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final ref = FirebaseFirestore.instance.collection('jobs').doc(job.id);

      // ✅ re-check serveur + sécuriser: seulement si c'est toi
      final snap = await ref.get();
      final data = snap.data() as Map<String, dynamic>?;

      final status = (data?['status'] ?? 'open').toString().toLowerCase();
      final takenBy =
      data?['takenBy'] == null ? null : data?['takenBy'].toString();

      if (status != 'taken' || takenBy != user.uid) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("You can't cancel this job.")),
          );
        }
        return;
      }

      // ✅ remettre en open
      await ref.update({
        'status': 'open',
        'takenBy': FieldValue.delete(),
        'takenAt': FieldValue.delete(),
      });

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Job cancelled ✅ Now available again.")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final status = job.status.toLowerCase();
    final isTaken = status == "taken";
    final isMine =
        user != null && job.takenBy != null && job.takenBy == user.uid;

    // ✅ logique bouton
    final bool canConfirm = !isTaken;
    final bool canCancel = isTaken && isMine;
    final bool takenByOther = isTaken && !isMine;

    String buttonText;
    VoidCallback? onPressed;
    Color buttonColor;

    if (canConfirm) {
      buttonText = "Confirm / Apply";
      onPressed = () => _confirmJob(context);
      buttonColor = const Color(0xFF34D399);
    } else if (canCancel) {
      buttonText = "Cancel job";
      onPressed = () => _cancelJob(context);
      buttonColor = const Color(0xFFEF4444); // rouge
    } else {
      buttonText = "Not available";
      onPressed = null;
      buttonColor = Colors.grey;
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header back
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                ],
              ),

              Text(
                job.title.isEmpty ? "Job" : job.title,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),

              Text(
                "${job.location} • ${job.type}",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 18),

              // Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.schedule,
                      label: "Hours / week",
                      value: job.hoursPerWeek.isEmpty ? "—" : job.hoursPerWeek,
                    ),
                    const SizedBox(height: 10),
                    _InfoRow(
                      icon: Icons.payments_outlined,
                      label: "Monthly salary",
                      value:
                      job.salaryPerMonth.isEmpty ? "—" : job.salaryPerMonth,
                    ),
                    const SizedBox(height: 10),
                    _InfoRow(
                      icon: Icons.price_change_outlined,
                      label: "Hourly salary",
                      value: job.salaryPerHour.isEmpty ? "—" : job.salaryPerHour,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              Text(
                job.descriptionTitle.isEmpty ? "Description" : job.descriptionTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                job.description.isEmpty
                    ? "No description available."
                    : job.description,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                "Your Tasks",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              if (job.tasks.isEmpty)
                const Text("—", style: TextStyle(color: Colors.grey))
              else
                ...job.tasks.map((t) => _Bullet(t)),

              const SizedBox(height: 22),

              const Text(
                "Your Skills",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              if (job.skills.isEmpty)
                const Text("—", style: TextStyle(color: Colors.grey))
              else
                ...job.skills.map((s) => _Bullet(s)),

              const SizedBox(height: 22),

              const Text(
                "Required Language",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                job.language.isEmpty ? "—" : job.language,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 30),

              if (takenByOther)
                const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                    "This job has been taken by another user.",
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                  ),
                ),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1D4ED8)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Icon(Icons.circle, size: 8, color: Colors.black54),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
