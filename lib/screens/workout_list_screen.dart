import 'package:fitark/screens/progress_screen.dart';
import 'package:flutter/material.dart';
import 'community_screen.dart';
import 'home_screen.dart';
import 'nofap_screen.dart';
import 'workout_detail_screen.dart';
import '../models/workout.dart';
import '../services/workout_service.dart';

class WorkoutListScreen extends StatefulWidget {
  const WorkoutListScreen({super.key});

  @override
  State<WorkoutListScreen> createState() => _WorkoutListScreenState();
}

class _WorkoutListScreenState extends State<WorkoutListScreen> {
  final WorkoutService _workoutService = WorkoutService();
  List<Workout> _workouts = [];
  List<Workout> _filteredWorkouts = [];
  List<Workout> _filteredForYouWorkouts = [];
  List<Workout> _filteredAllWorkouts = [];
  List<Workout> _searchResults = [];

  String _selectedCategory = 'All';
  bool _isSearchActive = false;
  Set<String> _selectedFilters = <String>{};
  bool isLoading = true;

  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Cardio',
    'Strength',
    'Core',
    'Yoga',
    'HIIT',
    'Beginner',
  ];

  final List<String> _filterCategories = [
    'All',
    'Cardio',
    'Strength',
    'Core',
    'Yoga',
    'HIIT',
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadWorkouts() {
    _workouts = _workoutService.getAllWorkouts();
    _applyFilters();

    setState(() {
      isLoading = false;
    });
  }

  void _applyFilters() {
    setState(() {
      if (_selectedFilters.isEmpty) {
        _filteredWorkouts = _workouts;
      } else {
        _filteredWorkouts = _workouts.where((workout) {
          return _selectedFilters.any((filter) =>
              workout.category.toLowerCase() == filter.toLowerCase() ||
              workout.difficulty.name.toLowerCase() == filter.toLowerCase());
        }).toList();
      }

      // Split workouts into "For You" and "All Workouts"
      _filteredForYouWorkouts = _filteredWorkouts.take(3).toList();
      _filteredAllWorkouts = _filteredWorkouts;
    });
  }

  void _filterWorkouts(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'All') {
        _filteredWorkouts = _workouts;
      } else {
        _filteredWorkouts = _workouts
            .where((workout) =>
                workout.category.toLowerCase() == category.toLowerCase())
            .toList();
      }
      _filteredForYouWorkouts = _filteredWorkouts.take(3).toList();
      _filteredAllWorkouts = _filteredWorkouts;
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (!_isSearchActive) {
        _searchController.clear();
        _searchResults.clear();
      }
    });
  }

  void _performSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _searchResults.clear();
      } else {
        _searchResults = _workouts.where((workout) {
          return workout.name.toLowerCase().contains(query.toLowerCase()) ||
              workout.description.toLowerCase().contains(query.toLowerCase()) ||
              workout.category.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _toggleFilter(String filter) {
    setState(() {
      if (filter == 'All') {
        _selectedFilters.clear();
      } else {
        if (_selectedFilters.contains(filter)) {
          _selectedFilters.remove(filter);
        } else {
          _selectedFilters.add(filter);
        }
      }
      _applyFilters();
    });
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterModal(
        selectedFilters: _selectedFilters,
        allFilters: _filterCategories,
        onFiltersChanged: (filters) {
          setState(() {
            _selectedFilters = filters;
            _applyFilters();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with search
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child:
                  _isSearchActive ? _buildSearchHeader() : _buildNormalHeader(),
            ),

            // Show search results or normal content
            Expanded(
              child: _isSearchActive
                  ? _buildSearchContent()
                  : _buildNormalContent(),
            ),

            // Bottom Navigation
            if (!_isSearchActive) _BottomNavBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildNormalHeader() {
    return Row(
      children: [
        const Spacer(),
        const Text(
          'Workouts',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0f172a),
          ),
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: _toggleSearch,
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.search,
                color: Color(0xFF0f172a),
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchHeader() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFf8fafc),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFe2e8f0)),
            ),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: _performSearch,
              decoration: const InputDecoration(
                hintText: 'Search workouts...',
                prefixIcon: Icon(Icons.search, color: Color(0xFF64748b)),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                hintStyle: TextStyle(color: Color(0xFF64748b)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        TextButton(
          onPressed: _toggleSearch,
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Color(0xFF2563eb),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchContent() {
    if (_searchController.text.isEmpty) {
      return const Center(
        child: Text(
          'Start typing to search workouts',
          style: TextStyle(
            color: Color(0xFF64748b),
            fontSize: 16,
          ),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: Color(0xFF94a3b8),
            ),
            const SizedBox(height: 16),
            Text(
              'No workouts found for "${_searchController.text}"',
              style: const TextStyle(
                color: Color(0xFF64748b),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _SearchResultCard(workout: _searchResults[index]);
      },
    );
  }

  Widget _buildNormalContent() {
    return Column(
      children: [
        // Filter chips
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'Filters',
                  hasIcon: true,
                  isSelected: _selectedFilters.isNotEmpty,
                  onTap: _showFilterModal,
                ),
                const SizedBox(width: 8),
                ..._filterCategories.take(4).map((filter) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _FilterChip(
                        label: filter,
                        isSelected: _selectedFilters.contains(filter) ||
                            (filter == 'All' && _selectedFilters.isEmpty),
                        onTap: () => _toggleFilter(filter),
                      ),
                    )),
              ],
            ),
          ),
        ),

        // Active filters display
        if (_selectedFilters.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Active filters: ${_selectedFilters.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748b),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedFilters.clear();
                      _applyFilters();
                    });
                  },
                  child: const Text(
                    'Clear all',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF2563eb),
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Main content
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // For You section
                if (_filteredForYouWorkouts.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      children: [
                        const Text(
                          'For You',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0f172a),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_filteredForYouWorkouts.length} workouts',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748b),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 260,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredForYouWorkouts.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        return _HorizontalWorkoutCard(
                          workout: _filteredForYouWorkouts[index],
                        );
                      },
                    ),
                  ),
                ],

                // All Workouts section
                if (_filteredAllWorkouts.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                    child: Row(
                      children: [
                        const Text(
                          'All Workouts',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0f172a),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_filteredAllWorkouts.length} workouts',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748b),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: _filteredAllWorkouts.length,
                      itemBuilder: (context, index) {
                        return _GridWorkoutCard(
                          workout: _filteredAllWorkouts[index],
                        );
                      },
                    ),
                  ),
                ],

                // Empty state when no workouts match filters
                if (_filteredForYouWorkouts.isEmpty &&
                    _filteredAllWorkouts.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.filter_list_off,
                            size: 64,
                            color: Color(0xFF94a3b8),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No workouts match your filters',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1e293b),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Try adjusting your filters to see more workouts',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748b),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedFilters.clear();
                                _applyFilters();
                              });
                            },
                            child: const Text('Clear filters'),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Enhanced Filter Chip with selection state
