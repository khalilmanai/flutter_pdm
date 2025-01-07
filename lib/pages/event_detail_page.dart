import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdm_flutter_app/services/api_constants.dart';
import 'dart:convert';
import '../models/event.dart';

class EventDetailPage extends StatefulWidget {
  final Event event;

  const EventDetailPage({Key? key, required this.event}) : super(key: key);

  @override
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  late TextEditingController titleController;
  late TextEditingController locationController;
  late TextEditingController dateController;
  late TextEditingController descriptionController;
  late TextEditingController imageUrlController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.event.title);
    locationController = TextEditingController(text: widget.event.location);
    dateController = TextEditingController(
        text: widget.event.date.toLocal().toString().split(' ')[0]);
    descriptionController =
        TextEditingController(text: widget.event.description);
    imageUrlController = TextEditingController(text: widget.event.imageUrl);
  }

  @override
  void dispose() {
    titleController.dispose();
    locationController.dispose();
    dateController.dispose();
    descriptionController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  Future<void> saveChanges() async {
    final url =
        Uri.parse('https://${ApiConstants.baseUrl}/events/${widget.event.id}');
    print(url);
    final body = {
      'title': titleController.text,
      'description': descriptionController.text,
      'date': dateController.text,
      'location': locationController.text,
      'imageUrl': imageUrlController.text,
    };

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event updated successfully!')),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Failed to update event');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Event'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: saveChanges,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: widget.event.date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      dateController.text =
                          pickedDate.toLocal().toString().split(' ')[0];
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              if (imageUrlController.text.isNotEmpty)
                Image.network(
                  imageUrlController.text,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image,
                    size: 100,
                    color: Colors.grey,
                  ),
                ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saveChanges,
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
