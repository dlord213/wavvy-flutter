enum APP_SETTINGS {
  SHOULD_SETUP(keyValue: "SHOULD_SETUP"),
  STORAGE_ACCESS_GRANTED(keyValue: "STORAGE_ACCESS_GRANTED"),
  DARK_MODE_TURNED_ON(keyValue: "DARK_MODE_TURNED_ON");

  const APP_SETTINGS({required this.keyValue});

  final String keyValue;
}
