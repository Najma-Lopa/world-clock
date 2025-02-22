import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'World Clock',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: WorldClockScreen(),
    );
  }
}

class WorldClockScreen extends StatefulWidget {
  @override
  _WorldClockScreenState createState() => _WorldClockScreenState();
}

class _WorldClockScreenState extends State<WorldClockScreen> {
  final Map<String, String> _timeZones = {
    'Bangladesh (Dhaka)': 'Asia/Dhaka',
    'India (New Delhi)': 'Asia/Kolkata',
    'USA (New York)': 'America/New_York',
    'UK (London)': 'Europe/London',
    'Japan (Tokyo)': 'Asia/Tokyo',
    'Australia (Sydney)': 'Australia/Sydney',
    'Canada (Toronto)': 'America/Toronto',
    'Germany (Berlin)': 'Europe/Berlin',
    'France (Paris)': 'Europe/Paris',
    'Italy (Rome)': 'Europe/Rome',
    'Spain (Madrid)': 'Europe/Madrid',
    'Russia (Moscow)': 'Europe/Moscow',
    'Brazil (Brasilia)': 'America/Sao_Paulo',
    'Mexico (Mexico City)': 'America/Mexico_City',
    'China (Beijing)': 'Asia/Shanghai',
    'South Korea (Seoul)': 'Asia/Seoul',
    'Singapore (Singapore)': 'Asia/Singapore',
    'Turkey (Istanbul)': 'Europe/Istanbul',
    'Argentina (Buenos Aires)': 'America/Argentina/Buenos_Aires',
    'South Africa (Cape Town)': 'Africa/Johannesburg',
    'Egypt (Cairo)': 'Africa/Cairo',
    'Nigeria (Lagos)': 'Africa/Lagos',
    'Kenya (Nairobi)': 'Africa/Nairobi',
    'New Zealand (Auckland)': 'Pacific/Auckland',
    'Chile (Santiago)': 'America/Santiago',
    'Thailand (Bangkok)': 'Asia/Bangkok',
    'Vietnam (Hanoi)': 'Asia/Ho_Chi_Minh',
    'Saudi Arabia (Riyadh)': 'Asia/Riyadh',
    'United Arab Emirates (Dubai)': 'Asia/Dubai',
  };

  String? _fromZone = 'Asia/Dhaka';
  String? _toZone = 'Asia/Kolkata';
  String _convertedTime = '';
  final TextEditingController _timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
  }

  void _convertTime() {
    if (_fromZone != null &&
        _toZone != null &&
        _timeController.text.isNotEmpty) {
      try {
        final inputTime = DateFormat('HH:mm').parse(_timeController.text);
        final fromTimeZone = tz.getLocation(_fromZone!);
        final toTimeZone = tz.getLocation(_toZone!);

        final fromTime = tz.TZDateTime(
          fromTimeZone,
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          inputTime.hour,
          inputTime.minute,
        );

        final toTime = tz.TZDateTime.from(fromTime, toTimeZone);

        setState(() {
          _convertedTime = DateFormat('HH:mm').format(toTime);
        });
      } catch (e) {
        setState(() {
          _convertedTime = 'Invalid input time.';
        });
      }
    } else {
      setState(() {
        _convertedTime = 'Please fill all fields.';
      });
    }
  }

  void _showDeveloperInfo() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Developer Info'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage('assets/IMG_5211.jpg'),
              ),
              SizedBox(height: 16),
              Text(
                'Name: Najma Akter Lopa\n'
                'Institute: Hajee Mohammad Danesh Science and Technology University\n'
                'Dept: CSE\n'
                'Email: najmalopa@gmail.com\n'
                'Phone: 01719131674',
                style: TextStyle(fontSize: 16, color: Colors.teal),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.shade700,
              Colors.pink.shade600,
              Colors.orange.shade300
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent, // Prevents white screen below
          extendBody: true, // Extends body to fill screen
          body: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(padding: EdgeInsets.all(20)),
                    Text(
                      'WORLD CLOCK',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 50,width: 20,),
                    Center(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.width * 1.4,
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          color: Colors.white.withOpacity(0.9),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                _buildDropdown('From Country:', _fromZone,
                                    (value) {
                                  setState(() => _fromZone = value);
                                }),
                                SizedBox(height: 16),
                                _buildTextField(),
                                SizedBox(height: 16),
                                _buildDropdown('To Country:', _toZone, (value) {
                                  setState(() => _toZone = value);
                                }),
                                SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _convertTime,
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 14, horizontal: 28),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Text(
                                    'Convert Time',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Converted Time:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple.shade800,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  _convertedTime,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showDeveloperInfo,
            backgroundColor: Colors.deepPurple.shade700,
            child: Icon(Icons.info),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
      String label, String? value, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade800)),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: _timeZones.entries
              .map((entry) =>
                  DropdownMenuItem(value: entry.value, child: Text(entry.key)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTextField() => TextField(
      controller: _timeController,
      decoration: InputDecoration(hintText: 'Enter time (HH:mm)'));
}
