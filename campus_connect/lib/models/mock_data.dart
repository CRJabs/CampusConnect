class Department {
  final String id;
  final String name;
  final int newNotices;

  Department(this.id, this.name, this.newNotices);
}

class Notice {
  final String title;
  final String description;
  final String timeAgo;

  Notice(this.title, this.description, this.timeAgo);
}

class MockData {
  static List<Department> departments = [
    Department('1', 'College of Engineering', 10),
    Department('2', 'College of Allied Health Sciences', 5),
    Department('3', 'College of Business & Accountancy', 3),
    Department('4', 'College of Criminal Justice', 8),
    Department('5', 'College of Education', 2),
    Department('6', 'College of Arts & Sciences', 0),
  ];

  static List<Notice> sampleNotices = [
    Notice(
      'OJT Program Partnership Announced!',
      'We are excited to announce our partnership with local industries for the upcoming OJT program. Students will have the opportunity to gain hands-on experience in leading companies across Bohol.',
      '2 hours ago',
    ),
    Notice(
      'CSO Workshop Highlights',
      'The University of Bohol CSO Workshop and Recognition for Accredited Student Organizations lit up the UB IRC Auditorium with a day dedicated to leadership and collaboration.',
      '1 day ago',
    ),
  ];

  static Map<String, String> faqs = {
    'How do I enroll?':
        'Online enrollment is available via the student portal. Ensure you have your clearance from the previous semester.',
    'Where is the UB Clinic?':
        'The UB Clinic is located on the ground floor of the Main Building, near the Registrar\'s office.',
    'How can I apply for a scholarship?':
        'Visit the Scholarship Office at the Student Affairs building with your latest report card and income tax return of your parents.',
    'What are the library hours?':
        'The library is open from 7:00 AM to 9:00 PM, Monday through Saturday.',
    'Where can I pay my tuition?':
        'Tuition can be paid at the Cashier\'s Office on the 2nd floor, or online via supported bank transfers.',
  };
}
