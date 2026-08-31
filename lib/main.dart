import 'package:soulsync/app/app.dart';
import 'package:soulsync/app/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const SoulSyncApp());
}
