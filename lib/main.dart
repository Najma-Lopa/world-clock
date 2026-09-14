import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  runApp(const WorldClockApp());
}

// ============================================================
// APP
// ============================================================

class WorldClockApp extends StatefulWidget {
  const WorldClockApp({super.key});

  @override
  State<WorldClockApp> createState() => _WorldClockAppState();
}

class _WorldClockAppState extends State<WorldClockApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void toggleTheme() {
    setState(() {
      _themeMode =
      _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'World Clock',
      themeMode: _themeMode,

      // ---------------- LIGHT THEME ----------------
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xfff5f7fb),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff6750A4),
          brightness: Brightness.light,
        ),
      ),

      // ---------------- DARK THEME ----------------
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xff0d0d16),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff8b5cf6),
          brightness: Brightness.dark,
        ),
      ),

      home: WorldClockScreen(
        onThemeToggle: toggleTheme,
        isDark: _themeMode == ThemeMode.dark,
      ),
    );
  }
}

// ============================================================
// MAIN SCREEN
// ============================================================

class WorldClockScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDark;

  const WorldClockScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDark,
  });

  @override
  State<WorldClockScreen> createState() => _WorldClockScreenState();
}

class _WorldClockScreenState extends State<WorldClockScreen> {
  // ==========================================================
  // TIME ZONES
  // ==========================================================

  final Map<String, String> _timeZones = {
    'Bangladesh (Dhaka)': 'Asia/Dhaka',
    'India (New Delhi)': 'Asia/Kolkata',
    'USA (New York)': 'America/New_York',
    'USA (Los Angeles)': 'America/Los_Angeles',
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
    'Malaysia (Kuala Lumpur)': 'Asia/Kuala_Lumpur',
    'Indonesia (Jakarta)': 'Asia/Jakarta',
    'Pakistan (Islamabad)': 'Asia/Karachi',
    'Nepal (Kathmandu)': 'Asia/Kathmandu',
    'Sri Lanka (Colombo)': 'Asia/Colombo',
    'Qatar (Doha)': 'Asia/Qatar',
    'Kuwait (Kuwait City)': 'Asia/Kuwait',
    'Switzerland (Zurich)': 'Europe/Zurich',
    'Netherlands (Amsterdam)': 'Europe/Amsterdam',
    'Sweden (Stockholm)': 'Europe/Stockholm',
    'Norway (Oslo)': 'Europe/Oslo',
    'Denmark (Copenhagen)': 'Europe/Copenhagen',
    'Finland (Helsinki)': 'Europe/Helsinki',
  };

  // ==========================================================
  // STATE
  // ==========================================================

  String? _fromZone = 'Asia/Dhaka';
  String? _toZone = 'Asia/Kolkata';

  String _convertedTime = '--:--';
  String _convertedDate = '';
  String _difference = '';

  bool _is24Hour = false;

  DateTime _selectedDate = DateTime.now();

  final TextEditingController _timeController =
  TextEditingController(text: DateFormat('HH:mm').format(DateTime.now()));

  Timer? _timer;

  DateTime _now = DateTime.now();

