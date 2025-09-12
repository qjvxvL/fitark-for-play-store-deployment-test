// // lib/screens/profile_setup_screen.dart
// import 'package:flutter/material.dart';
// import '../models/user_profile.dart';
// import '../services/auth_service.dart';
// import 'home_screen.dart';

// class ProfileSetupScreen extends StatefulWidget {
//   const ProfileSetupScreen({super.key});

//   @override
//   State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
// }

// class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
//   final PageController _pageController = PageController();
//   final AuthService _authService = AuthService();

//   int _currentPage = 0;
//   bool _isLoading = false;

//   // Form data
//   DateTime? _dateOfBirth;
//   Gender? _gender;
//   double? _height;
//   double? _weight;
//   FitnessLevel? _fitnessLevel;
//   final List<String> _selectedGoals = [];
//   final List<String> _medicalConditions = [];

//   final List<String> _availableGoals = [
//     'Lose Weight',
//     'Build Muscle',
//     'Improve Cardio',
//     'Increase Flexibility',
//     'Maintain Health',
//     'Gain Strength',
//     'Sport Performance',
//     'Stress Relief',
//   ];

//   Future<void> _completeSetup() async {
//     setState(() => _isLoading = true);

//     try {
//       final currentUser = _authService.currentUser;
//       if (currentUser == null) {
//         _showSnackBar('No user logged in', Colors.red);
//         return;
//       }

//       // Check if user profile exists, if not create a basic one first
//       final profileExists = await _authService.userProfileExists();
//       if (!profileExists) {
//         // Create basic profile first
//         await _authService._createUserProfile(
//           user: currentUser,
//           displayName: currentUser.displayName ?? 'User',
//         );
//       }

//       // Now update with detailed profile info
//       final profile = UserProfile(
//         uid: currentUser.uid,
//         email: currentUser.email!,
//         displayName: currentUser.displayName,
//         dateOfBirth: _dateOfBirth,
//         gender: _gender,
//         height: _height,
//         weight: _weight,
//         fitnessLevel: _fitnessLevel,
//         goals: _selectedGoals,
//         medicalConditions: _medicalConditions,
//         accountSetupComplete: true,
//       );

//       final result = await _authService.updateUserProfile(profile);

//       if (result.success) {
//         _showSnackBar('Profile setup completed!', Colors.green);
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const HomeScreen()),
//         );
//       } else {
//         _showSnackBar(result.error!, Colors.red);
//       }
//     } catch (e) {
//       print('Error in profile setup: $e');
//       _showSnackBar('Setup failed: ${e.toString()}', Colors.red);
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   void _showSnackBar(String message, Color color) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: color),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Complete Your Profile'),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black87,
//         elevation: 0,
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(4),
//           child: LinearProgressIndicator(
//             value: (_currentPage + 1) / 5,
//             backgroundColor: Colors.grey[200],
//             valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0b80ee)),
//           ),
//         ),
//       ),
//       body: PageView(
//         controller: _pageController,
//         onPageChanged: (page) => setState(() => _currentPage = page),
//         children: [
//           _buildDateOfBirthPage(),
//           _buildGenderPage(),
//           _buildPhysicalInfoPage(),
//           _buildFitnessLevelPage(),
//           _buildGoalsPage(),
//         ],
//       ),
//       bottomNavigationBar: _buildBottomNavigation(),
//     );
//   }

//   Widget _buildDateOfBirthPage() {
//     return Padding(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: 40),
//           const Text(
//             'When were you born?',
//             style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'This helps us personalize your workouts',
//             style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//           ),
//           const SizedBox(height: 40),
//           GestureDetector(
//             onTap: () => _selectDate(context),
//             child: Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey[300]!),
//                 borderRadius: BorderRadius.circular(12),
//                 color: Colors.grey[50],
//               ),
//               child: Row(
//                 children: [
//                   const Icon(Icons.calendar_today, color: Colors.grey),
//                   const SizedBox(width: 12),
//                   Text(
//                     _dateOfBirth != null
//                         ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
//                         : 'Select your birth date',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: _dateOfBirth != null
//                           ? Colors.black87
//                           : Colors.grey[500],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildGenderPage() {
//     return Padding(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: 40),
//           const Text(
//             'What\'s your gender?',
//             style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'This helps us calculate calories and recommendations',
//             style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//           ),
//           const SizedBox(height: 40),
//           ...Gender.values.map((gender) => _buildGenderOption(gender)),
//         ],
//       ),
//     );
//   }

//   Widget _buildPhysicalInfoPage() {
//     return Padding(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: 40),
//           const Text(
//             'Physical Information',
//             style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Help us calculate your BMI and daily calorie needs',
//             style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//           ),
//           const SizedBox(height: 40),

//           // Height
//           const Text('Height (cm)',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//           const SizedBox(height: 8),
//           Slider(
//             value: _height ?? 170,
//             min: 120,
//             max: 220,
//             divisions: 100,
//             label: _height != null ? '${_height!.round()} cm' : '170 cm',
//             onChanged: (value) => setState(() => _height = value),
//             activeColor: const Color(0xFF0b80ee),
//           ),
//           Text(
//             'Current: ${_height?.round() ?? 170} cm',
//             style: TextStyle(color: Colors.grey[600]),
//           ),

//           const SizedBox(height: 30),

