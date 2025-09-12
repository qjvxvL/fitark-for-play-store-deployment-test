import 'package:flutter/material.dart';
import '../models/workout.dart';

class WorkoutCard extends StatelessWidget {
  final Workout workout;
  final VoidCallback? onTap;
  final bool showProgress;
  final double? progress;

  const WorkoutCard({
    super.key,
    required this.workout,
    this.onTap,
    this.showProgress = false,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(),
            _buildContentSection(),
            if (showProgress && progress != null) _buildProgressSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getDifficultyColor().withOpacity(0.8),
            _getDifficultyColor().withOpacity(0.6),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background pattern or image would go here
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              image: workout.imageAsset.isNotEmpty
                  ? DecorationImage(
                      image: AssetImage(workout.imageAsset),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.3),
                        BlendMode.overlay,
                      ),
                    )
                  : null,
            ),
          ),
          // Overlay content
          Positioned(
            top: 12,
            right: 12,
            child: _buildDifficultyBadge(),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            child: _buildWorkoutIcon(),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  workout.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[600],
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            workout.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          _buildWorkoutStats(),
          const SizedBox(height: 12),
          _buildTags(),
        ],
      ),
    );
  }

  Widget _buildWorkoutStats() {
    return Row(
      children: [
        _buildStatItem(
          Icons.fitness_center,
          '${workout.exercises.length}',
          'exercises',
        ),
        const SizedBox(width: 16),
        _buildStatItem(
          Icons.access_time,
          '${workout.actualTotalDuration ~/ 60}',
          'min',
        ),
        const SizedBox(width: 16),
        _buildStatItem(
          Icons.local_fire_department,
          '${workout.actualEstimatedCalories}',
          'cal',
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[500],
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildTags() {
    if (workout.tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: workout.tags.take(3).map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getDifficultyColor().withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getDifficultyColor().withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Text(
            tag,
            style: TextStyle(
              fontSize: 10,
              color: _getDifficultyColor(),
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDifficultyBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getDifficultyColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        workout.difficulty.name.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildWorkoutIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        _getCategoryIcon(),
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildProgressSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(progress! * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  color: _getDifficultyColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[700],
            valueColor: AlwaysStoppedAnimation<Color>(_getDifficultyColor()),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor() {
    switch (workout.difficulty) {
      case DifficultyLevel.beginner:
        return Colors.green;
      case DifficultyLevel.intermediate:
        return Colors.orange;
      case DifficultyLevel.advanced:
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getCategoryIcon() {
    switch (workout.category.toLowerCase()) {
      case 'strength':
        return Icons.fitness_center;
      case 'cardio':
        return Icons.favorite;
      case 'flexibility':
      case 'yoga':
        return Icons.self_improvement;
      case 'core':
        return Icons.center_focus_strong;
      case 'quick':
        return Icons.flash_on;
      default:
        return Icons.sports_gymnastics;
    }
  }
}

// Compact workout card for lists
class CompactWorkoutCard extends StatelessWidget {
  final Workout workout;
  final VoidCallback? onTap;
  final bool isSelected;

  const CompactWorkoutCard({
    super.key,
    required this.workout,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getDifficultyColor().withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getCategoryIcon(),
                color: _getDifficultyColor(),
                size: 20,
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${workout.exercises.length} exercises • ${workout.actualTotalDuration ~/ 60} min',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[600],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor() {
    switch (workout.difficulty) {
      case DifficultyLevel.beginner:
        return Colors.green;
      case DifficultyLevel.intermediate:
        return Colors.orange;
      case DifficultyLevel.advanced:
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getCategoryIcon() {
    switch (workout.category.toLowerCase()) {
      case 'strength':
        return Icons.fitness_center;
      case 'cardio':
        return Icons.favorite;
      case 'flexibility':
      case 'yoga':
        return Icons.self_improvement;
      case 'core':
        return Icons.center_focus_strong;
      case 'quick':
        return Icons.flash_on;
      default:
        return Icons.sports_gymnastics;
    }
  }
}
