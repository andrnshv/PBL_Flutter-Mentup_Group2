import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildHeader(),
          _buildProfileInfo(),
          _buildTabs(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _aboutTab(),
                _activityTab(),
                _goalsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 180,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFB993D6), Color(0xFF8CA6DB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          left: 20,
          child: Stack(
            children: [
              const CircleAvatar(
                radius: 55,
                backgroundImage: AssetImage("assets/profile.jpg"),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.black,
                  child: const Icon(Icons.camera_alt,
                      size: 16, color: Colors.white),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildProfileInfo() {
    return Padding(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Park Chanyeol",
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                child: IconButton(
                  onPressed: () {
                    // aksi edit
                  },
                  icon: const Icon(Icons.edit, color: Colors.deepPurple),
                ),
              )
            ],
          ),
          const SizedBox(height: 5),
          const Text(
            "Client • Music Enthusiast",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 15),
          _buildStats(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: const [
        _StatItem(title: "Sessions", value: "24"),
        _StatItem(title: "Mentors", value: "5"),
        _StatItem(title: "Progress", value: "80%"),
      ],
    );
  }

  Widget _buildTabs() {
    return TabBar(
      controller: _tabController,
      indicatorColor: Colors.deepPurple,
      labelColor: Colors.deepPurple,
      unselectedLabelColor: Colors.grey,
      tabs: const [
        Tab(text: "About"),
        Tab(text: "Activity"),
        Tab(text: "Goals"),
      ],
    );
  }

  Widget _aboutTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        Text(
          "About Client",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          "Loves learning music and improving vocal skills. Actively books sessions with mentors.",
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _activityTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        ListTile(
          leading: Icon(Icons.calendar_today),
          title: Text("Session with Vocal Coach"),
          subtitle: Text("12 March 2026"),
        ),
        ListTile(
          leading: Icon(Icons.music_note),
          title: Text("Practice Completed"),
          subtitle: Text("2 hours session"),
        ),
      ],
    );
  }

  Widget _goalsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        ListTile(
          leading: Icon(Icons.flag),
          title: Text("Improve vocal range"),
        ),
        ListTile(
          leading: Icon(Icons.flag),
          title: Text("Release first single"),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;

  const _StatItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}