//           // Weight
//           const Text('Weight (kg)',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//           const SizedBox(height: 8),
//           Slider(
//             value: _weight ?? 70,
//             min: 30,
//             max: 150,
//             divisions: 120,
//             label: _weight != null ? '${_weight!.round()} kg' : '70 kg',
//             onChanged: (value) => setState(() => _weight = value),
//             activeColor: const Color(0xFF0b80ee),
//           ),
//           Text(
//             'Current: ${_weight?.round() ?? 70} kg',
//             style: TextStyle(color: Colors.grey[600]),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFitnessLevelPage() {
//     return Padding(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: 40),
//           const Text(
//             'What\'s your fitness level?',
//             style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'This helps us recommend appropriate workouts',
//             style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//           ),
//           const SizedBox(height: 40),
//           ...FitnessLevel.values
//               .map((level) => _buildFitnessLevelOption(level)),
//         ],
//       ),
//     );
//   }

//   Widget _buildGoalsPage() {
//     return Padding(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: 40),
//           const Text(
//             'What are your goals?',
//             style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Select all that apply (you can change these later)',
//             style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//           ),
//           const SizedBox(height: 40),
//           Expanded(
//             child: GridView.builder(
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 12,
//                 mainAxisSpacing: 12,
//                 childAspectRatio: 3,
//               ),
//               itemCount: _availableGoals.length,
//               itemBuilder: (context, index) {
//                 final goal = _availableGoals[index];
//                 final isSelected = _selectedGoals.contains(goal);

//                 return GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       if (isSelected) {
//                         _selectedGoals.remove(goal);
//                       } else {
//                         _selectedGoals.add(goal);
//                       }
//                     });
//                   },
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: isSelected
//                           ? const Color(0xFF0b80ee)
//                           : Colors.grey[100],
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: isSelected
//                             ? const Color(0xFF0b80ee)
//                             : Colors.grey[300]!,
//                       ),
//                     ),
//                     child: Center(
//                       child: Text(
//                         goal,
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: isSelected ? Colors.white : Colors.black87,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildGenderOption(Gender gender) {
//     final isSelected = _gender == gender;
//     String displayName =
//         gender.name.substring(0, 1).toUpperCase() + gender.name.substring(1);

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: GestureDetector(
//         onTap: () => setState(() => _gender = gender),
//         child: Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: isSelected ? const Color(0xFF0b80ee) : Colors.grey[100],
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: isSelected ? const Color(0xFF0b80ee) : Colors.grey[300]!,
//             ),
//           ),
//           child: Text(
//             displayName,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: isSelected ? Colors.white : Colors.black87,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFitnessLevelOption(FitnessLevel level) {
//     final isSelected = _fitnessLevel == level;
//     String displayName =
//         level.name.substring(0, 1).toUpperCase() + level.name.substring(1);
//     String description = _getFitnessLevelDescription(level);

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: GestureDetector(
//         onTap: () => setState(() => _fitnessLevel = level),
//         child: Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: isSelected ? const Color(0xFF0b80ee) : Colors.grey[100],
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: isSelected ? const Color(0xFF0b80ee) : Colors.grey[300]!,
//             ),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 displayName,
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: isSelected ? Colors.white : Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 description,
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: isSelected ? Colors.white70 : Colors.grey[600],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildBottomNavigation() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.2),
//             spreadRadius: 1,
//             blurRadius: 4,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           if (_currentPage > 0) ...[
//             Expanded(
//               child: OutlinedButton(
//                 onPressed: () {
//                   _pageController.previousPage(
//                     duration: const Duration(milliseconds: 300),
//                     curve: Curves.easeInOut,
//                   );
//                 },
//                 child: const Text('Back'),
//               ),
//             ),
//             const SizedBox(width: 16),
//           ],
//           Expanded(
//             flex: 2,
//             child: ElevatedButton(
//               onPressed: _canProceed()
//                   ? () {
//                       if (_currentPage == 4) {
//                         _completeSetup();
//                       } else {
//                         _pageController.nextPage(
//                           duration: const Duration(milliseconds: 300),
//                           curve: Curves.easeInOut,
//                         );
//                       }
//                     }
//                   : null,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF0b80ee),
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: _isLoading
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : Text(
//                       _currentPage == 4 ? 'Complete Setup' : 'Next',
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   bool _canProceed() {
//     switch (_currentPage) {
//       case 0:
//         return _dateOfBirth != null;
//       case 1:
//         return _gender != null;
//       case 2:
//         return _height != null && _weight != null;
//       case 3:
//         return _fitnessLevel != null;
//       case 4:
//         return _selectedGoals.isNotEmpty;
//       default:
//         return false;
//     }
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _dateOfBirth ?? DateTime(2000),
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now(),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: Color(0xFF0b80ee),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (picked != null && picked != _dateOfBirth) {
//       setState(() => _dateOfBirth = picked);
//     }
//   }

//   String _getFitnessLevelDescription(FitnessLevel level) {
//     switch (level) {
//       case FitnessLevel.beginner:
//         return 'New to regular exercise or returning after a break';
//       case FitnessLevel.intermediate:
//         return 'Exercise regularly, comfortable with basic movements';
//       case FitnessLevel.advanced:
//         return 'Very active, experienced with challenging workouts';
//     }
//   }
// }
