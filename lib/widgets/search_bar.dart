import 'package:flutter/material.dart';
import 'package:rent_car/core/app_color.dart';

class SearchBars extends StatefulWidget {
  // Live searching k liye callback aur controller baahir se receive karne k liye constructor variables
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const SearchBars({
    super.key, 
    this.onChanged,
    this.controller,
  });

  @override
  State<SearchBars> createState() => _SearchBarsState();
}

class _SearchBarsState extends State<SearchBars> {
  // Agar baahir se controller nahi aata to fallback k liye local controller bna rha ha
  late final TextEditingController _internalController;

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    // Agar local controller bna tha to use dispose kr rhy hain memory leaks se bachny k liye
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: AppColor.containerColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),

          const SizedBox(width: 10),

          Expanded(
            child: TextField(
              controller: _internalController, // Link controller here
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.yellow,
              // CHANGED HERE: Har key-press pr live text baahir HomeScreen ko jaye ga
              onChanged: widget.onChanged,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Type here to search",
                hintStyle: TextStyle(color: Colors.grey),
                isCollapsed: true,
              ),
            ),
          ),

          // CHANGED HERE: Close button ko interactive banaya ha jo search ko reset kray ga
          GestureDetector(
            onTap: () {
              _internalController.clear(); // Text field saaf ho jaye gi
              if (widget.onChanged != null) {
                widget.onChanged!(""); // HomeScreen par list dubara reset ho jaye gi
              }
            },
            child: Container(
              height: 22,
              width: 22,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColor.white.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}