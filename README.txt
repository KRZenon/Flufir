Phiên bản Android Studio: Android Studio Koala | 2024.1.1
Phiên bản Flutter: 3.19.5
Phiên bản Dart: 3.3.3

Cập nhật file pubspec.yaml như bên dưới để tải các thư viện cần thiết và lưu đường dẫn truy vấn hình ảnh:

name: flufir
description: "A new Flutter project."
publish_to: 'none'
version: 1.0.0+1
environment:
  sdk: '>=3.3.3 <4.0.0'
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6
  lottie: ^3.1.0
  get: ^4.6.6
  flutter_keyboard_visibility: ^6.0.0
  google_sign_in: ^6.2.1
  flutter_easyloading: ^3.0.5
  cached_network_image: ^3.3.1
  carousel_slider: ^4.2.1
  firebase_messaging: ^14.9.1
  firebase_core: ^2.30.1
  image_card: ^0.0.4
  flutter_swipe_action_cell: ^3.1.3
  url_launcher: ^6.2.6
  firebase_auth: ^4.19.3
  cloud_firestore: ^4.17.2
  firebase_storage: ^11.7.2
  image_picker: ^1.1.1
  permission_handler: ^11.3.1
  device_info_plus: ^10.1.0
  http: ^1.2.1
  intl: any
  diacritic: ^0.1.5
  flutter_rating_bar: ^4.0.1
  fl_chart: ^0.68.0
  video_player: ^2.8.7

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/
Sau đó nhấn pub get.

Yêu cầu thiết lập Firebase để sử dụng Firebase Authentication, Firestore Database, Firebase Storage.
Yêu cầu tạo tài khoản và lấy API thời tiết từ OpenWeatherMap từ link:https://openweathermap.org/
Khi được API key thì dán vào dòng String apiKey = 'API key vừa lấy được'; trong file weather_widget.dart
Sau khi hoàn tất thì có thể build và chạy ứng dụng



