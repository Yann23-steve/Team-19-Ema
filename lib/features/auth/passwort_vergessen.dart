import 'package:flutter/material.dart';

class PasswortVergessen extends StatelessWidget {
  const PasswortVergessen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 70,
                  child: Padding(
                    padding: const EdgeInsets.all(10), // espace interne
                    child: Row(
                      children: [
                        Text('Job',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4B6BFB),
                          ),),
                        Text('Suche',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('you can change your Passport her'),
                )

              ],
            ),
          )
      ),
    );
  }
}
