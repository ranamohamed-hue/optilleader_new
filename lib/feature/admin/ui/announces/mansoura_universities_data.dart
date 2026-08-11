/// ✅ كليات جامعة المنصورة وجميع أقسامها
class MansouraUniversitiesData {

  /// ✅ جميع الكليات
  static const List<FacultyData> faculties = [
    // ============================================================
    // 1. كلية الطب البشري
    // ============================================================
    FacultyData(
      id: 'medicine',
      nameAr: 'كلية الطب البشري',
      nameEn: 'Faculty of Medicine',
      departments: [
        DepartmentData(id: 'anatomy', nameAr: 'التشريح وعلم الأجنة', nameEn: 'Anatomy & Embryology'),
        DepartmentData(id: 'physiology', nameAr: 'الفسيولوجيا الطبية', nameEn: 'Medical Physiology'),
        DepartmentData(id: 'histology', nameAr: 'الهيستولوجيا وعلم الأنسجة', nameEn: 'Histology & Cell Biology'),
        DepartmentData(id: 'biochemistry', nameAr: 'الكيمياء الحيوية والطبية الجزيئية', nameEn: 'Biochemistry & Molecular Biology'),
        DepartmentData(id: 'pharmacology', nameAr: 'الفارماكولوجيا', nameEn: 'Pharmacology'),
        DepartmentData(id: 'parasitology', nameAr: 'علم الطفيليات', nameEn: 'Parasitology'),
        DepartmentData(id: 'microbiology_immunology', nameAr: 'الميكروبيولوجيا والمناعة', nameEn: 'Microbiology & Immunology'),
        DepartmentData(id: 'pathology', nameAr: 'الباثولوجيا', nameEn: 'Pathology'),
        DepartmentData(id: 'forensic', nameAr: 'الطب الشرعي والسموم', nameEn: 'Forensic Medicine & Toxicology'),
        DepartmentData(id: 'public_health', nameAr: 'الصحة العامة وطب المجتمع', nameEn: 'Public Health & Community Medicine'),
        DepartmentData(id: 'pediatrics', nameAr: 'طب الأطفال', nameEn: 'Pediatrics'),
        DepartmentData(id: 'obgyn', nameAr: 'طب النساء والتوليد', nameEn: 'Obstetrics & Gynecology'),
        DepartmentData(id: 'internal_medicine', nameAr: 'الطب الباطني', nameEn: 'Internal Medicine'),
        DepartmentData(id: 'general_surgery', nameAr: 'الجراحة العامة', nameEn: 'General Surgery'),
        DepartmentData(id: 'orthopedics', nameAr: 'جراحة العظام', nameEn: 'Orthopedic Surgery'),
        DepartmentData(id: 'cardiothoracic', nameAr: 'جراحة القلب والصدر', nameEn: 'Cardiothoracic Surgery'),
        DepartmentData(id: 'vascular', nameAr: 'جراحة الأوعية الدموية', nameEn: 'Vascular Surgery'),
        DepartmentData(id: 'neurosurgery', nameAr: 'جراحة الأعصاب', nameEn: 'Neurosurgery'),
        DepartmentData(id: 'urology', nameAr: 'جراحة المسالك البولية', nameEn: 'Urology'),
        DepartmentData(id: 'plastic_surgery', nameAr: 'جراحة التجميل والإصلاح', nameEn: 'Plastic & Reconstructive Surgery'),
        DepartmentData(id: 'ent', nameAr: 'الأنف والأذن والحنجرة', nameEn: 'ENT'),
        DepartmentData(id: 'ophthalmology', nameAr: 'العيون', nameEn: 'Ophthalmology'),
        DepartmentData(id: 'dermatology', nameAr: 'الأمراض الجلدية والتناسلية', nameEn: 'Dermatology & Venereology'),
        DepartmentData(id: 'psychiatry', nameAr: 'الطب النفسي', nameEn: 'Psychiatry'),
        DepartmentData(id: 'radiology', nameAr: 'الأشعة التشخيصية', nameEn: 'Diagnostic Radiology'),
        DepartmentData(id: 'anesthesia', nameAr: 'التخدير والإنعاش', nameEn: 'Anesthesiology & ICU'),
        DepartmentData(id: 'emergency', nameAr: 'طب الطوارئ', nameEn: 'Emergency Medicine'),
        DepartmentData(id: 'oncology', nameAr: 'الأورام', nameEn: 'Oncology'),
        DepartmentData(id: 'family_medicine', nameAr: 'طب الأسرة', nameEn: 'Family Medicine'),
        DepartmentData(id: 'rheumatology', nameAr: 'الروماتيزم والتأهيل', nameEn: 'Rheumatology & Rehabilitation'),
        DepartmentData(id: 'gastroenterology', nameAr: 'الجهاز الهضمي والكبد', nameEn: 'Gastroenterology & Hepatology'),
        DepartmentData(id: 'pulmonology', nameAr: 'الصدرية', nameEn: 'Pulmonology'),
        DepartmentData(id: 'endocrinology', nameAr: 'الغدد الصماء', nameEn: 'Endocrinology'),
        DepartmentData(id: 'nephrology', nameAr: 'الكلى', nameEn: 'Nephrology'),
        DepartmentData(id: 'cardiology', nameAr: 'القلب والأوعية الدموية', nameEn: 'Cardiology'),
        DepartmentData(id: 'neurology', nameAr: 'الدماغ والأعصاب', nameEn: 'Neurology'),
      ],
    ),

    // ============================================================
    // 2. كلية طب الأسنان
    // ============================================================
    FacultyData(
      id: 'dentistry',
      nameAr: 'كلية طب الأسنان',
      nameEn: 'Faculty of Dentistry',
      departments: [
        DepartmentData(id: 'pediatric_dentistry', nameAr: 'طب أسنان الأطفال', nameEn: 'Pediatric Dentistry'),
        DepartmentData(id: 'orthodontics', nameAr: 'تقويم الأسنان', nameEn: 'Orthodontics'),
        DepartmentData(id: 'endodontics', nameAr: 'علاج جذور الأسنان', nameEn: 'Endodontics'),
        DepartmentData(id: 'prosthodontics', nameAr: 'تركيبات الأسنان', nameEn: 'Prosthodontics'),
        DepartmentData(id: 'oral_surgery', nameAr: 'جراحة الفم والوجه والفكين', nameEn: 'Oral & Maxillofacial Surgery'),
        DepartmentData(id: 'dental_public_health', nameAr: 'وقاية الأسنان وصحة الفم', nameEn: 'Dental Public Health'),
        DepartmentData(id: 'oral_pathology', nameAr: 'أمراض الفم', nameEn: 'Oral Pathology'),
        DepartmentData(id: 'dental_materials', nameAr: 'مادة طب الأسنان', nameEn: 'Dental Materials'),
        DepartmentData(id: 'oral_medicine', nameAr: 'طب الفم والتشخيص', nameEn: 'Oral Medicine & Diagnosis'),
        DepartmentData(id: 'periodontology', nameAr: 'أمراض اللثة', nameEn: 'Periodontology'),
        DepartmentData(id: 'conservative_dentistry', nameAr: 'طب الأسنان التحفظي', nameEn: 'Conservative Dentistry'),
        DepartmentData(id: 'fixed_prosthodontics', nameAr: 'التركيبات الثابتة', nameEn: 'Fixed Prosthodontics'),
        DepartmentData(id: 'removable_prosthodontics', nameAr: 'التركيبات المتحركة', nameEn: 'Removable Prosthodontics'),
      ],
    ),

    // ============================================================
    // 3. كلية الصيدلة
    // ============================================================
    FacultyData(
      id: 'pharmacy',
      nameAr: 'كلية الصيدلة',
      nameEn: 'Faculty of Pharmacy',
      departments: [
        DepartmentData(id: 'pharmaceutics', nameAr: 'الصيدلانيات', nameEn: 'Pharmaceutics'),
        DepartmentData(id: 'pharmaceutical_chemistry', nameAr: 'الكيمياء الصيدلية', nameEn: 'Pharmaceutical Chemistry'),
        DepartmentData(id: 'pharmacognosy', nameAr: 'العقاقير والفارماكوجنوسي', nameEn: 'Pharmacognosy'),
        DepartmentData(id: 'pharmacology_pharmacy', nameAr: 'الفارماكولوجيا', nameEn: 'Pharmacology'),
        DepartmentData(id: 'pharmaceutical_microbiology', nameAr: 'الميكروبيولوجيا الصيدلية', nameEn: 'Pharmaceutical Microbiology'),
        DepartmentData(id: 'pharmaceutical_industry', nameAr: 'الصيدلة الصناعية', nameEn: 'Pharmaceutical Industry'),
        DepartmentData(id: 'clinical_pharmacy', nameAr: 'الصيدلة السريرية', nameEn: 'Clinical Pharmacy'),
        DepartmentData(id: 'pharmacy_practice', nameAr: 'ممارسة الصيدلة', nameEn: 'Pharmacy Practice'),
        DepartmentData(id: 'public_health_pharmacy', nameAr: 'صحة عامة صيدلية', nameEn: 'Public Health Pharmacy'),
      ],
    ),

    // ============================================================
    // 4. كلية الهندسة
    // ============================================================
    FacultyData(
      id: 'engineering',
      nameAr: 'كلية الهندسة',
      nameEn: 'Faculty of Engineering',
      departments: [
        DepartmentData(id: 'civil', nameAr: 'الهندسة المدنية', nameEn: 'Civil Engineering'),
        DepartmentData(id: 'architectural', nameAr: 'الهندسة المعمارية', nameEn: 'Architectural Engineering'),
        DepartmentData(id: 'mechanical', nameAr: 'الهندسة الميكانيكية', nameEn: 'Mechanical Engineering'),
        DepartmentData(id: 'electrical', nameAr: 'الهندسة الكهربية', nameEn: 'Electrical Engineering'),
        DepartmentData(id: 'electronics_comm', nameAr: 'هندسة الإلكترونيات والاتصالات', nameEn: 'Electronics & Communications'),
        DepartmentData(id: 'computer_eng', nameAr: 'هندسة الحاسبات', nameEn: 'Computer Engineering'),
        DepartmentData(id: 'chemical', nameAr: 'الهندسة الكيميائية', nameEn: 'Chemical Engineering'),
        DepartmentData(id: 'power', nameAr: 'هندسة القوى الكهربية', nameEn: 'Power Electrical Engineering'),
        DepartmentData(id: 'production', nameAr: 'هندسة الإنتاج', nameEn: 'Production Engineering'),
        DepartmentData(id: 'industrial', nameAr: 'الهندسة الصناعية', nameEn: 'Industrial Engineering'),
        DepartmentData(id: 'structural', nameAr: 'الهندسة الإنشائية', nameEn: 'Structural Engineering'),
        DepartmentData(id: 'public_works', nameAr: 'هندسة الأشغال العامة', nameEn: 'Public Works Engineering'),
        DepartmentData(id: 'water_sanitation', nameAr: 'هندسة الري والصرف', nameEn: 'Irrigation & Hydraulics'),
        DepartmentData(id: 'surveying', nameAr: 'المساحة', nameEn: 'Surveying'),
        DepartmentData(id: 'interior_design', nameAr: 'التصميم الداخلي', nameEn: 'Interior Design'),
      ],
    ),

    // ============================================================
    // 5. كلية العلوم
    // ============================================================
    FacultyData(
      id: 'science',
      nameAr: 'كلية العلوم',
      nameEn: 'Faculty of Science',
      departments: [
        DepartmentData(id: 'physics', nameAr: 'الفيزياء', nameEn: 'Physics'),
        DepartmentData(id: 'chemistry', nameAr: 'الكيمياء', nameEn: 'Chemistry'),
        DepartmentData(id: 'mathematics', nameAr: 'الرياضيات', nameEn: 'Mathematics'),
        DepartmentData(id: 'geology', nameAr: 'الجيولوجيا', nameEn: 'Geology'),
        DepartmentData(id: 'zoology', nameAr: 'علم الحيوان', nameEn: 'Zoology'),
        DepartmentData(id: 'botany', nameAr: 'علم النبات', nameEn: 'Botany'),
        DepartmentData(id: 'microbiology_science', nameAr: 'الميكروبيولوجيا', nameEn: 'Microbiology'),
        DepartmentData(id: 'biochemistry_science', nameAr: 'الكيمياء الحيوية', nameEn: 'Biochemistry'),
        DepartmentData(id: 'statistics_cs', nameAr: 'الإحصاء وعلوم الحاسب', nameEn: 'Statistics & Computer Science'),
        DepartmentData(id: 'entomology', nameAr: 'علم الحشرات', nameEn: 'Entomology'),
        DepartmentData(id: 'astronomy', nameAr: 'الفلك والفضاء', nameEn: 'Astronomy & Space Science'),
      ],
    ),

    // ============================================================
    // 6. كلية التجارة
    // ============================================================
    FacultyData(
      id: 'commerce',
      nameAr: 'كلية التجارة',
      nameEn: 'Faculty of Commerce',
      departments: [
        DepartmentData(id: 'accounting', nameAr: 'المحاسبة', nameEn: 'Accounting'),
        DepartmentData(id: 'business_admin', nameAr: 'إدارة الأعمال', nameEn: 'Business Administration'),
        DepartmentData(id: 'economics', nameAr: 'الاقتصاد', nameEn: 'Economics'),
        DepartmentData(id: 'statistics_insurance', nameAr: 'الإحصاء والتأمين', nameEn: 'Statistics & Insurance'),
        DepartmentData(id: 'mis', nameAr: 'نظم المعلومات الإدارية', nameEn: 'Management Information Systems'),
        DepartmentData(id: 'marketing', nameAr: 'التسويق', nameEn: 'Marketing'),
        DepartmentData(id: 'finance', nameAr: 'التمويل والمصارف', nameEn: 'Finance & Banking'),
        DepartmentData(id: 'public_accounting', nameAr: 'المحاسبة العامة', nameEn: 'Public Accounting'),
        DepartmentData(id: 'foreign_trade', nameAr: 'التجارة الخارجية', nameEn: 'Foreign Trade'),
      ],
    ),

    // ============================================================
    // 7. كلية الحقوق
    // ============================================================
    FacultyData(
      id: 'law',
      nameAr: 'كلية الحقوق',
      nameEn: 'Faculty of Law',
      departments: [
        DepartmentData(id: 'civil_law', nameAr: 'القانون المدني', nameEn: 'Civil Law'),
        DepartmentData(id: 'commercial_law', nameAr: 'القانون التجاري', nameEn: 'Commercial Law'),
        DepartmentData(id: 'criminal_law', nameAr: 'القانون الجنائي', nameEn: 'Criminal Law'),
        DepartmentData(id: 'public_int_law', nameAr: 'القانون الدولي العام', nameEn: 'Public International Law'),
        DepartmentData(id: 'private_int_law', nameAr: 'القانون الدولي الخاص', nameEn: 'Private International Law'),
        DepartmentData(id: 'constitutional_law', nameAr: 'قانون الدولة والإدارة', nameEn: 'Constitutional & Administrative Law'),
        DepartmentData(id: 'islamic_sharia', nameAr: 'الشريعة الإسلامية', nameEn: 'Islamic Sharia'),
        DepartmentData(id: 'labor_law', nameAr: 'قانون العمل', nameEn: 'Labor Law'),
        DepartmentData(id: 'public_economic_law', nameAr: 'القانون الاقتصادي العام', nameEn: 'Public Economic Law'),
        DepartmentData(id: 'international_relations', nameAr: 'العلاقات الدولية', nameEn: 'International Relations'),
      ],
    ),

    // ============================================================
    // 8. كلية الآداب
    // ============================================================
    FacultyData(
      id: 'arts',
      nameAr: 'كلية الآداب',
      nameEn: 'Faculty of Arts',
      departments: [
        DepartmentData(id: 'arabic', nameAr: 'اللغة العربية وآدابها', nameEn: 'Arabic Language & Literature'),
        DepartmentData(id: 'english', nameAr: 'اللغة الإنجليزية وآدابها', nameEn: 'English Language & Literature'),
        DepartmentData(id: 'french', nameAr: 'اللغة الفرنسية وآدابها', nameEn: 'French Language & Literature'),
        DepartmentData(id: 'history', nameAr: 'التاريخ', nameEn: 'History'),
        DepartmentData(id: 'geography', nameAr: 'الجغرافيا', nameEn: 'Geography'),
        DepartmentData(id: 'philosophy', nameAr: 'الفلسفة', nameEn: 'Philosophy'),
        DepartmentData(id: 'sociology', nameAr: 'علم الاجتماع', nameEn: 'Sociology'),
        DepartmentData(id: 'psychology_arts', nameAr: 'علم النفس', nameEn: 'Psychology'),
        DepartmentData(id: 'journalism', nameAr: 'الصحافة والإعلام', nameEn: 'Journalism & Media'),
        DepartmentData(id: 'library_science', nameAr: 'علم المعلومات والمكتبات', nameEn: 'Information & Library Science'),
        DepartmentData(id: 'archaeology', nameAr: 'الآثار', nameEn: 'Archaeology'),
        DepartmentData(id: 'german', nameAr: 'اللغة الألمانية', nameEn: 'German Language'),
        DepartmentData(id: 'spanish', nameAr: 'اللغة الإسبانية', nameEn: 'Spanish Language'),
        DepartmentData(id: 'italian', nameAr: 'اللغة الإيطالية', nameEn: 'Italian Language'),
        DepartmentData(id: 'oriental_studies', nameAr: 'الدراسات الشرقية', nameEn: 'Oriental Studies'),
      ],
    ),

    // ============================================================
    // 9. كلية التربية
    // ============================================================
    FacultyData(
      id: 'education',
      nameAr: 'كلية التربية',
      nameEn: 'Faculty of Education',
      departments: [
        DepartmentData(id: 'curricula', nameAr: 'المناهج وطرق التدريس', nameEn: 'Curricula & Teaching Methods'),
        DepartmentData(id: 'educational_psychology', nameAr: 'علم النفس التربوي', nameEn: 'Educational Psychology'),
        DepartmentData(id: 'foundations_edu', nameAr: 'أصول التربية', nameEn: 'Foundations of Education'),
        DepartmentData(id: 'edu_admin', nameAr: 'الإدارة التربوية والمقارنة', nameEn: 'Educational Administration'),
        DepartmentData(id: 'special_edu', nameAr: 'التربية الخاصة', nameEn: 'Special Education'),
        DepartmentData(id: 'early_childhood', nameAr: 'تربية الطفولة المبكرة', nameEn: 'Early Childhood Education'),
        DepartmentData(id: 'edu_technology', nameAr: 'تكنولوجيا التعليم', nameEn: 'Educational Technology'),
        DepartmentData(id: 'edu_guidance', nameAr: 'التوجيه والإرشاد', nameEn: 'Educational Guidance'),
      ],
    ),

    // ============================================================
    // 10. كلية التربية النوعية
    // ============================================================
    FacultyData(
      id: 'specific_education',
      nameAr: 'كلية التربية النوعية',
      nameEn: 'Faculty of Specific Education',
      departments: [
        DepartmentData(id: 'art_education', nameAr: 'التربية الفنية', nameEn: 'Art Education'),
        DepartmentData(id: 'music_education', nameAr: 'التربية الموسيقية', nameEn: 'Music Education'),
        DepartmentData(id: 'edu_media', nameAr: 'الإعلام التربوي', nameEn: 'Educational Media'),
        DepartmentData(id: 'home_economics', nameAr: 'التربية الاقتصادية المنزلية', nameEn: 'Home Economics Education'),
        DepartmentData(id: 'theater_edu', nameAr: 'التربية المسرحية', nameEn: 'Theater Education'),
        DepartmentData(id: 'tech_education', nameAr: 'تكنولوجيا التعليم', nameEn: 'Technology Education'),
        DepartmentData(id: 'com_education', nameAr: 'حاسب الي ', nameEn: 'Computer Education'),

      ],
    ),

    // ============================================================
    // 11. كلية الطب البيطري
    // ============================================================
    FacultyData(
      id: 'veterinary',
      nameAr: 'كلية الطب البيطري',
      nameEn: 'Faculty of Veterinary Medicine',
      departments: [
        DepartmentData(id: 'vet_anatomy', nameAr: 'التشريح وعلم الأجنة', nameEn: 'Anatomy & Embryology'),
        DepartmentData(id: 'vet_physiology', nameAr: 'الفسيولوجيا', nameEn: 'Physiology'),
        DepartmentData(id: 'vet_histology', nameAr: 'الهيستولوجيا', nameEn: 'Histology'),
        DepartmentData(id: 'vet_biochemistry', nameAr: 'الكيمياء الحيوية', nameEn: 'Biochemistry'),
        DepartmentData(id: 'vet_microbiology', nameAr: 'الميكروبيولوجيا', nameEn: 'Microbiology'),
        DepartmentData(id: 'vet_parasitology', nameAr: 'الطفيليات', nameEn: 'Parasitology'),
        DepartmentData(id: 'vet_pathology', nameAr: 'الباثولوجيا', nameEn: 'Pathology'),
        DepartmentData(id: 'vet_pharmacology', nameAr: 'الصيدلة السريرية', nameEn: 'Clinical Pharmacology'),
        DepartmentData(id: 'vet_medicine', nameAr: 'الأمراض المشتركة', nameEn: 'Internal Medicine'),
        DepartmentData(id: 'vet_poultry', nameAr: 'أمراض الدواجن', nameEn: 'Poultry Diseases'),
        DepartmentData(id: 'vet_surgery', nameAr: 'جراحة الحيوان', nameEn: 'Surgery'),
        DepartmentData(id: 'vet_obstetrics', nameAr: 'التوليد والتناسلية', nameEn: 'Obstetrics & Reproduction'),
        DepartmentData(id: 'vet_public_health', nameAr: 'الصحة العامة والطب الوقائي', nameEn: 'Public Health & Preventive Medicine'),
        DepartmentData(id: 'vet_meat', nameAr: 'اللحوم والتفتيش', nameEn: 'Meat Hygiene & Inspection'),
        DepartmentData(id: 'vet_nutrition', nameAr: 'تغذية الحيوان', nameEn: 'Animal Nutrition'),
        DepartmentData(id: 'vet_genetics', nameAr: 'الوراثة', nameEn: 'Genetics'),
        DepartmentData(id: 'vet_poultry_production', nameAr: 'إنتاج الدواجن', nameEn: 'Poultry Production'),
        DepartmentData(id: 'vet_dairy', nameAr: 'إنتاج الألبان', nameEn: 'Dairy Production'),
      ],
    ),

    // ============================================================
    // 12. كلية الزراعة
    // ============================================================
    FacultyData(
      id: 'agriculture',
      nameAr: 'كلية الزراعة',
      nameEn: 'Faculty of Agriculture',
      departments: [
        DepartmentData(id: 'crops', nameAr: 'المحاصيل', nameEn: 'Crop Science'),
        DepartmentData(id: 'horticulture', nameAr: 'البستنة', nameEn: 'Horticulture'),
        DepartmentData(id: 'plant_protection', nameAr: 'وقاية النبات', nameEn: 'Plant Protection'),
        DepartmentData(id: 'soil_water', nameAr: 'الأراضي والمياه', nameEn: 'Soil & Water Science'),
        DepartmentData(id: 'agricultural_eng', nameAr: 'الهندسة الزراعية', nameEn: 'Agricultural Engineering'),
        DepartmentData(id: 'agricultural_economics', nameAr: 'الاقتصاد الزراعي', nameEn: 'Agricultural Economics'),
        DepartmentData(id: 'food_science', nameAr: 'الصناعات الغذائية', nameEn: 'Food Science'),
        DepartmentData(id: 'dairy_science', nameAr: 'تكنولوجيا الألبان', nameEn: 'Dairy Science & Technology'),
        DepartmentData(id: 'animal_production', nameAr: 'الإنتاج الحيواني', nameEn: 'Animal Production'),
        DepartmentData(id: 'genetics_agri', nameAr: 'الوراثة', nameEn: 'Genetics'),
        DepartmentData(id: 'oil_crops', nameAr: 'المحاصيل الزيتية', nameEn: 'Oil Crops'),
        DepartmentData(id: 'agricultural_botany', nameAr: 'النبات الزراعي', nameEn: 'Agricultural Botany'),
        DepartmentData(id: 'agricultural_chemistry', nameAr: 'الكيمياء الزراعية', nameEn: 'Agricultural Chemistry'),
        DepartmentData(id: 'entomology_agri', nameAr: 'الحشرات الاقتصادية', nameEn: 'Economic Entomology'),
        DepartmentData(id: 'plant_pathology', nameAr: 'أمراض النبات', nameEn: 'Plant Pathology'),
        DepartmentData(id: 'weed_science', nameAr: 'نباتات الزهور', nameEn: 'Floriculture'),
        DepartmentData(id: 'landscape', nameAr: 'تنسيق المواقع', nameEn: 'Landscape Architecture'),
        DepartmentData(id: 'pomology', nameAr: 'فاكهة', nameEn: 'Pomology'),
        DepartmentData(id: 'vegetables', nameAr: 'خضر', nameEn: 'Vegetable Crops'),
      ],
    ),

    // ============================================================
    // 13. كلية الحاسبات والمعلومات
    // ============================================================
    FacultyData(
      id: 'computers_info',
      nameAr: 'كلية الحاسبات والمعلومات',
      nameEn: 'Faculty of Computers & Information',
      departments: [
        DepartmentData(id: 'computer_science', nameAr: 'علوم الحاسب', nameEn: 'Computer Science'),
        DepartmentData(id: 'information_systems', nameAr: 'نظم المعلومات', nameEn: 'Information Systems'),
        DepartmentData(id: 'software_eng', nameAr: 'هندسة البرمجيات', nameEn: 'Software Engineering'),
        DepartmentData(id: 'networks', nameAr: 'الشبكات', nameEn: 'Networks'),
        DepartmentData(id: 'artificial_intelligence', nameAr: 'الذكاء الاصطناعي', nameEn: 'Artificial Intelligence'),
        DepartmentData(id: 'data_science', nameAr: 'علوم البيانات', nameEn: 'Data Science'),
        DepartmentData(id: 'cyber_security', nameAr: 'الأمن السيبراني', nameEn: 'Cyber Security'),
        DepartmentData(id: 'bioinformatics', nameAr: 'المعلوماتية الحيوية', nameEn: 'Bioinformatics'),
      ],
    ),

    // ============================================================
    // 14. كلية التمريض
    // ============================================================
    FacultyData(
      id: 'nursing',
      nameAr: 'كلية التمريض',
      nameEn: 'Faculty of Nursing',
      departments: [
        DepartmentData(id: 'adult_nursing', nameAr: 'تمريض البالغين', nameEn: 'Adult Nursing'),
        DepartmentData(id: 'pediatric_nursing', nameAr: 'تمريض الأطفال', nameEn: 'Pediatric Nursing'),
        DepartmentData(id: 'obgyn_nursing', nameAr: 'تمريض النساء والتوليد', nameEn: 'Obstetric & Gynecological Nursing'),
        DepartmentData(id: 'psychiatric_nursing', nameAr: 'تمريض الصحة النفسية', nameEn: 'Psychiatric & Mental Health Nursing'),
        DepartmentData(id: 'community_nursing', nameAr: 'تمريض المجتمع', nameEn: 'Community Health Nursing'),
        DepartmentData(id: 'nursing_admin', nameAr: 'إدارة التمريض', nameEn: 'Nursing Administration'),
        DepartmentData(id: 'critical_care_nursing', nameAr: 'الرعاية الحرجة', nameEn: 'Critical Care Nursing'),
        DepartmentData(id: 'nursing_education', nameAr: 'التربية التمريضية', nameEn: 'Nursing Education'),
      ],
    ),

    // ============================================================
    // 15. كلية التربية الرياضية
    // ============================================================
    FacultyData(
      id: 'physical_education',
      nameAr: 'كلية التربية الرياضية',
      nameEn: 'Faculty of Physical Education',
      departments: [
        DepartmentData(id: 'pe_teaching', nameAr: 'التدريس', nameEn: 'Teaching'),
        DepartmentData(id: 'pe_training', nameAr: 'التدريب الرياضي', nameEn: 'Sports Training'),
        DepartmentData(id: 'pe_admin', nameAr: 'الإدارة الرياضية', nameEn: 'Sports Administration'),
        DepartmentData(id: 'pe_health', nameAr: 'علوم الصحة الرياضية', nameEn: 'Sports Health Sciences'),
        DepartmentData(id: 'pe_biomechanics', nameAr: 'الميكانيكا الحيوية', nameEn: 'Biomechanics'),
        DepartmentData(id: 'pe_kinesiology', nameAr: 'حركة الإنسان', nameEn: 'Kinesiology'),
        DepartmentData(id: 'pe_recreation', nameAr: 'الترويح', nameEn: 'Recreation'),
        DepartmentData(id: 'pe_adapted', nameAr: 'التربية الرياضية التكيفية', nameEn: 'Adapted Physical Education'),
      ],
    ),

    // ============================================================
    // 16. كلية العلوم الطبية التطبيقية
    // ============================================================
    FacultyData(
      id: 'applied_medical',
      nameAr: 'كلية العلوم الطبية التطبيقية',
      nameEn: 'Faculty of Applied Medical Sciences',
      departments: [
        DepartmentData(id: 'health_sciences', nameAr: 'العلوم الصحية', nameEn: 'Health Sciences'),
        DepartmentData(id: 'radiologic_technology', nameAr: 'تقنيات الأشعة', nameEn: 'Radiologic Technology'),
        DepartmentData(id: 'lab_technology', nameAr: 'تقنيات المخبر الطبي', nameEn: 'Medical Laboratory Technology'),
        DepartmentData(id: 'physiotherapy', nameAr: 'العلاج الطبيعي', nameEn: 'Physiotherapy'),
        DepartmentData(id: 'respiratory_therapy', nameAr: 'العلاج التنفسي', nameEn: 'Respiratory Therapy'),
        DepartmentData(id: 'anesthesia_tech', nameAr: 'تقنيات التخدير', nameEn: 'Anesthesia Technology'),
        DepartmentData(id: 'emergency_tech', nameAr: 'تقنيات الطوارئ', nameEn: 'Emergency Technology'),
      ],
    ),

    // ============================================================
    // 17. كلية السياحة والفنادق
    // ============================================================
    FacultyData(
      id: 'tourism_hotels',
      nameAr: 'كلية السياحة والفنادق',
      nameEn: 'Faculty of Tourism & Hotels',
      departments: [
        DepartmentData(id: 'tourism_studies', nameAr: 'الدراسات السياحية', nameEn: 'Tourism Studies'),
        DepartmentData(id: 'hotel_management', nameAr: 'إدارة الفنادق', nameEn: 'Hotel Management'),
        DepartmentData(id: 'tour_guidance', nameAr: 'الإرشاد السياحي', nameEn: 'Tour Guidance'),
        DepartmentData(id: 'travel_agencies', nameAr: 'إدارة وكالات السفر', nameEn: 'Travel Agencies Management'),
        DepartmentData(id: 'food_beverage', nameAr: 'إدارة المطاعم والمشروبات', nameEn: 'Food & Beverage Management'),
        DepartmentData(id: 'tourism_marketing', nameAr: 'التسويق السياحي', nameEn: 'Tourism Marketing'),
      ],
    ),

    // ============================================================
    // 18. كلية الطب البشري بمطروح (فرع)
    // ============================================================
    FacultyData(
      id: 'medicine_matroh',
      nameAr: 'كلية الطب البشري بمطروح',
      nameEn: 'Faculty of Medicine - Matrouh Branch',
      departments: [
        DepartmentData(id: 'matroh_anatomy', nameAr: 'التشريح وعلم الأجنة', nameEn: 'Anatomy & Embryology'),
        DepartmentData(id: 'matroh_physiology', nameAr: 'الفسيولوجيا الطبية', nameEn: 'Medical Physiology'),
        DepartmentData(id: 'matroh_biochemistry', nameAr: 'الكيمياء الحيوية', nameEn: 'Biochemistry'),
        DepartmentData(id: 'matroh_pathology', nameAr: 'الباثولوجيا', nameEn: 'Pathology'),
        DepartmentData(id: 'matroh_pharmacology', nameAr: 'الفارماكولوجيا', nameEn: 'Pharmacology'),
        DepartmentData(id: 'matroh_microbiology', nameAr: 'الميكروبيولوجيا', nameEn: 'Microbiology'),
        DepartmentData(id: 'matroh_parasitology', nameAr: 'الطفيليات', nameEn: 'Parasitology'),
        DepartmentData(id: 'matroh_forensic', nameAr: 'الطب الشرعي', nameEn: 'Forensic Medicine'),
        DepartmentData(id: 'matroh_public_health', nameAr: 'الصحة العامة', nameEn: 'Public Health'),
        DepartmentData(id: 'matroh_pediatrics', nameAr: 'طب الأطفال', nameEn: 'Pediatrics'),
        DepartmentData(id: 'matroh_obgyn', nameAr: 'طب النساء والتوليد', nameEn: 'Obstetrics & Gynecology'),
        DepartmentData(id: 'matroh_internal', nameAr: 'الطب الباطني', nameEn: 'Internal Medicine'),
        DepartmentData(id: 'matroh_surgery', nameAr: 'الجراحة العامة', nameEn: 'General Surgery'),
        DepartmentData(id: 'matroh_ent', nameAr: 'الأنف والأذن والحنجرة', nameEn: 'ENT'),
        DepartmentData(id: 'matroh_ophthalmology', nameAr: 'العيون', nameEn: 'Ophthalmology'),
        DepartmentData(id: 'matroh_dermatology', nameAr: 'الأمراض الجلدية', nameEn: 'Dermatology'),
        DepartmentData(id: 'matroh_psychiatry', nameAr: 'الطب النفسي', nameEn: 'Psychiatry'),
        DepartmentData(id: 'matroh_radiology', nameAr: 'الأشعة', nameEn: 'Radiology'),
        DepartmentData(id: 'matroh_anesthesia', nameAr: 'التخدير والإنعاش', nameEn: 'Anesthesiology'),
        DepartmentData(id: 'matroh_orthopedics', nameAr: 'جراحة العظام', nameEn: 'Orthopedics'),
        DepartmentData(id: 'matroh_urology', nameAr: 'جراحة المسالك البولية', nameEn: 'Urology'),
        DepartmentData(id: 'matroh_neurosurgery', nameAr: 'جراحة الأعصاب', nameEn: 'Neurosurgery'),
        DepartmentData(id: 'matroh_cardiothoracic', nameAr: 'جراحة القلب والصدر', nameEn: 'Cardiothoracic Surgery'),
        DepartmentData(id: 'matroh_cardiology', nameAr: 'أمراض القلب', nameEn: 'Cardiology'),
        DepartmentData(id: 'matroh_neurology', nameAr: 'أمراض الأعصاب', nameEn: 'Neurology'),
        DepartmentData(id: 'matroh_gastroenterology', nameAr: 'الجهاز الهضمي', nameEn: 'Gastroenterology'),
        DepartmentData(id: 'matroh_pulmonology', nameAr: 'أمراض الصدر', nameEn: 'Pulmonology'),
        DepartmentData(id: 'matroh_endocrinology', nameAr: 'الغدد الصماء', nameEn: 'Endocrinology'),
        DepartmentData(id: 'matroh_nephrology', nameAr: 'أمراض الكلى', nameEn: 'Nephrology'),
        DepartmentData(id: 'matroh_rheumatology', nameAr: 'الروماتيزم', nameEn: 'Rheumatology'),
        DepartmentData(id: 'matroh_oncology', nameAr: 'الأورام', nameEn: 'Oncology'),
        DepartmentData(id: 'matroh_emergency', nameAr: 'طب الطوارئ', nameEn: 'Emergency Medicine'),
        DepartmentData(id: 'matroh_family_medicine', nameAr: 'طب الأسرة', nameEn: 'Family Medicine'),
      ],
    ),

    // ============================================================
    // 19. كلية التمريض بمطروح (فرع)
    // ============================================================
    FacultyData(
      id: 'nursing_matroh',
      nameAr: 'كلية التمريض بمطروح',
      nameEn: 'Faculty of Nursing - Matrouh Branch',
      departments: [
        DepartmentData(id: 'matroh_nursing_adult', nameAr: 'تمريض البالغين', nameEn: 'Adult Nursing'),
        DepartmentData(id: 'matroh_nursing_pediatric', nameAr: 'تمريض الأطفال', nameEn: 'Pediatric Nursing'),
        DepartmentData(id: 'matroh_nursing_obgyn', nameAr: 'تمريض النساء والتوليد', nameEn: 'Obstetric Nursing'),
        DepartmentData(id: 'matroh_nursing_psychiatric', nameAr: 'تمريض الصحة النفسية', nameEn: 'Psychiatric Nursing'),
        DepartmentData(id: 'matroh_nursing_community', nameAr: 'تمريض المجتمع', nameEn: 'Community Nursing'),
        DepartmentData(id: 'matroh_nursing_admin', nameAr: 'إدارة التمريض', nameEn: 'Nursing Administration'),
        DepartmentData(id: 'matroh_nursing_critical', nameAr: 'الرعاية الحرجة', nameEn: 'Critical Care Nursing'),
      ],
    ),

    // ============================================================
    // 20. كلية التربية بمطروح (فرع)
    // ============================================================
    FacultyData(
      id: 'education_matroh',
      nameAr: 'كلية التربية بمطروح',
      nameEn: 'Faculty of Education - Matrouh Branch',
      departments: [
        DepartmentData(id: 'matroh_edu_curricula', nameAr: 'المناهج وطرق التدريس', nameEn: 'Curricula & Teaching'),
        DepartmentData(id: 'matroh_edu_psychology', nameAr: 'علم النفس التربوي', nameEn: 'Educational Psychology'),
        DepartmentData(id: 'matroh_edu_foundations', nameAr: 'أصول التربية', nameEn: 'Foundations of Education'),
        DepartmentData(id: 'matroh_edu_admin', nameAr: 'الإدارة التربوية', nameEn: 'Educational Administration'),
        DepartmentData(id: 'matroh_edu_special', nameAr: 'التربية الخاصة', nameEn: 'Special Education'),
        DepartmentData(id: 'matroh_edu_childhood', nameAr: 'الطفولة المبكرة', nameEn: 'Early Childhood'),
        DepartmentData(id: 'matroh_edu_technology', nameAr: 'تكنولوجيا التعليم', nameEn: 'Educational Technology'),
      ],
    ),

    // ============================================================
    // 21. كلية الآداب بمطروح (فرع)
    // ============================================================
    FacultyData(
      id: 'arts_matroh',
      nameAr: 'كلية الآداب بمطروح',
      nameEn: 'Faculty of Arts - Matrouh Branch',
      departments: [
        DepartmentData(id: 'matroh_arabic', nameAr: 'اللغة العربية', nameEn: 'Arabic Language'),
        DepartmentData(id: 'matroh_english', nameAr: 'اللغة الإنجليزية', nameEn: 'English Language'),
        DepartmentData(id: 'matroh_french', nameAr: 'اللغة الفرنسية', nameEn: 'French Language'),
        DepartmentData(id: 'matroh_history', nameAr: 'التاريخ', nameEn: 'History'),
        DepartmentData(id: 'matroh_geography', nameAr: 'الجغرافيا', nameEn: 'Geography'),
        DepartmentData(id: 'matroh_sociology', nameAr: 'علم الاجتماع', nameEn: 'Sociology'),
        DepartmentData(id: 'matroh_psychology', nameAr: 'علم النفس', nameEn: 'Psychology'),
        DepartmentData(id: 'matroh_philosophy', nameAr: 'الفلسفة', nameEn: 'Philosophy'),
      ],
    ),

    // ============================================================
    // 22. كلية التجارة بمطروح (فرع)
    // ============================================================
    FacultyData(
      id: 'commerce_matroh',
      nameAr: 'كلية التجارة بمطروح',
      nameEn: 'Faculty of Commerce - Matrouh Branch',
      departments: [
        DepartmentData(id: 'matroh_accounting', nameAr: 'المحاسبة', nameEn: 'Accounting'),
        DepartmentData(id: 'matroh_business', nameAr: 'إدارة الأعمال', nameEn: 'Business Administration'),
        DepartmentData(id: 'matroh_economics', nameAr: 'الاقتصاد', nameEn: 'Economics'),
        DepartmentData(id: 'matroh_statistics', nameAr: 'الإحصاء والتأمين', nameEn: 'Statistics & Insurance'),
        DepartmentData(id: 'matroh_mis', nameAr: 'نظم المعلومات', nameEn: 'MIS'),
        DepartmentData(id: 'matroh_marketing', nameAr: 'التسويق', nameEn: 'Marketing'),
        DepartmentData(id: 'matroh_finance', nameAr: 'التمويل', nameEn: 'Finance'),
      ],
    ),

    // ============================================================
    // 23. كلية الحقوق بمطروح (فرع)
    // ============================================================
    FacultyData(
      id: 'law_matroh',
      nameAr: 'كلية الحقوق بمطروح',
      nameEn: 'Faculty of Law - Matrouh Branch',
      departments: [
        DepartmentData(id: 'matroh_civil', nameAr: 'القانون المدني', nameEn: 'Civil Law'),
        DepartmentData(id: 'matroh_commercial', nameAr: 'القانون التجاري', nameEn: 'Commercial Law'),
        DepartmentData(id: 'matroh_criminal', nameAr: 'القانون الجنائي', nameEn: 'Criminal Law'),
        DepartmentData(id: 'matroh_public_int', nameAr: 'القانون الدولي العام', nameEn: 'Public International Law'),
        DepartmentData(id: 'matroh_constitutional', nameAr: 'القانون الدستوري', nameEn: 'Constitutional Law'),
        DepartmentData(id: 'matroh_sharia', nameAr: 'الشريعة الإسلامية', nameEn: 'Islamic Sharia'),
      ],
    ),

    // ============================================================
    // 24. كلية العلاج الطبيعي
    // ============================================================
    FacultyData(
      id: 'physiotherapy',
      nameAr: 'كلية العلاج الطبيعي',
      nameEn: 'Faculty of Physiotherapy',
      departments: [
        DepartmentData(id: 'pt_musculoskeletal', nameAr: 'العلاج الطبيعي للعظام والعضلات', nameEn: 'Musculoskeletal Physiotherapy'),
        DepartmentData(id: 'pt_neurological', nameAr: 'العلاج الطبيعي العصبي', nameEn: 'Neurological Physiotherapy'),
        DepartmentData(id: 'pt_cardiopulmonary', nameAr: 'العلاج الطبيعي للقلب والرئة', nameEn: 'Cardiopulmonary Physiotherapy'),
        DepartmentData(id: 'pt_pediatric', nameAr: 'العلاج الطبيعي للأطفال', nameEn: 'Pediatric Physiotherapy'),
        DepartmentData(id: 'pt_sports', nameAr: 'العلاج الطبيعي الرياضي', nameEn: 'Sports Physiotherapy'),
        DepartmentData(id: 'pt_geriatric', nameAr: 'العلاج الطبيعي لكبار السن', nameEn: 'Geriatric Physiotherapy'),
        DepartmentData(id: 'pt_electrotherapy', nameAr: 'العلاج بالكهرباء', nameEn: 'Electrotherapy'),
        DepartmentData(id: 'pt_biomechanics', nameAr: 'الميكانيكا الحيوية', nameEn: 'Biomechanics'),
        DepartmentData(id: 'pt_community', nameAr: 'العلاج الطبيعي المجتمعي', nameEn: 'Community Physiotherapy'),
      ],
    ),

    // ============================================================
    // 25. كلية الهندسة بمطروح (فرع)
    // ============================================================
    FacultyData(
      id: 'engineering_matroh',
      nameAr: 'كلية الهندسة بمطروح',
      nameEn: 'Faculty of Engineering - Matrouh Branch',
      departments: [
        DepartmentData(id: 'matroh_civil', nameAr: 'الهندسة المدنية', nameEn: 'Civil Engineering'),
        DepartmentData(id: 'matroh_architectural', nameAr: 'الهندسة المعمارية', nameEn: 'Architectural Engineering'),
        DepartmentData(id: 'matroh_electrical', nameAr: 'الهندسة الكهربية', nameEn: 'Electrical Engineering'),
        DepartmentData(id: 'matroh_mechanical', nameAr: 'الهندسة الميكانيكية', nameEn: 'Mechanical Engineering'),
        DepartmentData(id: 'matroh_computer_eng', nameAr: 'هندسة الحاسبات', nameEn: 'Computer Engineering'),
      ],
    ),

    // ============================================================
    // 26. كلية الصيدلة بمطروح (فرع)
    // ============================================================
    FacultyData(
      id: 'pharmacy_matroh',
      nameAr: 'كلية الصيدلة بمطروح',
      nameEn: 'Faculty of Pharmacy - Matrouh Branch',
      departments: [
        DepartmentData(id: 'matroh_pharmaceutics', nameAr: 'الصيدلانيات', nameEn: 'Pharmaceutics'),
        DepartmentData(id: 'matroh_pharm_chemistry', nameAr: 'الكيمياء الصيدلية', nameEn: 'Pharmaceutical Chemistry'),
        DepartmentData(id: 'matroh_pharmacognosy', nameAr: 'العقاقير', nameEn: 'Pharmacognosy'),
        DepartmentData(id: 'matroh_pharmacology', nameAr: 'الفارماكولوجيا', nameEn: 'Pharmacology'),
        DepartmentData(id: 'matroh_pharm_microbiology', nameAr: 'الميكروبيولوجيا الصيدلية', nameEn: 'Pharmaceutical Microbiology'),
        DepartmentData(id: 'matroh_clinical_pharmacy', nameAr: 'الصيدلة السريرية', nameEn: 'Clinical Pharmacy'),
        DepartmentData(id: 'matroh_pharm_industry', nameAr: 'الصيدلة الصناعية', nameEn: 'Pharmaceutical Industry'),
      ],
    ),

    // ============================================================
    // 27. كلية العلوم بمطروح (فرع)
    // ============================================================
    FacultyData(
      id: 'science_matroh',
      nameAr: 'كلية العلوم بمطروح',
      nameEn: 'Faculty of Science - Matrouh Branch',
      departments: [
        DepartmentData(id: 'matroh_physics', nameAr: 'الفيزياء', nameEn: 'Physics'),
        DepartmentData(id: 'matroh_chemistry', nameAr: 'الكيمياء', nameEn: 'Chemistry'),
        DepartmentData(id: 'matroh_mathematics', nameAr: 'الرياضيات', nameEn: 'Mathematics'),
        DepartmentData(id: 'matroh_geology', nameAr: 'الجيولوجيا', nameEn: 'Geology'),
        DepartmentData(id: 'matroh_zoology', nameAr: 'علم الحيوان', nameEn: 'Zoology'),
        DepartmentData(id: 'matroh_botany', nameAr: 'علم النبات', nameEn: 'Botany'),
        DepartmentData(id: 'matroh_microbiology_science', nameAr: 'الميكروبيولوجيا', nameEn: 'Microbiology'),
      ],
    ),
  ];

