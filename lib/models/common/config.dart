import 'package:json_annotation/json_annotation.dart';

part 'config.g.dart';

@JsonSerializable()
class Config {
  final String env;
  final bool production;

  const Config({
    this.env,
    this.production,
  });

  Config copyWith({
    String env,
    bool firstLaunch,
    bool firstTutorialLaunch,
    bool production,
    String storageKey,
    String apiBaseUrl,
  }) =>
      Config(
        env: env ?? this.env,
        production: production ?? this.production,
      );

  factory Config.fromJson(Map<String, dynamic> json) => _$ConfigFromJson(json);

  Map<String, dynamic> toJson() => _$ConfigToJson(this);

  @override
  String toString() => 'Config{env: $env, production: $production}';
}
