import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/dummy_data.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() =>
      _EditProfilePageState();
}

class _EditProfilePageState
    extends State<EditProfilePage> {
  final Color primary =
      const Color(0xFF6C63FF);

  final user = DummyData.user;

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController addressController;
  late TextEditingController aboutController;

  File? selectedImage;

  bool isPhotoDeleted = false;

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(text: user.name);

    emailController =
        TextEditingController(text: user.email);

    addressController =
        TextEditingController(
      text: user.address,
    );

    aboutController =
        TextEditingController(text: user.bio);
  }

  /// ================= PICK IMAGE =================

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
    debugPrint("ERROR CAMERA: $e");

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Failed to open camera: $e",
        ),
      ),
    );
  }
}

/// ================= REMOVE IMAGE =================

void removeImage() {
  setState(() {
    selectedImage = null;
    isPhotoDeleted = true;
  });

  Navigator.pop(context);
}

/// ================= SHOW PHOTO OPTIONS =================

void showPhotoOptions() {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text("Camera"),
            onTap: () async {
              Navigator.pop(context);

              await pickImage(
                ImageSource.camera,
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text("Gallery"),
            onTap: () async {
              Navigator.pop(context);

              await pickImage(
                ImageSource.gallery,
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text("Remove"),
            onTap: removeImage,
          ),
        ],
      );
    },
  );
}

  Widget _photoOption({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,

            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),

            child: Icon(
              icon,
              color: color,
              size: 32,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7FB),

      body: SingleChildScrollView(
        child: Column(
          children: [
            /// ================= HEADER =================

            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 260,

                  decoration:
                      const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFB993D6),
                        Color(0xFF8CA6DB),
                      ],
                      begin:
                          Alignment.topLeft,
                      end: Alignment
                          .bottomRight,
                    ),

                    borderRadius:
                        BorderRadius.vertical(
                      bottom:
                          Radius.circular(40),
                    ),
                  ),
                ),

                /// DECORATION CIRCLE

                Positioned(
                  top: -40,
                  right: -20,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                Positioned(
                  top: 70,
                  left: -30,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                /// BACK BUTTON

                Positioned(
                  top: 50,
                  left: 15,

                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),

                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),

                      onPressed: () =>
                          Navigator.pop(
                              context),
                    ),
                  ),
                ),

                /// TITLE

                const Positioned(
                  top: 58,
                  left: 0,
                  right: 0,

                  child: Center(
                    child: Text(
                      "Edit Profile",

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                /// ================= PROFILE =================

                Positioned(
                  bottom: -85,
                  left: 0,
                  right: 0,

                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding:
                                const EdgeInsets
                                    .all(5),

                            decoration:
                                BoxDecoration(
                              color:
                                  Colors.white,
                              shape:
                                  BoxShape.circle,

                              boxShadow: [
                                BoxShadow(
                                  color: Colors
                                      .black
                                      .withValues(alpha: 0.15),

                                  blurRadius:
                                      20,

                                  offset:
                                      const Offset(
                                          0, 10),
                                )
                              ],
                            ),

                            child: CircleAvatar(
                              radius: 60,

                              backgroundColor:
                                  Colors
                                      .grey
                                      .shade200,

                              backgroundImage:
                                  selectedImage !=
                                          null
                                      ? FileImage(
                                          selectedImage!,
                                        )
                                      : isPhotoDeleted
                                          ? null
                                          : AssetImage(
                                                  user
                                                      .image)
                                              as ImageProvider,

                              child: isPhotoDeleted
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

                          /// CAMERA BUTTON

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

                                  shape:
                                      BoxShape
                                          .circle,

                                  border:
                                      Border.all(
                                    color: Colors
                                        .white,
                                    width: 3,
                                  ),

                                  boxShadow: [
                                    BoxShadow(
                                      color: primary
                                          .withValues(alpha: 0.4),

                                      blurRadius:
                                          10,
                                    )
                                  ],
                                ),

                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 20,
                                  color:
                                      Colors.white,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),

                      const SizedBox(height: 4),

                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),

                        decoration:
                            BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),

                          borderRadius:
                              BorderRadius
                                  .circular(30),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 110),

            /// ================= FORM =================

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  /// CARD

                  Container(
                    padding:
                        const EdgeInsets.all(
                            22),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius:
                          BorderRadius
                              .circular(30),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),

                          blurRadius: 25,

                          offset:
                              const Offset(
                                  0, 12),
                        )
                      ],
                    ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [
                        Row(
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets
                                      .all(12),

                              decoration:
                                  BoxDecoration(
                                gradient:
                                    LinearGradient(
                                  colors: [
                                    primary.withValues(alpha: 0.15),

                                    Colors.blue.withValues(alpha: 0.15),
                                  ],
                                ),

                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            18),
                              ),

                              child: Icon(
                                Icons.person,
                                color: primary,
                              ),
                            ),

                            const SizedBox(
                                width: 14),

                            const Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [
                                Text(
                                  "Personal Information",

                                  style:
                                      TextStyle(
                                    fontSize:
                                        18,

                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),

                                SizedBox(
                                    height: 4),

                                Text(
                                  "Update your account details",

                                  style:
                                      TextStyle(
                                    color: Colors
                                        .grey,

                                    fontSize:
                                        12,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),

                        const SizedBox(
                            height: 30),

                        _buildInput(
                          label:
                              "Full Name",
                          controller:
                              nameController,
                          icon: Icons
                              .person_outline,
                        ),

                        const SizedBox(
                            height: 20),

                        _buildInput(
                          label: "Email",
                          controller:
                              emailController,
                          icon: Icons
                              .email_outlined,
                        ),

                        const SizedBox(
                            height: 20),

                        _buildInput(
                          label:
                              "Address",
                          controller:
                              addressController,
                          icon: Icons
                              .location_on_outlined,
                          maxLines: 2,
                        ),

                        const SizedBox(
                            height: 20),

                        _buildInput(
                          label: "About",
                          controller:
                              aboutController,
                          icon: Icons
                              .info_outline,
                          maxLines: 4,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  /// ================= SAVE BUTTON =================

                  SizedBox(
                    width: double.infinity,
                    height: 60,

                    child: ElevatedButton(
                      style:
                          ElevatedButton
                              .styleFrom(
                        padding:
                            EdgeInsets.zero,

                        elevation: 10,

                        shadowColor: primary.withValues(alpha:0.4),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      24),
                        ),
                      ),

                      onPressed: () {
                        DummyData.user =
                            DummyData.user
                                .copyWith(
                          name:
                              nameController
                                  .text,

                          email:
                              emailController
                                  .text,

                          address:
                              addressController
                                  .text,

                          bio:
                              aboutController
                                  .text,
                        );

                        ScaffoldMessenger.of(
                                context)
                            .showSnackBar(
                          SnackBar(
                            backgroundColor:
                                primary,

                            behavior:
                                SnackBarBehavior
                                    .floating,

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          18),
                            ),

                            margin:
                                const EdgeInsets
                                    .all(16),

                            content: const Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color:
                                      Colors
                                          .white,
                                ),

                                SizedBox(
                                    width: 10),

                                Text(
                                  "Profile updated successfully ✨",

                                  style:
                                      TextStyle(
                                    color: Colors
                                        .white,

                                    fontWeight:
                                        FontWeight
                                            .w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );

                        Navigator.pop(
                          context,
                        );
                      },

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
                                      24),
                        ),

                        child: const Center(
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,

                            children: [
                              Icon(
                                Icons.save_rounded,
                                color: Colors
                                    .white,
                              ),

                              SizedBox(
                                  width: 10),

                              Text(
                                "Save Changes",

                                style:
                                    TextStyle(
                                  fontSize:
                                      16,

                                  fontWeight:
                                      FontWeight
                                          .bold,

                                  color: Colors
                                      .white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 35),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  /// ================= INPUT =================

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
            color: Colors.grey.shade700,
            fontWeight:
                FontWeight.w700,
            fontSize: 13,
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

            hintText: label,

            hintStyle: TextStyle(
              color: Colors
                  .grey.shade400,
            ),

            contentPadding:
                const EdgeInsets
                    .symmetric(
              vertical: 18,
              horizontal: 15,
            ),

            border:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                      20),

              borderSide:
                  BorderSide.none,
            ),

            enabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                      20),

              borderSide: BorderSide(
                color:
                    Colors.grey.shade200,
              ),
            ),

            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                      20),

              borderSide: BorderSide(
                color: primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}