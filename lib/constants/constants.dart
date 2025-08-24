class Constants {
  static String currentLanguageCode = 'en_US';
  static const String isAPINotUseSelfDeviceUid = 'isAPINotUseSelfDeviceUid';
  static const String agoraID = 'd30ed447756a4706a8b8bf87b1698bd2';

  // check in status
  static const String beforeCheckIn = 'before_checkin';
  static const String preCheckedIn = 'pre_checked_in';
  static const String checkedIn = 'checked_in';
  static const String checkedOut = 'checked_out';

  // booking status
  static const String confirmed = 'confirmed';
  static const String overlapped = 'overlapped';
  static const String cancelled = 'cancelled';

  // check-in flow
  static const String preCheckInReady = 'pre_checkin_ready';
  static const String checkInReady = 'checkin_ready';
  static const String staying = 'staying';
  static const String departure = 'departure';
  static const String checkInFlowCancelled = 'cancelled';

  static const String qrPath = '/v2/checkin/booking';

  // regex for search booking
  static const String stageExp = r'^https:\/\/[\w+\-]+\.airhost\.co$';
  static const String prodExp = r'^https:\/\/[\w+\-]+\.onestayapp\.com$';
  static const String yyyyMMddFormat = 'yyyy-MM-dd';
  static const String hhMMFormat = 'HH:mm';
  static const String hhMMAFormat = 'hh:mm a';

  static const double pageWidthRatio = 0.6;
  static const double popModalWidthRatio = 0.625;
  static const double popModalHeightRatio = 0.85;
  static const double popModalMaxHeightRatio = 0.95;

  // intercom event names
  static const String fcmInitialized = 'intercom.fcm.initialized';
  static const String fcmHangup = 'intercom.fcm.hungup';
  static const String fcmAccepted = 'intercom.fcm.accepted';

  static const String wsmqInitialized = 'intercom.wsmq.initialized';
  static const String wsmqAccepted = 'intercom.wsmq.accepted';
  static const String wsmqJoined = 'intercom.wsmq.joined';
  static const String wsmqHangup = 'intercom.wsmq.hungup';

  /// The time to live for the intercom fcm message in seconds.
  static const int intercomFcmMessageTTL = 60;

  static const int intercomTimeout = 120;

  /// flutter incoming plugin's specific event name
  static const String forwardFcmMessage = 'forwardFcmMessage';

  static const double listFootSpace = 80;
  static const double calendarRadius = 8;

  static const Map<String, String> languagesMap = <String, String>{
    'en': 'English',
    'ja': '日本語',
    'zh-CN': '简体中文',
    'zh': '繁體中文',
  };

  static const int maxInt = 4294967296;
}