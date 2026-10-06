import 'package:cloud_firestore/cloud_firestore.dart';

class UltrasoundModel {
  final String id;
  final String title;
  final String description;
  final String image;
  final double price;
  final bool isActive;
  final int order;
  final List<DaySchedule> availableDays;

  const UltrasoundModel({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.price,
    required this.isActive,
    required this.order,
    required this.availableDays,
  });

  factory UltrasoundModel.fromMap({
    required String id,
    required Map<String, dynamic> map,
    List<DaySchedule> availableDays = const <DaySchedule>[],
  }) {
    return UltrasoundModel(
      id: _readString(map, const ['id'], fallback: id),
      title: _readString(map, const [
        'name_en',
        'title_en',
        'nameEn',
        'titleEn',
      ], fallback: id),
      description: _readString(map, const [
        'description_en',
        'descriptionEn',
        'desc_en',
        'descEn',
      ], fallback: ''),
      image: _readString(map, const [
        'image',
        'image_url',
        'imageUrl',
      ], fallback: ''),
      price: _readNum(map, const ['price'], fallback: 0).toDouble(),
      isActive: _readBool(map, const ['isActive', 'active'], fallback: true),
      order: _readInt(map, const ['order', 'sort', 'priority'], fallback: 0),
      availableDays: availableDays,
    );
  }

  String titleForLanguage(String languageCode) {
    final isArabic = languageCode.toLowerCase().startsWith('ar');
    final ar = _readString(const <String, dynamic>{}, const [], fallback: '');
    if (isArabic && ar.isNotEmpty) {
      return ar;
    }
    return title;
  }
}

class DaySchedule {
  final String day;
  final List<TimeSlot> slots;

  const DaySchedule({required this.day, required this.slots});
}

class TimeSlot {
  final String time;
  final int maxBookings;
  final int currentBookings;

  const TimeSlot({
    required this.time,
    required this.maxBookings,
    required this.currentBookings,
  });

  bool get isFull => currentBookings >= maxBookings;
  bool get isAvailable => currentBookings < maxBookings;

  int get remainingSlots =>
      (maxBookings - currentBookings).clamp(0, maxBookings);
}

class UltrasoundData {
  UltrasoundData._();

  static const String _collection = 'radiology_category';
  static const String _documentId = 'ultrasound';

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<List<UltrasoundModel>> loadFromFirestore() async {
    print('==================================================');
    print('🚀 [ULTRASOUND] Starting direct Firestore fetch...');
    print('📂 [ULTRASOUND] Path: $_collection/$_documentId');

    try {
      final doc = await _firestore
          .collection(_collection)
          .doc(_documentId)
          .get(const GetOptions(source: Source.server));

      print('✅ [ULTRASOUND] Document fetched.');
      print('ℹ️  [ULTRASOUND] Exists: ${doc.exists}');
      print('ℹ️  [ULTRASOUND] Doc ID: ${doc.id}');

      if (!doc.exists) {
        print('❌ [ULTRASOUND] Document not found.');
        return <UltrasoundModel>[];
      }

      final data = doc.data();
      if (data == null || data.isEmpty) {
        print('❌ [ULTRASOUND] Document data is empty.');
        return <UltrasoundModel>[];
      }

      print('ℹ️  [ULTRASOUND] Top-level keys: ${data.keys.join(', ')}');

      final rawUltrasound = _extractUltrasoundMap(data);

      if (rawUltrasound.isEmpty) {
        print(
          '❌ [ULTRASOUND] No ultrasound map found. Expected key "ultrasound".',
        );
        return <UltrasoundModel>[];
      }

      print('✅ [ULTRASOUND] Found items: ${rawUltrasound.length}');

      final items = <UltrasoundModel>[];

      for (final entry in rawUltrasound.entries) {
        final key = entry.key;
        final rawValue = entry.value;

        if (rawValue is! Map) {
          print('⚠️  [ULTRASOUND] Skipped "$key" because it is not a map.');
          continue;
        }
        final value = Map<String, dynamic>.from(rawValue);

        try {
          final isActive = _readBool(value, const [
            'isActive',
            'active',
          ], fallback: true);

          if (!isActive) {
            print('⚠️  [ULTRASOUND] Skipped "$key" because isActive=false.');
            continue;
          }

          final model = UltrasoundModel.fromMap(
            id: _readString(value, const ['id'], fallback: key),
            map: value,
            availableDays: _parseAvailableDays(
              value,
              seed: _readString(value, const ['id'], fallback: key),
            ),
          );

          items.add(model);

          print(
            '🧾 [ULTRASOUND] Item => id=${model.id}, '
            'title=${model.title}, '
            'price=${model.price}, '
            'image=${model.image}',
          );
        } catch (e) {
          print('💥 [ULTRASOUND] Parse error for "$key": $e');
        }
      }

      items.sort((a, b) {
        final orderCompare = a.order.compareTo(b.order);
        if (orderCompare != 0) return orderCompare;
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      });

      print('✅ [ULTRASOUND] Final items count: ${items.length}');
      print('==================================================');

      return items;
    } catch (e, stack) {
      print('💥 [ULTRASOUND] Firestore fetch error: $e');
      print('💥 [ULTRASOUND] Stack: $stack');
      print('==================================================');
      return <UltrasoundModel>[];
    }
  }

