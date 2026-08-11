import 'package:task_manager_cli/cli/cli_app.dart';

// Entry point. Tasks are persisted in "tasks.json" next to where
// the app is run from.
Future<void> main() async {
  final app = CliApp('tasks.json');
  await app.run();
}