  final List<String> _favoriteZones = [
    'Asia/Dhaka',
    'Asia/Kolkata',
    'Europe/London',
    'America/New_York',
    'Asia/Tokyo',
  ];

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timeController.dispose();
    super.dispose();
  }

  // ==========================================================
  // GET CITY NAME
  // ==========================================================

  String _getCityName(String zone) {
    final entry = _timeZones.entries.firstWhere(
          (e) => e.value == zone,
      orElse: () => const MapEntry('Unknown', ''),
    );

    final name = entry.key;

    if (name.contains('(')) {
      return name.substring(
        name.indexOf('(') + 1,
        name.indexOf(')'),
      );
    }

    return name;
  }

  // ==========================================================
  // GET COUNTRY NAME
  // ==========================================================

  String _getCountryName(String zone) {
    final entry = _timeZones.entries.firstWhere(
          (e) => e.value == zone,
      orElse: () => const MapEntry('Unknown', ''),
    );

    if (entry.key.contains('(')) {
      return entry.key.substring(0, entry.key.indexOf('(')).trim();
    }

    return entry.key;
  }

  // ==========================================================
  // GET FLAG
  // ==========================================================

  String _getFlag(String zone) {
    final country = _getCountryName(zone);

    const flags = {
      'Bangladesh': '🇧🇩',
      'India': '🇮🇳',
      'USA': '🇺🇸',
      'UK': '🇬🇧',
      'Japan': '🇯🇵',
      'Australia': '🇦🇺',
      'Canada': '🇨🇦',
      'Germany': '🇩🇪',
      'France': '🇫🇷',
      'Italy': '🇮🇹',
      'Spain': '🇪🇸',
      'Russia': '🇷🇺',
      'Brazil': '🇧🇷',
      'Mexico': '🇲🇽',
      'China': '🇨🇳',
      'South Korea': '🇰🇷',
      'Singapore': '🇸🇬',
      'Turkey': '🇹🇷',
      'Argentina': '🇦🇷',
      'South Africa': '🇿🇦',
      'Egypt': '🇪🇬',
      'Nigeria': '🇳🇬',
      'Kenya': '🇰🇪',
      'New Zealand': '🇳🇿',
      'Chile': '🇨🇱',
      'Thailand': '🇹🇭',
      'Vietnam': '🇻🇳',
      'Saudi Arabia': '🇸🇦',
      'United Arab Emirates': '🇦🇪',
      'Malaysia': '🇲🇾',
      'Indonesia': '🇮🇩',
      'Pakistan': '🇵🇰',
      'Nepal': '🇳🇵',
      'Sri Lanka': '🇱🇰',
      'Qatar': '🇶🇦',
      'Kuwait': '🇰🇼',
      'Switzerland': '🇨🇭',
      'Netherlands': '🇳🇱',
      'Sweden': '🇸🇪',
      'Norway': '🇳🇴',
      'Denmark': '🇩🇰',
      'Finland': '🇫🇮',
    };

    return flags[country] ?? '🌍';
  }

  // ==========================================================
  // UTC OFFSET
  // ==========================================================

  String _getUtcOffset(String zone) {
    final location = tz.getLocation(zone);
    final time = tz.TZDateTime.now(location);

    final offset = time.timeZoneOffset;

    final sign = offset.isNegative ? '-' : '+';
    final hours = offset.inHours.abs().toString().padLeft(2, '0');
    final minutes =
    (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');

    return 'UTC$sign$hours:$minutes';
  }

  // ==========================================================
  // DAY / NIGHT
  // ==========================================================

  bool _isDayTime(String zone) {
    final location = tz.getLocation(zone);
    final time = tz.TZDateTime.now(location);

    return time.hour >= 6 && time.hour < 18;
  }

  // ==========================================================
  // FORMAT TIME
  // ==========================================================

  String _formatTime(tz.TZDateTime time) {
    if (_is24Hour) {
      return DateFormat('HH:mm:ss').format(time);
    }

    return DateFormat('hh:mm:ss a').format(time);
  }

  // ==========================================================
  // CONVERT TIME
  // ==========================================================

  void _convertTime() {
    if (_fromZone == null || _toZone == null) {
      _showSnackBar('Please select both time zones.');
      return;
    }

    if (_timeController.text.trim().isEmpty) {
      _showSnackBar('Please enter a time.');
      return;
    }

    try {
      final parsedTime =
      DateFormat('HH:mm').parseStrict(_timeController.text.trim());

      final fromLocation = tz.getLocation(_fromZone!);
      final toLocation = tz.getLocation(_toZone!);

      final fromTime = tz.TZDateTime(
        fromLocation,
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        parsedTime.hour,
        parsedTime.minute,
      );

      final converted = tz.TZDateTime.from(
        fromTime,
        toLocation,
      );

      final difference =
          converted.timeZoneOffset - fromTime.timeZoneOffset;

      final sign = difference.isNegative ? '-' : '+';

      final diffHours = difference.inHours.abs();
      final diffMinutes = difference.inMinutes.abs() % 60;

      String diffText;

      if (diffMinutes == 0) {
        diffText = '$sign${diffHours}h';
      } else {
        diffText = '$sign${diffHours}h ${diffMinutes}m';
      }

      setState(() {
        _convertedTime = _formatTime(converted);
        _convertedDate = DateFormat('EEE, dd MMM yyyy').format(converted);
        _difference = 'Time difference: $diffText';
      });
    } catch (e) {
      setState(() {
        _convertedTime = 'Invalid time';
        _convertedDate = '';
        _difference = '';
      });

      _showSnackBar('Please enter time in HH:mm format.');
    }
  }

  // ==========================================================
  // SWAP
  // ==========================================================

  void _swapZones() {
    setState(() {
      final temp = _fromZone;
      _fromZone = _toZone;
      _toZone = temp;
    });

    if (_timeController.text.isNotEmpty) {
      _convertTime();
    }
  }

  // ==========================================================
  // DATE PICKER
  // ==========================================================

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xff8b5cf6),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });

      if (_timeController.text.isNotEmpty) {
        _convertTime();
      }
    }
  }

  // ==========================================================
  // COPY
  // ==========================================================

  void _copyResult() {
    if (_convertedTime == '--:--' || _convertedTime == 'Invalid time') {
      _showSnackBar('Nothing to copy.');
      return;
    }

    Clipboard.setData(
      ClipboardData(
        text:
        '$_convertedTime ($_convertedDate)\n${_getCityName(_toZone!)}',
      ),
    );

    _showSnackBar('Converted time copied!');
  }

  // ==========================================================
  // FAVORITES
  // ==========================================================

  void _toggleFavorite(String zone) {
    setState(() {
      if (_favoriteZones.contains(zone)) {
        _favoriteZones.remove(zone);
      } else {
        _favoriteZones.add(zone);
      }
    });
  }

  // ==========================================================
  // SNACKBAR
  // ==========================================================

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  // ==========================================================
  // COUNTRY SELECTOR
  // ==========================================================

  Future<String?> _showCountrySelector(String? currentZone) async {
    String search = '';

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = _timeZones.entries.where((entry) {
              return entry.key.toLowerCase().contains(search.toLowerCase());
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.82,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // Handle
                  Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade500,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Select Time Zone',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      autofocus: true,
                      onChanged: (value) {
                        setModalState(() {
                          search = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search country or city...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final entry = filtered[index];
                        final selected = entry.value == currentZone;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 4,
                          ),
                          leading: Text(
                            _getFlag(entry.value),
                            style: const TextStyle(fontSize: 28),
                          ),
                          title: Text(
                            entry.key,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            _getUtcOffset(entry.value),
                          ),
                          trailing: selected
                              ? const Icon(
                            Icons.check_circle,
                            color: Colors.deepPurple,
                          )
                              : null,
                          onTap: () {
                            Navigator.pop(context, entry.value);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================================
  // COUNTRY FIELD
  // ==========================================================

  Widget _countrySelector({
    required String label,
    required String? zone,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withOpacity(0.65),
          ),
        ),
        const SizedBox(height: 8),

        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withOpacity(0.55),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withOpacity(0.15),
              ),
            ),
            child: Row(
              children: [
                Text(
                  _getFlag(zone!),
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getCityName(zone),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_getCountryName(zone)} • ${_getUtcOffset(zone)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.55),
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(Icons.keyboard_arrow_down_rounded),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // CURRENT TIME CARD
  // ==========================================================

  Widget _currentTimeCard() {
    final location = tz.getLocation(_fromZone!);
    final current = tz.TZDateTime.now(location);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff7c3aed),
            Color(0xff9333ea),
            Color(0xffdb2777),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff7c3aed).withOpacity(0.35),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                _getFlag(_fromZone!),
                style: const TextStyle(fontSize: 30),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getCityName(_fromZone!),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getUtcOffset(_fromZone!),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                _isDayTime(_fromZone!)
                    ? Icons.wb_sunny_rounded
                    : Icons.nightlight_round,
                color: Colors.white,
              ),
            ],
          ),

          const SizedBox(height: 22),

          Text(
            _formatTime(current),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            DateFormat('EEEE, dd MMMM yyyy').format(current),
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _isDayTime(_fromZone!)
                  ? '☀️ Day Time'
                  : '🌙 Night Time',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // CONVERTER CARD
  // ==========================================================

  Widget _converterCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surface
            .withOpacity(0.95),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outline
              .withOpacity(0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              widget.isDark ? 0.18 : 0.06,
            ),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: const Color(0xff7c3aed).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.swap_horiz_rounded,
                  color: Color(0xff8b5cf6),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Time Converter',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Convert time between cities',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          // FROM
          _countrySelector(
            label: 'FROM',
            zone: _fromZone,
            onTap: () async {
              final result =
              await _showCountrySelector(_fromZone);

              if (result != null) {
                setState(() {
                  _fromZone = result;
                });
              }
            },
          ),

          const SizedBox(height: 10),

          // SWAP BUTTON
          Center(
            child: GestureDetector(
              onTap: _swapZones,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xff7c3aed),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff7c3aed)
                          .withOpacity(0.3),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.swap_vert_rounded,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 5),

          // TIME
          Text(
            'TIME',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withOpacity(0.65),
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _timeController,
                  keyboardType: TextInputType.datetime,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: 'HH:mm',
                    prefixIcon:
                    const Icon(Icons.access_time_rounded),
                    filled: true,
                    fillColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withOpacity(0.55),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _convertTime(),
                ),
              ),
              const SizedBox(width: 10),

              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: const Color(0xff7c3aed)
                        .withOpacity(0.12),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: Color(0xff8b5cf6),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            DateFormat('EEE, dd MMM yyyy').format(_selectedDate),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withOpacity(0.55),
            ),
          ),

          const SizedBox(height: 20),

          // TO
          _countrySelector(
            label: 'TO',
            zone: _toZone,
            onTap: () async {
              final result =
              await _showCountrySelector(_toZone);

              if (result != null) {
                setState(() {
                  _toZone = result;
                });
              }
            },
          ),

          const SizedBox(height: 22),

          // CONVERT BUTTON
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _convertTime,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff7c3aed),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sync_rounded),
                  SizedBox(width: 10),
                  Text(
                    'Convert Time',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 22),

          // RESULT
          if (_convertedTime != '--:--')
            _resultCard(),
        ],
      ),
    );
  }

  // ==========================================================
  // RESULT CARD
  // ==========================================================

  Widget _resultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.isDark
              ? [
            const Color(0xff172554),
            const Color(0xff312e81),
          ]
              : [
            const Color(0xffeef2ff),
            const Color(0xfff5f3ff),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xff8b5cf6).withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Converted Time',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: _copyResult,
                icon: const Icon(Icons.copy_rounded),
                tooltip: 'Copy',
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            _convertedTime,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: Color(0xff8b5cf6),
            ),
          ),

          const SizedBox(height: 5),

          Text(
            _convertedDate,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withOpacity(0.65),
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xff8b5cf6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _difference,
              style: const TextStyle(
                color: Color(0xff8b5cf6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // FAVORITE CLOCKS
  // ==========================================================

  Widget _favoriteClocks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Favorite Clocks',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '${_favoriteZones.length} cities',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.5),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        SizedBox(
          height: 155,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _favoriteZones.length,
            itemBuilder: (context, index) {
              final zone = _favoriteZones[index];

              return _favoriteCard(zone);
            },
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // FAVORITE CARD
  // ==========================================================

  Widget _favoriteCard(String zone) {
    final location = tz.getLocation(zone);
    final current = tz.TZDateTime.now(location);

    return Container(
      width: 185,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outline
              .withOpacity(0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _getFlag(zone),
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getCityName(zone),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _toggleFavorite(zone),
                child: const Icon(
                  Icons.star_rounded,
                  color: Colors.amber,
                  size: 20,
                ),
              ),
            ],
          ),

          const Spacer(),

          Text(
            _formatTime(current),
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 4),

          Row(
            children: [
              Icon(
                _isDayTime(zone)
                    ? Icons.wb_sunny_rounded
                    : Icons.nightlight_round,
                size: 14,
                color: _isDayTime(zone)
                    ? Colors.orange
                    : Colors.indigo,
              ),
              const SizedBox(width: 5),
              Text(
                _getUtcOffset(zone),
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // INFO DIALOG
  // ==========================================================

  void _showDeveloperInfo() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Profile
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xff7c3aed),
                        Color(0xffdb2777),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff7c3aed)
                            .withOpacity(0.3),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 50,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Developer',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  'Najma Akter Lopa',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 18),

                _infoRow(
                  Icons.school_rounded,
                  'HSTU • CSE',
                ),

                _infoRow(
                  Icons.email_rounded,
                  'najmalopa@gmail.com',
                ),

                _infoRow(
                  Icons.phone_rounded,
                  '01719131674',
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xff8b5cf6),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.isDark
                ? [
              const Color(0xff0f0c29),
              const Color(0xff302b63),
              const Color(0xff24243e),
            ]
                : [
              const Color(0xfff8f7ff),
              const Color(0xffeeeaff),
              const Color(0xfffff7fb),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                15,
                20,
                100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ====================================================
                  // APP BAR
                  // ====================================================

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xff7c3aed),
                              Color(0xffdb2777),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.public_rounded,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),

                      const SizedBox(width: 12),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              'WORLD CLOCK',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              'Time anywhere, anytime',
                              style: TextStyle(
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        onPressed: widget.onThemeToggle,
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .surface
                              .withOpacity(0.6),
                        ),
                        icon: Icon(
                          widget.isDark
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // ====================================================
                  // GREETING
                  // ====================================================

                  Text(
                    _now.hour < 12
                        ? 'Good Morning ☀️'
                        : _now.hour < 18
                        ? 'Good Afternoon 🌤️'
                        : 'Good Evening 🌙',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.65),
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    'What time is it there?',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ====================================================
                  // CURRENT TIME
                  // ====================================================

                  _currentTimeCard(),

                  const SizedBox(height: 25),

                  // ====================================================
                  // FORMAT SWITCH
                  // ====================================================

                  Row(
                    children: [
                      const Text(
                        'Time Format',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Spacer(),

                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surface
                              .withOpacity(0.8),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            _formatButton('12H', !_is24Hour),
                            _formatButton('24H', _is24Hour),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // ====================================================
                  // CONVERTER
                  // ====================================================

                  _converterCard(),

                  const SizedBox(height: 30),

                  // ====================================================
                  // FAVORITES
                  // ====================================================

                  _favoriteClocks(),
                ],
              ),
            ),
          ),
        ),
      ),

      // ================================================================
      // FAB
      // ================================================================

      floatingActionButton: FloatingActionButton(
        onPressed: _showDeveloperInfo,
        backgroundColor: const Color(0xff7c3aed),
        foregroundColor: Colors.white,
        elevation: 8,
        child: const Icon(Icons.person_rounded),
      ),
    );
  }

  // ==========================================================
  // FORMAT BUTTON
  // ==========================================================

  Widget _formatButton(String text, bool selected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _is24Hour = text == '24H';
        });

        if (_convertedTime != '--:--') {
          _convertTime();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xff7c3aed)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: selected ? Colors.white : null,
          ),
        ),
      ),
    );
  }
}