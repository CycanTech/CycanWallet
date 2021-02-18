
//初始化Bus
import 'package:event_bus/event_bus.dart';

EventBus eventBus = EventBus();

class ConvertEvent {
  int value;
  ConvertEvent(int value) {
    this.value = value;
  }
}
