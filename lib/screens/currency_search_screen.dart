import 'package:flutter/material.dart';
import '../models/currency.dart';
import '../services/currency_service.dart';

class CurrencySearchScreen extends StatefulWidget {
  final CurrencyService currencyService;
  final Function(Currency) onCurrencySelected;

  const CurrencySearchScreen({
    super.key,
    required this.currencyService,
    required this.onCurrencySelected,
  });

  @override
  State<CurrencySearchScreen> createState() => _CurrencySearchScreenState();
}

class _CurrencySearchScreenState extends State<CurrencySearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Currency> _searchResults = [];
  List<Currency> _favoriteCurrencies = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  void _loadData() {
    setState(() {
      _searchResults = widget.currencyService.getAllCurrencies();
      _favoriteCurrencies = widget.currencyService.getFavoriteCurrencies();
    });
  }

  void _onSearchChanged() {
    setState(() {
      _searchResults = widget.currencyService.searchCurrencies(_searchController.text);
    });
  }

  void _toggleFavorite(Currency currency) async {
    await widget.currencyService.toggleFavorite(currency.code);
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D3142),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  suffixIcon: Icon(Icons.clear, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                onChanged: (value) => _onSearchChanged(),
              ),
            ),
            
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Favorites section
                    if (_favoriteCurrencies.isNotEmpty) ...[
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.yellow, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Favorite',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.35, // 最多占用35%的屏幕高度
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          itemCount: _favoriteCurrencies.length,
                          itemBuilder: (context, index) {
                            final currency = _favoriteCurrencies[index];
                            return _buildCurrencyListItem(currency, true);
                          },
                        ),
                      ),
                      const Divider(color: Colors.grey, height: 32),
                    ],
                    
                    // All currencies section
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: const Text(
                        'ALL',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    // Currency list
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final currency = _searchResults[index];
                        return _buildCurrencyListItem(currency, currency.isFavorite);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyListItem(Currency currency, bool isFavorite) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF4A5568),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              currency.flag,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        title: Text(
          currency.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          currency.code,
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
        trailing: GestureDetector(
          onTap: () => _toggleFavorite(currency),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Checkbox(
              value: isFavorite,
              onChanged: (value) => _toggleFavorite(currency),
              activeColor: Colors.purple,
              checkColor: Colors.white,
            ),
          ),
        ),
        onTap: () => widget.onCurrencySelected(currency),
      ),
    );
  }
} 