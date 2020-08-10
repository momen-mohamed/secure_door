
// User model used to manipulate user information.

class User {
  User({
    this.mobileNumber,
    this.lockNumber,
    this.partNumber,
  });

  String mobileNumber;
  String lockNumber;
  String partNumber;

  factory User.fromJson(Map<String, dynamic> json) => User(
    mobileNumber: json["mobileNumber"],
    lockNumber: json["lockNumber"],
    partNumber: json["partNumber"],
  );

  Map<String, dynamic> toJson() => {
    "mobileNumber": mobileNumber,
    "lockNumber": lockNumber,
    "partNumber": partNumber,
  };
}