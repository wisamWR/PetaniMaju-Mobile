import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/services/supabase_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/models/calendar_event_model.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<CalendarEvent> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    final events = await SupabaseService().getCalendarEvents();
    if (mounted) {
      setState(() {
        _events = events;
        _isLoading = false;
      });
    }
  }

  List<CalendarEvent> _getEventsForDay(DateTime day) {
    return _events.where((event) => isSameDay(event.date, day)).toList();
  }

  void _showAddEventModal([CalendarEvent? eventToEdit]) {
    final titleController =
        TextEditingController(text: eventToEdit?.title ?? '');
    final notesController =
        TextEditingController(text: eventToEdit?.notes ?? '');
    String selectedType = eventToEdit?.type ?? 'Tanam';
    TimeOfDay? notificationTime; // New variable
    bool isEditing = eventToEdit != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isEditing ? "Edit Kegiatan" : "Tambah Kegiatan",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: "Nama Kegiatan",
                  hintText: "Contoh: Menanam Padi",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: "Catatan (Opsional)",
                  hintText: "Contoh: Menggunakan pupuk kompos...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                items: ['Tanam', 'Pupuk', 'Rawat', 'Panen', 'Lainnya']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => selectedType = val!,
                decoration: InputDecoration(
                  labelText: "Jenis Kegiatan",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),

              // Notification Time Picker
              StatefulBuilder(builder: (context, setStateModal) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!)),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications_outlined,
                          color: Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Waktu Pengingat",
                              style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w600)),
                          Text(
                            notificationTime == null
                                ? "Mengikuti Pengaturan (Default)"
                                : "Pukul ${notificationTime!.format(context)}",
                            style: GoogleFonts.inter(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      )),
                      TextButton(
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: notificationTime ??
                                const TimeOfDay(hour: 7, minute: 0),
                          );
                          if (picked != null) {
                            setStateModal(() => notificationTime = picked);
                          }
                        },
                        child: const Text("Ubah"),
                      ),
                      if (notificationTime != null)
                        IconButton(
                          icon: const Icon(Icons.close,
                              size: 20, color: Colors.red),
                          onPressed: () =>
                              setStateModal(() => notificationTime = null),
                          tooltip: "Gunakan Default",
                        )
                    ],
                  ),
                );
              }),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.isNotEmpty) {
                      final notes = notesController.text.isEmpty
                          ? null
                          : notesController.text;

                      // Merge Date and Time
                      final baseDate = _selectedDay ?? DateTime.now();
                      final time = notificationTime ??
                          const TimeOfDay(hour: 7, minute: 0);
                      final eventDateTime = DateTime(
                        baseDate.year,
                        baseDate.month,
                        baseDate.day,
                        time.hour,
                        time.minute,
                      );

                      // Ensure permissions are requested if they set a time
                      if (notificationTime != null) {
                        await NotificationService().requestPermissions();
                      }

                      if (isEditing) {
                        await SupabaseService().updateCalendarEvent(
                          id: eventToEdit!.id,
                          title: titleController.text,
                          type: selectedType,
                          notes: notes,
                        );
                      } else {
                        await SupabaseService().createCalendarEvent(
                          title: titleController.text,
                          date: eventDateTime, // Use combined DateTime
                          type: selectedType,
                          notes: notes,
                          notificationTime: notificationTime,
                        );
                      }
                      if (mounted) Navigator.pop(context);
                      _loadEvents();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF166534),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      Text(isEditing ? "Simpan Perubahan" : "Simpan Kegiatan"),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Jadwal Tanam",
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEventModal(),
        backgroundColor: const Color(0xFF166534),
        icon: const Icon(Icons.add_task, color: Colors.white),
        label: Text("Tambah",
            style: GoogleFonts.plusJakartaSans(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildCalendar(),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: _buildEventList(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      locale: 'id_ID',
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      daysOfWeekHeight: 50, // Added height ensuring text is not clipped
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      eventLoader: _getEventsForDay,
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        weekendStyle:
            GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.red),
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
            color: const Color(0xFF166534).withOpacity(0.5),
            shape: BoxShape.circle),
        selectedDecoration: const BoxDecoration(
            color: Color(0xFF166534), shape: BoxShape.circle),
        markerDecoration:
            const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
        outsideDaysVisible: false,
      ),
      headerStyle: HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
            fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEventList() {
    final dailyEvents = _getEventsForDay(_selectedDay!);

    if (dailyEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              "Tidak ada kegiatan",
              style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: dailyEvents.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final event = dailyEvents[index];
        return Dismissible(
          key: Key(event.id.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) async {
            await SupabaseService().deleteCalendarEvent(event.id);
            _loadEvents();
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              onTap: () => _showAddEventModal(event),
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getColorType(event.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getIconType(event.type),
                    color: _getColorType(event.type)),
              ),
              title: Text(
                event.title,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          event.type,
                          style: GoogleFonts.inter(
                              fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('HH:mm').format(event.date),
                        style: GoogleFonts.inter(fontSize: 12),
                      ),
                    ],
                  ),
                  if (event.notes != null && event.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber[100]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.sticky_note_2,
                              size: 14, color: Colors.amber),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              event.notes!,
                              style: GoogleFonts.inter(
                                  fontSize: 12, color: Colors.black87),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              trailing: const Icon(Icons.edit, color: Colors.grey, size: 20),
            ),
          ),
        );
      },
    );
  }

  Color _getColorType(String type) {
    switch (type) {
      case 'Tanam':
        return Colors.green;
      case 'Pupuk':
        return Colors.brown;
      case 'Panen':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  IconData _getIconType(String type) {
    switch (type) {
      case 'Tanam':
        return Icons.grass;
      case 'Pupuk':
        return Icons.science;
      case 'Panen':
        return Icons.agriculture;
      default:
        return Icons.task_alt;
    }
  }
}
