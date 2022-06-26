class APlayerConstant {
  static const methodChannelName = "a_player";
  static const playerEventChanneName = "a_player:event_";
  static const playerMethodChannelName = "a_player:method_";
}
class APlayerConfigHeader {
  final String key;
  final String value;

  APlayerConfigHeader(this.key, this.value);
}