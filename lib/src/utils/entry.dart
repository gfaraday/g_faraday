class FaradayEntry {
  final bool isNative;
  const FaradayEntry({this.isNative = false});
}

const entry = FaradayEntry();
const nativeEntry = FaradayEntry(isNative: true);
