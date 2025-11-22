import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../data/timetable_repository.dart';
import '../../domain/entities/timetable.dart';
import '../../domain/entities/exam_item.dart';
import '../../domain/entities/campus_event.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage>
    with SingleTickerProviderStateMixin {
  final _repo = TimetableRepository();
  late final TabController _tabController;

  final _dateFmt = DateFormat('EEE d MMM yyyy');
  final _timeFmt = DateFormat('HH:mm');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My timetable'),
            Tab(text: 'Exams & deadlines'),
            Tab(text: 'Events'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyTimetableTab(),
          _buildExamsTab(),
          _buildEventsTab(),
        ],
      ),
    );
  }

  // 1) My timetable
  Widget _buildMyTimetableTab() {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      return const Center(
        child: Text('Please sign in to view your timetable.'),
      );
    }

    return FutureBuilder<MyTimetable?>(
      future: _repo.getTimetableForUser(firebaseUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final timetable = snapshot.data;
        if (timetable == null || timetable.imageUrl.isEmpty) {
          return const Center(
            child: Text('No timetable uploaded yet.'),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                timetable.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (timetable.updatedAt != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Updated: ${_dateFmt.format(timetable.updatedAt!)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 3 / 2,
                  child: Image.network(
                    timetable.imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (ctx, child, progress) {
                      if (progress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                    errorBuilder: (_, __, ___) =>
                        const Center(child: Icon(Icons.broken_image, size: 48)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 2) Exams & deadlines
  Widget _buildExamsTab() {
    return StreamBuilder<List<ExamItem>>(
      stream: _repo.watchExams(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return const Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data!;
        if (items.isEmpty) {
          return const Center(
            child: Text('No exam dates or deadlines yet.'),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final e = items[i];
            return Card(
              child: ListTile(
                leading: Icon(
                  e.type == 'deadline'
                      ? Icons.assignment_turned_in
                      : Icons.event,
                ),
                title: Text(e.title),
                subtitle: Text(
                  '${e.module} • ${_dateFmt.format(e.date)}  ${_timeFmt.format(e.date)}\n'
                  'Venue: ${e.venue}\n'
                  '${e.notes}',
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }

  // 3) Events tab
  Widget _buildEventsTab() {
    return StreamBuilder<List<CampusEvent>>(
      stream: _repo.watchUpcomingEvents(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return const Center(child: CircularProgressIndicator());
        }

        final events = snapshot.data!;
        if (events.isEmpty) {
          return const Center(
            child: Text('No upcoming events.'),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: events.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final ev = events[i];
            return Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () => _openEventDetails(ev),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (ev.imageUrl.isNotEmpty)
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          ev.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Center(child: Icon(Icons.broken_image)),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ev.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_dateFmt.format(ev.startTime)}  '
                            '${_timeFmt.format(ev.startTime)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ev.location,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openEventDetails(CampusEvent e) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (e.imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        e.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  e.title,
                  style: Theme.of(ctx).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '${_dateFmt.format(e.startTime)}  '
                  '${_timeFmt.format(e.startTime)}',
                ),
                if (e.endTime != null)
                  Text('Ends: ${_timeFmt.format(e.endTime!)}'),
                const SizedBox(height: 4),
                Text('Location: ${e.location}'),
                const SizedBox(height: 12),
                Text(e.description),
              ],
            ),
          ),
        );
      },
    );
  }
}
