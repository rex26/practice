import 'app_secret.dart';
import 'package:envied/envied.dart';

part 'production_secret.g.dart';

@Envied(
  path: 'env/.env.prod',
  obfuscate: false,
)
class ProductionSecret implements AppSecret, AppEnvFields {
  @override
  @EnviedField(varName: 'SECRET_KEY')
  final String secretKey = _ProductionSecret.secretKey;

  @override
  @EnviedField(varName: 'LOG_LEVEL')
  final String logLevel = _ProductionSecret.logLevel;
}
