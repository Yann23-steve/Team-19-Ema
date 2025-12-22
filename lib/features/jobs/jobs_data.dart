import 'package:flutter/material.dart';

class JobItem {
  final String title;
  final String location;
  final String type; // Full-time / Part-time / Mini-Job etc.
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  // Details (pour la page job details)
  final String category;
  final String hoursPerWeek;
  final String salaryPerMonth;
  final String salaryPerHour;
  final String descriptionTitle;
  final String description;
  final List<String> tasks;
  final List<String> skills;
  final String language;

  const JobItem({
    required this.title,
    required this.location,
    required this.type,
    this.icon = Icons.work_outline,
    this.iconBg = const Color(0xFFEFF3FF),
    this.iconColor = const Color(0xFF1D4ED8),

    // details
    this.category = "Logistics Helper",
    this.hoursPerWeek = "15 - 25 h / week",
    this.salaryPerMonth = "990 - 1660 € / month (gross)",
    this.salaryPerHour = "15.50 € / hour",
    this.descriptionTitle = "We are hiring!",
    this.description =
    "You are looking for an exciting challenge? Join our team and support our daily operations.",
    this.tasks = const [
      "Picking and packing goods",
      "Stock checking and inventory control",
      "Loading and unloading delivery vehicles",
      "Ensuring quality standards",
      "Helping improve warehouse processes",
    ],
    this.skills = const [
      "Good communication",
      "Ability to do physical work",
      "Safety shoes required",
      "Team spirit and quick learning",
      "Warehouse experience is a plus",
    ],
    this.language = "English: Intermediate (B1)",
  });
}

// ✅ ICI tu ajoutes / modifies les jobs (c’est tout)
const List<JobItem> jobsList = [
  JobItem(
    title: "Frontend Developer",
    location: "Berlin",
    type: "Full-time",
    category: "IT / Software",
    hoursPerWeek: "40 h / week",
    salaryPerMonth: "3500 - 5000 € / month (gross)",
    salaryPerHour: "—",
    descriptionTitle: "Frontend Developer needed!",
    description:
    "Build modern interfaces, improve UX and work closely with product teams.",
    tasks: [
      "Create Flutter UI screens",
      "Work with APIs",
      "Fix bugs and improve performance",
      "Write clean reusable code",
      "Collaborate with designers",
    ],
    skills: [
      "Flutter / Dart",
      "REST APIs",
      "UI/UX basics",
      "Teamwork",
      "Git",
    ],
    language: "English: Intermediate (B1)",
  ),
  JobItem(
    title: "Driver",
    location: "Mannheim",
    type: "Part-time",
    iconBg: Color(0xFFF1FDF7),
    iconColor: Color(0xFF059669),
    category: "Transport",
    hoursPerWeek: "20 h / week",
    salaryPerMonth: "900 - 1400 € / month (gross)",
    salaryPerHour: "13.00 € / hour",
    descriptionTitle: "Driver wanted!",
    description:
    "Deliver goods safely and on time. Friendly attitude with customers.",
    tasks: [
      "Deliver packages",
      "Plan route efficiently",
      "Keep vehicle clean",
      "Follow safety rules",
      "Report issues",
    ],
    skills: [
      "Driving license",
      "Punctuality",
      "Customer friendly",
      "Good navigation",
      "Responsibility",
    ],
    language: "English: Basic (A2)",
  ),
  JobItem(
    title: "Web Security",
    location: "Ludwigshafen",
    type: "Mini-Job",
    category: "Security / IT",
    hoursPerWeek: "10 h / week",
    salaryPerMonth: "450 € / month (gross)",
    salaryPerHour: "—",
    descriptionTitle: "Web Security support",
    description:
    "Support security checks and help improve web security practices.",
  ),
  JobItem(
    title: "UI/UX Designer",
    location: "Hamburg",
    type: "Internship",
    category: "Design",
    hoursPerWeek: "35 h / week",
    salaryPerMonth: "1200 € / month (gross)",
    salaryPerHour: "—",
    descriptionTitle: "UI/UX Internship",
    description:
    "Design clean interfaces and improve the user experience across the app.",
  ),
];
