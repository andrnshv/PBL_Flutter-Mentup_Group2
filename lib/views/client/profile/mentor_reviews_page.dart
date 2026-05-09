import 'package:flutter/material.dart';
import '../../../models/mentor_model.dart';

class MentorReviewsPage extends StatelessWidget {
  final MentorModel mentor;

  const MentorReviewsPage({
    super.key,
    required this.mentor,
  });

  @override
  Widget build(BuildContext context) {
    final reviews = [
      {
        "name": "Aiska",
        "rating": 4.8,
        "review":
            "Mentor sangat membantu dan komunikatif!"
      },
      {
        "name": "Bintang",
        "rating": 5.0,
        "review":
            "Penjelasan mudah dipahami dan detail."
      },
      {
        "name": "Rina",
        "rating": 4.9,
        "review":
            "Sangat recommended untuk mentoring Flutter."
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${mentor.name} Reviews",
        ),
      ),

      backgroundColor:
          const Color(0xFFF4F6FA),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reviews.length,

        itemBuilder: (context, index) {
          final item = reviews[index];

          return Container(
            margin:
                const EdgeInsets.only(
                    bottom: 15),

            padding:
                const EdgeInsets.all(15),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(
                      18),
            ),

            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                const CircleAvatar(
                  child:
                      Icon(Icons.person),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [

                      Row(
                        children: [

                          Text(
                            item["name"]
                                .toString(),

                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),

                          const SizedBox(
                              width: 6),

                          const Icon(
                            Icons.star,
                            color:
                                Colors.amber,
                            size: 16,
                          ),

                          Text(
                            item["rating"]
                                .toString(),
                          ),
                        ],
                      ),

                      const SizedBox(
                          height: 8),

                      Text(
                        item["review"]
                            .toString(),

                        style:
                            const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}