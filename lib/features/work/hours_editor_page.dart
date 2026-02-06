import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../jobs/jobs_data.dart';

class HoursEditorPage extends StatefulWidget {
  final JobItem job;
  const HoursEditorPage({super.key, required this.job});

  @override
  State<HoursEditorPage> createState() => _HoursEditorPageState();
}

class _HoursEditorPageState extends State<HoursEditorPage> {
  DateTime? _start;
  DateTime? _end;
  final TextEditingController _hoursPerDay = TextEditingController(text: "8");

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  @override
  void dispose() {
    _hoursPerDay.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('workHours')
        .doc(widget.job.id);

    final snap = await ref.get();
    if (snap.exists) {
      final data = snap.data() as Map<String, dynamic>;
      final s = data['startDate'];
      final e = data['endDate'];
      final h = data['hoursPerDay'];

      if (s is Timestamp) _start = s.toDate();
      if (e is Timestamp) _end = e.toDate();
      if (h != null) _hoursPerDay.text = h.toString();
    }

    if (mounted) setState(() => _loading = false);
  }

  int _countWeekdaysInclusive(DateTime start, DateTime end) {
    // inclusif: start..end
    int count = 0;
    DateTime d = DateTime(start.year, start.month, start.day);
    final last = DateTime(end.year, end.month, end.day);

    while (!d.isAfter(last)) {
      final wd = d.weekday; // 1=Mon ... 7=Sun
      if (wd >= DateTime.monday && wd <= DateTime.friday) {
        count++;
      }
      d = d.add(const Duration(days: 1));
    }
    return count;
  }

  double _parseHoursPerDay() {
    final raw = _hoursPerDay.text.trim().replaceAll(',', '.');
    final v = double.tryParse(raw);
    return v == null ? 0.0 : v;
  }

  double _parseSalaryPerHour(String raw) {
    // "15.50 € / hour" -> 15.50
    final cleaned = raw.replaceAll(RegExp(r'[^0-9.,]'), '').replaceAll(',', '.');
    return double.tryParse(cleaned) ?? 0.0;
  }

  String _fmt(DateTime? d) {
    if (d == null) return "—";
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = d.year.toString();
    return "$dd/$mm/$yy";
  }

  Future<DateTime?> _pickDate(DateTime? current) async {
    final now = DateTime.now();
    final initial = current ?? DateTime(now.year, now.month, now.day);

    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
    );
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_start == null || _end == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Choose a start and end date.")),
      );
      return;
    }
    if (_end!.isBefore(_start!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("End date must be after start date.")),
      );
      return;
    }

    final hoursPerDay = _parseHoursPerDay();
    if (hoursPerDay <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hours per day must be > 0.")),
      );
      return;
    }

    final weekdays = _countWeekdaysInclusive(_start!, _end!);
    final totalHours = weekdays * hoursPerDay;

    final salaryPerHour = _parseSalaryPerHour(widget.job.salaryPerHour);
    final estimated = salaryPerHour <= 0 ? 0.0 : (totalHours * salaryPerHour);

    setState(() => _saving = true);

    try {
      final ref = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('workHours')
          .doc(widget.job.id);

      await ref.set({
        'jobId': widget.job.id,
        'jobTitle': widget.job.title,
        'startDate': Timestamp.fromDate(DateTime(_start!.year, _start!.month, _start!.day)),
        'endDate': Timestamp.fromDate(DateTime(_end!.year, _end!.month, _end!.day)),
        'hoursPerDay': hoursPerDay,
        'weekdays': weekdays,
        'totalHours': totalHours,
        'salaryPerHourRaw': widget.job.salaryPerHour,
        'estimatedEarnings': estimated,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Hours saved ✅")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete hours?"),
        content: const Text("Do you really want to delete these hours?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
        ],
      ),
    );

    if (ok != true) return;

    try {
      final ref = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('workHours')
          .doc(widget.job.id);

      await ref.delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Deleted ✅")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hoursPerDay = _parseHoursPerDay();
    final canCalc = _start != null && _end != null && !_end!.isBefore(_start!) && hoursPerDay > 0;

    final weekdays = canCalc ? _countWeekdaysInclusive(_start!, _end!) : 0;
    final totalHours = canCalc ? weekdays * hoursPerDay : 0.0;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
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
                    "Enter hours",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Text(
                widget.job.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                "${widget.job.location} • ${widget.job.type}",
                style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 18),

              _FieldCard(
                child: Column(
                  children: [
                    _PickRow(
                      label: "Start date",
                      value: _fmt(_start),
                      onTap: () async {
                        final d = await _pickDate(_start);
                        if (d != null) setState(() => _start = d);
                      },
                    ),
                    const SizedBox(height: 10),
                    _PickRow(
                      label: "End date",
                      value: _fmt(_end),
                      onTap: () async {
                        final d = await _pickDate(_end);
                        if (d != null) setState(() => _end = d);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _hoursPerDay,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: "Hours per day (Mon-Fri)",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              _FieldCard(
                child: Row(
                  children: [
                    const Icon(Icons.calculate, color: Color(0xFF059669)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        canCalc
                            ? "Weekdays: $weekdays  •  Total: ${totalHours.toStringAsFixed(1)} h"
                            : "Fill dates and hours to calculate",
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _delete,
                      child: const Text("Delete"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF34D399),
                        foregroundColor: const Color(0xFF0F172A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(_saving ? "Saving..." : "Save"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldCard extends StatelessWidget {
  final Widget child;
  const _FieldCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _PickRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _PickRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              value,
              style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.calendar_month, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
