import 'package:flutter/material.dart';

class PoliceHomeScreen extends StatefulWidget {
  const PoliceHomeScreen({super.key});

  @override
  State<PoliceHomeScreen> createState() => _PoliceHomeScreenState();
}

class _PoliceHomeScreenState extends State<PoliceHomeScreen> {
  // Officer ge nama storage eken ganna puluwan passe
  final String officerName = "Officer Perera"; 
  final String stationName = "Colombo Fort";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Background color
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1), // Police Dark Blue
        elevation: 0,
        title: const Text("Traffic Control Unit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(), // Menu eka passe hadamu
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER SECTION (Name & Station)
            Container(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30),
              decoration: const BoxDecoration(
                color: Color(0xFF0D47A1),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage('https://cdn-icons-png.flaticon.com/512/206/206853.png'), // Placeholder Image
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome Back,",
                            style: TextStyle(color: Colors.blue[100], fontSize: 14),
                          ),
                          Text(
                            officerName,
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            stationName,
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2. DASHBOARD GRID (Buttons)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Quick Actions",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 15),
                  
                  // Grid Layout
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2, // Button 2k peliyata
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    children: [
                      _buildMenuCard(
                        title: "New Fine",
                        icon: Icons.note_add_outlined,
                        color: Colors.redAccent,
                        onTap: () {
                          // Fine page ekata yanna
                        },
                      ),
                      _buildMenuCard(
                        title: "Check License",
                        icon: Icons.qr_code_scanner,
                        color: Colors.blue,
                        onTap: () {
                          // QR scan karana thanata
                        },
                      ),
                      _buildMenuCard(
                        title: "Fine History",
                        icon: Icons.history,
                        color: Colors.orange,
                        onTap: () {
                          // History page ekata
                        },
                      ),
                      _buildMenuCard(
                        title: "Profile",
                        icon: Icons.person_outline,
                        color: Colors.green,
                        onTap: () {
                          // Profile page ekata
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Lassanata Button hadana function eka
  Widget _buildMenuCard({required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 35, color: color),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}