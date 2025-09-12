import 'package:fitark/screens/nofap_screen.dart';
import 'package:fitark/screens/progress_screen.dart';
import 'package:fitark/screens/workout_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _postController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<CommunityPost> _posts = [];
  List<CommunityPost> _filteredPosts = [];
  bool _isLoading = true;
  final Map<String, bool> _likedPosts = {};
  final Map<String, bool> _dislikedPosts = {};

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _loadUserInteractions();
    _searchController.addListener(_filterPosts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _postController.dispose();
    super.dispose();
  }

  // Load posts from Firebase
  Future<void> _loadPosts() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final QuerySnapshot snapshot = await _firestore
          .collection('community_posts')
          .orderBy('created_at', descending: true)
          .limit(50)
          .get();

      final List<CommunityPost> loadedPosts = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // Get user info
        final userDoc =
            await _firestore.collection('users').doc(data['user_id']).get();

        final userData = userDoc.data() ?? {};

        if(!mounted) return;


        loadedPosts.add(CommunityPost(
          id: doc.id,
          userId: data['user_id'] ?? '',
          username: userData['displayName'] ?? 'Anonymous',
          userAvatar: userData['photoURL'] ??
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
          timeAgo:
              _formatTimeAgo(data['created_at']?.toDate() ?? DateTime.now()),
          content: data['content'] ?? '',
          likes: data['likes'] ?? 0,
          dislikes: data['dislikes'] ?? 0,
          comments: data['comments'] ?? 0,
          hashtags: List<String>.from(data['hashtags'] ?? []),
          workoutType: data['workout_type'],
          achievement: data['achievement'],
          imageUrl: data['image_url'],
        ));
      }

      setState(() {
        _posts = loadedPosts;
        _filteredPosts = loadedPosts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading posts: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Load user's like/dislike interactions
  Future<void> _loadUserInteractions() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final QuerySnapshot likesSnapshot = await _firestore
          .collection('user_interactions')
          .where('user_id', isEqualTo: user.uid)
          .where('type', isEqualTo: 'like')
          .get();

      final QuerySnapshot dislikesSnapshot = await _firestore
          .collection('user_interactions')
          .where('user_id', isEqualTo: user.uid)
          .where('type', isEqualTo: 'dislike')
          .get();

      setState(() {
        for (var doc in likesSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          _likedPosts[data['post_id']] = true;
        }

        for (var doc in dislikesSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          _dislikedPosts[data['post_id']] = true;
        }
      });
    } catch (e) {
      print('Error loading user interactions: $e');
    }
  }

  // Filter posts based on search
  void _filterPosts() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredPosts = _posts;
      });
    } else {
      setState(() {
        _filteredPosts = _posts.where((post) {
          return post.content.toLowerCase().contains(query) ||
              post.username.toLowerCase().contains(query) ||
              post.hashtags.any((tag) => tag.toLowerCase().contains(query));
        }).toList();
      });
    }
  }

  // Format time ago
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Search Bar
            _buildSearchBar(),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadPosts,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            // Trending Section
                            _buildTrendingSection(),

                            // Activity Feed
                            _buildActivityFeed(),

                            const SizedBox(height: 100), // Space for FAB
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: const _BottomNavBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40), // Balance the search button
          const Text(
            'Community',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          IconButton(
            onPressed: () {
              // Toggle search focus
              FocusScope.of(context).requestFocus(FocusNode());
            },
            icon: const Icon(Icons.search),
            color: Colors.grey[800],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search community posts...',
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _filterPosts();
                  },
                  icon: Icon(Icons.clear, color: Colors.grey[400]),
                )
              : null,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildTrendingSection() {
    // Get trending hashtags from posts
    Map<String, int> hashtagCount = {};
    for (var post in _posts) {
      for (var hashtag in post.hashtags) {
        hashtagCount[hashtag] = (hashtagCount[hashtag] ?? 0) + 1;
      }
    }

    var sortedHashtags = hashtagCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topHashtags = sortedHashtags.take(5).toList();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Trending',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (topHashtags.isNotEmpty) ...[
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: topHashtags.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final hashtag = topHashtags[index];
                  return GestureDetector(
                    onTap: () {
                      _searchController.text = hashtag.key;
                      _filterPosts();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C7FF2).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFF0C7FF2).withOpacity(0.3)),
                      ),
                      child: Text(
                        '${hashtag.key} (${hashtag.value})',
                        style: const TextStyle(
                          color: Color(0xFF0C7FF2),
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildTrendingCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C7FF2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Community Challenge',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0C7FF2),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '30-Day Fitness Challenge',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Join ${_posts.length} members in this month\'s challenge!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=200&h=200&fit=crop',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityFeed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Activity Feed',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              TextButton.icon(
                onPressed: _loadPosts,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (_filteredPosts.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  _searchController.text.isEmpty
                      ? 'No posts yet. Be the first to share!'
                      : 'No posts found for "${_searchController.text}"',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredPosts.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey[100],
            ),
            itemBuilder: (context, index) {
              return _buildPostCard(_filteredPosts[index]);
            },
          ),
      ],
    );
  }

  Widget _buildPostCard(CommunityPost post) {
    final isLiked = _likedPosts[post.id] ?? false;
    final isDisliked = _dislikedPosts[post.id] ?? false;
    final currentUser = _auth.currentUser;
    final isOwnPost = currentUser?.uid == post.userId;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Avatar
          GestureDetector(
            onTap: () => _showUserProfile(post.userId, post.username),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(post.userAvatar),
                  fit: BoxFit.cover,
                ),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Post Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Info & Menu
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () =>
                                _showUserProfile(post.userId, post.username),
                            child: Text(
                              post.username,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            post.timeAgo,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          if (post.workoutType != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                post.workoutType!,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (isOwnPost)
                      PopupMenuButton<String>(
                        onSelected: (value) =>
                            _handlePostAction(value, post.id),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ],
                        child: Icon(Icons.more_vert,
                            color: Colors.grey[500], size: 20),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Post Content
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                    children: _buildContentWithHashtags(post.content),
                  ),
                ),

                // Post Image
                if (post.imageUrl != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      post.imageUrl!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 200,
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image),
                        );
                      },
                    ),
                  ),
                ],

                // Achievement Badge
                if (post.achievement != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.emoji_events,
                            color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Achievement: ${post.achievement}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Action Buttons
                Row(
                  children: [
                    _buildActionButton(
                      icon: isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                      count: post.likes,
                      color:
                          isLiked ? const Color(0xFF0C7FF2) : Colors.grey[500]!,
                      activeColor: const Color(0xFF0C7FF2),
                      onTap: () => _handleLike(post.id),
                    ),
                    const SizedBox(width: 24),
                    _buildActionButton(
                      icon: isDisliked
                          ? Icons.thumb_down
                          : Icons.thumb_down_outlined,
                      count: post.dislikes,
                      color: isDisliked ? Colors.red : Colors.grey[500]!,
                      activeColor: Colors.red,
                      onTap: () => _handleDislike(post.id),
                    ),
                    const SizedBox(width: 24),
                    _buildActionButton(
                      icon: Icons.chat_bubble_outline,
                      count: post.comments,
                      color: Colors.grey[500]!,
                      activeColor: Colors.grey[700]!,
                      onTap: () => _handleComment(post.id),
                    ),
                    const Spacer(),
                    _buildActionButton(
                      icon: Icons.share_outlined,
                      count: 0,
                      color: Colors.grey[500]!,
                      activeColor: Colors.grey[700]!,
                      onTap: () => _handleShare(post),
                      showCount: false,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _buildContentWithHashtags(String content) {
    final List<TextSpan> spans = [];
    final words = content.split(' ');

    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      if (word.startsWith('#')) {
        spans.add(TextSpan(
          text: word,
          style: const TextStyle(
            color: Color(0xFF0C7FF2),
            fontWeight: FontWeight.w500,
          ),
        ));
      } else {
        spans.add(TextSpan(text: word));
      }

      if (i < words.length - 1) {
        spans.add(const TextSpan(text: ' '));
      }
    }

    return spans;
  }

  Widget _buildActionButton({
    required IconData icon,
    required int count,
    required Color color,
    required Color activeColor,
    required VoidCallback onTap,
    bool showCount = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          if (showCount) ...[
            const SizedBox(width: 4),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _showCreatePostDialog,
      backgroundColor: const Color(0xFF0C7FF2),
      child: const Icon(Icons.add, color: Colors.white, size: 28),
    );
  }

  // Handle like action
  Future<void> _handleLike(String postId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final isCurrentlyLiked = _likedPosts[postId] ?? false;
      final isCurrentlyDisliked = _dislikedPosts[postId] ?? false;

      // Remove dislike if present
      if (isCurrentlyDisliked) {
        await _removeInteraction(postId, 'dislike');
        await _updatePostCount(postId, 'dislikes', -1);
        setState(() {
          _dislikedPosts[postId] = false;
        });
      }

      if (isCurrentlyLiked) {
        // Remove like
        await _removeInteraction(postId, 'like');
        await _updatePostCount(postId, 'likes', -1);
        setState(() {
          _likedPosts[postId] = false;
        });
      } else {
        // Add like
        await _addInteraction(postId, 'like');
        await _updatePostCount(postId, 'likes', 1);
        setState(() {
          _likedPosts[postId] = true;
        });
      }

      // Update local post data
      final postIndex = _posts.indexWhere((p) => p.id == postId);
      if (postIndex != -1) {
        setState(() {
          final post = _posts[postIndex];
          final newLikes = isCurrentlyLiked ? post.likes - 1 : post.likes + 1;
          final newDislikes =
              isCurrentlyDisliked ? post.dislikes - 1 : post.dislikes;

          _posts[postIndex] = CommunityPost(
            id: post.id,
            userId: post.userId,
            username: post.username,
            userAvatar: post.userAvatar,
            timeAgo: post.timeAgo,
            content: post.content,
            likes: newLikes,
            dislikes: newDislikes,
            comments: post.comments,
            hashtags: post.hashtags,
            workoutType: post.workoutType,
            achievement: post.achievement,
            imageUrl: post.imageUrl,
          );
          _filterPosts();
        });
      }
    } catch (e) {
      print('Error handling like: $e');
    }
  }

  // Handle dislike action
  Future<void> _handleDislike(String postId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final isCurrentlyLiked = _likedPosts[postId] ?? false;
      final isCurrentlyDisliked = _dislikedPosts[postId] ?? false;

      // Remove like if present
      if (isCurrentlyLiked) {
        await _removeInteraction(postId, 'like');
        await _updatePostCount(postId, 'likes', -1);
        setState(() {
          _likedPosts[postId] = false;
        });
      }

      if (isCurrentlyDisliked) {
        // Remove dislike
        await _removeInteraction(postId, 'dislike');
        await _updatePostCount(postId, 'dislikes', -1);
        setState(() {
          _dislikedPosts[postId] = false;
        });
      } else {
        // Add dislike
        await _addInteraction(postId, 'dislike');
        await _updatePostCount(postId, 'dislikes', 1);
        setState(() {
          _dislikedPosts[postId] = true;
        });
      }

      // Update local post data
      final postIndex = _posts.indexWhere((p) => p.id == postId);
      if (postIndex != -1) {
        setState(() {
          final post = _posts[postIndex];
          final newLikes = isCurrentlyLiked ? post.likes - 1 : post.likes;
          final newDislikes =
              isCurrentlyDisliked ? post.dislikes - 1 : post.dislikes + 1;

          _posts[postIndex] = CommunityPost(
            id: post.id,
            userId: post.userId,
            username: post.username,
            userAvatar: post.userAvatar,
            timeAgo: post.timeAgo,
            content: post.content,
            likes: newLikes,
            dislikes: newDislikes,
            comments: post.comments,
            hashtags: post.hashtags,
            workoutType: post.workoutType,
            achievement: post.achievement,
            imageUrl: post.imageUrl,
          );
          _filterPosts();
        });
      }
    } catch (e) {
      print('Error handling dislike: $e');
    }
  }

  // Add user interaction
  Future<void> _addInteraction(String postId, String type) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('user_interactions').add({
      'user_id': user.uid,
      'post_id': postId,
      'type': type,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  // Remove user interaction
  Future<void> _removeInteraction(String postId, String type) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final QuerySnapshot snapshot = await _firestore
        .collection('user_interactions')
        .where('user_id', isEqualTo: user.uid)
        .where('post_id', isEqualTo: postId)
        .where('type', isEqualTo: type)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // Update post count
  Future<void> _updatePostCount(
      String postId, String field, int increment) async {
    await _firestore.collection('community_posts').doc(postId).update({
      field: FieldValue.increment(increment),
    });
  }

  // Handle comment action
  void _handleComment(String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CommentBottomSheet(postId: postId),
    );
  }

  // Handle share action
  void _handleShare(CommunityPost post) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Share Post',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text('Share functionality coming soon!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  // Handle post actions (edit/delete)
  void _handlePostAction(String action, String postId) {
    switch (action) {
      case 'edit':
        _editPost(postId);
        break;
      case 'delete':
        _showDeleteConfirmation(postId);
        break;
    }
  }

  // Edit post
  void _editPost(String postId) {
    final post = _posts.firstWhere((p) => p.id == postId);
    _postController.text = post.content;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Post'),
        content: TextField(
          controller: _postController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'What\'s on your mind?',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _updatePost(postId),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  // Update post
  Future<void> _updatePost(String postId) async {
    try {
      final hashtags = _extractHashtags(_postController.text);

      await _firestore.collection('community_posts').doc(postId).update({
        'content': _postController.text,
        'hashtags': hashtags,
        'updated_at': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
      _postController.clear();
      _loadPosts();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating post: $e')),
      );
    }
  }

  // Show delete confirmation
  void _showDeleteConfirmation(String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _deletePost(postId),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Delete post
  Future<void> _deletePost(String postId) async {
    try {
      await _firestore.collection('community_posts').doc(postId).delete();

      // Delete associated interactions
      final QuerySnapshot interactions = await _firestore
          .collection('user_interactions')
          .where('post_id', isEqualTo: postId)
          .get();

      for (var doc in interactions.docs) {
        await doc.reference.delete();
      }

      Navigator.pop(context);
      _loadPosts();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting post: $e')),
      );
    }
  }

  // Show user profile
  void _showUserProfile(String userId, String username) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$username\'s Profile',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text('Profile feature coming soon!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  // Show create post dialog
  void _showCreatePostDialog() {
    _postController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Create Post',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _postController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText:
                      'Share your fitness journey, tips, or achievements...',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFF5F5F5),
                ),
              ),
              const SizedBox(height: 16),

              // Post type options
              const Text(
                'Add tags:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  '#workout',
                  '#motivation',
                  '#progress',
                  '#tips',
                  '#achievement'
                ]
                    .map((tag) => GestureDetector(
                          onTap: () {
                            final text = _postController.text;
                            if (!text.contains(tag)) {
                              _postController.text =
                                  text + (text.isEmpty ? '' : ' ') + tag;
                            }
                          },
                          child: Chip(
                            label: Text(tag),
                            backgroundColor: Colors.grey[200],
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _createPost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C7FF2),
                      ),
                      child: const Text('Post',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Create new post
  Future<void> _createPost() async {
    if (_postController.text.trim().isEmpty) return;

    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final hashtags = _extractHashtags(_postController.text);

      await _firestore.collection('community_posts').add({
        'user_id': user.uid,
        'content': _postController.text.trim(),
        'hashtags': hashtags,
        'likes': 0,
        'dislikes': 0,
        'comments': 0,
        'created_at': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
      _postController.clear();
      _loadPosts();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post shared successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating post: $e')),
      );
    }
  }

  // Extract hashtags from text
  List<String> _extractHashtags(String text) {
    final RegExp hashtagRegex = RegExp(r'#\w+');
    final Iterable<Match> matches = hashtagRegex.allMatches(text);
    return matches.map((match) => match.group(0)!).toList();
  }
}

// Updated CommunityPost model
class CommunityPost {
  final String id;
  final String userId;
  final String username;
  final String userAvatar;
  final String timeAgo;
  final String content;
  final int likes;
  final int dislikes;
  final int comments;
  final List<String> hashtags;
  final String? workoutType;
  final String? achievement;
  final String? imageUrl;

  CommunityPost({
    required this.id,
    required this.userId,
    required this.username,
    required this.userAvatar,
    required this.timeAgo,
    required this.content,
    required this.likes,
    required this.dislikes,
    required this.comments,
    required this.hashtags,
    this.workoutType,
    this.achievement,
    this.imageUrl,
  });
}

// Comment bottom sheet widget
class _CommentBottomSheet extends StatelessWidget {
  final String postId;

  const _CommentBottomSheet({required this.postId});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Comments',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Comments will be implemented here
          const Expanded(
            child: Center(
              child: Text('Comments feature coming soon!'),
            ),
          ),
        ],
      ),
    );
  }
}

// Bottom Navigation Bar
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    const blueColor = Color(0xFF2563eb);

    Widget navItem({
      required IconData icon,
      required String label,
      bool selected = false,
      VoidCallback? onTap,
    }) {
      return Expanded(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: selected ? blueColor : const Color(0xFF64748b),
                    size: 24,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: selected ? blueColor : const Color(0xFF64748b),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFf1f5f9))),
        color: Colors.white,
      ),
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Row(
        children: [
          navItem(
            icon: Icons.home,
            label: "Home",
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ),
              );
            },
          ),
          navItem(
            icon: Icons.fitness_center,
            label: "Workouts",
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const WorkoutListScreen(),
                ),
              );
            },
          ),
          navItem(
            icon: Icons.leaderboard,
            label: "Progress",
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const ProgressScreen(),
                ),
              );
            },
          ),
          navItem(
            icon: Icons.groups,
            label: "Community",
            selected: true,
            onTap: () {
              // Already on community screen
            },
          ),
          navItem(
            icon: Icons.self_improvement,
            label: "Nofap",
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const NofapScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
