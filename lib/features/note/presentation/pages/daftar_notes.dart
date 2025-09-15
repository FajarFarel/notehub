import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notehub/core/const/colors.dart';
import 'package:notehub/core/functions/convert_date.dart';
import 'package:notehub/core/functions/warna_kategori.dart';
import 'package:notehub/core/widgets/custom_textfield.dart';
import 'package:notehub/core/widgets/note_card.dart';
import 'package:notehub/features/auth/presentation/controllers/auth_controller.dart';
import 'package:notehub/features/note/presentation/controllers/note_controller.dart';
import 'package:notehub/features/note/presentation/pages/note_pribadi.dart';
import 'package:notehub/features/profile/presentation/pages/profile_page.dart';
import 'package:shimmer/shimmer.dart';

class DaftarNotes extends StatefulWidget {
  DaftarNotes({super.key});

  @override
  State<DaftarNotes> createState() => _DaftarNotesState();
}

class _DaftarNotesState extends State<DaftarNotes> {
  final authController = Get.find<AuthController>();

  final noteController = Get.find<NoteController>();

  final cariController = TextEditingController();

  @override
  void initState() {
    super.initState();
    noteController.fetchUserNotes(authController.user.value!.id,
        forPeople: false); // load di sini
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --------- Header (tombol back dan profil)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      // Membersihkan filter
                      noteController.selectedFilter.value = '';
                      noteController.searchQuery.value = '';
                      // Ke homepage
                      Get.back();
                    },
                    icon: const Icon(Icons.arrow_back,
                        color: AppColors.buttonColor3),
                  ),
                  GestureDetector(
                    child: Obx(
                      () => CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.buttonColor2,
                        backgroundImage: authController.user.value?.foto != ''
                            ? NetworkImage(authController.user.value!.foto!)
                            : const AssetImage(
                                    'assets/images/default_avatar.png')
                                as ImageProvider,
                      ),
                    ),
                    onTap: () {
                      Get.to(ProfilePage());
                    },
                  ),
                ],
              ),
            ),

            // ---------- Search + Filter Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Daftar Notes Kamu",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryTextColor,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: customTextfield(
                          hintText: "Cari Note",
                          controller: cariController,
                          onChanged: (value) {
                            noteController.searchQuery.value = value;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        icon:
                            const Icon(Icons.menu_rounded, color: Colors.white),
                        color: AppColors.buttonColor3,
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all(AppColors.buttonColor3),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        onSelected: (value) {
                          // toggle filter
                          noteController.selectedFilter.value = value;
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'Belajar',
                            child: Text('Belajar',
                                style:
                                    TextStyle(color: AppColors.surfaceColor)),
                          ),
                          PopupMenuItem(
                            value: 'Cerita',
                            child: Text('Cerita',
                                style:
                                    TextStyle(color: AppColors.surfaceColor)),
                          ),
                          PopupMenuItem(
                            value: 'Random',
                            child: Text('Random',
                                style:
                                    TextStyle(color: AppColors.surfaceColor)),
                          ),
                          PopupMenuItem(
                            value: '',
                            child: Text('Semua',
                                style:
                                    TextStyle(color: AppColors.surfaceColor)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 15),

            // ------------- List Notes
            Expanded(
              child: Obx(() {
                if (noteController.isLoading.value) {
                  // Tampilan jika loading
                  return DaftarNotesShimmer();
                }
                if (noteController.notes.isEmpty) {
                  // Tampilan jika tidak ada catatan
                  return const Center(
                      child: Text(
                    "Belum ada catatan",
                    style: TextStyle(color: AppColors.disabledTextColor),
                  ));
                }
                // Tampilan list catatan
                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  itemCount: noteController
                      .getFilteredNotes(noteController.notes)
                      .length,
                  itemBuilder: (context, index) {
                    final note = noteController
                        .getFilteredNotes(noteController.notes)[index];
                    return NoteCard(
                      kategori: note.kategori,
                      judul: note.judul,
                      isi: note.isi,
                      tanggal: formatTanggal(note.tanggal),
                      getKategoriColor: getKategoriColor,
                      onTap: () {
                        Get.off(NotePribadi(note: note));
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class DaftarNotesShimmer extends StatelessWidget {
  const DaftarNotesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          highlightColor: Colors.grey[100]!,
          baseColor: Colors.grey[300]!,
          child: Container(
            height: 230,
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }
}
