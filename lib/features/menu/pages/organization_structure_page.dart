import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class OrganizationStructurePage extends StatelessWidget {
  const OrganizationStructurePage({super.key});

  static const String routeName = '/organization-structure';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFF),
      appBar: AppBar(
        title: const Text(
          'Struktur Organisasi',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFDDE7F5)),
              ),
              child: const Row(
                children: [
                  Icon(PhosphorIconsFill.gitBranch, size: 18, color: Color(0xFF156DFF)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Data dummy untuk preview UI struktur organisasi.',
                      style: TextStyle(
                        color: Color(0xFF0F2A5F),
                        fontWeight: FontWeight.w600,
                        fontSize: 12.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 980,
                child: Column(
                  children: [
                    _OrgNodeCard(
                      name: 'Budi Santoso',
                      title: 'Director',
                      department: 'Executive',
                      initials: 'BS',
                      accent: const Color(0xFF1D4ED8),
                    ),
                    _vLine(),
                    _hLine(width: 620),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _managerBranch(
                          manager: const _OrgNodeCard(
                            name: 'Rina Prameswari',
                            title: 'HR Manager',
                            department: 'Human Resources',
                            initials: 'RP',
                            accent: Color(0xFF0EA5E9),
                          ),
                          members: const [
                            _OrgNodeCard(
                              name: 'Fajar Nugroho',
                              title: 'HR Officer',
                              department: 'People Ops',
                              initials: 'FN',
                              accent: Color(0xFF38BDF8),
                            ),
                            _OrgNodeCard(
                              name: 'Lia Aprilia',
                              title: 'Payroll Staff',
                              department: 'Comp & Benefit',
                              initials: 'LA',
                              accent: Color(0xFF38BDF8),
                            ),
                          ],
                        ),
                        _managerBranch(
                          manager: const _OrgNodeCard(
                            name: 'Andi Saputra',
                            title: 'GA Manager',
                            department: 'General Affairs',
                            initials: 'AS',
                            accent: Color(0xFF0284C7),
                          ),
                          members: const [
                            _OrgNodeCard(
                              name: 'Rizka Amelia',
                              title: 'GA Supervisor',
                              department: 'Facility',
                              initials: 'RA',
                              accent: Color(0xFF22D3EE),
                            ),
                            _OrgNodeCard(
                              name: 'Deni Wibowo',
                              title: 'Logistic Staff',
                              department: 'Support',
                              initials: 'DW',
                              accent: Color(0xFF22D3EE),
                            ),
                          ],
                        ),
                        _managerBranch(
                          manager: const _OrgNodeCard(
                            name: 'Sinta Maharani',
                            title: 'Operations Manager',
                            department: 'Operations',
                            initials: 'SM',
                            accent: Color(0xFF2563EB),
                          ),
                          members: const [
                            _OrgNodeCard(
                              name: 'Yoga Prabowo',
                              title: 'Site Supervisor',
                              department: 'Field Ops',
                              initials: 'YP',
                              accent: Color(0xFF60A5FA),
                            ),
                            _OrgNodeCard(
                              name: 'Nanda Putri',
                              title: 'Admin Operasional',
                              department: 'Operations Support',
                              initials: 'NP',
                              accent: Color(0xFF60A5FA),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _managerBranch({
    required Widget manager,
    required List<Widget> members,
  }) {
    return SizedBox(
      width: 300,
      child: Column(
        children: [
          manager,
          _vLine(),
          _hLine(width: 230),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: members,
          ),
        ],
      ),
    );
  }

  Widget _vLine() {
    return Container(
      width: 2,
      height: 26,
      color: const Color(0xFFD4E2F2),
      margin: const EdgeInsets.symmetric(vertical: 6),
    );
  }

  Widget _hLine({required double width}) {
    return Container(
      width: width,
      height: 2,
      margin: const EdgeInsets.only(bottom: 10),
      color: const Color(0xFFD4E2F2),
    );
  }
}

class _OrgNodeCard extends StatelessWidget {
  const _OrgNodeCard({
    required this.name,
    required this.title,
    required this.department,
    required this.initials,
    required this.accent,
  });

  final String name;
  final String title;
  final String department;
  final String initials;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor: accent.withValues(alpha: 0.18),
            child: Text(
              initials,
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF061B49),
              fontSize: 12.4,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: accent,
              fontSize: 11.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            department,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF718096),
              fontSize: 10.8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
