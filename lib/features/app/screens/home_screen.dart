import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prioro/colors.dart';
import 'package:prioro/features/app/screens/task/task_screen.dart';
import 'package:prioro/features/app/screens/profile_screen.dart';
import 'package:prioro/features/app/widgets/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return IndexedStack(
      index: currentIndex,
      children: [
        _buildHomeContent(user),
        TaskScreen(
          currentIndex: currentIndex,
          onTabChange: (index) => setState(() => currentIndex = index),
        ),
        ProfileScreen(
          currentIndex: currentIndex,
          onTabChange: (index) => setState(() => currentIndex = index),
          user: user,
        ),
      ],
    );
  }

  Widget _buildHomeContent(User? user) {
    final String firstName = (user?.displayName ?? user?.email ?? 'User')
        .split(' ')
        .first;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 20),

            // ── Header ──────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          '$firstName ',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const Text('🌟', style: TextStyle(fontSize: 22)),
                      ],
                    ),
                  ],
                ),
                // Avatar
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.orange.shade300,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: user?.photoURL != null
                        ? Image.network(user!.photoURL!, fit: BoxFit.cover)
                        : Container(
                            color: Colors.orange.shade100,
                            child: Icon(
                              Icons.person,
                              color: Colors.orange.shade400,
                              size: 26,
                            ),
                          ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── User Info Card (horizontal) ─────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade300, appbarColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: user?.photoURL != null
                        ? ClipOval(
                            child: Image.network(
                              user!.photoURL!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 28,
                          ),
                  ),
                  const SizedBox(width: 14),
                  // Name + email
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? 'User',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Stats pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '23',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.orange.shade600,
                          ),
                        ),
                        Text(
                          'Tasks',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange.shade400,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── 2×2 Stats Grid ───────────────────────────
            Row(
              children: [
                // View Task card
                Expanded(
                  child: Transform.translate(
                    offset: const Offset(0, -16),
                    child: _buildGradientCard(
                      title: 'View Task',
                      subtitle: '30 tasks in total',
                      count1: '12',
                      count2: '528',
                      icon: Icons.task_alt_rounded,
                      gradientColors: [const Color(0xFFF5A55A), appbarColor],
                      onTap: () => setState(() => currentIndex = 1),
                      height: 125,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Completed Tasks card
                Expanded(
                  child: _buildGradientCard(
                    title: 'Completed',
                    subtitle: '3.95 minutes avg',
                    count1: '19',
                    count2: '535',
                    icon: Icons.check_circle_rounded,
                    gradientColors: [
                      appbarColor,
                      const Color.fromARGB(255, 224, 135, 71),
                    ],
                    onTap: () {},
                    height: 156,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                // In Progress card
                Expanded(
                  child: Transform.translate(
                    offset: const Offset(0, -36),
                    child: _buildGradientCard(
                      title: 'In Progress',
                      subtitle: 'Active tasks',
                      count1: '11',
                      count2: '523',
                      icon: Icons.pending_actions_rounded,
                      gradientColors: [
                        const Color(0xFFFFCF8B),
                        const Color(0xFFF5A55A),
                      ],
                      onTap: () {},
                      height: 132,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // High Priority card (white)
                Expanded(
                  child: Transform.translate(
                    offset: const Offset(0, -9),
                    child: _buildHighPriorityCard(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ── Upcoming Tasks ───────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upcoming Tasks',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    _iconBtn(Icons.chevron_left_rounded),
                    const SizedBox(width: 6),
                    _iconBtn(Icons.favorite_border_rounded),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 14),

            _buildUpcomingTask(
              label: 'Tieks',
              progress: 0.65,
              color: Colors.orange.shade400,
              doneIcon: Icons.edit_rounded,
              actionColor: Colors.green,
            ),
            const SizedBox(height: 10),
            _buildUpcomingTask(
              label: 'Mola',
              progress: 0.40,
              color: Colors.blue.shade300,
              doneIcon: Icons.check_rounded,
              actionColor: Colors.red.shade400,
            ),
            const SizedBox(height: 10),
            _buildUpcomingTask(
              label: 'Dues',
              progress: 0.80,
              color: Colors.green.shade400,
              doneIcon: Icons.check_rounded,
              actionColor: Colors.orange.shade400,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  Gradient stat card
  // ─────────────────────────────────────────────────
  Widget _buildGradientCard({
    required String title,
    required String subtitle,
    required String count1,
    required String count2,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    double height = 128,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withOpacity(0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const Spacer(),
            // Pill counts
            Row(
              children: [
                _countPill(count1),
                const SizedBox(width: 8),
                _countPill(count2),
                const Spacer(),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    color: Colors.white,
                    size: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _countPill(String count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        count,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  High Priority card (white)
  // ─────────────────────────────────────────────────
  Widget _buildHighPriorityCard() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'High Priority',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              Icon(Icons.more_horiz, color: Colors.grey.shade400, size: 18),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '01:00 2:20:88',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
          ),
          const Spacer(),
          // Colored dots
          Row(
            children: [
              _dot(Colors.red.shade400),
              const SizedBox(width: 5),
              _dot(Colors.orange.shade400),
              const SizedBox(width: 5),
              _dot(Colors.green.shade400),
              const SizedBox(width: 5),
              _dot(Colors.blue.shade300),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  // ─────────────────────────────────────────────────
  //  Upcoming task row
  // ─────────────────────────────────────────────────
  Widget _buildUpcomingTask({
    required String label,
    required double progress,
    required Color color,
    required IconData doneIcon,
    required Color actionColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Dot
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          // Label + bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Action icons
          Icon(doneIcon, size: 18, color: Colors.grey.shade400),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: Colors.grey.shade400,
          ),
          const SizedBox(width: 8),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: actionColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, color: Colors.white, size: 14),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, size: 18, color: Colors.grey.shade600),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }
}
