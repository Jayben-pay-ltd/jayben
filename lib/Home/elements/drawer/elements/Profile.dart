import 'package:jayben/Utilities/constants.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'components/ProfileWidgets.dart';
import 'package:flutter/material.dart';
import 'MyQRCode.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isUpdatingInfo = false;
  final picker = ImagePicker();
  String? imageUrl;
  File? image;

  Future<void> getImage() async {
    XFile? pickedFile =
        (await picker.pickImage(source: ImageSource.gallery, imageQuality: 50));

    if (pickedFile == null) return;

    File file = File(pickedFile.path);

    setState(() {
      image = File(file.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProviderFunctions>(builder: (_, value, child) {
      return value.returnIsLoading()
          ? uploadProgressLoadingPage(context)
          : Scaffold(
              backgroundColor: Colors.white,
              floatingActionButton: ["Agent"].contains(box("account_type"))
                  ? nothing()
                  : FloatingActionButton.extended(
                      onPressed: () =>
                          changePage(context, const UserQRCodePage()),
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.qr_code),
                          wGap(10),
                          Text(
                            "My QR Code",
                            style: googleStyle(
                              weight: FontWeight.w400,
                              color: Colors.white,
                              size: 15,
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.black,
                    ),
              body: SafeArea(
                bottom: false,
                child: profileBody(
                  context,
                  image,
                  getImage,
                  () async {
                    if (value.returnIsLoading()) return;

                    if (image == null) {
                      showSnackBar(context, "No changes made");

                      return;
                    }

                    value.toggleIsLoading();

                    // uploads the profile image
                    await value.updateProfileImage(image);

                    showSnackBar(context, "Profile saved");

                    image = null;

                    value.toggleIsLoading();

                    // changePage(context, const HomePage(), type: "pr");
                  },
                ),
              ),
            );
    });
  }
}
