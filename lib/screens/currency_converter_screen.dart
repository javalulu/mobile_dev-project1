import 'package:flutter/material.dart';
import '../models/currency.dart';
import '../services/currency_service.dart';
import '../widgets/currency_card.dart';
import '../widgets/custom_keyboard.dart';
import 'currency_search_screen.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final CurrencyService _currencyService = CurrencyService();
  final PageController _pageController = PageController(initialPage: 1);
  
  List<Currency> _displayedCurrencies = [];
  Currency? _selectedCurrency;
  String _inputAmount = '';
  bool _showKeyboard = false;
  
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _currencyService.loadFavorites();
    
    // Get initial currencies to display (favorites + some popular ones)
    final favorites = _currencyService.getFavoriteCurrencies();
    final allCurrencies = _currencyService.getAllCurrencies();
    
    // Default currencies to show if no favorites
    final defaultCurrencies = ['USD', 'EUR', 'GBP', 'JPY', 'KRW', 'CNY', 'THB', 'SGD'];
    
    setState(() {
      if (favorites.isNotEmpty) {
        _displayedCurrencies = favorites;
      } else {
        _displayedCurrencies = allCurrencies
            .where((currency) => defaultCurrencies.contains(currency.code))
            .toList();
      }
      
      // Set initial amounts - first currency 100, others converted from first
      if (_displayedCurrencies.isNotEmpty) {
        _displayedCurrencies[0].amount = 100.0;
        for (int i = 1; i < _displayedCurrencies.length; i++) {
          _displayedCurrencies[i].amount = _currencyService.convertCurrency(
            100.0,
            _displayedCurrencies[0].code,
            _displayedCurrencies[i].code,
          );
        }
      }
    });
  }

  void _selectCurrency(Currency currency) {
    setState(() {
      // Deselect all currencies
      for (var c in _displayedCurrencies) {
        c.isSelected = false;
      }
      
      // Select the tapped currency
      currency.isSelected = true;
      _selectedCurrency = currency;
      _inputAmount = currency.amount.toStringAsFixed(2);
      _showKeyboard = true;
    });
  }

  void _onKeyPress(String key) {
    setState(() {
      if (key == '.') {
        if (!_inputAmount.contains('.')) {
          _inputAmount += key;
        }
      } else {
        if (_inputAmount == '0.00' || _inputAmount.isEmpty) {
          _inputAmount = key;
        } else {
          _inputAmount += key;
        }
      }
      _updateCurrencyAmounts();
    });
  }

  void _onClear() {
    setState(() {
      _inputAmount = '';
      if (_selectedCurrency != null) {
        _selectedCurrency!.amount = 0.0;
        _updateCurrencyAmounts();
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_inputAmount.isNotEmpty) {
        _inputAmount = _inputAmount.substring(0, _inputAmount.length - 1);
        _updateCurrencyAmounts();
      }
    });
  }

  void _updateCurrencyAmounts() {
    if (_selectedCurrency == null || _inputAmount.isEmpty) return;
    
    final inputValue = double.tryParse(_inputAmount) ?? 0.0;
    _selectedCurrency!.amount = inputValue;
    
    // Convert to all other currencies
    for (var currency in _displayedCurrencies) {
      if (currency != _selectedCurrency) {
        currency.amount = _currencyService.convertCurrency(
          inputValue,
          _selectedCurrency!.code,
          currency.code,
        );
      }
    }
  }

  void _hideKeyboard() {
    setState(() {
      _showKeyboard = false;
      // Deselect all currencies
      for (var currency in _displayedCurrencies) {
        currency.isSelected = false;
      }
      _selectedCurrency = null;
    });
  }

  void _onCurrencySelectedFromSearch(Currency selectedCurrency) {
    setState(() {
      // Check if currency is already in displayed currencies
      int existingIndex = _displayedCurrencies.indexWhere((c) => c.code == selectedCurrency.code);
      
      if (existingIndex != -1) {
        // Currency already exists, do nothing
        return;
      }
      
      // Find currently selected currency to replace
      int selectedIndex = _displayedCurrencies.indexWhere((c) => c.isSelected);
      
      if (selectedIndex != -1) {
        // Replace the selected currency
        double currentAmount = _displayedCurrencies[selectedIndex].amount;
        String fromCode = _displayedCurrencies[selectedIndex].code;
        
        _displayedCurrencies[selectedIndex] = selectedCurrency.copyWith(
          amount: _currencyService.convertCurrency(currentAmount, fromCode, selectedCurrency.code),
          isSelected: false,
        );
      } else {
        // No currency selected, add to the end
        _displayedCurrencies.add(selectedCurrency.copyWith(
          amount: _currencyService.convertCurrency(
            _displayedCurrencies.isNotEmpty ? _displayedCurrencies[0].amount : 100.0,
            _displayedCurrencies.isNotEmpty ? _displayedCurrencies[0].code : 'USD',
            selectedCurrency.code,
          ),
        ));
      }
      
      // Hide keyboard and deselect all
      _showKeyboard = false;
      _selectedCurrency = null;
      for (var currency in _displayedCurrencies) {
        currency.isSelected = false;
      }
    });
    
    // Navigate back to main screen
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D3142),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              // Hide keyboard when swiping to different pages
              if (_showKeyboard) {
                _hideKeyboard();
              }
            },
            children: [
              // Search Screen (Left)
              CurrencySearchScreen(
                currencyService: _currencyService,
                onCurrencySelected: _onCurrencySelectedFromSearch,
              ),
              
              // Main Screen (Center)
              SafeArea(
                child: GestureDetector(
                  onTap: _hideKeyboard,
                  child: Column(
                    children: [
                      // App Bar
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => _pageController.animateToPage(
                                0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              ),
                              child: const Icon(
                                Icons.search,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const Text(
                              'Currency Converter',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 28), // Balance the layout
                          ],
                        ),
                      ),
                      
                      // Currency List
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: _displayedCurrencies.length,
                          itemBuilder: (context, index) {
                            final currency = _displayedCurrencies[index];
                            return CurrencyCard(
                              currency: currency,
                              isSelected: currency.isSelected,
                              onTap: () => _selectCurrency(currency),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Custom Keyboard Overlay
          if (_showKeyboard)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: GestureDetector(
                onHorizontalDragStart: (_) => _hideKeyboard(),
                child: CustomKeyboard(
                  onKeyPress: _onKeyPress,
                  onClear: _onClear,
                  onBackspace: _onBackspace,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
} 