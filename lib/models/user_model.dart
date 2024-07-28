class UserModel {
  final String uId;
  final String username;
  final String email;
  final String phone;
  final String userImg;
  final String userAddress;
  final String street;
  final bool isAdmin;
  final dynamic createdOn;
  final String city;

  UserModel({
    required this.uId,
    required this.username,
    required this.email,
    required this.phone,
    required this.userImg,
    required this.userAddress,
    required this.street,
    required this.isAdmin,
    required this.createdOn,
    required this.city,
  });


  Map<String, dynamic> toMap() {
    return {
      'uId': uId,
      'username': username,
      'email': email,
      'phone': phone,
      'userImg': userImg,
      'userAddress': userAddress,
      'street': street,
      'isAdmin': isAdmin,
      'createdOn': createdOn,
      'city': city,
    };
  }


  factory UserModel.fromMap(Map<String, dynamic> json) {
    return UserModel(
      uId: json['uId'],
      username: json['username'],
      email: json['email'],
      phone: json['phone'],
      userImg: json['userImg'],
      userAddress: json['userAddress'],
      street: json['street'],
      isAdmin: json['isAdmin'],
      createdOn: json['createdOn'].toString(),
      city: json['city'],
    );
  }

}
