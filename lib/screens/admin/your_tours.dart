import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flufir/controllers/tour_controller.dart';
import 'package:flufir/models/tour_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_card/image_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utils/constant.dart';
import '../../utils/currency_utils.dart';
import 'all_revuene.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/tour_search_bar.dart';
import '../../widgets/tours_filter.dart';
import '../user/tour_details.dart';

class YourToursScreen extends StatefulWidget {
  const YourToursScreen({super.key});

  @override
  _YourToursScreenState createState() => _YourToursScreenState();
}

class _YourToursScreenState extends State<YourToursScreen> {
  final TourController _tourController = Get.find<TourController>();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _searchController = TextEditingController();
  List<TourModel> _userTours = [];
  List<TourModel> _filteredTours = [];
  bool _showFilter = false;
  String _sortCriteria = '';
  bool _isSale = false;
  String _city = '';

  @override
  void initState() {
    super.initState();
    _fetchUserTours();
  }

  void _fetchUserTours() async {
    final userId = currentUser?.uid ?? '';
    final tours = await _tourController.getUserTours(userId);
    setState(() {
      _userTours = tours;
      _filteredTours = tours;
    });
  }

  void _filterTours() async {
    String searchQuery = _searchController.text.toLowerCase();
    searchQuery = removeDiacritics(searchQuery);
    String cityQuery = removeDiacritics(_city);

    List<TourModel> filteredTours = _userTours.where((tour) {
      bool matchesSearch = removeDiacritics(tour.tourName.toLowerCase()).contains(searchQuery);
      bool matchesSale = !_isSale || tour.isSale;
      bool matchesCity = cityQuery.isEmpty || removeDiacritics(tour.tourCity.toLowerCase()).contains(cityQuery);
      return matchesSearch && matchesSale && matchesCity;
    }).toList();

    if (_sortCriteria.isNotEmpty) {
      final sortedTours = await _sortTours(filteredTours);
      setState(() {
        _filteredTours = sortedTours;
      });
    } else {
      setState(() {
        _filteredTours = filteredTours;
      });
    }
  }

  Future<List<TourModel>> _sortTours(List<TourModel> tours) async {
    if (_sortCriteria == 'price_asc') {
      tours.sort((a, b) => _parsePrice(a).compareTo(_parsePrice(b)));
    } else if (_sortCriteria == 'price_desc') {
      tours.sort((a, b) => _parsePrice(b).compareTo(_parsePrice(a)));
    } else if (_sortCriteria == 'date_new') {
      tours.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (_sortCriteria == 'date_old') {
      tours.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else if (_sortCriteria == 'purchase_count') {
      tours = await _sortByPurchaseCount(tours);
    } else if (_sortCriteria == 'last_purchase_date') {
      tours = await _sortByLastPurchaseDate(tours);
    }
    return tours;
  }

  Future<List<TourModel>> _sortByPurchaseCount(List<TourModel> tours) async {
    final List<Map<String, dynamic>> tourDataList = [];

    for (var tour in tours) {
      final ordersQuery = await FirebaseFirestore.instance
          .collectionGroup('userOrders')
          .where('tourId', isEqualTo: tour.tourId)
          .get();
      tourDataList.add({
        'tour': tour,
        'purchaseCount': ordersQuery.docs.length,
      });
    }

    tourDataList.sort((a, b) => b['purchaseCount'].compareTo(a['purchaseCount']));

    return tourDataList.map((data) => data['tour'] as TourModel).toList();
  }

  Future<List<TourModel>> _sortByLastPurchaseDate(List<TourModel> tours) async {
    final List<Map<String, dynamic>> tourDataList = [];

    for (var tour in tours) {
      final ordersQuery = await FirebaseFirestore.instance
          .collectionGroup('userOrders')
          .where('tourId', isEqualTo: tour.tourId)
          .orderBy('createdAt', descending: true)
          .get();

      final lastPurchaseDate = ordersQuery.docs.isNotEmpty
          ? (ordersQuery.docs.first.data()['createdAt'] as Timestamp).toDate()
          : DateTime.fromMillisecondsSinceEpoch(0);

      tourDataList.add({
        'tour': tour,
        'lastPurchaseDate': lastPurchaseDate,
      });
    }

    tourDataList.sort((a, b) => b['lastPurchaseDate'].compareTo(a['lastPurchaseDate']));

    return tourDataList.map((data) => data['tour'] as TourModel).toList();
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
    _fetchUserTours();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstant.appMainColor,
        title: const Text('Your Tours',
            style: TextStyle(color: AppConstant.appTextColor)),
        iconTheme: const IconThemeData(color: AppConstant.appStatusBarColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              Get.to(() => AllToursRevenueScreen());
            },
          ),
        ],
      ),
      drawer: DrawerWidget(user: currentUser),
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
              isUserTours: true, // Chỉ định bộ lọc này là cho YourToursScreen
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
                        child: Text(
                            "Price: ${formatCurrency(tourModel.isSale ? tourModel.salePrice : tourModel.fullPrice)}"),
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
