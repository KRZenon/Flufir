import 'package:flutter/material.dart';
import 'package:diacritic/diacritic.dart';

class TourFilter extends StatefulWidget {
  final Function(String) onSortChanged;
  final Function(bool) onSaleChanged;
  final Function(String) onCityChanged;
  final VoidCallback onClearSort;
  final bool isUserTours; // Thêm biến này để xác định màn hình nào đang sử dụng bộ lọc này

  TourFilter({
    required this.onSortChanged,
    required this.onSaleChanged,
    required this.onCityChanged,
    required this.onClearSort,
    this.isUserTours = false, // Mặc định là false để không ảnh hưởng tới AllToursScreen
  });

  @override
  _TourFilterState createState() => _TourFilterState();
}

class _TourFilterState extends State<TourFilter> {
  String _sortCriteria = '';
  bool _isSale = false;
  String _city = '';

  void _updateSortCriteria(String value) {
    setState(() {
      _sortCriteria = value;
    });
    widget.onSortChanged(value);
  }

  void _updateSale(bool value) {
    setState(() {
      _isSale = value;
    });
    widget.onSaleChanged(value);
  }

  void _updateCity(String value) {
    setState(() {
      _city = value;
    });
    widget.onCityChanged(value);
  }

  void _clearSort() {
    setState(() {
      _sortCriteria = '';
      _isSale = false;
      _city = '';
    });
    widget.onClearSort();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Sale'),
          value: _isSale,
          onChanged: _updateSale,
        ),
        TextField(
          decoration: const InputDecoration(
            labelText: 'City',
          ),
          onChanged: (value) =>
              _updateCity(removeDiacritics(value.toLowerCase())),
        ),
        if (_city.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text('Current city filter: $_city'),
          ),
        DropdownButton<String>(
          value: _sortCriteria.isEmpty ? null : _sortCriteria,
          hint: const Text('Sort by'),
          items: [
            DropdownMenuItem(
              value: 'price_asc',
              child: Row(
                children: [
                  if (_sortCriteria == 'price_asc') Icon(Icons.check),
                  const Text('Price: Low to High'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'price_desc',
              child: Row(
                children: [
                  if (_sortCriteria == 'price_desc') Icon(Icons.check),
                  const Text('Price: High to Low'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'date_new',
              child: Row(
                children: [
                  if (_sortCriteria == 'date_new') Icon(Icons.check),
                  const Text('Date: Newest First'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'date_old',
              child: Row(
                children: [
                  if (_sortCriteria == 'date_old') Icon(Icons.check),
                  const Text('Date: Oldest First'),
                ],
              ),
            ),
            if (widget.isUserTours) ...[
              DropdownMenuItem(
                value: 'purchase_count',
                child: Row(
                  children: [
                    if (_sortCriteria == 'purchase_count') Icon(Icons.check),
                    const Text('Purchase Count'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'last_purchase_date',
                child: Row(
                  children: [
                    if (_sortCriteria == 'last_purchase_date') Icon(Icons.check),
                    const Text('Last Purchase Date'),
                  ],
                ),
              ),
            ],
          ],
          onChanged: (value) {
            if (value != null) {
              _updateSortCriteria(value);
            }
          },
        ),
        ElevatedButton(
          onPressed: _clearSort,
          child: const Text('Clear Sort'),
        ),
      ],
    );
  }
}
