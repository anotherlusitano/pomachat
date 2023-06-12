import 'package:flutter/material.dart';

class GroupListItem extends StatelessWidget {
  final String bio;
  final String name;
  final String pictureUrl;
  final String membersQuantity;

  const GroupListItem({
    super.key,
    required this.bio,
    required this.name,
    required this.pictureUrl,
    required this.membersQuantity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: const EdgeInsets.all(25),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[400],
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(10),
            child: pictureUrl.isNotEmpty ? GroupImage(pictureUrl: pictureUrl) : const GroupIcon(),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 10),
                Text(bio),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: 65,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Membros:"),
                  const SizedBox(height: 10),
                  Text(membersQuantity),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GroupImage extends StatelessWidget {
  const GroupImage({
    super.key,
    required this.pictureUrl,
  });

  final String pictureUrl;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      pictureUrl,
      height: 40,
      width: 40,
      filterQuality: FilterQuality.high,
    );
  }
}

class GroupIcon extends StatelessWidget {
  const GroupIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.people,
      size: 40,
      color: Colors.white,
    );
  }
}
