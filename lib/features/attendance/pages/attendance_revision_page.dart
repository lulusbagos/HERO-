import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AttendanceRevisionPage extends StatefulWidget {
  const AttendanceRevisionPage({super.key});

  static const String routeName = '/attendance-revision';

  @override
  State<AttendanceRevisionPage> createState() => _AttendanceRevisionPageState();
}

class _AttendanceRevisionPageState extends State<AttendanceRevisionPage> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _detailController = TextEditingController();

  DateTime? _revisionDate;
  TimeOfDay? _revisionTime;
  String _revisionType = 'Check In';
  bool _isSubmitting = false;

  final List<_RevisionApprovalItem> _approvalItems = <_RevisionApprovalItem>[
    _RevisionApprovalItem(
      employeeName: 'Rifky Pratama',
      employeeId: 'EMP-00125',
      revisionDate: '29 Mei 2026',
      revisionTime: '08:17',
      reason: 'Terlambat scan karena device error saat masuk area kantor.',
      status: _RevisionStatus.pending,
    ),
    _RevisionApprovalItem(
      employeeName: 'Nadia Puspita',
      employeeId: 'EMP-00191',
      revisionDate: '28 Mei 2026',
      revisionTime: '17:11',
      reason: 'Sudah check out di lapangan, sinkronisasi jaringan terlambat.',
      status: _RevisionStatus.approved,
    ),
    _RevisionApprovalItem(
      employeeName: 'Sandi Kurniawan',
      employeeId: 'EMP-00088',
      revisionDate: '27 Mei 2026',
      revisionTime: '08:56',
      reason: 'Menghadiri emergency briefing sebelum sempat absen.',
      status: _RevisionStatus.rejected,
    ),
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final minDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7));
    final maxDate = DateTime(now.year, now.month, now.day);

    final result = await showDatePicker(
      context: context,
      initialDate: _revisionDate ?? maxDate,
      firstDate: minDate,
      lastDate: maxDate,
      helpText: 'Pilih Tanggal Revisi',
    );

    if (result != null) {
      setState(() => _revisionDate = result);
    }
  }

  Future<void> _pickTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: _revisionTime ?? TimeOfDay.now(),
      helpText: 'Pilih Jam Revisi',
    );

    if (result != null) {
      setState(() => _revisionTime = result);
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_revisionDate == null || _revisionTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal revisi dan jam revisi wajib dipilih.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) {
      return;
    }
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengajuan revisi berhasil dikirim ke atasan.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _updateApprovalStatus(int index, _RevisionStatus status) {
    setState(() {
      _approvalItems[index] = _approvalItems[index].copyWith(status: status);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6FAFF),
        appBar: AppBar(
          title: const Text(
            'Revisi Absen',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          bottom: TabBar(
            labelStyle: const TextStyle(fontWeight: FontWeight.w700),
            tabs: const [
              Tab(text: 'Pengajuan Revisi'),
              Tab(text: 'Approval Karyawan'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRequestTab(),
            _buildApprovalTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFDCEBFF)),
              ),
              child: const Row(
                children: [
                  Icon(PhosphorIconsFill.info, color: Color(0xFF156DFF), size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tanggal revisi hanya bisa dipilih dari 7 hari terakhir.',
                      style: TextStyle(
                        color: Color(0xFF0F3D8C),
                        fontSize: 12.8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _premiumFieldCard(
              child: DropdownButtonFormField<String>(
                initialValue: _revisionType,
                decoration: const InputDecoration(
                  labelText: 'Jenis Revisi',
                  border: InputBorder.none,
                ),
                items: const [
                  DropdownMenuItem(value: 'Check In', child: Text('Revisi Check In')),
                  DropdownMenuItem(value: 'Check Out', child: Text('Revisi Check Out')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _revisionType = value);
                  }
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _premiumPickerTile(
                    label: 'Tanggal Revisi',
                    value: _revisionDate == null
                        ? 'Pilih tanggal'
                        : '${_revisionDate!.day.toString().padLeft(2, '0')}/${_revisionDate!.month.toString().padLeft(2, '0')}/${_revisionDate!.year}',
                    icon: PhosphorIconsRegular.calendar,
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _premiumPickerTile(
                    label: 'Jam Revisi',
                    value: _revisionTime == null
                        ? 'Pilih jam'
                        : _revisionTime!.format(context),
                    icon: PhosphorIconsRegular.clock,
                    onTap: _pickTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _premiumFieldCard(
              child: TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Alasan Revisi',
                  hintText: 'Contoh: lupa check-in karena kendala aplikasi',
                  border: InputBorder.none,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Alasan revisi wajib diisi';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 10),
            _premiumFieldCard(
              child: TextFormField(
                controller: _detailController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Detail Pendukung',
                  hintText: 'Tambahkan detail kronologi atau data pendukung',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitRequest,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(PhosphorIconsFill.paperPlaneTilt, size: 18),
                label: Text(_isSubmitting ? 'Mengirim...' : 'Kirim Pengajuan ke Atasan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF156DFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalTab() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      itemCount: _approvalItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = _approvalItems[index];
        final pending = item.status == _RevisionStatus.pending;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _statusBorderColor(item.status)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x11061B49),
                blurRadius: 12,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF2FF),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(PhosphorIconsFill.user, color: Color(0xFF156DFF), size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.employeeName,
                          style: const TextStyle(
                            color: Color(0xFF061B49),
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
                          ),
                        ),
                        Text(
                          item.employeeId,
                          style: const TextStyle(
                            color: Color(0xFF718096),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _statusChip(item.status),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Tanggal: ${item.revisionDate}  •  Jam: ${item.revisionTime}',
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontWeight: FontWeight.w600,
                  fontSize: 12.8,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.reason,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              if (pending) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _updateApprovalStatus(index, _RevisionStatus.rejected),
                        icon: const Icon(PhosphorIconsBold.x, size: 16),
                        label: const Text('Tolak'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFDC2626),
                          side: const BorderSide(color: Color(0xFFFECACA)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _updateApprovalStatus(index, _RevisionStatus.approved),
                        icon: const Icon(PhosphorIconsBold.check, size: 16),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _premiumFieldCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: child,
    );
  }

  Widget _premiumPickerTile({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF718096),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                Icon(icon, color: const Color(0xFF156DFF), size: 17),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: Color(0xFF061B49),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusBorderColor(_RevisionStatus status) {
    switch (status) {
      case _RevisionStatus.pending:
        return const Color(0xFFFDE68A);
      case _RevisionStatus.approved:
        return const Color(0xFFBBF7D0);
      case _RevisionStatus.rejected:
        return const Color(0xFFFECACA);
    }
  }

  Widget _statusChip(_RevisionStatus status) {
    switch (status) {
      case _RevisionStatus.pending:
        return _chip('Menunggu', const Color(0xFF92400E), const Color(0xFFFEF3C7));
      case _RevisionStatus.approved:
        return _chip('Disetujui', const Color(0xFF166534), const Color(0xFFDCFCE7));
      case _RevisionStatus.rejected:
        return _chip('Ditolak', const Color(0xFF991B1B), const Color(0xFFFEE2E2));
    }
  }

  Widget _chip(String text, Color fg, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

enum _RevisionStatus { pending, approved, rejected }

class _RevisionApprovalItem {
  const _RevisionApprovalItem({
    required this.employeeName,
    required this.employeeId,
    required this.revisionDate,
    required this.revisionTime,
    required this.reason,
    required this.status,
  });

  final String employeeName;
  final String employeeId;
  final String revisionDate;
  final String revisionTime;
  final String reason;
  final _RevisionStatus status;

  _RevisionApprovalItem copyWith({
    _RevisionStatus? status,
  }) {
    return _RevisionApprovalItem(
      employeeName: employeeName,
      employeeId: employeeId,
      revisionDate: revisionDate,
      revisionTime: revisionTime,
      reason: reason,
      status: status ?? this.status,
    );
  }
}
