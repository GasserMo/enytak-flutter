import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_sanar_proj/PATIENT/Widgets/Constant_Widgets/custom_AppBar.dart';

class Staff_Nurse_AppointmentScreen extends StatefulWidget {
  const Staff_Nurse_AppointmentScreen({super.key});

  @override
  State<Staff_Nurse_AppointmentScreen> createState() =>
      _Staff_Nurse_AppointmentScreenState();
}

class _Staff_Nurse_AppointmentScreenState
    extends State<Staff_Nurse_AppointmentScreen> {
  List<ListItem> confirmedAppointments = [];
  List<ListItem> refusedAppointments = [];
  bool isLoading = true;

  Future<void> fetchAppointments() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access') ?? '';
    final specificId = prefs.getInt('specificId');

    final url =
        'http://164.92.111.149/api/nurses/$specificId/appointments/?page=1';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'X-CSRFTOKEN':
              'nBu98iMSXQUHWNabH8k7LLALqEPDzjQVmeBE9u7XssKYmYnL1hmvmJ8qRXOAfQ0u',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = List<Map<String, dynamic>>.from(data['results']);

        setState(() {
          confirmedAppointments = results
              .where((appointment) => appointment['status'] == 'confirmed')
              .map((appointment) => ListItem(
                    id: appointment['id'],
                    title: appointment['service_type'] ?? 'No Service Type',
                    subtitle: appointment['date_time'] ?? 'No Date Time',
                    trailing: appointment['cost']?.toString() ?? 'No Cost',
                    notes: appointment['notes'] ?? 'No notes provided',
                  ))
              .toList();

          refusedAppointments = results
              .where((appointment) => appointment['status'] == 'cancelled')
              .map((appointment) => ListItem(
                    id: appointment['id'],
                    title: appointment['service_type'] ?? 'No Service Type',
                    subtitle: appointment['date_time'] ?? 'No Date Time',
                    trailing: appointment['cost']?.toString() ?? 'No Cost',
                    notes: appointment['notes'] ?? 'No notes provided',
                  ))
              .toList();
        });
      } else {
        debugPrint('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching appointments: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateAppointmentNote(
    int appointmentId,
    String note,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access') ?? '';
    final specificId =
        prefs.getInt('specificId'); // Assuming this is the patient ID

    final url = 'http://164.92.111.149/api/appointments/$appointmentId/';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'X-CSRFTOKEN':
              'FTXOrj7A0h4seuYibzZLTxHGGC3ZiNsrDXnP3Rj4N0PoHDBw7o6XMfzBmZLAGfkf',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          "notes": note,
          "service_type":
              "teleconsultation", // Replace with a valid service type
          "patient": specificId, // Replace with a valid patient ID
          "doctor": '',
          "nurse": '',
          "services": [4],
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('Note updated successfully');
        fetchAppointments(); // Refresh data
      } else {
        debugPrint(
            'Error updating note: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const CustomAppBar(),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.teal,
              ),
            )
          : TabbedList(
              tabs: [
                TabData(
                  title: 'Accepted Requests',
                  items: confirmedAppointments,
                ),
                TabData(
                  title: 'Refused Requests',
                  items: refusedAppointments,
                ),
              ],
              onSaveNote: updateAppointmentNote,
            ),
    );
  }
}

class TabbedList extends StatefulWidget {
  final List<TabData> tabs;
  final Function(int, String) onSaveNote;

  const TabbedList({
    super.key,
    required this.tabs,
    required this.onSaveNote,
  });

  @override
  State<TabbedList> createState() => _TabbedListState();
}

class _TabbedListState extends State<TabbedList>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.teal[400],
              borderRadius: BorderRadius.circular(15),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: false,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black54,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              indicator: BoxDecoration(
                color: Colors.teal[600],
                borderRadius: BorderRadius.circular(15),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: widget.tabs
                  .map((tab) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: SizedBox(
                          width: double.infinity,
                          child: Center(
                            child: Text(
                              tab.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: widget.tabs
                .map((tab) => ListContent(
                      items: tab.items,
                      onSaveNote: widget.onSaveNote,
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class ListContent extends StatelessWidget {
  final List<ListItem> items;
  final Function(int, String) onSaveNote;

  const ListContent({
    super.key,
    required this.items,
    required this.onSaveNote,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final listItem = items[index];

          return GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  final TextEditingController notesController =
                      TextEditingController(text: listItem.notes);

                  return AlertDialog(
                    title: const Text('Add Notes'),
                    content: TextField(
                      controller: notesController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Enter your notes here',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          onSaveNote(listItem.id, notesController.text);
                          Navigator.pop(context);
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  );
                },
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 15),
              child: Card(
                elevation: 5,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  title: Text(
                    listItem.title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    listItem.subtitle,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.normal),
                  ),
                  trailing: Text(
                    '\$${listItem.trailing}',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ListItem {
  final int id;
  final String title;
  final String subtitle;
  final String trailing;
  final String notes;

  ListItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.notes,
  });
}

class TabData {
  final String title;
  final List<ListItem> items;

  TabData({
    required this.title,
    required this.items,
  });
}
