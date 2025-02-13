// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';

// class HomePage extends StatelessWidget {
// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     backgroundColor: Colors.white,
//     body: CustomScrollView(
//       slivers: [
//         // Clean AppBar
//         SliverAppBar(
//           pinned: true,
//           backgroundColor: Colors.white,
//           elevation: 0,
//           title: Row(
//             children: [
//               Container(
//                 padding: EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.black,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   Icons.local_dining_outlined,
//                   color: Colors.white,
//                   size: 18,
//                 ),
//               ),
//               SizedBox(width: 8),
//               Text(
//                 'CalculATE',
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//               margin: EdgeInsets.only(right: 12),
//               decoration: BoxDecoration(
//                 color: Colors.orange.shade50,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.local_fire_department, 
//                        color: Colors.orange, 
//                        size: 16),
//                   SizedBox(width: 4),
//                   Text(
//                     '5',
//                     style: TextStyle(
//                       color: Colors.orange,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.only(right: 16),
//               child: CircleAvatar(
//                 radius: 16,
//                 backgroundColor: Colors.grey[100],
//                 child: Text(
//                   'A',
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontWeight: FontWeight.w500,
//                     fontSize: 13,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),

//         // Greeting & Status
//         SliverToBoxAdapter(
//           child: Padding(
//             padding: EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Hello, Alex',
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 SizedBox(height: 8),
//                 Text(
//                   'You\'re doing great! Keep up with your healthy eating habits.',
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                     fontSize: 14,
//                   ),
//                 ),
//                 SizedBox(height: 24),

//                 // Date Selector
//                 SizedBox(
//                   height: 80,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: 7,
//                     itemBuilder: (context, index) {
//                       bool isToday = index == 0;
//                       return Container(
//                         width: 55,
//                         margin: EdgeInsets.only(right: 8),
//                         decoration: BoxDecoration(
//                           color: isToday ? Colors.black : Colors.white,
//                           border: Border.all(
//                             color: isToday ? Colors.black : Colors.grey[200]!,
//                           ),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               ['Today', 'Thu', 'Wed', 'Tue', 'Mon', 'Sun', 'Sat'][index],
//                               style: TextStyle(
//                                 color: isToday ? Colors.white : Colors.grey[600],
//                                 fontSize: 12,
//                               ),
//                             ),
//                             SizedBox(height: 4),
//                             Text(
//                               ['24', '23', '22', '21', '20', '19', '18'][index],
//                               style: TextStyle(
//                                 color: isToday ? Colors.white : Colors.black,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                 ),

