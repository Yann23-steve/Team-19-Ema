import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PageLogin extends StatelessWidget {
  const PageLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(

          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF9CA3FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),

                    Container(

                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9CA3FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    )
                  ],
                )
              ],
            ),
          )
      ),
    );
  }
}