  static Map<String, dynamic> _extractUltrasoundMap(Map<String, dynamic> data) {
    final ultrasound = data['ultrasound'];
    if (ultrasound is Map) {
      return Map<String, dynamic>.from(ultrasound);
    }

    final directMap = <String, dynamic>{};
    for (final entry in data.entries) {
      if (entry.value is Map) {
        final map = Map<String, dynamic>.from(entry.value as Map);
        if (map.containsKey('name_en') ||
            map.containsKey('description_en') ||
            map.containsKey('image') ||
            map.containsKey('price')) {
          directMap[entry.key] = map;
        }
      }
    }
    return directMap;
  }

  static List<DaySchedule> _parseAvailableDays(
    Map<String, dynamic> map, {
    required String seed,
  }) {
    final raw =
        map['available_days'] ??
        map['availableDays'] ??
        map['schedule'] ??
        map['schedules'];

    if (raw is List) {
      final parsed = <DaySchedule>[];

      for (final rawItem in raw) {
        if (rawItem is! Map) continue;
        final item = Map<String, dynamic>.from(rawItem);

        final day = _readString(item, const ['day'], fallback: '');
        final slotsRaw = item['slots'];

        if (day.trim().isEmpty) continue;

        parsed.add(DaySchedule(day: day, slots: _parseSlots(slotsRaw)));
      }

      if (parsed.isNotEmpty) return parsed;
    }

    if (raw is Map) {
      final rawMap = Map<String, dynamic>.from(raw);
      final parsed = <DaySchedule>[];

      for (final entry in rawMap.entries) {
        final day = entry.key;
        final slots = _parseSlots(entry.value);

        if (slots.isEmpty) continue;

        parsed.add(DaySchedule(day: day, slots: slots));
      }

      if (parsed.isNotEmpty) return parsed;
    }

    return _buildFallbackSchedule(seed);
  }

  static List<TimeSlot> _parseSlots(dynamic raw) {
    if (raw is! List) return const <TimeSlot>[];

    final slots = <TimeSlot>[];

    for (final rawItem in raw) {
      if (rawItem is! Map) continue;
      final item = Map<String, dynamic>.from(rawItem);

      slots.add(
        TimeSlot(
          time: _readString(item, const ['time'], fallback: ''),
          maxBookings: _readInt(item, const ['maxBookings'], fallback: 0),
          currentBookings: _readInt(item, const [
            'currentBookings',
          ], fallback: 0),
        ),
      );
    }

    return slots;
  }

  static List<DaySchedule> _buildFallbackSchedule(String seed) {
    final dayNames = ['Monday', 'Wednesday', 'Thursday', 'Saturday'];
    final offset = seed.hashCode.abs() % dayNames.length;

    return List.generate(2, (index) {
      final day = dayNames[(offset + index) % dayNames.length];
      return DaySchedule(
        day: day,
        slots: [
          TimeSlot(
            time: '09:00 AM',
            maxBookings: 3,
            currentBookings: (seed.hashCode + index) % 3,
          ),
          TimeSlot(
            time: '12:00 PM',
            maxBookings: 3,
            currentBookings: (seed.hashCode + index + 1) % 3,
          ),
          TimeSlot(
            time: '03:00 PM',
            maxBookings: 3,
            currentBookings: (seed.hashCode + index + 2) % 3,
          ),
        ],
      );
    });
  }
}

String _readString(
  Map<String, dynamic> map,
  List<String> keys, {
  required String fallback,
}) {
  for (final key in keys) {
    final value = map[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString();
    }
  }
  return fallback;
}

int _readInt(
  Map<String, dynamic> map,
  List<String> keys, {
  required int fallback,
}) {
  for (final key in keys) {
    final value = map[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    final parsed = int.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;
  }
  return fallback;
}

num _readNum(
  Map<String, dynamic> map,
  List<String> keys, {
  required num fallback,
}) {
  for (final key in keys) {
    final value = map[key];
    if (value is num) return value;
    final parsed = num.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;
  }
  return fallback;
}

bool _readBool(
  Map<String, dynamic> map,
  List<String> keys, {
  required bool fallback,
}) {
  for (final key in keys) {
    final value = map[key];
    if (value is bool) return value;
    final text = value?.toString().trim().toLowerCase();
    if (text == 'true') return true;
    if (text == 'false') return false;
  }
  return fallback;
}