//                 // Daily Progress
//                 Container(
//                   margin: EdgeInsets.only(top: 24),
//                   padding: EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.black,
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Calories Remaining',
//                         style: TextStyle(
//                           color: Colors.white70,
//                           fontSize: 14,
//                         ),
//                       ),
//                       SizedBox(height: 8),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             '1,247',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 28,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           Container(
//                             padding: EdgeInsets.symmetric(
//                               horizontal: 10,
//                               vertical: 4,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.white24,
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Text(
//                               'Goal: 2,000',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 13,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 16),
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(4),
//                         child: LinearProgressIndicator(
//                           value: 0.38,
//                           backgroundColor: Colors.white12,
//                           valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                           minHeight: 4,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 // Macronutrient boxes
// Container(
//   margin: EdgeInsets.only(top: 16),
//   child: Row(
//     children: [
//       Expanded(
//         child: Container(
//           padding: EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey[200]!),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     padding: EdgeInsets.all(4),
//                     decoration: BoxDecoration(
//                       color: Colors.blue[50],
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                     child: Icon(
//                       Icons.egg_outlined,
//                       color: Colors.blue,
//                       size: 16,
//                     ),
//                   ),
//                   SizedBox(width: 8),
//                   Text(
//                     'Protein',
//                     style: TextStyle(
//                       color: Colors.grey[600],
//                       fontSize: 13,
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 12),
//               RichText(
//                 text: TextSpan(
//                   children: [
//                     TextSpan(
//                       text: '45',
//                       style: TextStyle(
//                         color: Colors.black,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     TextSpan(
//                       text: '/120g',
//                       style: TextStyle(
//                         color: Colors.grey[600],
//                         fontSize: 14,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       SizedBox(width: 12),
//       Expanded(
//         child: Container(
//           padding: EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey[200]!),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     padding: EdgeInsets.all(4),
//                     decoration: BoxDecoration(
//                       color: Colors.orange[50],
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                     child: Icon(
//                       Icons.grain,
//                       color: Colors.orange,
//                       size: 16,
//                     ),
//                   ),
//                   SizedBox(width: 8),
//                   Text(
//                     'Carbs',
//                     style: TextStyle(
//                       color: Colors.grey[600],
//                       fontSize: 13,
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 12),
//               RichText(
//                 text: TextSpan(
//                   children: [
//                     TextSpan(
//                       text: '156',
//                       style: TextStyle(
//                         color: Colors.black,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     TextSpan(
//                       text: '/250g',
//                       style: TextStyle(
//                         color: Colors.grey[600],
//                         fontSize: 14,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       SizedBox(width: 12),
//       Expanded(
//         child: Container(
//           padding: EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey[200]!),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     padding: EdgeInsets.all(4),
//                     decoration: BoxDecoration(
//                       color: Colors.green[50],
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                     child: Icon(
//                       Icons.water_drop_outlined,
//                       color: Colors.green,
//                       size: 16,
//                     ),
//                   ),
//                   SizedBox(width: 8),
//                   Text(
//                     'Fat',
//                     style: TextStyle(
//                       color: Colors.grey[600],
//                       fontSize: 13,
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 12),
//               RichText(
//                 text: TextSpan(
//                   children: [
//                     TextSpan(
//                       text: '25',
//                       style: TextStyle(
//                         color: Colors.black,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     TextSpan(
//                       text: '/65g',
//                       style: TextStyle(
//                         color: Colors.grey[600],
//                         fontSize: 14,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ],
//   ),
// ),

// // Weekly Summary Graph (tambahkan sebelum Recently Eaten)
// Container(
//   margin: EdgeInsets.only(top: 24),
//   child: Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             'Weekly Overview',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           Text(
//             'Last 7 days',
//             style: TextStyle(
//               color: Colors.grey[600],
//               fontSize: 13,
//             ),
//           ),
//         ],
//       ),
//       SizedBox(height: 16),
//       Container(
//         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey[200]!),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           children: [
//             // Goal Line
//             Row(
//               children: [
//                 Container(
//                   width: 8,
//                   height: 8,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(color: Colors.grey[400]!),
//                   ),
//                 ),
//                 SizedBox(width: 8),
//                 Text(
//                   'Goal: 2000 kcal',
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 8),
//             // Bar Chart
//             AspectRatio(
//               aspectRatio: 16/9,
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   ...List.generate(7, (index) {
//                     final values = [1850, 1950, 1750, 2100, 1800, 1600, 1200];
//                     final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
//                     final isToday = index == 6;
//                     final value = values[index];
//                     final percentage = value / 2000; // 2000 is goal
                    
//                     return Expanded(
//                       child: Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 4),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             Container(
//                               height: 140 * percentage,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.vertical(
//                                   top: Radius.circular(4),
//                                   bottom: Radius.circular(4),
//                                 ),
//                                 color: isToday 
//                                     ? Colors.grey[200]
//                                     : value > 2000 
//                                         ? Colors.red[400]!.withOpacity(0.8)
//                                         : Colors.black,
//                               ),
//                             ),
//                             SizedBox(height: 8),
//                             Text(
//                               days[index],
//                               style: TextStyle(
//                                 color: isToday ? Colors.black : Colors.grey[600],
//                                 fontSize: 13,
//                                 fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   }),
//                 ],
//               ),
//             ),
//             // Divider
//             Padding(
//               padding: EdgeInsets.symmetric(vertical: 16),
//               child: Divider(),
//             ),
//             // Stats
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _buildWeeklyStat(
//                   'Average Intake',
//                   '1,850',
//                   'kcal/day',
//                   Icons.calendar_today_outlined,
//                 ),
//                 _buildWeeklyStat(
//                   'On Track Days',
//                   '5',
//                   'days',
//                   Icons.check_circle_outline,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     ],
//   ),
// ),

// Container(
//   margin: EdgeInsets.only(top: 24),
//   child: Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(
//         'Quick Add',
//         style: TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//       SizedBox(height: 12),
//       SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           children: [
//             _buildQuickAddCard(
//               title: 'Nasi Putih',
//               calories: '204',
//               portion: '1 porsi',
//             ),
//             SizedBox(width: 12),
//             _buildQuickAddCard(
//               title: 'Kopi Hitam',
//               calories: '2',
//               portion: '1 cup',
//             ),
//             SizedBox(width: 12),
//             _buildQuickAddCard(
//               title: 'Roti Tawar',
//               calories: '160',
//               portion: '2 lembar',
//             ),

//           ],
//         ),
//       ),
//     ],
//   ),
// ),

//                 // Recently Eaten
//                 Padding(
//                   padding: EdgeInsets.only(top: 24, bottom: 16),
//                   child: Text(
//                     'Recently Eaten',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 ListView.separated(
//                   shrinkWrap: true,
//                   physics: NeverScrollableScrollPhysics(),
//                   itemCount: 3,
//                   separatorBuilder: (context, index) => SizedBox(height: 12),
//                   itemBuilder: (context, index) {
//                     return Container(
//                       padding: EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey[200]!),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Row(
//                         children: [
//                           Container(
//                             width: 50,
//                             height: 50,
//                             decoration: BoxDecoration(
//                               color: Colors.grey[100],
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Icon(
//                               Icons.restaurant,
//                               color: Colors.grey[400],
//                             ),
//                           ),
//                           SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   ['Fried Rice', 'Chicken Salad', 'Protein Shake'][index],
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                                 SizedBox(height: 4),
//                                 Text(
//                                   ['450 kcal • Lunch', '380 kcal • Dinner', '200 kcal • Snack'][index],
//                                   style: TextStyle(
//                                     color: Colors.grey[600],
//                                     fontSize: 13,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Text(
//                             ['2h ago', '5h ago', '8h ago'][index],
//                             style: TextStyle(
//                               color: Colors.grey[500],
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
                
//               ],
//             ),
//           ),
//         ),
        
        
//       ],
//     ),
//     bottomNavigationBar: _buildCustomBottomBar(),
//   );
// }


// // Helper method untuk weekly stats
// // Helper method for stat
// Widget _buildWeeklyStat(String label, String value, String unit, IconData icon) {
//   return Row(
//     children: [
//       Icon(icon, size: 18, color: Colors.grey[600]),
//       SizedBox(width: 8),
//       Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               color: Colors.grey[600],
//               fontSize: 12,
//             ),
//           ),
//           SizedBox(height: 2),
//           RichText(
//             text: TextSpan(
//               children: [
//                 TextSpan(
//                   text: value,
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 TextSpan(
//                   text: ' $unit',
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     ],
//   );
// }
// // Helper method untuk Saved Meal Card

// Widget _buildQuickAddCard({
//   required String title,
//   required String calories,
//   required String portion,
// }) {
//   return Container(
//     width: 140,
//     padding: EdgeInsets.all(12),
//     decoration: BoxDecoration(
//       border: Border.all(color: Colors.grey[200]!),
//       borderRadius: BorderRadius.circular(12),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(
//               Icons.add_circle_outline,
//               size: 18,
//               color: Colors.grey[600],
//             ),
//             SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 title,
//                 style: TextStyle(
//                   fontWeight: FontWeight.w500,
//                 ),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 8),
//         Text(
//           '$calories kcal',
//           style: TextStyle(
//             color: Colors.grey[800],
//             fontSize: 13,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         Text(
//           portion,
//           style: TextStyle(
//             color: Colors.grey[600],
//             fontSize: 12,
//           ),
//         ),
//       ],
//     ),
//   );
// }

// Widget _buildCustomBottomBar() {
//   return Container(
//     height: 65,
//     child: Stack(
//       children: [
//         // Background navigation bar
//         Container(
//           height: 65,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             border: Border(
//               top: BorderSide(
//                 color: Colors.grey[200]!,
//                 width: 1,
//               ),
//             ),
//           ),
//           padding: EdgeInsets.only(top: 8),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               Expanded(
//                 child: _buildNavItem(
//                   icon: Icons.home_outlined,
//                   label: 'Home',
//                   isSelected: true,
//                   onPressed: () {
//                     // Add your navigation logic here
//                     print('Home pressed');
//                     // Example: Navigator.pushNamed(context, '/home');
//                   },
//                 ),
//               ),
//               Expanded(
//                 child: _buildNavItem(
//                   icon: Icons.bar_chart_outlined,
//                   label: 'Progress',
//                   isSelected: false,
//                   onPressed: () {
//                     // Add your navigation logic here
//                     print('Progress pressed');
//                     // Example: Navigator.pushNamed(context, '/progress');
//                   },
//                 ),
//               ),
//               // Expanded kosong untuk scan button
//               Expanded(child: SizedBox()),
//               Expanded(
//                 child: _buildNavItem(
//                   icon: Icons.book_outlined,
//                   label: 'Diary',
//                   isSelected: false,
//                   onPressed: () {
//                     // Add your navigation logic here
//                     print('Diary pressed');
//                     // Example: Navigator.pushNamed(context, '/diary');
//                   },
//                 ),
//               ),
//               Expanded(
//                 child: _buildNavItem(
//                   icon: Icons.person_outline,
//                   label: 'Profile',
//                   isSelected: false,
//                   onPressed: () {
//                     // Add your navigation logic here
//                     print('Profile pressed');
//                     // Example: Navigator.pushNamed(context, '/profile');
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),

//         // Center Scan Button - Now with onPress
//         Align(
//           alignment: Alignment.center,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Transform.translate(
//                 offset: Offset(0, -15),
//                 child: GestureDetector(
//                   onTap: () {
//                     // Add your scan button logic here
//                     print('Scan button pressed');
//                     // Example: Navigator.pushNamed(context, '/scan');
//                   },
//                   child: Container(
//                     width: 50,
//                     height: 50,
//                     decoration: BoxDecoration(
//                       color: Colors.black,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       Icons.camera_alt,
//                       color: Colors.white,
//                       size: 24,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
        
//         // Scan Text (sejajar dengan teks lain)
//         Align(
//           alignment: Alignment.bottomCenter,
//           child: Container(
//             width: double.infinity / 5,
//             padding: EdgeInsets.only(bottom: 5),
//             child: GestureDetector(
//               onTap: () {
//                 // Add your scan text press logic here
//                 print('Scan text pressed');
//                 // Example: Navigator.pushNamed(context, '/scan');
//                 Navigator.of(context).pushReplacement((context)=> {

//                 })
//               },
//               child: Text(
//                 'Scan Food',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 11,
//                   color: Colors.grey[400],
//                   fontWeight: FontWeight.normal,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }

// Widget _buildNavItem({
//   required IconData icon,
//   required String label,
//   required bool isSelected,
//   required VoidCallback onPressed, // Add this parameter
// }) {
//   return GestureDetector( // Wrap with GestureDetector
//     onTap: onPressed, // Add the onTap handler
//     behavior: HitTestBehavior.opaque, // Makes the entire area tappable
//     child: Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(
//           icon,
//           size: 24,
//           color: isSelected ? Colors.black : Colors.grey[400],
//         ),
//         SizedBox(height: 4),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 11,
//             color: isSelected ? Colors.black : Colors.grey[400],
//             fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
//           ),
//         ),
//       ],
//     ),
//   );
// }
// }