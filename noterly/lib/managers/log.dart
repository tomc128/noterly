import 'package:logger/logger.dart';
import 'package:noterly/managers/app_manager.dart';

class Log {
  static Logger get logger => AppManager.instance.logger;
}
