import 'package:flutter/material.dart';

class WorkoutsPage extends StatelessWidget {
  final Color primaryColor = const Color(0xFF3d98f4);

  final List<_Category> categories = const [
    _Category(
      name: 'Cardio',
      image:
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDdDBaoykVjvPsxAxVN3YLaL5Kpl9DRfbiEicCoaV79yoFIFv-4sCOHB02kJv39jlZwe97n9aP1oB0R0bu60SA6W3T90C6mlpgZBa5EbNrAVrZeOeYZ5QOPHjgaJpFZJIr5T-qH4f63khq39uOWI3XO_ivBMAJtq-zcCHmeotYpMZrzEYSNjOXdfNyjL2GMtiK6C-4VAeiv82PlgOJWfnUp3NKDjM2zH4Nm706wFKzXXhO7hzf_d8SqdbqGOqbDzDOUmZUL6JcUkSp9',
    ),
    _Category(
      name: 'Strength',
      image:
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAeg1dsCfw5HYC33Q6cWBbBGuj6BBDvXRG589fQbC5oiGnZT8wfmXHUoG4eObKlyYRzDY5lMsKkhyk4NQ1hNm00eYDJ545vVsSvEiUKYJ-XBKHRl4Y1mccoS_dT6y8HgT732WilqJPcUXUuCGnn8q4eBq7NR4aTuQ3175V1Cd5K0VS5_fLAK5157hlCXi9_HkLhh_NCSHEK8eO_VUswZDHc5vRynF5BN4CmqswoD0QUihwKjprJPLEATdD0FUaTsd_DxnVDgZ9dzvIl',
    ),
    _Category(
      name: 'Yoga',
      image:
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDfFScvcboyWaAIPgggRknnECZqsm6LEixdbqUA8dV-uXe7ie6g1akV6GXYkW59vgr9Q0J_3tXFMutBaX8ZcroRcffn-s46LsVAFg3Y6MVZkYQCEZhqr1A-BRPUhWA9DDJwXMQHaAzIS5AR6lf7iVFfky6IJx65uC0Zywzq4c5DXucH-Ax_VKq4En1hEY_wWn4NNBc6HMZiRLg6AeEhXkedPgG247ZclqEjFxa42Ufsd4NQGTqw52qYWVnTn9mS_0yvZiUV60Aidki0',
    ),
    _Category(
      name: 'Pilates',
      image:
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAen17wzAlaS35SgtWroFDRR8Fa8ToBKLqhjm6ld4mt7Jt7SPfmtOfHKYsM-DZlVbP1nQOrMpf_048uAI1NsBh_FiWzAYDGClpt3BIvXDETDW3Bypk5C8YKX5ztiUJzVZkq6Ppz0NkHng9LeK33E959nKYbJt3AiLawLhGJw9GOn9ogDW0VYAcJ1ItiS_qmPIqszLL_-RFaAl6_02SK2qbu3Xde_MYq-8QXqFwIe9w1EKv5GFfcnVKCTBgWqFdyWZ0eZAzqwpJm-yBW',
    ),
    _Category(
      name: 'Dance',
      image:
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBJENG--NW76n3FgRZmGFa9eP3nFZEU7iYl4dFAUGHNsjD1GD4sRxCDQ5QwKnGy37HTQROMdKotRcGg_GfHzcFxK1zYmjW2n2lCXHlDlbRjpEX-pmMolr2pIy5g2BxNB9Hg0ikLNZfvuK89jU83ufmc4bB_uGNXuI6g826umrTO-eNCrRHEjmdVGueCr4OsOIZzF7D2xdk6aJ1SqhVFn0rR8sw_m-kV_oyx4i9Esa2K0ewzSoYjElIfs5JbGROCNaWqxNPKCIuW_R_p',
    ),
    _Category(
      name: 'HIIT',
      image:
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDXbFjVVqSv2VTHzjX9kkdXrHjoXLlVYnWipt0BhQh-eFj8NszeqNZnvveOvWwoRCAj-WNmvXKgjh45SCIFj-6dT8WomGXkhjM7A0rj2LKScZban-Hws5TAlup0MjNMLYpb1VW5KrUMzD7Q-6-JeXKaUDt_t9BoL4Nr_G8NZ5GWucwxDu49sZERuIxAUhEsQlF0J4f_6XOFak3V0wyZSNpGBaPqj9gnG3XOXNgpRrwFaONxM1pYysTbBXHS9cKqf0Vl98UUVr-wUphu',
    ),
  ];

  const WorkoutsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  _iconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () {},
                    color: Colors.grey[600],
                  ),
                  const Spacer(),
                  const Text(
                    'Workouts',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  _iconButton(
                    icon: Icons.add,
                    onTap: () {},
                    color: Colors.white,
                    background: primaryColor,
                  ),
                ],
              ),
            ),
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[50],
                  hintText: 'Find a workout',
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                ),
              ),
            ),
            // Categories Title
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            // Categories Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GridView.builder(
                  itemCount: categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemBuilder: (context, i) => _CategoryCard(
                    category: categories[i],
                  ),
                ),
              ),
            ),
            // Bottom Navigation Bar
            _BottomNavBar(primaryColor: primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _iconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
    Color? background,
  }) =>
      Material(
        color: background ?? Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            height: 40,
            width: 40,
            child: Icon(icon, color: color ?? Colors.black),
          ),
        ),
      );
}

class _Category {
  final String name;
  final String image;
  const _Category({required this.name, required this.image});
}

class _CategoryCard extends StatelessWidget {
  final _Category category;
  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              category.image,
              fit: BoxFit.cover,
              errorBuilder: (ctx, o, e) => Container(color: Colors.grey[200]),
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.20),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: Text(
              category.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                shadows: [
                  Shadow(
                    color: Colors.black45,
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final Color primaryColor;
  const _BottomNavBar({required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavBarButton(
              icon: Icons.grid_view_rounded,
              label: 'Home',
              selected: true,
              color: primaryColor,
            ),
            _NavBarButton(
              icon: Icons.view_module_rounded,
              label: 'Workouts',
              selected: false,
              color: primaryColor,
            ),
            _NavBarButton(
              icon: Icons.bar_chart_rounded,
              label: 'Progress',
              selected: false,
              color: primaryColor,
            ),
            _NavBarButton(
              icon: Icons.brightness_1_outlined,
              label: 'Settings',
              selected: false,
              color: primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color color;

  const _NavBarButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? color : Colors.grey[500], size: 28),
            Text(
              label,
              style: TextStyle(
                color: selected ? color : Colors.grey[500],
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}