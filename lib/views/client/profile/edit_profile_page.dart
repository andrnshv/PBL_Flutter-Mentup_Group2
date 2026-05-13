import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../controller/clien/edit_profile_controller.dart';
import '../../../models/clien/edit_profile_model.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() =>
      _EditProfilePageState();
}

class _EditProfilePageState
    extends State<EditProfilePage> {

  final EditProfileController
      _controller =
      EditProfileController();

  final Color primary =
      const Color(0xFF6C63FF);

  final nameController =
      TextEditingController();

  final emailController =
      TextEditingController();

  final aboutController =
      TextEditingController();

  File? selectedImage;

  String? networkImage;

  bool isPhotoDeleted = false;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile()
  async {

    final EditProfileModel? profile =
        await _controller.getProfile();

    if (profile != null) {

      nameController.text =
          profile.namaLengkap;

      emailController.text =
          profile.email;

      aboutController.text =
          profile.bio;

      networkImage =
          profile.fotoUrl;
    }

    if (mounted) {

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {

    nameController.dispose();

    emailController.dispose();

    aboutController.dispose();

    super.dispose();
  }

  Future<void> pickImage(
    ImageSource source,
  ) async {

    try {

      final picker = ImagePicker();

      final pickedImage =
          await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedImage != null) {

        setState(() {
          selectedImage =
              File(pickedImage.path);

          isPhotoDeleted = false;
        });
      }

    } catch (e) {

      debugPrint(
        "ERROR CAMERA: $e",
      );
    }
  }

  void removeImage() {

    setState(() {
      selectedImage = null;
      networkImage = null;
      isPhotoDeleted = true;
    });

    Navigator.pop(context);
  }

  void showPhotoOptions() {

    showModalBottomSheet(
      context: context,

      builder: (context) {

        return Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [

            ListTile(
              leading:
                  const Icon(
                Icons.camera_alt,
              ),

              title:
                  const Text(
                "Camera",
              ),

              onTap: () async {

                Navigator.pop(
                  context,
                );

                await pickImage(
                  ImageSource.camera,
                );
              },
            ),

            ListTile(
              leading:
                  const Icon(
                Icons.photo,
              ),

              title:
                  const Text(
                "Gallery",
              ),

              onTap: () async {

                Navigator.pop(
                  context,
                );

                await pickImage(
                  ImageSource.gallery,
                );
              },
            ),

            ListTile(
              leading:
                  const Icon(
                Icons.delete,
              ),

              title:
                  const Text(
                "Remove",
              ),

              onTap: removeImage,
            ),
          ],
        );
      },
    );
  }

  Future<void> saveProfile()
  async {

    setState(() {
      isLoading = true;
    });

    String? imageUrl =
        networkImage;

    if (selectedImage != null) {

      imageUrl =
          await _controller
              .uploadImage(
        selectedImage!,
      );
    }

    final success =
        await _controller
            .updateProfile(
      namaLengkap:
          nameController.text,
      email:
          emailController.text,
      bio:
          aboutController.text,
      fotoUrl:
          isPhotoDeleted
              ? null
              : imageUrl,
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (success) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          backgroundColor:
              primary,

          content: const Text(
            "Profile updated successfully",
          ),
        ),
      );

      Navigator.pop(context);

    } else {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Failed to update profile",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {

      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7FB),

      body: SingleChildScrollView(
        child: Column(
          children: [

            Container(
              height: 260,

              decoration:
                  const BoxDecoration(
                gradient:
                    LinearGradient(
                  colors: [
                    Color(0xFFB993D6),
                    Color(0xFF8CA6DB),
                  ],
                ),

                borderRadius:
                    BorderRadius.vertical(
                  bottom:
                      Radius.circular(40),
                ),
              ),

              child: SafeArea(
                child: Column(
                  children: [

                    Row(
                      children: [

                        IconButton(
                          onPressed: () {
                            Navigator.pop(
                              context,
                            );
                          },

                          icon: const Icon(
                            Icons.arrow_back,
                            color:
                                Colors.white,
                          ),
                        ),

                        const Expanded(
                          child: Text(
                            "Edit Profile",

                            textAlign:
                                TextAlign
                                    .center,

                            style:
                                TextStyle(
                              color:
                                  Colors.white,
                              fontSize:
                                  22,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 48,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Transform.translate(
              offset:
                  const Offset(0, -70),

              child: Column(
                children: [

                  Stack(
                    children: [

                      CircleAvatar(
                        radius: 65,

                        backgroundColor:
                            Colors.white,

                        child: CircleAvatar(
                          radius: 60,

                          backgroundColor:
                              Colors.grey
                                  .shade200,

                          backgroundImage:
                              selectedImage !=
                                      null
                                  ? FileImage(
                                      selectedImage!,
                                    )

                                  : networkImage !=
                                          null
                                      ? NetworkImage(
                                          networkImage!,
                                        )

                                      : null,

                          child:
                              selectedImage ==
                                          null &&
                                      networkImage ==
                                          null
                                  ? Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors
                                          .grey
                                          .shade500,
                                    )
                                  : null,
                        ),
                      ),

                      Positioned(
                        bottom: 5,
                        right: 5,

                        child: GestureDetector(
                          onTap:
                              showPhotoOptions,

                          child: Container(
                            padding:
                                const EdgeInsets
                                    .all(10),

                            decoration:
                                const BoxDecoration(
                              gradient:
                                  LinearGradient(
                                colors: [
                                  Color(
                                      0xFFB993D6),
                                  Color(
                                      0xFF8CA6DB),
                                ],
                              ),

                              shape:
                                  BoxShape.circle,
                            ),

                            child: const Icon(
                              Icons.camera_alt,
                              color:
                                  Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  Padding(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 20,
                    ),

                    child: Container(
                      padding:
                          const EdgeInsets
                              .all(22),

                      decoration:
                          BoxDecoration(
                        color:
                            Colors.white,

                        borderRadius:
                            BorderRadius
                                .circular(30),

                        boxShadow: [
                          BoxShadow(
                            color: Colors
                                .black
                                .withValues(
                                  alpha: 0.05,
                                ),

                            blurRadius:
                                25,
                          ),
                        ],
                      ),

                      child: Column(
                        children: [

                          _buildInput(
                            label:
                                "Full Name",
                            controller:
                                nameController,
                            icon:
                                Icons.person,
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          _buildInput(
                            label:
                                "Email",
                            controller:
                                emailController,
                            icon:
                                Icons.email,
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          _buildInput(
                            label:
                                "About",
                            controller:
                                aboutController,
                            icon:
                                Icons.info,
                            maxLines: 4,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Padding(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 20,
                    ),

                    child: SizedBox(
                      width: double.infinity,
                      height: 60,

                      child: ElevatedButton(
                        onPressed:
                            saveProfile,

                        style:
                            ElevatedButton
                                .styleFrom(
                          padding:
                              EdgeInsets.zero,

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              24,
                            ),
                          ),
                        ),

                        child: Ink(
                          decoration:
                              BoxDecoration(
                            gradient:
                                const LinearGradient(
                              colors: [
                                Color(
                                    0xFFB993D6),
                                Color(
                                    0xFF8CA6DB),
                              ],
                            ),

                            borderRadius:
                                BorderRadius
                                    .circular(
                              24,
                            ),
                          ),

                          child:
                              const Center(
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,

                              children: [

                                Icon(
                                  Icons.save,
                                  color: Colors
                                      .white,
                                ),

                                SizedBox(
                                  width: 10,
                                ),

                                Text(
                                  "Save Changes",

                                  style:
                                      TextStyle(
                                    color:
                                        Colors.white,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required TextEditingController
        controller,
    required IconData icon,
    int maxLines = 1,
  }) {

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Text(
          label,

          style: TextStyle(
            color:
                Colors.grey.shade700,
            fontWeight:
                FontWeight.w700,
          ),
        ),

        const SizedBox(height: 10),

        TextField(
          controller: controller,
          maxLines: maxLines,

          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: primary,
            ),

            filled: true,

            fillColor:
                const Color(0xFFF8F9FD),

            border:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                20,
              ),

              borderSide:
                  BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}