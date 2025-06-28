//Basic Imports
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;                
import 'package:maps_launcher/maps_launcher.dart';
import 'package:dynamic_color/dynamic_color.dart';

void main() {
  runApp(const IpLocatorApp());
}

class IpLocatorApp extends StatelessWidget {
  const IpLocatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          title: 'IP Info',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.system,
          theme: _buildTheme(
            lightDynamic ??
                ColorScheme.fromSeed(
                    seedColor: Colors.blue, brightness: Brightness.light),
          ),
          darkTheme: _buildTheme(
            darkDynamic ??
                ColorScheme.fromSeed(
                    seedColor: Colors.blue, brightness: Brightness.dark),
          ),
          home: const IpLookupScreen(),
        );
      },
    );
  }

  ThemeData _buildTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: colorScheme.brightness,
      scaffoldBackgroundColor: colorScheme.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: colorScheme.surface,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class IpLookupScreen extends StatefulWidget {
  const IpLookupScreen({super.key});

  @override
  State<IpLookupScreen> createState() => _IpLookupScreenState();
}

class _IpLookupScreenState extends State<IpLookupScreen> {
  final _controller = TextEditingController();

  String ip = '-';
  String country = '-';
  String city = '-';
  String region = '-';
  String timezone = '-';
  String postal = '-';
  String org = '-';
  String latitude = '-';
  String longitude = '-';

  @override
  void initState() {
    super.initState();
    _fetchCurrentIpAndDetails();
  }

  Future<void> _fetchCurrentIpAndDetails() async {
    try {
      final response = await http.get(Uri.parse('https://api64.ipify.org?format=json'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final currentIp = data['ip'] as String?;
        if (currentIp != null) {
          _fetchIpDetails(currentIp);
        }
      }
    } catch (_) {
      // Handle errors if necessary
    }
  }

  Future<void> _fetchIpDetails(String ipAddress) async {
    try {
      final response = await http.get(Uri.parse('https://ipinfo.io/$ipAddress/json'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          ip = data['ip'] ?? '-';
          country = data['country'] ?? '-';
          city = data['city'] ?? '-';
          region = data['region'] ?? '-';
          timezone = data['timezone'] ?? '-';
          postal = data['postal'] ?? '-';
          org = data['org'] ?? '-';
          final loc = data['loc']?.split(',');
          if (loc?.length == 2) {
            latitude = loc![0];
            longitude = loc[1];
          } else {
            latitude = '-';
            longitude = '-';
          }
        });
      }
    } catch (_) {
      // Handle errors
    }
  }

  void _launchMap() {
    if (latitude != '-' && longitude != '-') {
      final lat = double.tryParse(latitude);
      final lon = double.tryParse(longitude);
      if (lat != null && lon != null) {
        MapsLauncher.launchCoordinates(lat, lon);
      }
    }
  }

  void _copyToClipboard(String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isMap = false}) {
    return GestureDetector(
      onTap: isMap && value != '-' ? _launchMap : null,
      onLongPress: () => _copyToClipboard(value),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              color: isMap && value != '-' ? Colors.blue : null,
              decoration: isMap && value != '-' ? TextDecoration.underline : null,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('IP Info'),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter IP address',
                fillColor: colorScheme.surface,
                filled: true,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
              ),
              keyboardType: TextInputType.text,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F:.]')),
              ],
              onSubmitted: _fetchIpDetails,
            ),
            const SizedBox(height: 20),
            _buildInfoRow('IP Address', ip),
            _buildInfoRow('Country', country),
            _buildInfoRow('City', city),
            _buildInfoRow('Region', region),
            _buildInfoRow('Postal Code', postal),
            _buildInfoRow('Time Zone', timezone),
            _buildInfoRow('Organization', org),
            _buildInfoRow('Latitude', latitude, isMap: true),
            _buildInfoRow('Longitude', longitude, isMap: true),
          ],
        ),
      ),
    );
  }
}
