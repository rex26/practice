import 'package:flutter/material.dart';

enum LogLevel { off, medium, detail }

enum FacilityType {
  restaurant,
  swimming_pool,
  gym,
  front_desk,
  spa,
  kids_club,
  bar,
  room_service,
}

enum PredefinedFieldType { full_name, first_name, last_name, phone, email }

enum FormFieldType { input, textarea, checkbox, yes_or_no, block_of_text }

// Whether the user has chosen a theme color via a direct [ColorSeed] selection,
// or an image [ColorImageProvider].
enum ColorSelectionMethod {
  colorSeed,
  image,
}

enum ColorSeed {
  baseColor('Baseline', Color(0xff00d28e)),
  indigo('Indigo', Colors.indigo),
  blue('Blue', Colors.blue),
  teal('Teal', Colors.teal),
  green('Green', Colors.green),
  yellow('Yellow', Colors.yellow),
  orange('Orange', Colors.orange),
  deepOrange('Deep Orange', Colors.deepOrange),
  pink('Pink', Colors.pink);

  const ColorSeed(this.label, this.color);
  final String label;
  final Color color;
}

enum ScreenSelected {
  intercom('intercom'),
  reservation('reservation_product'),
  restaurant('restaurant_order'),
  task('task'),
  booking('guest_checkin');

  const ScreenSelected(this.value);
  final String value;
}

enum HomeDrawerType {
  messageOtaOrder,
  messageAlteration,
  messageTemplate,
  bookingDetail,
}
