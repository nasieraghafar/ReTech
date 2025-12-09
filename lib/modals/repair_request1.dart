class Requests {
  String id;
  String title;
  String deviceType;
  String detail;
  String imageUrl;
  DateTime createDate;
  String email;

  Requests(
      {required this.id,
      required this.title,
      required this.deviceType,
      required this.detail,
      required this.imageUrl,
      required this.createDate,
      required this.email});
}
