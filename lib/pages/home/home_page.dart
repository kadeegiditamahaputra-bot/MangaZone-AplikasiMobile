import 'dart:async'; // WAJIB DIIMPORT UNTUK TIMER
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/manga.dart';
import '../../services/api_service.dart';
import 'Baca.dart';
import '../../services/favorite_service.dart';
import 'searching.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  String _selectedGenre = 'Semua';
  late Future<List<Manga>> _mangaFuture;
  String? _currentUid;

  // Variabel untuk penanganan Auto-Scroll Banner
  final PageController _pageController = PageController();
  Timer? _carouselTimer;
  int _currentPage = 0;
  final int _maxFeaturedItems = 5; // Jumlah manga populer yang ingin di-scroll

  final List<String> _genres = [
    'Semua', 'Action', 'Adventure', 'Comedy', 'Drama', 'Fantasy', 'Romance', 'Sci-Fi'
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _mangaFuture = ApiService.getManga();
    _currentUid = FirebaseAuth.instance.currentUser?.uid;
  }

  // Menginisialisasi Timer otomatis setelah data manga dipastikan ada
  void _startAutoScroll(int totalItems) {
    _carouselTimer?.cancel(); // Bersihkan timer lama jika ada
    _carouselTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (_pageController.hasClients) {
        if (_currentPage < totalItems - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B14),
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            const Text("Manga", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 26, letterSpacing: -0.5)),
            const Text("Zone", style: TextStyle(color: Colors.deepPurpleAccent, fontWeight: FontWeight.w900, fontSize: 26, letterSpacing: -0.5)),
            const SizedBox(width: 12),

            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(_currentUid)
                  .snapshots(),
              builder: (context, snapshot) {
                bool premium = false;

                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>?;

                  if (data != null) {
                    premium = data["isPremium"] ?? false;

                    if (premium && data["premiumUntil"] != null) {
                      DateTime expired;

                      if (data["premiumUntil"] is Timestamp) {
                        expired = (data["premiumUntil"] as Timestamp).toDate();
                      } else {
                        expired = DateTime.parse(data["premiumUntil"].toString());
                      }

                      if (expired.isBefore(DateTime.now())) {
                        premium = false;

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          FirebaseFirestore.instance
                              .collection("users")
                              .doc(_currentUid)
                              .update({"isPremium": false});
                        });
                      }
                    }
                  }
                }

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: premium
                          ? const [Color(0xFFFFD54F), Color(0xFFFF9800)]
                          : const [Color(0xFF1E1E2F), Color(0xFF252539)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: premium ? Colors.amber.withOpacity(0.3) : Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: Text(
                    premium ? "PREMIUM" : "FREE",
                    style: TextStyle(
                      color: premium ? Colors.black : Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          _buildAppBarButton(Icons.search_rounded, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchingPage()));
          }),
          _buildAppBarButton(Icons.notifications_none_rounded, () {}),
          const SizedBox(width: 16),
        ],
      ),
      body: FutureBuilder<List<Manga>>(
        future: _mangaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _HomeShimmerLoading();
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(snapshot.hasError ? 'Error: ${snapshot.error}' : 'Data tidak ditemukan', style: const TextStyle(color: Colors.white70)));
          }

          final allMangas = snapshot.data!;
          final filteredMangas = allMangas.where((manga) {
            if (_selectedGenre == 'Semua') return true;
            return manga.genres.contains(_selectedGenre);
          }).toList();

          if (_selectedGenre == 'Semua' && allMangas.isNotEmpty) {
            final featuredCount = allMangas.length < _maxFeaturedItems ? allMangas.length : _maxFeaturedItems;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_carouselTimer == null || !_carouselTimer!.isActive) {
                _startAutoScroll(featuredCount);
              }
            });
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              if (_selectedGenre == 'Semua' && allMangas.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _buildAutoScrollingHeroBanner(context, allMangas),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                SliverToBoxAdapter(
                  child: _buildSectionTitle("Sedang Tren"),
                ),
                SliverToBoxAdapter(
                  child: _buildTrendingHorizontalList(allMangas),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildGenreFilterChips(),
                ),
              ),

              SliverToBoxAdapter(
                child: _buildSectionTitle(_selectedGenre == 'Semua' ? "Rekomendasi Untukmu" : "Genre: $_selectedGenre"),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.58,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 20,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => MangaGridItem(manga: filteredMangas[index], uid: _currentUid ?? ''),
                    childCount: filteredMangas.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBarButton(IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
      child: IconButton(icon: Icon(icon, color: Colors.white, size: 22), onPressed: onTap),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800, letterSpacing: 0.3),
      ),
    );
  }

  Widget _buildAutoScrollingHeroBanner(BuildContext context, List<Manga> mangas) {
    final featuredMangas = mangas.take(_maxFeaturedItems).toList();

    return SizedBox(
      height: 220,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          _currentPage = index;
        },
        itemCount: featuredMangas.length,
        itemBuilder: (context, index) {
          final manga = featuredMangas[index];
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Baca(manga: manga))),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 15, offset: const Offset(0, 8))
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Positioned.fill(child: Image.network(manga.imageUrl, fit: BoxFit.cover, alignment: Alignment.topCenter)),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.4), const Color(0xFF0B0B14)],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.75),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber.withOpacity(0.5), width: 1)
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                              const SizedBox(width: 4),
                              // PERBAIKAN: Menggunakan FontWeight.w900 agar valid dan tidak crash
                              Text(
                                  "${manga.score}",
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(manga.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(manga.genres.join(' • '), style: const TextStyle(color: Colors.white70, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrendingHorizontalList(List<Manga> mangas) {
    final trending = mangas.take(6).toList();
    return SizedBox(
      height: 170,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: trending.length,
        itemBuilder: (context, index) {
          final manga = trending[index];
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Baca(manga: manga))),
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(right: 14),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Positioned.fill(child: Image.network(manga.imageUrl, fit: BoxFit.cover)),
                  Positioned.fill(child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.8)])))),
                  Positioned(
                    bottom: 8, left: 8, right: 8,
                    child: Text(manga.title, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGenreFilterChips() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _genres.length,
        itemBuilder: (_, i) {
          final genre = _genres[i];
          final selected = _selectedGenre == genre;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(genre),
              selected: selected,
              selectedColor: Colors.deepPurpleAccent,
              backgroundColor: Colors.white.withOpacity(0.03),
              labelStyle: TextStyle(
                color: selected ? Colors.white : Colors.white60,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: selected ? Colors.transparent : Colors.white.withOpacity(0.08)),
              ),
              onSelected: (_) => setState(() {
                _selectedGenre = genre;
                if (_selectedGenre != 'Semua') {
                  _carouselTimer?.cancel();
                }
              }),
            ),
          );
        },
      ),
    );
  }
}

