import 'package:practice/envied/development_secret.dart';
import 'package:practice/envied/production_secret.dart';

abstract class AppEnvFields {
  String get secretKey;
  String get logLevel;
}

abstract class AppSecret implements AppEnvFields {
  static const String environment = String.fromEnvironment('ENV', defaultValue: 'prod');

  static final AppSecret _instance = environment == 'prod' ? ProductionSecret() : DevelopmentSecret();

  factory AppSecret() => _instance;
}
