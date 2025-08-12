import '../model/standard_hadith_model.dart';
import '../model/standard_remote_book.dart';

RemotBook getLocalArbaeenBook() {
  final List<Hadith> localHadiths = [
    Hadith(
      id: 1,
      title: "الحديث الأول",
      sanad: "عن أمير المؤمنين أبي حفص عمر بن الخطاب رضي الله عنه قال...",
      matn: "إنما الأعمال بالنيات، وإنما لكل امرئ ما نوى",
    ),
    Hadith(
      id: 2,
      title: "الحديث الثاني",
      sanad: "قال رسول الله صلى الله عليه وسلم",
      matn: "إن الحلالَ بيِّنٌ وإنَّ الحرامَ بيِّنٌ وبينهما أمورٌ مشتبهات...",
    ),
    // أكمل باقي الأحاديث الـ 40 بنفس الطريقة.
  ];

  return RemotBook(
    id: -1, // ID فريد للكتب المحلية
    title: "الأربعون النووية",
    description: "مجموعة من الأحاديث النبوية الجامعة التي جمعها الإمام النووي.",
    author: "الإمام النووي",
    createdAt: DateTime.now(),
    updatedAt: null,
    hadiths: localHadiths,
  );
}