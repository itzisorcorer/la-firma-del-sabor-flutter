import 'package:flutter/material.dart';
import 'package:app_firma_sabor/constants/app_theme.dart';
import 'package:app_firma_sabor/services/product_service.dart';
import 'package:app_firma_sabor/services/home_service.dart';
import 'package:app_firma_sabor/services/cart_service.dart';
import 'package:app_firma_sabor/screens/creator_profile_screen.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductService _productService = ProductService();
  final HomeService _homeService = HomeService();

  bool _isLoading = true;
  Map<String, dynamic>? _product;
  bool _isFavorite = false;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _loadProductDetails();
  }

  Future<void> _loadProductDetails() async {
    final data = await _productService.fetchProductDetails(widget.productId);

    if (data != null && mounted) {
      setState(() {
        _product = data['product'];
        _isFavorite = data['is_favorite'];

        _quantity = (_product!['stock'] > 0) ? 1 : 0;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _toggleFavorite() async {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    try {
      final isNowFavorite = await _homeService.toggleFavorite(widget.productId);
      if (_isFavorite != isNowFavorite && mounted) {
        setState(() => _isFavorite = isNowFavorite);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFavorite = !_isFavorite);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al guardar favorito')));
      }
    }
  }

  //Lógica del botón + con límite
  void _increment() {
    if (_product != null && _quantity < _product!['stock']) {
      setState(() => _quantity++);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Has alcanzado el límite de stock!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _decrement() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF9F5F0),
        body: Center(child: CircularProgressIndicator(color: AppTheme.orangeBrand)),
      );
    }

    if (_product == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF9F5F0),
        body: Center(child: Text("Error al cargar el producto")),
      );
    }

    final creatorName = _product!['creator']?['name'] ?? 'Creador';
    final int stockAvailable = _product!['stock'] ?? 0;
    final bool hasStock = stockAvailable > 0;
    final bool canAddMore = _quantity < stockAvailable;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F0),
      body: SingleChildScrollView(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              height: 350,
              width: double.infinity,
              child: Image.network(
                'https://media.airedesantafe.com.ar/p/9ac096426bd44b6fe19d566ec41b5083/adjuntos/268/imagenes/003/771/0003771857/1200x0/smart/imagepng.png',
                fit: BoxFit.cover,
              ),
            ),

            Container(
              margin: const EdgeInsets.only(top: 320),
              decoration: const BoxDecoration(
                color: Color(0xFFF9F5F0),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 45.0, left: 25.0, right: 25.0, bottom: 25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _product!['name'],
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.navyBlue),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\$${_product!['price']}',
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.navyBlue),
                            ),
                            // Letrerito de stock
                            Text(
                              hasStock ? 'Disponibles: $stockAvailable' : 'Agotado',
                              style: TextStyle(
                                color: hasStock ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _decrement,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppTheme.navyBlue, width: 1.5),
                                ),
                                child: const Icon(Icons.remove, color: AppTheme.navyBlue, size: 20),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Text(
                              '$_quantity',
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.navyBlue),
                            ),
                            const SizedBox(width: 15),

                            //BOTÓN + CON VALIDACIÓN DE COLOR
                            GestureDetector(
                              onTap: _increment,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: canAddMore ? AppTheme.orangeBrand : Colors.grey.shade400,
                                  border: Border.all(
                                      color: canAddMore ? AppTheme.orangeBrand : Colors.grey.shade400,
                                      width: 1.5
                                  ),
                                ),
                                child: const Icon(Icons.add, color: Colors.white, size: 20,),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    const Text(
                      "Acerca del producto",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.navyBlue),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _product!['description'],
                      style: TextStyle(color: AppTheme.navyBlue.withOpacity(0.7), fontSize: 16, height: 1.6),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 25),

                    const Text(
                      "Conoce más este producto",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.navyBlue),
                    ),
                    const SizedBox(height: 15),

                    Builder(
                        builder: (context) {
                          final List<dynamic> videos = _product!['videos'] ?? [];

                          if (videos.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: Row(
                                children: [
                                  Icon(Icons.movie_creation_outlined, color: Colors.grey.shade400),
                                  const SizedBox(width: 10),
                                  const Text(
                                    "Videos sobre este producto en camino...",
                                    style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 16),
                                  ),
                                ],
                              ),
                            );
                          }

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: videos.map((video) {
                                return VideoPlayerItem(videoUrl: video['url_youtube'],
                                    accessibilityDescription: video['accessibility_description'] ?? 'Video ilustrativo del producto');
                              }).toList(),
                            ),
                          );
                        }
                    ),
                    const SizedBox(height: 40),

                    // 👇 BOTÓN FINAL: SE BLOQUEA SI NO HAY STOCK
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hasStock ? AppTheme.orangeBrand : Colors.grey.shade400,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                        ),
                        // Si no hay stock, pasamos 'null' para deshabilitar el botón
                        onPressed: hasStock ? () {
                          CartService().addToCart(_product!, _quantity);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('¡Agregaste $_quantity ${_product!['name']} al carrito! 🛒'),
                              backgroundColor: AppTheme.orangeBrand,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } : null,
                        child: Text(
                          hasStock ? "Agregar al carrito" : "Agotado",
                          style: const TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            Positioned(
              top: 300,
              left: 20,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreatorProfileScreen(
                        creatorId: _product!['creator_id'],
                        creatorName: creatorName,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.brandYellow,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: AppTheme.navyBlue, width: 2),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline, color: AppTheme.navyBlue, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        '¡Conoce a $creatorName!',
                        style: const TextStyle(color: AppTheme.navyBlue, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              top: 295,
              right: 30,
              child: GestureDetector(
                onTap: _toggleFavorite,
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: AppTheme.navyBlue,
                  child: Icon(
                    Icons.bookmark,
                    color: _isFavorite ? Colors.redAccent : const Color(0xFFF9F5F0),
                    size: 28,
                  ),
                ),
              ),
            ),

            Positioned(
              top: 50,
              left: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                  child: const Icon(Icons.reply, color: AppTheme.navyBlue, size: 28),
                ),
              ),
            ),

            Positioned(
              top: 150,
              right: 15,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), shape: BoxShape.circle),
                child: const Icon(Icons.arrow_forward, color: AppTheme.orangeBrand),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoPlayerItem extends StatefulWidget {
  final String videoUrl;
  final String accessibilityDescription;

  const VideoPlayerItem({
    super.key,
    required this.videoUrl,
    required this.accessibilityDescription,
  });

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late YoutubePlayerController _controller;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);

    if (videoId != null) {
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          hideControls: false,
        ),
      );
    } else {
      _isError = true;
    }
  }

  @override
  void dispose() {
    if (!_isError) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isError) return const SizedBox.shrink();

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))
              ],
            ),
            child: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: AppTheme.orangeBrand,
              progressColors: const ProgressBarColors(
                playedColor: AppTheme.orangeBrand,
                handleColor: AppTheme.brandYellow,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.closed_caption_outlined, size: 18, color: AppTheme.navyBlue),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  widget.accessibilityDescription,
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      fontStyle: FontStyle.italic,
                      height: 1.3
                  ),
                  maxLines: 7,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}