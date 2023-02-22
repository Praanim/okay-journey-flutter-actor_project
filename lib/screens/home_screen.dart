import 'dart:io';

import 'package:actor_project/colors.dart';
import 'package:actor_project/controller/backend.dart';
import 'package:actor_project/global_img_url.dart';
import 'package:actor_project/screens/actor_description.dart';
import 'package:actor_project/screens/favourite_lists_screen.dart';
import 'package:actor_project/screens/widgets/custom_button.dart';
import 'package:actor_project/screens/widgets/custom_text_field.dart';
import 'package:actor_project/screens/widgets/show_SnackBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final formKey = GlobalKey<FormState>();
  final _actorNameController = TextEditingController();
  final firebaseController = FirebaseController();
  bool isLoading = false;

  File? imageFile;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _actorNameController.dispose();
  }

  void _showImageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Please choose an option"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  _getFromCamera();
                  Navigator.of(context).pop();
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.camera,
                      color: mainColor,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text("Camera")
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  _getFromGallery();
                  Navigator.of(context).pop();
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.image,
                      color: mainColor,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text("Gallery")
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _getFromCamera() async {
    try {
      XFile? pickedFile =
          await ImagePicker().pickImage(source: ImageSource.camera);

      if (pickedFile == null) {
        showSnackBar(context: context, text: "No image was selected");
      }
      _cropImage(pickedFile!.path);
    } catch (e) {
      showSnackBar(context: context, text: e.toString());
    }
  }

  void _getFromGallery() async {
    try {
      XFile? pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile == null) {
        showSnackBar(context: context, text: "No image was selected");
      }

      _cropImage(pickedFile!.path);
    } catch (e) {
      showSnackBar(context: context, text: e.toString());
    }
  }

  void _cropImage(filePath) async {
    CroppedFile? croppedImage = await ImageCropper()
        .cropImage(sourcePath: filePath, maxHeight: 1080, maxWidth: 1080);

    if (croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "Save Your,\nFavorite Actors\nhere",
                      style: TextStyle(
                          fontSize: 40,
                          color: mainColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
                  CircleAvatar(
                    radius: 100,
                    // backgroundColor: ,
                    backgroundImage: imageFile == null
                        ? const AssetImage('assets/images/pranim_hero.jpg')
                        : Image.file(imageFile!).image,
                    child: Align(
                      alignment: const Alignment(0.9, 0.93),
                      child: IconButton(
                        icon: const Icon(
                          Icons.add_a_photo_rounded,
                          color: appColor,
                          size: 35,
                        ),
                        onPressed: () {
                          _showImageDialog();
                        },
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: SizedBox(
                      height: 10,
                      child: Text(
                        "(Add Photo from Gallery or Camera)",
                        style: TextStyle(color: Colors.black, fontSize: 10),
                      ),
                    ),
                  ),
                  MyTextField(
                    hintText: "Actor's Name",
                    controller: _actorNameController,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  CustomButton(
                    text: "Save",
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        isLoading = true;
                        setState(() {});

                        if (imageFile != null) {
                          //then go to cloud to save the data
                          final imageFromFirebase =
                              await firebaseController.storeImage(imageFile!,
                                  _actorNameController.text, context);

                          final actorModel =
                              await firebaseController.saveDataAndGet(
                            actorName: _actorNameController.text.trim(),
                            imageUrl: imageFromFirebase == null
                                ? imageUrl
                                : imageFromFirebase,
                            context: context,
                          );

                          if (actorModel != null) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ActorDescription(actor: actorModel),
                                ));
                          } else {
                            showSnackBar(
                                context: context, text: "Something went wrong");
                          }
                          print(actorModel!.docId);
                        } else {
                          showSnackBar(
                              context: context,
                              text:
                                  "Image File was null (Please select an Image)");
                        }
                        imageFile = null;
                        _actorNameController.clear();
                        isLoading = false;

                        setState(() {});
                      }
                    },
                  ),
                  isLoading
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: CircularProgressIndicator(
                            color: mainColor,
                          ),
                        )
                      : Container(),
                  CustomButton(
                      text: "Actors List",
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => FavouriteList(),
                        ));
                      })
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
//snack bar ni show garni ho
//try catch block ni implement garni