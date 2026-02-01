import 'package:flutter/material.dart';
import 'jobs_data.dart';
import '../work/work_store.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  final TextEditingController _searchController = TextEditingController();
  late List<JobItem> _filteredJobs;

  @override
  void initState() {
    super.initState();
    _filteredJobs = jobsList; // au début on affiche tout
  }

  void _filterJobs(String query) {
    setState(() {
      final input = query.trim().toLowerCase();

      if (input.isEmpty) {
        _filteredJobs = jobsList;
        return;
      }

      _filteredJobs = jobsList.where((job) {
        final title = job.title.toLowerCase();
        final location = job.location.toLowerCase();
        final type = job.type.toLowerCase();

        return title.contains(input) ||
            location.contains(input) ||
            type.contains(input);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _jobCard(JobItem job) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        addToAssignments(job);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${job.title} added to My Shifts"),
            duration: const Duration(seconds: 2),
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
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: job.iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(job.icon, color: job.iconColor),
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
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header JobSuche
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

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              Text(
                'Find a Job',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              Text(
                'Search and browse available jobs',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 55,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF1D4ED8),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterJobs,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search a job title...",
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Expanded(
            child: _filteredJobs.isEmpty
                ? const Center(
              child: Text(
                "No jobs found",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
                : ListView.builder(
              itemCount: _filteredJobs.length,
              itemBuilder: (context, index) {
                final job = _filteredJobs[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _jobCard(job),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
