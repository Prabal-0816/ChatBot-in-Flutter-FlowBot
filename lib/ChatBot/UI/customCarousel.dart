import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CarouselSliderWidget extends StatefulWidget {
  final List<String> imageUrls;
  final List<String>? layoverData;

   CarouselSliderWidget({
    super.key,
    required this.imageUrls,
    this.layoverData
  });

  @override
  _CarouselSliderWidgetState createState() => _CarouselSliderWidgetState();
}

class _CarouselSliderWidgetState extends State<CarouselSliderWidget> {
  int _currentCarouselIndex = 0; // For tracking the active index of the carousel
  final CarouselSliderController _carouselController = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main carousel
        Stack(
          children: [
            CarouselSlider.builder(
              carouselController: _carouselController,
              itemCount: widget.imageUrls.length,
              options: CarouselOptions(
                height: MediaQuery.of(context).size.height * 0.3, // Adjust height
                viewportFraction: 1.0,
                enableInfiniteScroll: true,
                autoPlay: widget.imageUrls.length > 1 ? true : false,
                autoPlayInterval: const Duration(seconds: 5),
                pauseAutoPlayOnTouch: true,
                enlargeCenterPage: false,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentCarouselIndex = index;
                  });
                },
              ),
              itemBuilder: (context, index, realIndex) {
                return GestureDetector(
                  onTap: () {
                    _showImagePopup(context, widget.imageUrls[index]);
                  },
                  child: Stack(
                    children: [
                      // Main image with rounded corners
                      Container(
                        padding: const EdgeInsets.all(2.0), // Add padding here
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.0), // Rounded corners
                          child: Image.network(
                            widget.imageUrls[index],
                            width: double.infinity,
                            fit: BoxFit.cover, // Use BoxFit.cover to fill the container
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(Icons.broken_image, color: Colors.grey, size: 48.0),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // overlay text on image
                      if(widget.layoverData != null && widget.layoverData!.isNotEmpty)
                        _buildOverlayText(widget.layoverData![index])
                    ],
                  ),
                );
              },
            ),
            // Dot indicators
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.imageUrls.asMap().entries.map((entry) {
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentCarouselIndex == entry.key ? Colors.blueAccent
                          : Colors.grey,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Show image popup
  void _showImagePopup(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(10.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 2.0,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error , stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.broken_image , color: Colors.grey, size: 48.0),
                    ),
                  );
                },
              ),
            )
          ),
        );
      },
    );
  }

  Widget _buildOverlayText(String text) {
    return Stack(
      children: [
        if(text.isNotEmpty)
          Center(
            child: Positioned(
              // top: 10,
              // right: 10,
              // left: 50,
              child: Container(
                // color: Colors.black54,
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(16)
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                      text,
                      style: const TextStyle(color: Colors.white, fontSize: 14)
                  ),
                ),
              ),
            ),
          )
      ],
    );
  }
}