import 'package:envied/envied.dart';
import 'app_secret.dart';

part 'development_secret.g.dart';

@Envied(
  path: 'env/.env.stage',
  obfuscate: false,
)
class DevelopmentSecret implements AppSecret, AppEnvFields {
  @override
  @EnviedField(varName: 'SECRET_KEY')
  final String secretKey = _DevelopmentSecret.secretKey;

  @override
  @EnviedField(varName: 'LOG_LEVEL')
  final String logLevel = _DevelopmentSecret.logLevel;
}
