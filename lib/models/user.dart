enum Gender { MALE, FEMALE }

class User {
  final String name;
  final String phone;
  final String address;
  final String weight;
  final String height;
  final Gender gender;
  final DateTime birthday;

  User(
      {required this.name,
      required this.phone,
      required this.address,
      required this.weight,
      required this.height,
      required this.gender,
      required this.birthday});
}
