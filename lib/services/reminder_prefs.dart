import 'package:hive/hive.dart';

class ReminderPrefs {
  static const String _boxName = 'reminder_prefs';
  static const String _key = 'offsets';

  static const List<int> _defaultOffsets = [60, 5];

  static Future<Box> _open() async => Hive.openBox(_boxName);

  static Future<List<int>> getOffsets() async {
    final box = await _open();
    final list = box.get(_key);
    if (list == null) {
      await box.put(_key, _defaultOffsets);
      return List<int>.from(_defaultOffsets);
    }
    return List<int>.from(list.cast<int>());
  }

  static Future<void> setOffsets(List<int> offsets) async {
    final box = await _open();
    await box.put(_key, offsets);
  }

  static Future<void> addOffset(int minutes) async {
    final offsets = await getOffsets();
    if (!offsets.contains(minutes)) {
      offsets.add(minutes);
      offsets.sort((a, b) => b.compareTo(a));
      await setOffsets(offsets);
    }
  }

  static Future<void> removeOffset(int minutes) async {
    final offsets = await getOffsets();
    offsets.remove(minutes);
    await setOffsets(offsets);
  }
}
