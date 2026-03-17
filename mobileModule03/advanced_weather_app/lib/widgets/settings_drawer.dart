import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
//  SettingsDrawer  — volet paramètres overlay depuis la gauche
//  Couvre 3/4 de l'écran. Cliquer sur le 1/4 droit ferme.
//  Affiche les miniatures de background + option "None".
// ─────────────────────────────────────────────────────────────

const List<String> kBackgroundAssets = [
  'assets/background_assets/backgroud_image_weatherApp.jpg',
  'assets/background_assets/Pacific_Wallpaper_0.jpg',
  'assets/background_assets/Pacific_Wallpaper_1.jpg',
  'assets/background_assets/Pacific_Wallpaper_2.jpg',
  'assets/background_assets/Pacific_Wallpaper_3.jpg',
  'assets/background_assets/Pacific_Wallpaper_4.jpg',
  'assets/background_assets/Pacific_Wallpaper_5.jpg',
  'assets/background_assets/Pacific_Wallpaper_6.jpg',
];

class SettingsDrawer extends StatelessWidget {
  final String? selectedBackground;
  final ValueChanged<String?> onBackgroundSelected;
  final VoidCallback onClose;

  const SettingsDrawer({
    super.key,
    required this.selectedBackground,
    required this.onBackgroundSelected,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = screenWidth * 0.75;

    return Stack(
      children: [
        // ── Zone transparente à droite (1/4) : tap pour fermer ──
        Positioned(
          left: drawerWidth,
          top: 0,
          bottom: 0,
          width: screenWidth * 0.25,
          child: GestureDetector(
            onTap: onClose,
            child: Container(color: Colors.transparent),
          ),
        ),

        // ── Volet settings (3/4 gauche) ──
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: drawerWidth,
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xF01A1A2E),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 20,
                  offset: Offset(4, 0),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Paramètres',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: onClose,
                        ),
                      ],
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Fond d\'écran',
                      style: TextStyle(
                        color: Color(0xFFE8A045),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(color: Color(0x44FFFFFF), height: 1),
                  ),

                  const SizedBox(height: 16),

                  // ── Grille de miniatures ──
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 9 / 16,
                        ),
                        itemCount: kBackgroundAssets.length + 1, // +1 pour Aucun
                        itemBuilder: (context, index) {
                          // Dernière case = Aucun
                          if (index == kBackgroundAssets.length) {
                            final isSelected = selectedBackground == null;
                            return _ThumbnailTile(
                              isSelected: isSelected,
                              onTap: () => onBackgroundSelected(null),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0D0D1A),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.block,
                                        color: Colors.white38,
                                        size: 22,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Aucun',
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }

                          final assetPath = kBackgroundAssets[index];
                          final isSelected = selectedBackground == assetPath;

                          return _ThumbnailTile(
                            isSelected: isSelected,
                            onTap: () => onBackgroundSelected(assetPath),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                assetPath,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Tuile avec bordure de sélection ──
class _ThumbnailTile extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;

  const _ThumbnailTile({
    required this.isSelected,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFFE8A045) : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? [
                  const BoxShadow(
                    color: Color(0x88E8A045),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : [],
        ),
        child: child,
      ),
    );
  }
}
