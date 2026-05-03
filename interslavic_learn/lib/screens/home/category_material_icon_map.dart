import 'package:flutter/material.dart';

/// Соответствие строки `Category.icon` из JSON/БД иконке Material.
IconData categoryMaterialIcon(String key) =>
    kCategoryMaterialIconMap[key] ?? Icons.book;

const Map<String, IconData> kCategoryMaterialIconMap = {
  'school': Icons.school,
  'waving_hand': Icons.waving_hand,
  'restaurant': Icons.restaurant,
  'family_restroom': Icons.family_restroom,
  'pin': Icons.pin,
  'palette': Icons.palette,
  'flight': Icons.flight,
  'menu_book': Icons.menu_book,
  'record_voice_over': Icons.record_voice_over,
  'calendar_month': Icons.calendar_month,
  'schedule': Icons.schedule,
  'home': Icons.home,
  'local_cafe': Icons.local_cafe,
  'navigation': Icons.navigation,
  'hotel': Icons.hotel,
  'shopping_cart': Icons.shopping_cart,
  'local_pharmacy': Icons.local_pharmacy,
  'emergency': Icons.emergency,
  'location_city': Icons.location_city,
  'work': Icons.work,
  'sports_esports': Icons.sports_esports,
  'park': Icons.park,
  'directions_run': Icons.directions_run,
  'swap_horiz': Icons.swap_horiz,
  'format_color_fill': Icons.format_color_fill,
  'touch_app': Icons.touch_app,
  'help_outline': Icons.help_outline,
  'history': Icons.history,
  'update': Icons.update,
  'campaign': Icons.campaign,
  'account_tree': Icons.account_tree,
  'format_align_center': Icons.format_align_center,
  'badge': Icons.badge,
  'device_hub': Icons.device_hub,
  'groups': Icons.groups,
  'forum': Icons.forum,
};
