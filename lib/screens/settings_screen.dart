import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/user_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Box<UserSettings> settingsBox;
  int selectedMinutes = 60;

  final Map<String, int> options = {
    "1 Hour Before": 60,
    "6 Hours Before": 360,
    "1 Day Before": 1440,
  };

  @override
  void initState() {
    super.initState();
    settingsBox = Hive.box<UserSettings>('settingsBox');
    if (settingsBox.isNotEmpty) {
      selectedMinutes = settingsBox.getAt(0)!.reminderMinutes;
    }
  }

  void saveSetting(int minutes) {
    settingsBox.clear();
    settingsBox.add(UserSettings(reminderMinutes: minutes));
    setState(() {
      selectedMinutes = minutes;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reminder time updated!')),
    );
  }

  void _showCustomTimerDialog() {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            "Custom Reminder",
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Enter minutes before event",
              hintStyle: TextStyle(color: Colors.white54),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white54),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.tealAccent),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel", style: TextStyle(color: Colors.redAccent)),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent,
                foregroundColor: Colors.black,
              ),
              child: const Text("Save"),
              onPressed: () {
                final val = int.tryParse(controller.text);
                if (val != null && val > 0) {
                  saveSetting(val);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter a valid number!')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _openAboutPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AboutPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: const Color(0xFF1F1F1F),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Notification Reminder",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          ...options.entries.map((entry) {
            return Card(
              color: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: RadioListTile<int>(
                activeColor: Colors.tealAccent,
                title: Text(
                  entry.key,
                  style: const TextStyle(color: Colors.white),
                ),
                value: entry.value,
                groupValue: selectedMinutes,
                onChanged: (val) {
                  if (val != null) saveSetting(val);
                },
              ),
            );
          }),

          // Custom Timer Card
          const SizedBox(height: 12),
          Card(
            color: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.timer_outlined, color: Colors.tealAccent),
              title: const Text(
                "Custom Timer",
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                "Set your own reminder in minutes",
                style: TextStyle(color: Colors.white54),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 18),
              onTap: _showCustomTimerDialog,
            ),
          ),

          const SizedBox(height: 24),
          Divider(color: Colors.white24),

          // About Section
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.tealAccent),
            title: const Text(
              "About",
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              "Open source project • Tap to learn more",
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            onTap: _openAboutPage,
          ),
        ],
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("About"),
        backgroundColor: const Color(0xFF1F1F1F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Icon(Icons.flag_outlined, size: 80, color: Colors.tealAccent),
              SizedBox(height: 20),
              Text(
                "CTF Reminder App",
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                "This is an open-source project.\nHelp improve it by contributing on GitHub!",
                style: TextStyle(color: Colors.white70, fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
