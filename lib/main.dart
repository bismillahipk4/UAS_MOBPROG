import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  runApp(KonsultasiApp());
}

class KonsultasiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Konsultasi Akademik',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: KonsultasiHomePage(),
    );
  }
}

class KonsultasiHomePage extends StatefulWidget {
  @override
  _KonsultasiHomePageState createState() => _KonsultasiHomePageState();
}

class _KonsultasiHomePageState extends State<KonsultasiHomePage> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  List<Map<String, String>> konsultasiList = []; // Menyimpan riwayat konsultasi
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String? selectedDosen;

  @override
  void initState() {
    super.initState();
    var initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Fungsi untuk menampilkan notifikasi
  Future<void> _showNotification(String title, String body) async {
    var androidDetails = AndroidNotificationDetails(
      'channelId', 'channelName',
      importance: Importance.max,
      priority: Priority.high,
    );
    var generalNotificationDetails =
    NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      generalNotificationDetails,
    );
  }

  // Fungsi memilih tanggal
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Fungsi memilih waktu
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked =
    await showTimePicker(context: context, initialTime: selectedTime);
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  // Fungsi untuk menjadwalkan konsultasi
  void _scheduleKonsultasi() {
    if (selectedDosen != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
      String formattedTime = selectedTime.format(context);

      setState(() {
        konsultasiList.add({
          'dosen': selectedDosen!,
          'tanggal': '$formattedDate, $formattedTime',
          'feedback': 'Belum ada feedback'
        });
      });

      _showNotification('Pengingat Konsultasi',
          'Konsultasi dengan $selectedDosen pada $formattedDate jam $formattedTime');
    }
  }

  // Fungsi untuk memulai video call (dummy)
  void _startVideoCall(String dosen) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Video Call'),
        content: Text('Memulai video call dengan $dosen...'),
        actions: [
          TextButton(
            child: Text('Tutup'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  // Fungsi untuk menampilkan chat (dummy)
  void _openChat(String dosen) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chat dengan $dosen'),
        content: Text('Fitur chat belum tersedia.'),
        actions: [
          TextButton(
            child: Text('Tutup'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aplikasi Konsultasi Akademik'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Form Penjadwalan Konsultasi
            DropdownButton<String>(
              hint: Text('Pilih Dosen'),
              value: selectedDosen,
              onChanged: (String? newValue) {
                setState(() {
                  selectedDosen = newValue!;
                });
              },
              items: <String>['Dosen A', 'Dosen B', 'Dosen C']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text("Pilih Tanggal: ${DateFormat('yyyy-MM-dd').format(selectedDate)}"),
            ),
            ElevatedButton(
              onPressed: () => _selectTime(context),
              child: Text("Pilih Waktu: ${selectedTime.format(context)}"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _scheduleKonsultasi,
              child: Text('Jadwalkan Konsultasi'),
            ),
            Divider(),
            Text(
              'Riwayat Konsultasi:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: konsultasiList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(konsultasiList[index]['dosen']!),
                    subtitle: Text(konsultasiList[index]['tanggal']!),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.chat),
                          onPressed: () =>
                              _openChat(konsultasiList[index]['dosen']!),
                        ),
                        IconButton(
                          icon: Icon(Icons.video_call),
                          onPressed: () =>
                              _startVideoCall(konsultasiList[index]['dosen']!),
                        ),
                      ],
                    ),
                    onTap: () {
                      // Placeholder untuk melihat feedback
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Feedback'),
                          content: Text(konsultasiList[index]['feedback']!),
                          actions: [
                            TextButton(
                              child: Text('Tutup'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
