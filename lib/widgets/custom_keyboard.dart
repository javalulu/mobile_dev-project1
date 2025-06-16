import 'package:flutter/material.dart';

class CustomKeyboard extends StatelessWidget {
  final Function(String) onKeyPress;
  final VoidCallback onClear;
  final VoidCallback onBackspace;

  const CustomKeyboard({
    super.key,
    required this.onKeyPress,
    required this.onClear,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF2D3142),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: 1, 2, 3
          Row(
            children: [
              _buildKey('1', 'ABC'),
              const SizedBox(width: 8),
              _buildKey('2', 'DEF'),
              const SizedBox(width: 8),
              _buildKey('3', 'GHI'),
            ],
          ),
          const SizedBox(height: 8),
          // Row 2: 4, 5, 6
          Row(
            children: [
              _buildKey('4', 'JKL'),
              const SizedBox(width: 8),
              _buildKey('5', 'MNO'),
              const SizedBox(width: 8),
              _buildKey('6', 'PQRS'),
            ],
          ),
          const SizedBox(height: 8),
          // Row 3: 7, 8, 9
          Row(
            children: [
              _buildKey('7', 'TUVY'),
              const SizedBox(width: 8),
              _buildKey('8', 'WXYZ'),
              const SizedBox(width: 8),
              _buildKey('9', ''),
            ],
          ),
          const SizedBox(height: 8),
          // Row 4: *, 0, #
          Row(
            children: [
              _buildSpecialKey('+*#', onClear),
              const SizedBox(width: 8),
              _buildKey('0', ''),
              const SizedBox(width: 8),
              _buildSpecialKey('⌫', onBackspace),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String number, String letters) {
    return Expanded(
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => onKeyPress(number),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  number,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                if (letters.isNotEmpty)
                  Text(
                    letters,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialKey(String symbol, VoidCallback onTap) {
    return Expanded(
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: Center(
              child: Text(
                symbol,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 