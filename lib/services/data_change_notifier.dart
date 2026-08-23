import 'package:flutter/foundation.dart';

class DataChangeNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}
