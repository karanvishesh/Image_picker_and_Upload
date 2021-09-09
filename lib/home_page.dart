import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? image;
  Dio dio = Dio();
  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) {
        return;
      }
      final tempImage = File(image.path);
      setState(() {
        this.image = tempImage;
      });
    } on PlatformException catch (e) {
      print("Failed to pick Image");
    }
    await uploadImage();
  }

  Future<dynamic> uploadImage() async {
    try {
      String filename = image!.path.split("/").last;
      FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(image!.path,
            filename: filename, contentType: MediaType('image', 'jpeg')),
        "type": "image/jpg"
      });
      Response response =
          await dio.post("https://codelime.in/api/remind-app-token",
              data: formData,
              options: Options(responseType: ResponseType.plain, headers: {
                "accept": "*/*",
                "Authorization": "bearer accesstoken",
                "Content-type": "multipart/form-data"
              }));
      print(response.statusCode);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          image != null
              ? Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                        image: FileImage(
                          File(image!.path),
                        ),
                      ),
                      shape: BoxShape.circle,
                      color: Colors.black),
                )
              : Container(),
          Center(
            child: MaterialButton(
              color: Colors.green,
              onPressed: () {
                showModalBottomSheet(
                  context: (context),
                  builder: (context) => Container(
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          child: Text("Gallery"),
                          onPressed: () {
                            pickImage(ImageSource.gallery);
                            Navigator.pop(context);
                          },
                        ),
                        TextButton(
                          child: Text("Camera"),
                          onPressed: () {
                            pickImage(ImageSource.camera);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: Text(
                "Upload Image",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
