/// ✅ الإدارات والوظائف الإدارية بجامعة المنصورة
/// تستخدم عند اختيار نوع الإعلان = admin_manager
class AdministrativeRolesData {

  /// ✅ جميع الإدارات العامة بالجامعة
  static const List<AdminDepartmentData> departments = [

    // ============================================================
    // 1. قطاع الشؤون الإدارية والمالية
    // ============================================================
    AdminDepartmentData(
      id: 'financial_admin',
      nameAr: 'قطاع الشؤون الإدارية والمالية',
      nameEn: 'Administrative & Financial Affairs Sector',
      subDepartments: [
        AdminSubDepartmentData(id: 'university_secretary', nameAr: 'أمين عام الجامعة', nameEn: 'University Secretary General'),
        AdminSubDepartmentData(id: 'assistant_secretary', nameAr: 'مساعد أمين عام الجامعة', nameEn: 'Assistant Secretary General'),
        AdminSubDepartmentData(id: 'financial_affairs', nameAr: 'الإدارة العامة للشؤون المالية', nameEn: 'General Financial Affairs Department'),
        AdminSubDepartmentData(id: 'budget', nameAr: 'إدارة الميزانية والحسابات', nameEn: 'Budget & Accounts Department'),
        AdminSubDepartmentData(id: 'procurement', nameAr: 'إدارة المشتريات والمناقصات', nameEn: 'Procurement & Tenders Department'),
        AdminSubDepartmentData(id: 'stores', nameAr: 'إدارة المخازن العامة', nameEn: 'General Stores Department'),
        AdminSubDepartmentData(id: 'assets', nameAr: 'إدارة أصول الجامعة وممتلكاتها', nameEn: 'University Assets Department'),
      ],
    ),

    // ============================================================
    // 2. قطاع شؤون العاملين
    // ============================================================
    AdminDepartmentData(
      id: 'hr_sector',
      nameAr: 'قطاع شؤون العاملين',
      nameEn: 'Human Resources Sector',
      subDepartments: [
        AdminSubDepartmentData(id: 'hr_general', nameAr: 'الإدارة العامة لشؤون العاملين', nameEn: 'General HR Department'),
        AdminSubDepartmentData(id: 'hr_appointments', nameAr: 'إدارة التعيينات والترقيات', nameEn: 'Appointments & Promotions Department'),
        AdminSubDepartmentData(id: 'hr_salaries', nameAr: 'إدارة المرتبات والأجور', nameEn: 'Salaries & Wages Department'),
        AdminSubDepartmentData(id: 'hr_social_insurance', nameAr: 'إدارة التأمينات الاجتماعية', nameEn: 'Social Insurance Department'),
        AdminSubDepartmentData(id: 'hr_pensions', nameAr: 'إدارة المعاشات', nameEn: 'Pensions Department'),
        AdminSubDepartmentData(id: 'hr_medical', nameAr: 'إدارة الرعاية الطبية للعاملين', nameEn: 'Employee Medical Care Department'),
        AdminSubDepartmentData(id: 'hr_training', nameAr: 'إدارة التدريب والتأهيل', nameEn: 'Training & Qualification Department'),
        AdminSubDepartmentData(id: 'hr_complaints', nameAr: 'إدارة شكاوى العاملين', nameEn: 'Employee Complaints Department'),
      ],
    ),

    // ============================================================
    // 3. قطاع شؤون الطلاب
    // ============================================================
    AdminDepartmentData(
      id: 'student_affairs_sector',
      nameAr: 'قطاع شؤون الطلاب',
      nameEn: 'Student Affairs Sector',
      subDepartments: [
        AdminSubDepartmentData(id: 'student_general', nameAr: 'الإدارة العامة لشؤون الطلاب', nameEn: 'General Student Affairs Department'),
        AdminSubDepartmentData(id: 'admissions', nameAr: 'إدارة التنسيق والقبول', nameEn: 'Admissions & Registration Department'),
        AdminSubDepartmentData(id: 'student_records', nameAr: 'إدارة سجلات الطلاب', nameEn: 'Student Records Department'),
        AdminSubDepartmentData(id: 'student_activities', nameAr: 'إدارة الأنشطة الطلابية', nameEn: 'Student Activities Department'),
        AdminSubDepartmentData(id: 'student_welfare', nameAr: 'إدارة رعاية الشباب', nameEn: 'Youth Welfare Department'),
        AdminSubDepartmentData(id: 'student_services', nameAr: 'إدارة الخدمات الطلابية', nameEn: 'Student Services Department'),
        AdminSubDepartmentData(id: 'graduates', nameAr: 'إدارة شؤون الخريجين', nameEn: 'Graduates Affairs Department'),
        AdminSubDepartmentData(id: 'student_exams', nameAr: 'إدارة شؤون الامتحانات', nameEn: 'Examinations Affairs Department'),
        AdminSubDepartmentData(id: 'student_missions', nameAr: 'إدارة البعثات والإيفادات', nameEn: 'Missions & Delegations Department'),
      ],
    ),

    // ============================================================
    // 4. قطاع الدراسات العليا والبحوث
    // ============================================================
    AdminDepartmentData(
      id: 'postgrad_sector',
      nameAr: 'قطاع الدراسات العليا والبحوث',
      nameEn: 'Postgraduate Studies & Research Sector',
      subDepartments: [
        AdminSubDepartmentData(id: 'postgrad_general', nameAr: 'الإدارة العامة للدراسات العليا', nameEn: 'General Postgraduate Studies Department'),
        AdminSubDepartmentData(id: 'postgrad_registration', nameAr: 'إدارة قيد طلاب الدراسات العليا', nameEn: 'Postgraduate Registration Department'),
        AdminSubDepartmentData(id: 'postgrad_exams', nameAr: 'إدارة امتحانات الدراسات العليا', nameEn: 'Postgraduate Examinations Department'),
        AdminSubDepartmentData(id: 'thesis_disputes', nameAr: 'إدارة المناقشات والمحكمين', nameEn: 'Thesis Defense & Reviewers Department'),
        AdminSubDepartmentData(id: 'research_grants', nameAr: 'إدارة المنح والباحثين', nameEn: 'Research Grants Department'),
        AdminSubDepartmentData(id: 'research_projects', nameAr: 'إدارة مشروعات البحث العلمي', nameEn: 'Research Projects Department'),
        AdminSubDepartmentData(id: 'scientific_publications', nameAr: 'إدارة النشر العلمي', nameEn: 'Scientific Publications Department'),
        AdminSubDepartmentData(id: 'conferences_org', nameAr: 'إدارة تنظيم المؤتمرات', nameEn: 'Conferences Organization Department'),
        AdminSubDepartmentData(id: 'patents', nameAr: 'إدارة براءات الاختراع والتسجيل', nameEn: 'Patents & Registration Department'),
        AdminSubDepartmentData(id: 'university_theses', nameAr: 'إدارة الرسائل الجامعية', nameEn: 'University Theses Department'),
      ],
    ),

    // ============================================================
    // 5. قطاع خدمة المجتمع وتنمية البيئة
    // ============================================================
    AdminDepartmentData(
      id: 'community_sector',
      nameAr: 'قطاع خدمة المجتمع وتنمية البيئة',
      nameEn: 'Community Service & Environmental Development Sector',
      subDepartments: [
        AdminSubDepartmentData(id: 'community_general', nameAr: 'الإدارة العامة لخدمة المجتمع', nameEn: 'General Community Service Department'),
        AdminSubDepartmentData(id: 'continuing_edu', nameAr: 'إدارة التعليم المستمر', nameEn: 'Continuing Education Department'),
        AdminSubDepartmentData(id: 'community_programs', nameAr: 'إدارة البرامج المجتمعية', nameEn: 'Community Programs Department'),
        AdminSubDepartmentData(id: 'environment_dev', nameAr: 'إدارة تنمية البيئة', nameEn: 'Environmental Development Department'),
        AdminSubDepartmentData(id: 'special_centers', nameAr: 'إدارة المراكز الخاصة', nameEn: 'Special Centers Department'),
        AdminSubDepartmentData(id: 'consultations', nameAr: 'إدارة الاستشارات والخدمات الفنية', nameEn: 'Consultations & Technical Services Department'),
      ],
    ),

    // ============================================================
    // 6. قطاع تكنولوجيا المعلومات
    // ============================================================
    AdminDepartmentData(
      id: 'it_sector',
      nameAr: 'قطاع تكنولوجيا المعلومات والاتصالات',
      nameEn: 'ICT Sector',
      subDepartments: [
        AdminSubDepartmentData(id: 'it_center', nameAr: 'مركز تكنولوجيا المعلومات', nameEn: 'Information Technology Center'),
        AdminSubDepartmentData(id: 'networks_admin', nameAr: 'إدارة الشبكات والبنية التحتية', nameEn: 'Networks & Infrastructure Department'),
        AdminSubDepartmentData(id: 'systems_dev', nameAr: 'إدارة تطوير الأنظمة', nameEn: 'Systems Development Department'),
        AdminSubDepartmentData(id: 'databases', nameAr: 'إدارة قواعد البيانات', nameEn: 'Databases Administration Department'),
        AdminSubDepartmentData(id: 'cybersecurity', nameAr: 'إدارة الأمن السيبراني', nameEn: 'Cybersecurity Department'),
        AdminSubDepartmentData(id: 'tech_support', nameAr: 'إدارة الدعم الفني', nameEn: 'Technical Support Department'),
        AdminSubDepartmentData(id: 'digital_transformation', nameAr: 'إدارة التحول الرقمي', nameEn: 'Digital Transformation Department'),
        AdminSubDepartmentData(id: 'university_portal', nameAr: 'إدارة بوابة الجامعة الإلكترونية', nameEn: 'University Portal Administration'),
        AdminSubDepartmentData(id: 'e_learning', nameAr: 'إدارة التعلم الإلكتروني', nameEn: 'E-Learning Department'),
        AdminSubDepartmentData(id: 'data_center', nameAr: 'إدارة مركز البيانات', nameEn: 'Data Center Department'),
      ],
    ),

    // ============================================================
    // 7. قطاع الأمن والسلامة
    // ============================================================
    AdminDepartmentData(
      id: 'security_sector',
      nameAr: 'قطاع الأمن والسلامة',
      nameEn: 'Security & Safety Sector',
      subDepartments: [
        AdminSubDepartmentData(id: 'security_general', nameAr: 'الإدارة العامة للأمن', nameEn: 'General Security Department'),
        AdminSubDepartmentData(id: 'campus_security', nameAr: 'إدارة أمن المباني والحراسة', nameEn: 'Campus Security Department'),
        AdminSubDepartmentData(id: 'traffic', nameAr: 'إدارة المرور وانتظار السيارات', nameEn: 'Traffic & Parking Department'),
        AdminSubDepartmentData(id: 'safety', nameAr: 'إدارة السلامة والصحة المهنية', nameEn: 'Occupational Health & Safety Department'),
        AdminSubDepartmentData(id: 'fire_safety', nameAr: 'إدارة الدفاع المدني والحماية من الحرائق', nameEn: 'Fire Protection & Civil Defense Department'),
        AdminSubDepartmentData(id: 'surveillance', nameAr: 'إدارة كاميرات المراقبة', nameEn: 'Surveillance Systems Department'),
        AdminSubDepartmentData(id: 'investigations', nameAr: 'إدارة التحقيقات', nameEn: 'Investigations Department'),
      ],
    ),

    // ============================================================
    // 8. قطاع الخدمات العامة والصيانة
    // ============================================================
    AdminDepartmentData(
      id: 'services_sector',
      nameAr: 'قطاع الخدمات العامة والصيانة',
      nameEn: 'General Services & Maintenance Sector',
      subDepartments: [
        AdminSubDepartmentData(id: 'services_general', nameAr: 'الإدارة العامة للخدمات', nameEn: 'General Services Department'),
        AdminSubDepartmentData(id: 'maintenance', nameAr: 'إدارة الصيانة العامة', nameEn: 'General Maintenance Department'),
        AdminSubDepartmentData(id: 'electrical_maintenance', nameAr: 'إدارة الصيانة الكهربية', nameEn: 'Electrical Maintenance Department'),
        AdminSubDepartmentData(id: 'plumbing', nameAr: 'إدارة السباكة والصرف الصحي', nameEn: 'Plumbing & Sanitation Department'),
        AdminSubDepartmentData(id: 'carpentry', nameAr: 'إدارة النجارة والأثاث', nameEn: 'Carpentry & Furniture Department'),
        AdminSubDepartmentData(id: 'cleaning', nameAr: 'إدارة النظافة العامة', nameEn: 'General Cleaning Department'),
        AdminSubDepartmentData(id: 'landscaping', nameAr: 'إدارة تشجير وزينة الحدائق', nameEn: 'Landscaping & Gardens Department'),
        AdminSubDepartmentData(id: 'pest_control', nameAr: 'إدارة مكافحة الحشرات والقوارض', nameEn: 'Pest Control Department'),
      ],
    ),

    // ============================================================
    // 9. قطاع شؤون المكتبات
    // ============================================================
    AdminDepartmentData(
      id: 'libraries_sector',
      nameAr: 'قطاع شؤون المكتبات',
      nameEn: 'Libraries Affairs Sector',
      subDepartments: [
        AdminSubDepartmentData(id: 'central_library', nameAr: 'مكتبة الجامعة المركزية', nameEn: 'Central University Library'),
        AdminSubDepartmentData(id: 'digital_library', nameAr: 'المكتبة الرقمية', nameEn: 'Digital Library'),
        AdminSubDepartmentData(id: 'library_cataloging', nameAr: 'إدارة الفهرسة والتصنيف', nameEn: 'Cataloging & Classification Department'),
        AdminSubDepartmentData(id: 'library_acquisitions', nameAr: 'إدارة الإيداع والاستلام', nameEn: 'Acquisitions Department'),
        AdminSubDepartmentData(id: 'library_lending', nameAr: 'إدارة الإعارة والمراجع', nameEn: 'Lending & References Department'),
        AdminSubDepartmentData(id: 'rare_books', nameAr: 'إدارة الكتب والوثائق النادرة', nameEn: 'Rare Books & Documents Department'),
        AdminSubDepartmentData(id: 'faculty_libraries', nameAr: 'إدارة مكتبات الكليات', nameEn: 'Faculty Libraries Supervision'),
      ],
    ),

    // ============================================================
    // 10. قطاع الشؤون القانونية
    // ============================================================
    AdminDepartmentData(
      id: 'legal_sector',
      nameAr: 'قطاع الشؤون القانونية',
      nameEn: 'Legal Affairs Sector',
      subDepartments: [
        AdminSubDepartmentData(id: 'legal_general', nameAr: 'الإدارة العامة للشؤون القانونية', nameEn: 'General Legal Affairs Department'),
        AdminSubDepartmentData(id: 'legal_opinions', nameAr: 'إدارة إبداء الرأي القانوني', nameEn: 'Legal Opinions Department'),
        AdminSubDepartmentData(id: 'litigation', nameAr: 'إدارة النزاعات والتقاضي', nameEn: 'Litigation Department'),
        AdminSubDepartmentData(id: 'contracts', nameAr: 'إدارة العقود والاتفاقيات', nameEn: 'Contracts & Agreements Department'),
        AdminSubDepartmentData(id: 'legislation', nameAr: 'إدارة التشريعات واللوائح', nameEn: 'Legislation & Regulations Department'),
      ],
    ),

    // ============================================================
    // 11. قطاع التخطيط والمتابعة
    // ============================================================
    AdminDepartmentData(
      id: 'planning_sector',
      nameAr: 'قطاع التخطيط والمتابعة',
      nameEn: 'Planning & Follow-up Sector',
      subDepartments: [
        AdminSubDepartmentData(id: 'planning_general', nameAr: 'الإدارة العامة للتخطيط', nameEn: 'General Planning Department'),
        AdminSubDepartmentData(id: 'strategic_planning', nameAr: 'إدارة التخطيط الاستراتيجي', nameEn: 'Strategic Planning Department'),
        AdminSubDepartmentData(id: 'performance_followup', nameAr: 'إدارة متابعة الأداء', nameEn: 'Performance Follow-up Department'),
        AdminSubDepartmentData(id: 'statistics_planning', nameAr: 'إدارة الإحصاء والتقارير', nameEn: 'Statistics & Reports Department'),
        AdminSubDepartmentData(id: 'quality_assurance', nameAr: 'إدارة ضمان الجودة بالجامعة', nameEn: 'University Quality Assurance Department'),
        AdminSubDepartmentData(id: 'accreditation', nameAr: 'إدارة الاعتماد المؤسسي', nameEn: 'Institutional Accreditation Department'),
        AdminSubDepartmentData(id: 'project_management', nameAr: 'إدارة إعداد وتنفيذ المشروعات', nameEn: 'Project Management Department'),
      ],
    ),

    // ============================================================
    // 12. قطاع العلاقات العامة والإعلام
    // ============================================================
    AdminDepartmentData(
      id: 'media_sector',
      nameAr: 'قطاع العلاقات العامة والإعلام',
      nameEn: 'Public Relations & Media Sector',
      subDepartments: [
        AdminSubDepartmentData(id: 'media_general', nameAr: 'الإدارة العامة للإعلام', nameEn: 'General Media Department'),
        AdminSubDepartmentData(id: 'pr', nameAr: 'إدارة العلاقات العامة', nameEn: 'Public Relations Department'),
        AdminSubDepartmentData(id: 'press', nameAr: 'إدارة الصحافة', nameEn: 'Press Department'),
        AdminSubDepartmentData(id: 'social_media', nameAr: 'إدارة التواصل الاجتماعي', nameEn: 'Social Media Department'),
        AdminSubDepartmentData(id: 'protocol', nameAr: 'إدارة البروتوكول والاستقبال', nameEn: 'Protocol & Reception Department'),
        AdminSubDepartmentData(id: 'university_newsletter', nameAr: 'إدارة نشرة الجامعة', nameEn: 'University Newsletter Department'),
        AdminSubDepartmentData(id: 'photography', nameAr: 'إدارة التصوير والمرئيات', nameEn: 'Photography & Visual Media Department'),
        AdminSubDepartmentData(id: 'events', nameAr: 'إدارة تنظيم الفعاليات والمؤتمرات', nameEn: 'Events & Conferences Organization Department'),
      ],
    ),

    // ============================================================
    // 13. قطاع الشؤون الطبية
    // ============================================================
    AdminDepartmentData(
      id: 'medical_sector',
      nameAr: 'قطاع الشؤون الطبية والصحية',
      nameEn: 'Medical & Health Affairs Sector',
      subDepartments: [
        AdminSubDepartmentData(id: 'medical_general', nameAr: 'الإدارة العامة للشؤون الطبية', nameEn: 'General Medical Affairs Department'),
        AdminSubDepartmentData(id: 'university_hospital', nameAr: 'مستشفى الجامعة', nameEn: 'University Hospital Administration'),
        AdminSubDepartmentData(id: 'medical_labs', nameAr: 'إدارة المعامل الطبية', nameEn: 'Medical Laboratories Department'),
        AdminSubDepartmentData(id: 'radiology_admin', nameAr: 'إدارة الأشعة التشخيصية', nameEn: 'Diagnostic Radiology Administration'),
        AdminSubDepartmentData(id: 'pharmacy_admin', nameAr: 'إدارة الصيدلية المركزية', nameEn: 'Central Pharmacy Administration'),
        AdminSubDepartmentData(id: 'blood_bank', nameAr: 'إدارة بنك الدم', nameEn: 'Blood Bank Administration'),
        AdminSubDepartmentData(id: 'infection_control', nameAr: 'إدارة مكافحة العدوى', nameEn: 'Infection Control Department'),
        AdminSubDepartmentData(id: 'medical_supplies', nameAr: 'إدارة المستلزمات الطبية', nameEn: 'Medical Supplies Department'),
        AdminSubDepartmentData(id: 'medical_eng', nameAr: 'إدارة الهندسة الطبية', nameEn: 'Biomedical Engineering Department'),
        AdminSubDepartmentData(id: 'emergency_admin', nameAr: 'إدارة قسم الطوارئ', nameEn: 'Emergency Department Administration'),
        AdminSubDepartmentData(id: 'icu_admin', nameAr: 'إدارة الرعايات المركزة', nameEn: 'ICU Administration'),
        AdminSubDepartmentData(id: 'operations', nameAr: 'إدارة غرف العمليات', nameEn: 'Operating Rooms Administration'),
        AdminSubDepartmentData(id: 'medical_records', nameAr: 'إدارة السجلات الطبية', nameEn: 'Medical Records Department'),
        AdminSubDepartmentData(id: 'medical_statistics', nameAr: 'إدارة الإحصاء الطبي', nameEn: 'Medical Statistics Department'),
      ],
    ),

    // ============================================================
    // 14. قطاع الإسكان والطالبات
    // ============================================================
    AdminDepartmentData(
      id: 'housing_sector',
      nameAr: 'قطاع الإسكان والمباني',
      nameEn: 'Housing & Buildings Sector',
      subDepartments: [
        AdminSubDepartmentData(id: 'housing_general', nameAr: 'الإدارة العامة للإسكان', nameEn: 'General Housing Department'),
        AdminSubDepartmentData(id: 'male_hostels', nameAr: 'إدارة المدن الجامعية للطلاب', nameEn: 'Male Student Hostels Administration'),
        AdminSubDepartmentData(id: 'female_hostels', nameAr: 'إدارة المدن الجامعية للطالبات', nameEn: 'Female Student Hostels Administration'),
        AdminSubDepartmentData(id: 'housing_services', nameAr: 'إدارة خدمات الإسكان', nameEn: 'Housing Services Department'),
        AdminSubDepartmentData(id: 'buildings', nameAr: 'إدارة المباني والتعمير', nameEn: 'Buildings & Construction Department'),
        AdminSubDepartmentData(id: 'engineering_office', nameAr: 'المكتب الهندسي بالجامعة', nameEn: 'University Engineering Office'),
      ],
    ),

    // ============================================================
    // 15. قطاع النقل والمواصلات
    // ============================================================
    AdminDepartmentData(
      id: 'transport_sector',
      nameAr: 'قطاع النقل والمواصلات',
      nameEn: 'Transportation Sector',
      subDepartments: [
        AdminSubDepartmentData(id: 'transport_general', nameAr: 'الإدارة العامة للنقل', nameEn: 'General Transportation Department'),
        AdminSubDepartmentData(id: 'university_buses', nameAr: 'إدارة سيارات الجامعة', nameEn: 'University Buses Department'),
        AdminSubDepartmentData(id: 'vehicle_maintenance', nameAr: 'إدارة صيانة المركبات', nameEn: 'Vehicle Maintenance Department'),
        AdminSubDepartmentData(id: 'fuel', nameAr: 'إدارة الوقود والتموين', nameEn: 'Fuel & Supply Department'),
      ],
    ),

    // ============================================================
    // 16. قطاع شؤون أعضاء هيئة التدريس
    // ============================================================
    AdminDepartmentData(
      id: 'faculty_staff_sector',
      nameAr: 'قطاع شؤون أعضاء هيئة التدريس ومعاونيهم',
      nameEn: 'Faculty Staff Affairs Sector',
      subDepartments: [
        AdminSubDepartmentData(id: 'staff_general', nameAr: 'الإدارة العامة لشؤون أعضاء هيئة التدريس', nameEn: 'General Faculty Staff Department'),
        AdminSubDepartmentData(id: 'staff_appointments', nameAr: 'إدارة تعيينات هيئة التدريس', nameEn: 'Faculty Staff Appointments'),
        AdminSubDepartmentData(id: 'staff_promotions', nameAr: 'إدارة الترقيات العلمية', nameEn: 'Scientific Promotions Department'),
        AdminSubDepartmentData(id: 'staff_delegations', nameAr: 'إادة الإعارات والإيفادات العلمية', nameEn: 'Scientific Delegations Department'),
        AdminSubDepartmentData(id: 'staff_evaluations', nameAr: 'إدارة تقييم أداء هيئة التدريس', nameEn: 'Faculty Staff Evaluation Department'),
        AdminSubDepartmentData(id: 'staff_disputes', nameAr: 'إادة المنازعات والتظلمات', nameEn: 'Disputes & Grievances Department'),
        AdminSubDepartmentData(id: 'staff_assistants', nameAr: 'إدارة شؤون المعيدين والمباحثين', nameEn: 'Teaching Assistants Affairs'),
      ],
    ),

    // ============================================================
    // 17. قطاع الطباعة والنشر
    // ============================================================
    AdminDepartmentData(
      id: 'printing_sector',
      nameAr: 'قطاع الطباعة والنشر الجامعي',
      nameEn: 'Printing & Publishing Sector',
      subDepartments: [
        AdminSubDepartmentData(id: 'printing_general', nameAr: 'الإدارة العامة للطباعة', nameEn: 'General Printing Department'),
        AdminSubDepartmentData(id: 'press_center', nameAr: 'مركز الطباعة والنشر', nameEn: 'Printing & Publishing Center'),
        AdminSubDepartmentData(id: 'design', nameAr: 'إدارة التصميم والإخراج الفني', nameEn: 'Design & Layout Department'),
        AdminSubDepartmentData(id: 'distribution', nameAr: 'إدارة التوزيع', nameEn: 'Distribution Department'),
      ],
    ),

    // ============================================================
    // 18. قطاع المراكز والوحدات ذات الطابع الخاص
    // ============================================================
    AdminDepartmentData(
      id: 'special_centers_sector',
      nameAr: 'قطاع المراكز والوحدات ذات الطابع الخاص',
      nameEn: 'Special Centers & Units Sector',
      subDepartments: [
        AdminSubDepartmentData(id: 'genetic_eng_center', nameAr: 'مركز الهندسة الوراثية والتقنية الحيوية', nameEn: 'Genetic Engineering & Biotechnology Center'),
        AdminSubDepartmentData(id: 'laser_center', nameAr: 'مركز الليزر وال تطبيقاته', nameEn: 'Laser & Applications Center'),
        AdminSubDepartmentData(id: 'env_studies_center', nameAr: 'مركز الدراسات البيئية', nameEn: 'Environmental Studies Center'),
        AdminSubDepartmentData(id: 'gis_center', nameAr: 'مركز نظم المعلومات الجغرافية', nameEn: 'GIS Center'),
        AdminSubDepartmentData(id: 'language_center', nameAr: 'مركز تعليم اللغات', nameEn: 'Language Center'),
        AdminSubDepartmentData(id: 'consultation_center', nameAr: 'مركز الاستشارات والدراسات', nameEn: 'Consultations & Studies Center'),
        AdminSubDepartmentData(id: 'tech_incubator', nameAr: 'حاضنة تكنولوجيا الأعمال', nameEn: 'Technology Incubator'),
        AdminSubDepartmentData(id: 'innovation_center', nameAr: 'مركز الابتكار وريادة الأعمال', nameEn: 'Innovation & Entrepreneurship Center'),
        AdminSubDepartmentData(id: 'nanotech_center', nameAr: 'مركز علوم وتكنولوجيا النانو', nameEn: 'Nanoscience & Technology Center'),
        AdminSubDepartmentData(id: 'energy_center', nameAr: 'مركز الطاقة الجديدة والمتجددة', nameEn: 'New & Renewable Energy Center'),
      ],
    ),

    // ============================================================
    // 19. قطاع التعليم المفتوح والتعليم عن بعد
    // ============================================================
    AdminDepartmentData(
      id: 'open_education_sector',
      nameAr: 'قطاع التعليم المفتوح',
      nameEn: 'Open Education Sector',
      subDepartments: [
        AdminSubDepartmentData(id: 'open_edu_general', nameAr: 'الإدارة العامة للتعليم المفتوح', nameEn: 'General Open Education Department'),
        AdminSubDepartmentData(id: 'open_edu_admission', nameAr: 'إدارة قبول التعليم المفتوح', nameEn: 'Open Education Admissions'),
        AdminSubDepartmentData(id: 'open_edu_exams', nameAr: 'إدارة امتحانات التعليم المفتوح', nameEn: 'Open Education Examinations'),
        AdminSubDepartmentData(id: 'open_edu_programs', nameAr: 'إدارة البرامج الدراسية', nameEn: 'Study Programs Department'),
        AdminSubDepartmentData(id: 'distance_learning', nameAr: 'إدارة التعليم عن بعد', nameEn: 'Distance Learning Department'),
      ],
    ),

    // ============================================================
    // 20. قطاع رعاية ذوي الاحتياجات الخاصة
    // ============================================================
    AdminDepartmentData(
      id: 'special_needs_sector',
      nameAr: 'قطاع رعاية ذوي الإعاقة والاحتياجات الخاصة',
      nameEn: 'Special Needs Care Sector',
      subDepartments: [
        AdminSubDepartmentData(id: 'special_needs_general', nameAr: 'الإدارة العامة لرعاية ذوي الاحتياجات الخاصة', nameEn: 'General Special Needs Department'),
        AdminSubDepartmentData(id: 'accessibility', nameAr: 'إدارة سهولة الوصول', nameEn: 'Accessibility Department'),
        AdminSubDepartmentData(id: 'rehabilitation', nameAr: 'إدارة التأهيل والدعم الأكاديمي', nameEn: 'Rehabilitation & Academic Support'),
        AdminSubDepartmentData(id: 'assistive_tech', nameAr: 'إدارة التقنيات المساعدة', nameEn: 'Assistive Technology Department'),
      ],
    ),

    // ============================================================
    // 21. قطاع الشؤون الدولية والبعثات
    // ============================================================
    AdminDepartmentData(
      id: 'international_sector',
      nameAr: 'قطاع الشؤون الدولية والتعاون العلمي',
      nameEn: 'International Affairs & Scientific Cooperation Sector',
      subDepartments: [
        AdminSubDepartmentData(id: 'international_general', nameAr: 'الإدارة العامة للشؤون الدولية', nameEn: 'General International Affairs Department'),
        AdminSubDepartmentData(id: 'agreements', nameAr: 'إدارة الاتفاقيات الدولية', nameEn: 'International Agreements Department'),
        AdminSubDepartmentData(id: 'cultural_exchange', nameAr: 'إدارة التبادل الثقافي', nameEn: 'Cultural Exchange Department'),
        AdminSubDepartmentData(id: 'foreign_students', nameAr: 'إدارة شؤون الطلاب الوافدين', nameEn: 'Foreign Students Affairs'),
        AdminSubDepartmentData(id: 'international_programs', nameAr: 'إدارة البرامج الدولية المشتركة', nameEn: 'Joint International Programs'),
        AdminSubDepartmentData(id: 'scholarships', nameAr: 'إدارة المنح الدولية', nameEn: 'International Scholarships Department'),
      ],
    ),

    // ============================================================
    // 22. قطاع الموارد البشرية والتدريب
    // ============================================================
    AdminDepartmentData(
      id: 'capacity_building_sector',
      nameAr: 'قطاع بناء القدرات والتدريب',
      nameEn: 'Capacity Building & Training Sector',
      subDepartments: [
        AdminSubDepartmentData(id: 'training_center', nameAr: 'مركز التدريب والتطوير', nameEn: 'Training & Development Center'),
        AdminSubDepartmentData(id: 'leadership_dev', nameAr: 'إدارة تطوير القيادات', nameEn: 'Leadership Development Department'),
        AdminSubDepartmentData(id: 'professional_dev', nameAr: 'إدارة التطوير المهني', nameEn: 'Professional Development Department'),
        AdminSubDepartmentData(id: 'skills_training', nameAr: 'إدارة تدريب المهارات', nameEn: 'Skills Training Department'),
        AdminSubDepartmentData(id: 'workshops', nameAr: 'إدارة الورش وبرامج التأهيل', nameEn: 'Workshops & Qualification Programs'),
      ],
    ),

    // ============================================================
    // 23. قطاع الشؤون المالية والمحاسبة
    // ============================================================
    AdminDepartmentData(
      id: 'accounting_sector',
      nameAr: 'قطاع الحسابات والمراجعة الداخلية',
      nameEn: 'Accounts & Internal Audit Sector',
      subDepartments: [
        AdminSubDepartmentData(id: 'accounts_general', nameAr: 'الإدارة العامة للحسابات', nameEn: 'General Accounts Department'),
        AdminSubDepartmentData(id: 'revenues', nameAr: 'إدارة الإيرادات والمحصلات', nameEn: 'Revenues & Collections Department'),
        AdminSubDepartmentData(id: 'expenditures', nameAr: 'إدارة المصروفات والصرف', nameEn: 'Expenditures Department'),
        AdminSubDepartmentData(id: 'internal_audit', nameAr: 'إدارة المراجعة الداخلية', nameEn: 'Internal Audit Department'),
        AdminSubDepartmentData(id: 'final_accounts', nameAr: 'إدارة الحسابات الختامية', nameEn: 'Final Accounts Department'),
        AdminSubDepartmentData(id: 'cost_accounting', nameAr: 'إدارة المحاسبة التكلفية', nameEn: 'Cost Accounting Department'),
      ],
    ),

    // ============================================================
    // 24. قطاع شؤون المتقاعدين
    // ============================================================
    AdminDepartmentData(
      id: 'retirees_sector',
      nameAr: 'قطاع شؤون المتقاعدين',
      nameEn: 'Retirees Affairs Sector',
      subDepartments: [
        AdminSubDepartmentData(id: 'retirees_general', nameAr: 'الإدارة العامة لشؤون المتقاعدين', nameEn: 'General Retirees Affairs Department'),
        AdminSubDepartmentData(id: 'retirees_papers', nameAr: 'إدارة أوراق ومعاشات المتقاعدين', nameEn: 'Retirees Papers & Pensions'),
        AdminSubDepartmentData(id: 'retirees_care', nameAr: 'إدارة رعاية المتقاعدين', nameEn: 'Retirees Care Department'),
      ],
    ),

    // ============================================================
    // 25. قطاع مراقبة الأداء المؤسسي
    // ============================================================
    AdminDepartmentData(
      id: 'performance_monitoring_sector',
      nameAr: 'قطاع مراقبة الأداء المؤسسي والمتابعة',
      nameEn: 'Institutional Performance Monitoring Sector',
      subDepartments: [
        AdminSubDepartmentData(id: 'kpi_general', nameAr: 'الإدارة العامة لمؤشرات الأداء', nameEn: 'General KPI Department'),
        AdminSubDepartmentData(id: 'kpi_measurement', nameAr: 'إدارة قياس الأداء', nameEn: 'Performance Measurement Department'),
        AdminSubDepartmentData(id: 'followup_reports', nameAr: 'إدارة التقارير الدورية', nameEn: 'Periodic Reports Department'),
        AdminSubDepartmentData(id: 'compliance', nameAr: 'إدارة الالتزام والمتابعة', nameEn: 'Compliance & Follow-up Department'),
      ],
    ),

    // ============================================================
    // 26. أمانة سر المجالس الجامعية
    // ============================================================
    AdminDepartmentData(
      id: 'councils_secretariat',
      nameAr: 'أمانة سر المجالس واللجان الجامعية',
      nameEn: 'University Councils & Committees Secretariat',
      subDepartments: [
        AdminSubDepartmentData(id: 'university_council', nameAr: 'أمانة سر مجلس الجامعة', nameEn: 'University Council Secretariat'),
        AdminSubDepartmentData(id: 'graduates_council', nameAr: 'أمانة سر مجلس الدراسات العليا', nameEn: 'Postgraduate Council Secretariat'),
        AdminSubDepartmentData(id: 'community_council', nameAr: 'أمانة سر مجلس خدمة المجتمع', nameEn: 'Community Service Council Secretariat'),
        AdminSubDepartmentData(id: 'scientific_council', nameAr: 'أمانة سر المجالس العلمية', nameEn: 'Scientific Councils Secretariat'),
        AdminSubDepartmentData(id: 'disciplinary_council', nameAr: 'أمانة سر مجالس التأديب', nameEn: 'Disciplinary Councils Secretariat'),
        AdminSubDepartmentData(id: 'committees_secretariat', nameAr: 'أمانة سر اللجان المشكلة', nameEn: 'Formed Committees Secretariat'),
      ],
    ),

    // ============================================================
    // 27. قطاع شؤون ذوي الوفيات والمعاشات
    // ============================================================
    AdminDepartmentData(
      id: 'welfare_sector',
      nameAr: 'قطاع الرعاية الاجتماعية',
      nameEn: 'Social Welfare Sector',
      subDepartments: [
        AdminSubDepartmentData(id: 'social_welfare', nameAr: 'إدارة الرعاية الاجتماعية', nameEn: 'Social Welfare Department'),
        AdminSubDepartmentData(id: 'orphans_care', nameAr: 'إدارة رعاية أسر الشهداء والمتوفين', nameEn: 'Martyrs & Deceased Families Care'),
        AdminSubDepartmentData(id: 'aid_relief', nameAr: 'إدارة المعونات والإغاثة', nameEn: 'Aid & Relief Department'),
        AdminSubDepartmentData(id: 'cooperative', nameAr: 'التعاونية المركزية', nameEn: 'Central Cooperative Society'),
      ],
    ),
  ];