  // ============================================================
  // 🔧 دوال مساعدة
  // ============================================================

  /// ✅ جلب كلية بالـ id
  static FacultyData? getFacultyById(String id) {
    try {
      return faculties.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  /// ✅ جلب اسم الكلية بالـ id مع دعم اللغة
  static String getFacultyNameById(String id, {bool isArabic = true}) {
    final faculty = getFacultyById(id);
    if (faculty == null) return '';
    return isArabic ? faculty.nameAr : faculty.nameEn;
  }

  /// ✅ جلب أقسام كلية معينة بالـ id
  static List<DepartmentData> getDepartmentsByFacultyId(String facultyId) {
    final faculty = getFacultyById(facultyId);
    return faculty?.departments ?? [];
  }

  /// ✅ جلب قسم بالـ id داخل كلية معينة
  static DepartmentData? getDepartmentById({
    required String facultyId,
    required String departmentId,
  }) {
    final departments = getDepartmentsByFacultyId(facultyId);
    try {
      return departments.firstWhere((d) => d.id == departmentId);
    } catch (_) {
      return null;
    }
  }

  /// ✅ جلب اسم القسم بالـ id مع دعم اللغة
  static String getDepartmentNameById({
    required String facultyId,
    required String departmentId,
    bool isArabic = true,
  }) {
    final dept = getDepartmentById(facultyId: facultyId, departmentId: departmentId);
    if (dept == null) return '';
    return isArabic ? dept.nameAr : dept.nameEn;
  }

  /// ✅ البحث في الكليات بالاسم
  static List<FacultyData> searchFaculties(String query, {bool isArabic = true}) {
    final lowerQuery = query.toLowerCase();
    return faculties.where((f) {
      return isArabic
          ? f.nameAr.toLowerCase().contains(lowerQuery)
          : f.nameEn.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// ✅ البحث في الأقسام بالاسم داخل كلية
  static List<DepartmentData> searchDepartments({
    required String facultyId,
    required String query,
    bool isArabic = true,
  }) {
    final departments = getDepartmentsByFacultyId(facultyId);
    final lowerQuery = query.toLowerCase();
    return departments.where((d) {
      return isArabic
          ? d.nameAr.toLowerCase().contains(lowerQuery)
          : d.nameEn.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// ✅ هل نوع الإعلان يحتاج كلية؟
  static bool targetRoleRequiresFaculty(String targetRole) {
    return !['admin_manager'].contains(targetRole);
  }

  /// ✅ هل نوع الإعلان يحتاج قسم؟
  static bool targetRoleRequiresDepartment(String targetRole) {
    return ['head_department'].contains(targetRole);
  }
}

// ============================================================
// 📦 موديلات البيانات
// ============================================================

/// ✅ موديل الكلية
class FacultyData {
  final String id;
  final String nameAr;
  final String nameEn;
  final List<DepartmentData> departments;

  const FacultyData({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.departments,
  });
}

/// ✅ موديل القسم
class DepartmentData {
  final String id;
  final String nameAr;
  final String nameEn;

  const DepartmentData({
    required this.id,
    required this.nameAr,
    required this.nameEn,
  });
}