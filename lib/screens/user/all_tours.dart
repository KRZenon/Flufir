import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_card/image_card.dart';

import '../../models/tour_model.dart';
import '../../utils/constant.dart';
import '../../utils/currency_utils.dart';
import '../../widgets/tour_search_bar.dart';
import '../../widgets/tours_filter.dart';
import '../user/tour_details.dart';


class AllToursScreen extends StatefulWidget {
  const AllToursScreen({super.key});

  @override
  _AllToursScreenState createState() => _AllToursScreenState();
}

class _AllToursScreenState extends State<AllToursScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<TourModel> _allTours = [];
  List<TourModel> _filteredTours = [];
  bool _showFilter = false;
  String _sortCriteria = '';
  bool _isSale = false;
  String _city = '';

  @override
  void initState() {
    super.initState();
    _fetchTours();
  }

  void _fetchTours() async {
    final snapshot = await FirebaseFirestore.instance.collection('tours').get();
    final tours = snapshot.docs.map((doc) => TourModel.fromMap(doc.data())).toList();

    setState(() {
      _allTours = tours;
      _filteredTours = tours;
    });
  }

  void _filterTours() {
    String searchQuery = _searchController.text.toLowerCase();
    searchQuery = removeDiacritics(searchQuery);
    String cityQuery = removeDiacritics(_city);

    setState(() {
      _filteredTours = _allTours.where((tour) {
        bool matchesSearch = removeDiacritics(tour.tourName.toLowerCase()).contains(searchQuery);
        bool matchesSale = !_isSale || tour.isSale;
        bool matchesCity = cityQuery.isEmpty || removeDiacritics(tour.tourCity.toLowerCase()).contains(cityQuery);
        return matchesSearch && matchesSale && matchesCity;
      }).toList();

      if (_sortCriteria == 'price_asc') {
        _filteredTours.sort((a, b) => _parsePrice(a).compareTo(_parsePrice(b)));
      } else if (_sortCriteria == 'price_desc') {
        _filteredTours.sort((a, b) => _parsePrice(b).compareTo(_parsePrice(a)));
      } else if (_sortCriteria == 'date_new') {
        _filteredTours.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else if (_sortCriteria == 'date_old') {
        _filteredTours.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      }
    });
  }

  double _parsePrice(TourModel tour) {
    try {
      return double.parse(tour.isSale ? tour.salePrice : tour.fullPrice);
    } catch (e) {
      return 0.0;
    }
  }

  void _onSearch(String query) {
    _filterTours();
  }

  void _onChanged(String query) {
    _filterTours();
  }

  void _onSortChanged(String criteria) {
    setState(() {
      _sortCriteria = criteria;
    });
    _filterTours();
  }

  void _onSaleChanged(bool value) {
    setState(() {
      _isSale = value;
    });
    _filterTours();
  }

  void _onCityChanged(String city) {
    setState(() {
      _city = city;
    });
    _filterTours();
  }

  void _onClearSort() {
    setState(() {
      _sortCriteria = '';
      _isSale = false;
      _city = '';
      _searchController.clear();
    });
    _fetchTours(); // Refetch to reset the tours list to the original state
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: AppConstant.appTextColor,
        ),
        backgroundColor: AppConstant.appMainColor,
        title: const Text(
          'All Tours',
          style: TextStyle(color: AppConstant.appTextColor),
        ),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TourSearchBar(
                  controller: _searchController,
                  onSearch: _onSearch,
                  onChanged: _onChanged,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {
                  setState(() {
                    _showFilter = !_showFilter;
                  });
                },
              ),
            ],
          ),
          if (_showFilter)
            TourFilter(
              onSortChanged: _onSortChanged,
              onSaleChanged: _onSaleChanged,
              onCityChanged: _onCityChanged,
              onClearSort: _onClearSort,
            ),
          Expanded(
            child: _filteredTours.isEmpty
                ? const Center(child: Text("No tours found!"))
                : GridView.builder(
              itemCount: _filteredTours.length,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
                childAspectRatio: 0.80,
              ),
              itemBuilder: (context, index) {
                final tourModel = _filteredTours[index];
                return GestureDetector(
                  onTap: () {
                    Get.to(() => TourDetailsScreen(tourModel: tourModel));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FillImageCard(
                      borderRadius: 20.0,
                      width: Get.width / 2.3,
                      heightImage: Get.height / 6,
                      imageProvider: CachedNetworkImageProvider(
                        tourModel.tourImages.isNotEmpty ? tourModel.tourImages[0] : '',
                      ),
                      title: Center(
                        child: Text(
                          tourModel.tourName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(fontSize: 12.0),
                        ),
                      ),
                      footer: Center(
                        child: Text("Price: ${formatCurrency(tourModel.isSale ? tourModel.salePrice : tourModel.fullPrice)}"),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
