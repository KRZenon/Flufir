import 'package:flutter/material.dart';
import '../screens/user/single_category_tour.dart'; // Thay thế đường dẫn này bằng đúng đường dẫn của file single_category_tour.dart

class CategoryWidget extends StatelessWidget {
  CategoryWidget({super.key});

  final List<String> cities = [
    'Hồ Chí Minh',
    'Đà Lạt',
    'Huế',
    'Hà Nội',
    'Nha Trang',
  ];

  final List<Color> cityColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cities.length,
        itemBuilder: (context, index) {
          final city = cities[index];
          final cityColor = cityColors[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SingleCategoryTourScreen(selectedCity: city), // Truyền tên thành phố vào SingleCategoryTourScreen
                ),
              );
            },
            child: Container(
              width: 100,
              color: cityColor,
              child: Center(
                child: Text(
                  city,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
