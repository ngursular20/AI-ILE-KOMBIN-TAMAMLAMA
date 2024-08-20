import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'images.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late File _image = File(''); // Boş bir dosya nesnesi olarak tanımlanıyor
  final picker = ImagePicker();
  String _selectedProduct = ''; // Seçilen ürün
  String _selectedGender = ''; // Seçilen cinsiyet
  bool _isLoading = false; // Yükleme durumu

  @override
  void initState() {
    super.initState();
    _image = File('');
    _initializeCameraAndOpen();
  }

  Future<void> _initializeCameraAndOpen() async {
    await _initializeCamera();
    _openCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _controller = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      setState(() {
        _image = File(image.path);
      });
      await _showSelectionDialog();
    } catch (e) {
      print(e);
    }
  }

  List<Map<String, dynamic>> parseApiResponse(dynamic responseData) {
    List<Map<String, dynamic>> parsedData = [];
    for (var item in responseData) {
      String id =
          (item.length > 0 && item[0] != null) ? item[0].toString() : '';
      Map<String, dynamic> itemMap = {
        'id': id,
        'image_url': item.length > 1 ? item[1] : '',
        'product_url': item.length > 2 ? item[2] : '',
        'attribute': item.length > 3 ? jsonDecode(item[3] ?? '{}') : {},
        'price': item.length > 4 ? item[4] : '',
      };
      parsedData.add(itemMap);
    }
    return parsedData;
  }

  Future<void> _sendImageToAPI(
    File image,
    String selectedProduct,
    String selectedGender,
  ) async {
    String base64Image = base64Encode(image.readAsBytesSync());
    Map<String, dynamic> requestData = {
      'image': base64Image,
      'gender': selectedGender,
      'table_name': selectedProduct,
      'page': '1',
      'size': '5',
    };

    setState(() {
      _isLoading = true; // Yükleme başlatıldı
    });

    try {
      final response = await http.post(
        Uri.parse('http://89.252.140.157:2600/predict'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        dynamic responseData = jsonDecode(response.body);
        List<Map<String, dynamic>> parsedData = parseApiResponse(responseData);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImagesPage(responseData: parsedData),
          ),
        );
      } else {
        throw Exception('API\'ye resim gönderme başarısız oldu');
      }
    } catch (e) {
      print('Hata: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Hata'),
            content: Text(
              'Resmi API\'ye gönderme başarısız oldu. Lütfen daha sonra tekrar deneyin.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Tamam'),
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        _isLoading = false; // Yükleme durumu bitirildi
      });
    }
  }

  Future<void> _showSelectionDialog() async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Cinsiyet Seçiniz:'),
                ListTile(
                  title: Text('Kadın'),
                  onTap: () {
                    setState(() {
                      _selectedGender = 'Kadın';
                    });
                    Navigator.pop(context);
                    _showProductSelectionDialog();
                  },
                ),
                ListTile(
                  title: Text('Erkek'),
                  onTap: () {
                    setState(() {
                      _selectedGender = 'Erkek';
                    });
                    Navigator.pop(context);
                    _showProductSelectionDialog();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showProductSelectionDialog() async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hangi ürüne ihtiyacınız var?'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  title: Text('Tişört'),
                  onTap: () {
                    setState(() {
                      _selectedProduct = 't_shirts';
                    });
                    Navigator.pop(context);
                    _sendImageToAPI(_image, _selectedProduct, _selectedGender);
                  },
                ),
                ListTile(
                  title: Text('Pantolon'),
                  onTap: () {
                    setState(() {
                      _selectedProduct = 'pants';
                    });
                    Navigator.pop(context);
                    _sendImageToAPI(_image, _selectedProduct, _selectedGender);
                  },
                ),
                ListTile(
                  title: Text('Kazak'),
                  onTap: () {
                    setState(() {
                      _selectedProduct = 'sweaters';
                    });
                    Navigator.pop(context);
                    _sendImageToAPI(_image, _selectedProduct, _selectedGender);
                  },
                ),
                ListTile(
                  title: Text('Elbise'),
                  onTap: () {
                    setState(() {
                      _selectedProduct = 'dresses';
                    });
                    Navigator.pop(context);
                    _sendImageToAPI(_image, _selectedProduct, _selectedGender);
                  },
                ),
                ListTile(
                  title: Text('Ceket'),
                  onTap: () {
                    setState(() {
                      _selectedProduct = 'jackets';
                    });
                    Navigator.pop(context);
                    _sendImageToAPI(_image, _selectedProduct, _selectedGender);
                  },
                ),
                ListTile(
                  title: Text('Gömlek'),
                  onTap: () {
                    setState(() {
                      _selectedProduct = 'shirts';
                    });
                    Navigator.pop(context);
                    _sendImageToAPI(_image, _selectedProduct, _selectedGender);
                  },
                ),
                ListTile(
                  title: Text('Ayakkabı'),
                  onTap: () {
                    setState(() {
                      _selectedProduct = 'sneakers';
                    });
                    Navigator.pop(context);
                    _sendImageToAPI(_image, _selectedProduct, _selectedGender);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openCamera() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TakePictureScreen(
          camera: _controller.description,
        ),
      ),
    ).then((imagePath) {
      if (imagePath != null) {
        setState(() {
          _image = File(imagePath);
        });
        _showSelectionDialog();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kamera'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            GoRouter.of(context).go('/home');
          },
        ),
        backgroundColor: Color.fromARGB(255, 110, 118, 146),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : _image.path.isNotEmpty
                ? Image.file(_image)
                : Text('No image selected'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        onPressed: _takePicture,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({required this.camera});

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      Navigator.pop(context, pickedFile.path);
    } else {
      print('No image selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kameradan Çek'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            GoRouter.of(context).go('/home'); // Geri tuşuna basıldığında ana sayfaya yönlendir
          },
        ),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SizedBox.expand(
              child: SingleChildScrollView(
                child: Stack(
                  children: [
                    CameraPreview(_controller),
                    Positioned(
                      bottom: 16.0,
                      left: 16.0,
                      child: IconButton(
                        icon: Icon(Icons.photo_library, color: Colors.white),
                        onPressed: _getImageFromGallery,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            final image = await _controller.takePicture();
            Navigator.pop(context, image.path);
          } catch (e) {
            print(e);
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
