import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void _launchURL(String url) async {
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  } else {
    throw 'Could not launch $url';
  }
}

class ImagesPage extends StatefulWidget {
  final List<dynamic> responseData;

  const ImagesPage({Key? key, required this.responseData}) : super(key: key);

  @override
  _ImagesPageState createState() => _ImagesPageState();
}

class _ImagesPageState extends State<ImagesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Önerilen Kıyafetler'),
        backgroundColor: Color.fromARGB(255, 141, 140, 142), // Arka plan rengi
      ),
      body: ListView.builder(
        itemCount: widget.responseData.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> product = widget.responseData[index];

          // Özelliklerin düzenlenmesi
          Map<String, dynamic> attributeMap = product['attribute'];
          String imageUrl = product['image_url'] ?? '';
          String productUrl = product['product_url'] ?? '';
          String price = product['price'] ?? '';
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Color.fromARGB(255, 56, 56, 56),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Resim
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Container(
                        width: 120,
                        height: 200, // Resmin yüksekliği
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 8), // Boşluk
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Fiyat
                            Text(
                              price,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8), // Boşluk
                            // Ürün detayları
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:
                                  attributeMap.entries.take(8).map((entry) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: Text(
                                    '• ${entry.key}: ${entry.value}',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 8), // Boşluk
                    // Detaylar Butonu
                    IconButton(
                      onPressed: () {
                        // Ürünün detay sayfasına gitmek için URL'ye yönlendirme yap
                        if (productUrl.isNotEmpty) {
                          // Eğer productUrl boş değilse, URL'ye gitmek için bir işlev çağrısı yap
                          _launchURL(productUrl);
                        }
                      },
                      icon: Icon(
                        Icons.arrow_forward,
                        color: Color.fromARGB(
                            255, 56, 56, 56), // İkon rengini mor yap
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