  // ============================================================
  // 🔧 دوال مساعدة
  // ============================================================

  /// ✅ جلب إدارة بالـ id
  static AdminDepartmentData? getDepartmentById(String id) {
    try {
      return departments.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  /// ✅ جلب اسم الإدارة بالـ id مع دعم اللغة
  static String getDepartmentNameById(String id, {bool isArabic = true}) {
    final dept = getDepartmentById(id);
    if (dept == null) return '';
    return isArabic ? dept.nameAr : dept.nameEn;
  }

  /// ✅ جلب الإدارات الفرعية لإدارة معينة
  static List<AdminSubDepartmentData> getSubDepartmentsByDepartmentId(String departmentId) {
    final dept = getDepartmentById(departmentId);
    return dept?.subDepartments ?? [];
  }

  /// ✅ جلب إدارة فرعية بالـ id
  static AdminSubDepartmentData? getSubDepartmentById({
    required String departmentId,
    required String subDepartmentId,
  }) {
    final subs = getSubDepartmentsByDepartmentId(departmentId);
    try {
      return subs.firstWhere((s) => s.id == subDepartmentId);
    } catch (_) {
      return null;
    }
  }

  /// ✅ جلب اسم الإدارة الفرعية بالـ id مع دعم اللغة
  static String getSubDepartmentNameById({
    required String departmentId,
    required String subDepartmentId,
    bool isArabic = true,
  }) {
    final sub = getSubDepartmentById(
      departmentId: departmentId,
      subDepartmentId: subDepartmentId,
    );
    if (sub == null) return '';
    return isArabic ? sub.nameAr : sub.nameEn;
  }

  /// ✅ جلب جميع الإدارات الفرعية مسطحة (للفلاتر والبحث)
  static List<AdminSubDepartmentData> getAllSubDepartments() {
    final List<AdminSubDepartmentData> all = [];
    for (var dept in departments) {
      all.addAll(dept.subDepartments);
    }
    return all;
  }

  /// ✅ جلب جميع الإدارات الفرعية مع اسم القطاع الأب
  static List<Map<String, String>> getAllSubDepartmentsWithParent({bool isArabic = true}) {
    final List<Map<String, String>> result = [];
    for (var dept in departments) {
      final parentName = isArabic ? dept.nameAr : dept.nameEn;
      for (var sub in dept.subDepartments) {
        result.add({
          'subId': sub.id,
          'subName': isArabic ? sub.nameAr : sub.nameEn,
          'parentId': dept.id,
          'parentName': parentName,
        });
      }
    }
    return result;
  }

  /// ✅ البحث في الإدارات الرئيسية
  static List<AdminDepartmentData> searchDepartments(String query, {bool isArabic = true}) {
    final lowerQuery = query.toLowerCase();
    return departments.where((d) {
      return isArabic
          ? d.nameAr.toLowerCase().contains(lowerQuery)
          : d.nameEn.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// ✅ البحث في الإدارات الفرعية في قطاع معين
  static List<AdminSubDepartmentData> searchSubDepartments({
    required String departmentId,
    required String query,
    bool isArabic = true,
  }) {
    final subs = getSubDepartmentsByDepartmentId(departmentId);
    final lowerQuery = query.toLowerCase();
    return subs.where((s) {
      return isArabic
          ? s.nameAr.toLowerCase().contains(lowerQuery)
          : s.nameEn.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// ✅ البحث الشامل في كل الإدارات الفرعية
  static List<Map<String, String>> globalSearchSubDepartments(String query, {bool isArabic = true}) {
    final all = getAllSubDepartmentsWithParent(isArabic: isArabic);
    final lowerQuery = query.toLowerCase();
    return all.where((item) {
      return item['subName']!.toLowerCase().contains(lowerQuery) ||
          item['parentName']!.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}

// ============================================================
// 📦 موديلات البيانات
// ============================================================

/// ✅ موديل الإدارة الرئيسية (القطاع)
class AdminDepartmentData {
  final String id;
  final String nameAr;
  final String nameEn;
  final List<AdminSubDepartmentData> subDepartments;

  const AdminDepartmentData({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.subDepartments,
  });
}

/// ✅ موديل الإدارة الفرعية
class AdminSubDepartmentData {
  final String id;
  final String nameAr;
  final String nameEn;

  const AdminSubDepartmentData({
    required this.id,
    required this.nameAr,
    required this.nameEn,
  });
}