class MangaGridItem extends StatelessWidget {
  final Manga manga;
  final String uid;

  const MangaGridItem({super.key, required this.manga, required this.uid});

  @override
  Widget build(BuildContext context) {
    if (uid.isEmpty) return const SizedBox.shrink();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('favorites').doc(manga.malId.toString()).snapshots(),
      builder: (context, favSnapshot) {
        final isFavorite = favSnapshot.data?.exists ?? false;

        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Baca(manga: manga))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          manga.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(color: const Color(0xFF141424), child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.deepPurpleAccent))));
                          },
                          errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF141424), child: const Center(child: Icon(Icons.broken_image_rounded, color: Colors.white24))),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter, end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.6)],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8, left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(6)),
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                              const SizedBox(width: 2),
                              Text("${manga.score}", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8, right: 8,
                        child: BlurCircleButton(
                          isFavorite: isFavorite,
                          onTap: () async {
                            if (isFavorite) {
                              await FavoriteService.removeFavorite(manga);
                            } else {
                              await FavoriteService.addFavorite(manga);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(manga.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.1)),
                    const SizedBox(height: 2),
                    Text(manga.genres.join(', '), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class BlurCircleButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;

  const BlurCircleButton({super.key, required this.isFavorite, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: Colors.black.withOpacity(0.4),
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        onPressed: onTap,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
          child: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            key: ValueKey(isFavorite),
            color: isFavorite ? Colors.redAccent : Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _HomeShimmerLoading extends StatelessWidget {
  const _HomeShimmerLoading();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 220, margin: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(24))),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Container(width: 120, height: 20, color: Colors.white.withOpacity(0.04))),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (_, __) => Container(width: 100, margin: const EdgeInsets.only(right: 14), decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(14))),
            ),
          ),
        ],
      ),
    );
  }
}