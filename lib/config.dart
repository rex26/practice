
enum Environment { dev, stage, prod }

final ApiKeys devApiKeys = ApiKeys(
  clientId: 'zPA2v_lR9Kv04SarcyWWJr-6nkOcH6rq65LU9eA8SDU',
  iosICMApiKey: 'ios_sdk-1ab0af8c2214cf9ac9f93a1c3b59daad99eea3d5',
  androidICMApiKey: 'android_sdk-f38da5896db6ca9040a9209ee97d6727b929dc01',
);

final ApiKeys stageApiKeys = ApiKeys(
  clientId: 'zPA2v_lR9Kv04SarcyWWJr-6nkOcH6rq65LU9eA8SDU',
  iosICMApiKey: 'ios_sdk-1ab0af8c2214cf9ac9f93a1c3b59daad99eea3d5',
  androidICMApiKey: 'android_sdk-f38da5896db6ca9040a9209ee97d6727b929dc01',
);

final ApiKeys prodApiKeys = ApiKeys(
  clientId: 'z3xm4QwhdsaADSvCRubTXMIXeoIyRrH6hmhOTSzLzXY',
  iosICMApiKey: 'ios_sdk-cb8354de206588ec789be0a784bee661de0f8daf',
  androidICMApiKey: 'android_sdk-25790a73a2f2298069696eb7790d823474c6d334',
);

class AppConfig {
  static const Environment currentEnvironment = Environment.stage;

  AppConfig._();

  static ApiKeys get apiKeys => _getApiKeys();

  static String get baseURL => 'https://jsonplaceholder.typicode.com';

  static String get webSocketURL => '';

  static String? get proxyIP => '';

  static bool get logOutputToConsole => true;

  static String get qrHost => '';

  static bool get isGA4TrackingEnabled => true;

  static bool get isProd => currentEnvironment == Environment.prod;
  static bool get isStage => currentEnvironment == Environment.stage;
  static bool get isDev => currentEnvironment == Environment.dev;

  static String get iosICMApiKey => apiKeys.iosICMApiKey;

  static String get androidICMApiKey => apiKeys.androidICMApiKey;

  static ApiKeys _getApiKeys() {
    switch (currentEnvironment) {
      case Environment.dev:
        return devApiKeys;
      case Environment.stage:
        return stageApiKeys;
      case Environment.prod:
        return prodApiKeys;
    }
  }
}


class ApiKeys {
  final String clientId;
  final String iosICMApiKey;
  final String androidICMApiKey;

  ApiKeys({
    required this.clientId,
    required this.iosICMApiKey,
    required this.androidICMApiKey,
  });
}