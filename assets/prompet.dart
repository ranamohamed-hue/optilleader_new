/*
API KEY:   AIzaSyBRHqbFSmjk5M9KV8BZCKbEAjOr9lmzYBs
NAME : Gemini API Key
PROJECR NAME : projects/1041471151167
PROJECT NUMBER : 1041471151167

AIzaSyBRHqbFSmjk5M9KV8BZCKbEAjOr9lmzYBs
curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent" \
  -H 'Content-Type: application/json' \
  -H 'X-goog-api-key: AIzaSyBRHqbFSmjk5M9KV8BZCKbEAjOr9lmzYBs' \
  -X POST \
  -d '{
    "contents": [
      {
        "parts": [
          {
            "text": "Explain how AI works in a few words"
          }
        ]
      }
    ]
  }'


 */



/*
n:
أنت مساعد أكاديمي خبير في استخراج البيانات. قم بتحليل ملف البحث المرفق واستخرج البيانات التالية بدقة. إذا كانت القيمة غير موجودة، ضع null.

يجب أن يكون الرد بصيغة JSON فقط، بدون أي نص إضافي، وبالمفاتيح التالية:
JSON

{
  "titleAr": "عنوان البحث بالعربي (ترجمه إذا كان بالإنجليزية فقط)",
  "titleEn": "The full title in English",
  "journalName": "اسم المجلة",
  "issn": "الرقم المعياري للمجلة",
  "impactFactor": "تصنيف المجلة (Q1, Q2, Q3, Q4)",
  "publicationYear": "سنة النشر (رقم)",
  "authorOrder": "ترتيب الباحث في القائمة (رقم)",
  "totalAuthors": "إجمالي عدد الباحثين (رقم)"
}




قم بتحليل الشهادة أو الملف المرفق لتحديد تفاصيل النشاط الأكاديمي.

يجب أن يكون الرد بصيغة JSON فقط، بدون أي نص إضافي، وبالمفاتيح التالية:
JSON

{
  "type": "نوع النشاط (Training أو Conference)",
  "title": "اسم الدورة أو المؤتمر",
  "organization": "الجهة المنظمة (مثلاً: FLDC أو جامعة كذا)",
  "date": "التاريخ بصيغة YYYY-MM-DD",
  "duration_hours": "عدد الساعات إن وجد (رقم)",
  "participation_type": "نوع المشاركة (Speaker أو Attendee أو Paper Presenter)"
}





طبقة التحكم (Access): (الـ role والـ uid) -> عشان السيستم يعرف هو داخل كـ "دكتور" ولا "أدمن".

    طبقة التعريف (Identity): (الاسم، الرقم القومي، الإيميل الجامعي) -> بيانات ثابتة للتوثيق في الشيتات الرسمية.

    طبقة الأهلية (Eligibility): (promotionDate, disciplinary_clearance, إلخ) -> دي "الفلتر" اللي بيحدد مين ينفع يكمل ومين "غير مستوفٍ للشروط".

    طبقة التواصل (Contact): (الصورة، الموبايل) -> بيانات مرنة للدكتور يقدر يحدثها في أي وقت.

    طبقة النتائج (Scoring Summary): (الدرجات النهائية) -> دي "الخلاصة" اللي السيستم بيحدثها كل ما دكتور يرفع بحث أو دورة، وهي دي اللي الأدمن بيشوفها في "الشيت" النهائي.


    الـ Firestore: هتدخلي وتنشئي كوليكشن users وتبدأي تجربي الهيكل ده ببيانات "عينة" (Mock Data).

الـ Gemini API: معاكِ الـ Key ومعاكِ الـ Prompt، دول هما "المحرك" اللي هيملأ باقي الكوليكشنات الفرعية (الأبحاث والدورات).

الـ Flutter: هتبدأي تعملي الـ Models (كلاسات برمجية) اللي بتمثل الهيكل ده عشان تقدري تعرضي ال
5$4L+XmBhv7_eXyباسورد قاعدة البيانات 
 */