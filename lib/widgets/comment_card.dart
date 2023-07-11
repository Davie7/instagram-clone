import '../barrel/export.dart';

class CommentCard extends StatefulWidget {
  final snap;
  const CommentCard({super.key, required this.snap});

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {

  @override
  Widget build(BuildContext context) {
    DateTime commentDate = widget.snap['datePublished'].toDate();
    DateTime now = DateTime.now();
    Duration difference = now.difference(commentDate);
    String timeAgo;

    if (difference.inSeconds < 60) {
      timeAgo = '${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes < 60) {
      timeAgo = '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      timeAgo = difference.inHours == 1 ? '1 hour ago' :'${difference.inHours} hours ago';
    } else if (difference.inDays < 7){
      timeAgo = difference.inDays == 1 ? '1 day ago' : '${difference.inDays} days ago';
    } else {
      int weeks = (difference.inDays / 7).floor();
      timeAgo = '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 16,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(widget.snap['profilePic']),
            radius: 18,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: widget.snap['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: ' ${widget.snap['text']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 4,
                    ),
                    child: Text(
                      timeAgo,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(
              Icons.favorite,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}
