import 'package:flutter/material.dart';
import '../services/service_locator.dart';
import '../models/event.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({Key? key}) : super(key: key);

  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  Future<void> _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      final newEvent = Event(
        title: _titleController.text,
        description: _descriptionController.text,
        location: _locationController.text,
        capacity: int.parse(_capacityController.text),
        imageUrl: _imageUrlController.text,
        date: _selectedDate ?? DateTime.now(),
        participants: [],
      );

      await ServiceLocator.eventService.createEvent(newEvent);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Event created successfully'),
            backgroundColor: Colors.green.shade800,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create event: $e'),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check_rounded),
              onPressed: _submitForm,
              tooltip: 'Create Event',
            ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Event Details',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title_rounded),
                        ),
                        enabled: !_isLoading,
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true) {
                            return 'Title is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description_rounded),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                        enabled: !_isLoading,
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true) {
                            return 'Description is required';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location & Capacity',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on_rounded),
                        ),
                        enabled: !_isLoading,
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true) {
                            return 'Location is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _capacityController,
                        decoration: const InputDecoration(
                          labelText: 'Capacity',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.people_rounded),
                        ),
                        keyboardType: TextInputType.number,
                        enabled: !_isLoading,
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true) {
                            return 'Capacity is required';
                          }
                          final capacity = int.tryParse(value!);
                          if (capacity == null || capacity <= 0) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date & Image',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _isLoading ? null : () => _selectDate(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today_rounded),
                          ),
                          child: Text(
                            _selectedDate == null
                                ? 'Select Date'
                                : _selectedDate!.toLocal().toString().split(' ')[0],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _imageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Image URL',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.image_rounded),
                        ),
                        enabled: !_isLoading,
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true) {
                            return 'Image URL is required';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _isLoading ? null : _submitForm,
                icon: const Icon(Icons.add_rounded),
                label: const Text('CREATE EVENT'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}