class _FilterChip extends StatelessWidget {
  final String label;
  final bool hasIcon;
  final bool isSelected;
  final VoidCallback? onTap;

  const _FilterChip({
    required this.label,
    this.hasIcon = false,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? const Color(0xFF2563eb) : const Color(0xFFe2e8f0),
        ),
        borderRadius: BorderRadius.circular(20),
        color: isSelected ? const Color(0xFF2563eb) : Colors.white,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: hasIcon ? 12 : 16,
              vertical: 8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasIcon) ...[
                  Icon(
                    Icons.tune,
                    size: 20,
                    color: isSelected ? Colors.white : const Color(0xFF334155),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Filter Modal for advanced filtering
class _FilterModal extends StatefulWidget {
  final Set<String> selectedFilters;
  final List<String> allFilters;
  final Function(Set<String>) onFiltersChanged;

  const _FilterModal({
    required this.selectedFilters,
    required this.allFilters,
    required this.onFiltersChanged,
  });

  @override
  _FilterModalState createState() => _FilterModalState();
}

class _FilterModalState extends State<_FilterModal> {
  late Set<String> _tempSelectedFilters;

  @override
  void initState() {
    super.initState();
    _tempSelectedFilters = Set.from(widget.selectedFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Text(
                  'Filter Workouts',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _tempSelectedFilters.clear();
                    });
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ),

          // Filter options
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.allFilters.map((filter) {
                      final isSelected =
                          _tempSelectedFilters.contains(filter) ||
                              (filter == 'All' && _tempSelectedFilters.isEmpty);
                      return _FilterChip(
                        label: filter,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            if (filter == 'All') {
                              _tempSelectedFilters.clear();
                            } else {
                              if (_tempSelectedFilters.contains(filter)) {
                                _tempSelectedFilters.remove(filter);
                              } else {
                                _tempSelectedFilters.add(filter);
                              }
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Apply button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  widget.onFiltersChanged(_tempSelectedFilters);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563eb),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Apply Filters${_tempSelectedFilters.isEmpty ? '' : ' (${_tempSelectedFilters.length})'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final Workout workout;

  const _SearchResultCard({required this.workout});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => WorkoutDetailScreen(
                workoutId: workout.id,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFe2e8f0)),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    workout.heroImageUrl ??
                        'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.fitness_center,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFF1e293b),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      workout.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748b),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563eb).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        workout.category,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF2563eb),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF94a3b8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HorizontalWorkoutCard extends StatelessWidget {
  final Workout workout;

  const _HorizontalWorkoutCard({
    required this.workout,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 288,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => WorkoutDetailScreen(
                  workoutId: workout.id,
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 162,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    workout.heroImageUrl ??
                        'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop',
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                workout.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1e293b),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                workout.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748b),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridWorkoutCard extends StatelessWidget {
  final Workout workout;

  const _GridWorkoutCard({
    required this.workout,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => WorkoutDetailScreen(
                workoutId: workout.id,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    workout.heroImageUrl ??
                        'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop',
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 30,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              workout.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1e293b),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const blueColor = Color(0xFF2563eb); // blue-600

    Widget navItem({
      IconData? icon,
      Widget? customIcon,
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
                  icon != null
                      ? Icon(
                    icon,
                    size: 24,
                    color: selected ? blueColor : const Color(0xFF64748b),
                  )
                      : customIcon!,
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
        border: Border(top: BorderSide(color: Color(0xFFf1f5f9))), // slate-100
        color: Colors.white,
      ),
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Row(
        children: [
          navItem(
            icon: Icons.home,
            label: "Home",
            selected: false,
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
            selected: true,
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
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const CommunityScreen(),
                ),
              );
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


