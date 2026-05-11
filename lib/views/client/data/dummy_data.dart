import 'package:intl/intl.dart';
import '../../../models/mentor_model.dart';
import '../../../models/user_model.dart';

class DummyData {
  // ================= FILTER STATE =================
  static String selectedCategory = "All";
  static double maxPrice = 100000;
  static double maxDistance = 10;

  // ================= CATEGORY =================
  static final List<String> categories = [
    "All",
    "Balet",
    "Produk designer",
    "UX Designer",
    "Dance",
    "Matematika",
    "Music",
  ];

  // ================= FORMAT =================
  static final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // ================= MENTOR =================
  static final List<MentorModel> mentors = [
    MentorModel(
      id: "1",
      name: "Jerome",
      username: "jerome",
      category: "Matematika",
      education: "UI",
      price: 80000,
      distance: 5,
      image: "assets/mentor1.jpg",
      rating: 4.8,
    ),
    MentorModel(
      id: "2",
      name: "Belva",
      username: "belva",
      category: "UX Designer",
      education: "ITS",
      price: 100000,
      distance: 3,
      image: "assets/mentor2.jpg",
      rating: 4.7,
    ),
    MentorModel(
      id: "3",
      name: "Loey",
      username: "loey",
      category: "Music",
      education: "UB",
      price: 60000,
      distance: 7,
      image: "assets/profile.jpg",
      rating: 4.5,
    ),
  ];

  // ================= TAB =================
  static int selectedTab = 0;

  // ================= HISTORY =================
  static final List<Map<String, dynamic>> historyMentors = [
    {
      "name": "Jerome",
      "role": "Matematika",
      "image": "assets/mentor1.jpg",
      "date": "12 April 2026",
      "dateObject": DateTime(2026, 4, 12),
      "status": "Done",
      "rating": 4,
      "review": "Mentor sangat membantu dan penjelasannya mudah dipahami!",
    },
    {
      "name": "Belva",
      "role": "UX Designer",
      "image": "assets/mentor2.jpg",
      "date": "10 April 2026",
      "dateObject": DateTime(2026, 4, 10),
      "status": "Done",
      "rating": 0,
      "review": null,
    },
    {
      "name": "Loey",
      "role": "Music",
      "image": "assets/profile.jpg",
      "date": "5 April 2026",
      "dateObject": DateTime(2026, 4, 5),
      "status": "Cancelled",
      "rating": 0,
      "review": null,
    },
  ];

  // ================= USER =================
  static UserModel user = UserModel(
    username: "@chanyeol",
    token: "dummy_token",
    name: "Park Chanyeol",
    email: "pcy2727@gmail.com",
    password:"Aiska2727*",
    image: "assets/profile.jpg",
    bio: "Loves learning music and improving vocal skills. Actively books sessions with mentors.",
    address : "jl.in aja dulu",
  );
}