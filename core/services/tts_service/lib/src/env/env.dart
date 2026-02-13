import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'ELEVENLABS_API_KEY', obfuscate: true)
  static final String elevenLabsApiKey = _Env.elevenLabsApiKey;
}
