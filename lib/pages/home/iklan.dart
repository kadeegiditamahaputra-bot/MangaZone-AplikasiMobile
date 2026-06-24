import 'dart:async';
import 'package:flutter/material.dart';
import 'reader_page.dart';

class IklanPage extends StatefulWidget {
  final String chapterName;

  const IklanPage({
    super.key,
    required this.chapterName,
  });

  @override
  State<IklanPage> createState() => _IklanPageState();
}

class _IklanPageState extends State<IklanPage> {
  int countdown = 10;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (countdown > 0) {
          setState(() {
            countdown--;
          });
        } else {
          timer.cancel();
        }
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void bukaChapter() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ReaderPage(
          chapterName: widget.chapterName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: countdown > 0
                    ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "$countdown",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                    : IconButton(
                  onPressed: bukaChapter,
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),

              const Spacer(),

              const Icon(
                Icons.ads_click,
                color: Colors.white,
                size: 100,
              ),

              const SizedBox(height: 20),

              const Text(
                "IKLAN",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Upgrade ke Premium untuk menghilangkan iklan.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),

              const Spacer(),

            ],
          ),
        ),
      ),
    );
  }
}