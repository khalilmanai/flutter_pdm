import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/service_locator.dart';
import 'event_detail_page.dart';
import 'create_event_page.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({Key? key}) : super(key: key);

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  late Future<List<Event>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  void _fetchEvents() {
    _eventsFuture = ServiceLocator.eventService.fetchEvents();
    setState(() {});
  }

  Future<void> _deleteEvent(Event event) async {
    if (event.id == null) {
      _showSnackBar('Cannot delete event: Invalid ID', true);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${event.title}?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ServiceLocator.eventService.deleteEvent(event.id!);
      _showSnackBar('Event deleted successfully', false);
      _fetchEvents();
    } catch (e) {
      _showSnackBar('Failed to delete event: $e', true);
    }
  }

  void _showSnackBar(String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade800 : Colors.green.shade800,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateEventPage()),
              ).then((_) => _fetchEvents());
            },
            tooltip: 'Create Event',
          ),
        ],
      ),
      body: FutureBuilder<List<Event>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading events',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _fetchEvents,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('RETRY'),
                  ),
                ],
              ),
            );
          }

          final events = snapshot.data ?? [];
          if (events.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy_rounded,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Events Yet',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first event to get started',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateEventPage(),
                        ),
                      ).then((_) => _fetchEvents());
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('CREATE EVENT'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _fetchEvents(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventDetailPage(event: event),
                        ),
                      ).then((_) => _fetchEvents());
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.network(
                            event.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              child: Icon(
                                Icons.broken_image_rounded,
                                size: 48,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      event.title,
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_rounded),
                                    color: theme.colorScheme.error,
                                    onPressed: () => _deleteEvent(event),
                                    tooltip: 'Delete Event',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                event.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    size: 16,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      event.location,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ),
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 16,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    event.date.toLocal().toString().split(' ')[0],
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateEventPage()),
          ).then((_) => _fetchEvents());
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}