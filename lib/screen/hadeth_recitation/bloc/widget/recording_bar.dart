// import 'package:flutter/material.dart';
//
// class RecordingBar extends StatefulWidget {
//   const RecordingBar({super.key});
//
//   @override
//   State<RecordingBar> createState() => _RecordingBarState();
// }
//
// class _RecordingBarState extends State<RecordingBar> {
//   @override
//   Widget build(BuildContext context) {
//     final int minutes = (tasmiyaState.elapsedTimeInSeconds / 60).floor();
//     final int seconds = (tasmiyaState.elapsedTimeInSeconds % 60);
//     return Container(
//       height: 60,
//       decoration: const BoxDecoration(
//         color: Color(0xffE4EBF0),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             "$minutes:${seconds.toString().padLeft(2, '0')}",
//             style: const TextStyle(color: Colors.black, fontSize: 16),
//           ),
//           SizedBox(
//             width: screenWidth * 0.5,
//             // يمكنك هنا وضع الموجة الصوتية
//           ),
//           const Icon(Icons.circle, color: Colors.red, size: 16),
//         ],
//       ),
//     );
//   }
// }
