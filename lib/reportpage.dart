import 'package:flutter/material.dart';

class ReportHeader extends StatelessWidget {
  final String universityName;
  final String facultyName;
  final String programName;

  const ReportHeader({
    Key? key,
    this.universityName = 'UNIVERSITAS INDONESIA',
    this.facultyName = 'FAKULTAS TEKNIK',
    this.programName = 'PROGRAM STUDI TEKNIK KOMPUTER',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          // Logo Universitas
          Image.asset(
            'assets/images/logo.png', // Pastikan logo sudah ditambahkan di pubspec.yaml
            height: 80,
          ),
          const SizedBox(height: 16),
          
          // Informasi Universitas
          Text(
            universityName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            facultyName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            programName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class ReportFooter extends StatelessWidget {
  final int pageNumber;
  final String year;

  const ReportFooter({
    Key? key,
    required this.pageNumber,
    this.year = '2025',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            year,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          Text(
            'Halaman $pageNumber',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// Contoh penggunaan dalam halaman laporan
class ReportPage extends StatelessWidget {
  final int pageNumber;
  final Widget content;

  const ReportPage({
    Key? key,
    required this.pageNumber,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ReportHeader(),
        Expanded(child: content),
        ReportFooter(pageNumber: pageNumber),
      ],
    );
  }
}