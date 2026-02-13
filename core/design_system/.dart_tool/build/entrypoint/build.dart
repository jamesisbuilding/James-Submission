// @dart=3.6
// ignore_for_file: directives_ordering
// build_runner >=2.4.16
// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:build_runner/src/build_plan/builder_factories.dart' as _i1;
import 'package:flutter_gen_runner/flutter_gen_runner.dart' as _i2;
import 'dart:io' as _i3;
import 'package:build_runner/src/bootstrap/processes.dart' as _i4;

final _builderFactories = _i1.BuilderFactories(
  {
    'flutter_gen_runner:flutter_gen_runner': [_i2.build]
  },
  postProcessBuilderFactories: {},
);
void main(List<String> args) async {
  _i3.exitCode = await _i4.ChildProcess.run(
    args,
    _builderFactories,
  )!;
}
