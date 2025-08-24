import 'package:talker_flutter/talker_flutter.dart';

enum BookingPageSource {
  checkin,
  messages,
  bookingCalendar,
  toDo,
}

class AppRoutes {
  AppRoutes._();

  /// Auth
  static const String login = '/auth/login';
  static const String otp = '/auth/otp';
  static const String registerGuide = '/auth/register_guide';
  static const String selectCompany = '/auth/select_company';
  static const String deviceSettings = '/auth/device_settings';

  /// Home
  static const String home = '/home';

  /// Calling
  static const String calling = '/calling';
  static const String missedCallDetail = '/calling/missed_call_detail';
  static const String contactRecordDetail = '/calling/contact_record_detail';
  static const String audioCall = '/calling/audio_call';
  static const String videoVerificationCall = '/calling/video_verification_call';
  static const String viewBookingPopup = '/calling/video_view_booking_popup';
  static const String viewGuestPopup = '/calling/video_view_guest_popup';
  static const String callsQueuePopup = '/calling/calls_queue_popup';
  static const String callingAddTodo = '/calling/to_do_add';

  /// Checkin
  static const String checkin = '/checkin';
  static const String bookingDetail = '/checkin/booking_detail';
  static const String bookingSearch = '/checkin/booking_search';

  /// Message
  static const String messages = '/messages';
  static const String msgDetail = '/messages/message_detail';
  static const String msgOrderDetail = '/messages/message_order_detail';
  static const String msgAlterationDetail = '/messages/message_alteration_detail';
  static const String msgTemplate = '/messages/message_template';
  static const String msgTemplateSearch = '/messages/message_template_search';
  static const String messageBookingDetail = '/messages/booking_detail';


  /// Reservations
  static const String reservations = '/reservations';

  /// Orders
  static const String orders = '/orders';

  /// POS
  static const String serviceList = '/pos/service_list';
  static const String serviceMenu = '/pos/service_menu';
  static const String shoppingCart = '/pos/shopping_cart';
  static const String orderDetail = '/pos/order_detail';
  static const String reserveItemPopup = '/pos/reserve_item_popup';
  static const String variationItemPopup = '/pos/variation_item_popup';
  static const String modifierItemPopup = '/pos/modifier_item_popup';
  static const String recordPaymentPopup = '/pos/record_payment_popup';

  /// Booking calendar
  static const String bookingCalendar = '/booking_calendar';
  static const String bcBookingDetail = '/booking_calendar/booking_detail';
  static const String blockBookingDetail = '/booking_calendar/block_booking_detail';

  /// Cleaning
  static const String cleaning = '/cleaning';
  static const String cleaningDetail = '/cleaning/cleaning_detail';

  /// To-do
  static const String toDo = '/todo';
  static const String toDoList = '/todo/to_do_list';
  static const String toDoDetail = '/todo/to_do_detail';
  static const String toDoAddPopup = '/todo/to_do_add_popup';
  static const String toDoEditPopup = '/todo/to_do_edit_popup';
  static const String toDoBookingDetail = '/todo/booking_detail';

  /// Settings
  static const String settings = '/settings';
  static const String language = '/settings/language';
  static const String facility = '/settings/facility';
  static const String themeColor = '/settings/theme_color';
  static const String darkMode = '/settings/dark_mode';
  static const String contactUs = '/settings/contact_us';
  static const String helpCenter = '/settings/help_center';
  static const String about = '/settings/about';

  /// Common
  static const String camera = '/common/camera';
  static const String pdfViewer = '/common/pdf_viewer';
  static const String scanQrCode = '/common/scan_qr_code';
  static const String signature = '/common/signature';
  static const String signaturePad = '/common/signature_pad';
  static const String webview = '/common/webview';
  static const String log = '/common/log';


  /// Type -> routeName Mapping
  static const Map<Type, String> _routeNames = <Type, String>{
    TalkerScreen: log,
  };

  static String? nameFor(Type pageType) {
    if (!_routeNames.containsKey(pageType)) {
      return null;
    }
    return _routeNames[pageType];
  }
}

class AppChildRoutes {
  static const String guestList = '/guest_list';
  static const String editRoomInfo = '/edit_room_info';
  static const String editGuestInfo = '/edit_guest_info';
  static const String addGuest = '/add_guest';
}