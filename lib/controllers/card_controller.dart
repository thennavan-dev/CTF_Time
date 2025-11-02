import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import '../services/notification_service.dart';
import '../utils/env.dart';
import '../models/ctf_event.dart';

class CardController extends ChangeNotifier {
  List<CtfEvent> _events = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _errorMessage;
  int _page = 0;
  final int _limit = 50;
  final String _hiveBoxName = 'ctf_events';
  late Box<CtfEvent> _box;
  late Box _metaBox;

  List<CtfEvent> get events => _events;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;

  CardController() {
    init();
  }

  Future<void> init() async {
    _box = await Hive.openBox<CtfEvent>(_hiveBoxName);
    _metaBox = await Hive.openBox('ctf_meta');

    await loadFromHive();

    final lastFetchMillis = _metaBox.get('lastFetch') as int?;
    final now = DateTime.now();
    final shouldFetch =
        _events.isEmpty ||
        lastFetchMillis == null ||
        now
                .difference(
                  DateTime.fromMillisecondsSinceEpoch(lastFetchMillis),
                )
                .inHours >=
            24;

    if (shouldFetch) {
      if (_events.isNotEmpty) {
        fetchUpcomingEvents(reset: true, showLoading: false);
      } else {
        await fetchUpcomingEvents(reset: true, showLoading: true);
      }
    }
  }

  Future<void> loadFromHive() async {
    _events = _box.values.toList();

    final now = DateTime.now();
    _events.removeWhere((event) {
      if (event.finish != null && event.finish!.isBefore(now)) {
        _box.delete(event.id);
        return true;
      }
      return false;
    });

    _events.sort(
      (a, b) =>
          (a.start ?? DateTime.now()).compareTo(b.start ?? DateTime.now()),
    );

    notifyListeners();
  }

  Future<void> fetchUpcomingEvents({
    bool reset = false,
    bool showLoading = true,
  }) async {
    if (_isLoading && showLoading) return;

    if (reset) {
      _page = 0;
      _hasMore = true;
    }

    if (showLoading) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    } else {
      _errorMessage = null;
    }

    try {
      final now = DateTime.now();
      final oneMonthLater = now.add(const Duration(days: 30));
      final startTimestamp = (now.millisecondsSinceEpoch / 1000).round();
      final finishTimestamp = (oneMonthLater.millisecondsSinceEpoch / 1000)
          .round();

      final url =
          '${Env.apiBaseUrl}${Env.eventsEndpoint}?limit=$_limit&start=$startTimestamp&finish=$finishTimestamp&page=$_page';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final newEvents = jsonList.map((e) => CtfEvent.fromJson(e)).toList();

        for (var event in newEvents) {
          _box.put(event.id, event);

          int index = _events.indexWhere((e) => e.id == event.id);
          if (index >= 0) {
            _events[index] = event;
          } else {
            _events.add(event);
          }
        }

        _events.removeWhere((event) {
          if (event.finish != null && event.finish!.isBefore(now)) {
            _box.delete(event.id);
            return true;
          }
          return false;
        });

        _events.sort(
          (a, b) =>
              (a.start ?? DateTime.now()).compareTo(b.start ?? DateTime.now()),
        );

        if (newEvents.length < _limit) {
          _hasMore = false;
        } else {
          _page++;
        }

        try {
          _metaBox.put('lastFetch', DateTime.now().millisecondsSinceEpoch);
        } catch (_) {}

        notifyListeners();
      } else {
        _errorMessage = 'Failed to load events: ${response.statusCode}';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      notifyListeners();
    } finally {
      if (showLoading) {
        _isLoading = false;
        notifyListeners();
      } else {
        notifyListeners();
      }
    }
  }

  Future<void> setReminder(int eventId, bool value) async {
    try {
      if (!_box.isOpen) {
        await Hive.openBox<CtfEvent>(_hiveBoxName);
      }

      if (_box.containsKey(eventId)) {
        final item = _box.get(eventId);
        if (item != null) {
          try {
            (item as dynamic).reminder = value;
            await _box.put(eventId, item);

            final idx = _events.indexWhere((e) => e.id == eventId);
            if (idx >= 0) {
              _events[idx] = item;
            }

            if (!value) {
              try {
                await NotificationService().cancelForEvent(eventId);
              } catch (_) {}
            }

            notifyListeners();
          } catch (_) {}
        }
      }
    } catch (_) {}
  }
}
