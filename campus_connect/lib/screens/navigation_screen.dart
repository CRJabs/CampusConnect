import 'package:flutter/material.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  bool _isSidebarCollapsed = false;
  String? _selectedBuilding;
  String? _selectedFloor;
  String _currentMapAsset = 'assets/campus_map.jpg';
  bool _isUsingPlaceholder = false;

  final List<Map<String, dynamic>> _buildings = [
    {
      'name': "Founders Building",
      'icon': Icons.school,
      'floors': [
        {
          'name': '1st Floor',
          'rooms': [
            {'code': '', 'name': 'Office of the Dean, College of Education'},
            {'code': '', 'name': 'Office of the Dean, College of Liberal Arts'},
            {'code': '', 'name': 'Founders Student Lounge'},
            {'code': '', 'name': 'UB Plaza'},
            {'code': '', 'name': 'Founders Building Entrance/Exit Gate'},
          ]
        },
        {
          'name': '2nd Floor',
          'rooms': [
            {'code': '', 'name': 'Experimental Psychology Laboratory'},
            {'code': '', 'name': 'Office of the Dean, Planning'},
            {'code': '', 'name': 'Office of Vice President for Academics'},
          ]
        },
        {
          'name': '3rd Floor',
          'rooms': [
            {'code': '', 'name': 'Music Room'},
            {'code': '', 'name': 'TLE Laboratory'},
            {'code': '', 'name': 'I.E. Laboratory'},
          ]
        },
      ]
    },
    {
      'name': "Achievers Building",
      'icon': Icons.emoji_events,
      'floors': [
        {
          'name': '1st Floor',
          'rooms': [
            {'code': '', 'name': 'Dental & Medical Clinic'},
            {'code': '', 'name': 'Hydraulic Laboratory'},
            {'code': '', 'name': 'Machine Shop'},
            {'code': '', 'name': 'AMT Laboratory'},
            {'code': '', 'name': 'AMT Office'},
            {'code': '', 'name': 'Soil Mechanics Laboratory'},
            {'code': '', 'name': 'Surveying Instrument Room'},
            {'code': '', 'name': 'Boiler'},
          ]
        },
        {
          'name': '2nd Floor',
          'rooms': [
            {'code': '', 'name': 'Office of the University Research Center'},
            {'code': '', 'name': 'Electrical Laboratory'},
            {'code': '', 'name': 'Electronics Laboratory'},
            {'code': '', 'name': 'Digital & Microprocessor Laboratory'},
            {'code': '', 'name': 'Mechanical Engineering Laboratory'},
          ]
        },
        {
          'name': '3rd Floor',
          'rooms': [
            {'code': '', 'name': 'Achievers Hall Conference Room'},
            {'code': '', 'name': 'Office of the Dean, College of Engineering, Technology, Architecture and Fine Arts'},
          ]
        },
      ]
    },
    {
      'name': 'Administration Building',
      'icon': Icons.business,
      'floors': [
        {
          'name': 'Basement',
          'rooms': [
            {'code': '', 'name': 'Instructional Media Center'},
            {'code': '', 'name': 'Electrical Control Room'},
            {'code': '', 'name': 'UBSSG Office'},
            {'code': '', 'name': 'Deans Office, College of Business & Accountancy'},
            {'code': '', 'name': 'Office of the Head Security & Safety Officer'},
            {'code': '', 'name': 'Civic Welfare Training Services (CWTS) Office'},
          ]
        },
        {
          'name': '1st Floor',
          'rooms': [
            {'code': '', 'name': 'Office of the President'},
            {'code': '', 'name': 'Office of the Vice President for Administration'},
            {'code': '', 'name': 'Office of the School Registrar'},
            {'code': '', 'name': 'Iluminadas Home'},
            {'code': '', 'name': 'Tourism Hospitality Management (THM) Laboratory'},
            {'code': '', 'name': 'Conference Room 1'},
          ]
        },
        {
          'name': '2nd Floor',
          'rooms': [
            {'code': '', 'name': 'Office of the Dean, College of Tourism Hospitality Management, Nutrition & Dietetics'},
            {'code': '', 'name': 'Office of the Dean, College of Pharmacy'},
            {'code': '', 'name': 'MIS Office'},
            {'code': '', 'name': 'Speech Clinic'},
            {'code': '', 'name': 'Computer Lab D (High School Computer Lab.)'},
          ]
        },
        {
          'name': '3rd Floor',
          'rooms': [
            {'code': '', 'name': 'Zoology Laboratory'},
            {'code': '', 'name': 'Botany Laboratory'},
            {'code': '', 'name': 'Computer Lab A, Lab. B, Lab. C'},
            {'code': '', 'name': 'Biochemistry Laboratory'},
          ]
        },
        {
          'name': '4th Floor',
          'rooms': [
            {'code': '', 'name': 'Dance Hall'},
            {'code': '', 'name': 'College Physics Laboratory'},
            {'code': '', 'name': 'College Chemistry Laboratory'},
          ]
        },
      ]
    },
    {
      'name': 'Admin Annex & GASA Bldg',
      'icon': Icons.business_center,
      'floors': [
        {
          'name': 'Basement',
          'rooms': [{'code': '', 'name': 'Purchasing Office'}]
        },
        {
          'name': '1st Floor',
          'rooms': [
            {'code': '', 'name': 'Conference Room 2'},
            {'code': '', 'name': 'Office of the Vice President for Finance'},
            {'code': '', 'name': 'Tellering'},
            {'code': '', 'name': 'Office of the Property Custodian'},
            {'code': '', 'name': 'Office of the Manager, General Services'},
          ]
        },
        {
          'name': '2nd Floor',
          'rooms': [
            {'code': '', 'name': 'High School Physics Laboratory'},
            {'code': '', 'name': 'High School Chemistry Laboratory'},
            {'code': '', 'name': 'High School TLE'},
          ]
        },
      ]
    },
    {
      'name': 'Information Resource Center',
      'icon': Icons.menu_book,
      'floors': [
        {
          'name': 'Basement',
          'rooms': [
            {'code': '', 'name': 'CYDEM Quarters (Janitorials)'},
            {'code': '', 'name': 'Vacant Classrooms'},
          ]
        },
        {
          'name': '1st Floor',
          'rooms': [
            {'code': '', 'name': 'Office of the Dean, Student Personnel Services'},
            {'code': '', 'name': 'Guidance'},
            {'code': '', 'name': 'Student Affairs Office'},
            {'code': '', 'name': 'Athletics Coordinator'},
            {'code': '', 'name': 'Office of the Dean, Graduate School and Professional Studies'},
            {'code': '', 'name': 'Graduate School'},
            {'code': '', 'name': 'Oral Defense Room'},
          ]
        },
        {
          'name': '2nd Floor',
          'rooms': [{'code': '', 'name': 'Main Library'}]
        },
        {
          'name': '3rd Floor',
          'rooms': [
            {'code': '', 'name': 'e-Library'},
            {'code': '', 'name': 'IRC Auditorium'},
            {'code': '', 'name': 'Periodical Library'},
          ]
        },
      ]
    },
    {
      'name': 'High School Building',
      'icon': Icons.auto_stories,
      'floors': [
        {
          'name': '1st Floor',
          'rooms': [
            {'code': '', 'name': 'Activity Center'},
          ]
        },
        {
          'name': '2nd Floor',
          'rooms': [
            {'code': '', 'name': 'Office of the Principal, Junior High School'},
            {'code': '', 'name': 'Guidance Office (High School)'},
          ]
        },
      ]
    },
    {
      'name': 'Diamond Building',
      'icon': Icons.diamond,
      'floors': [
        {
          'name': 'Basement',
          'rooms': [
            {'code': '', 'name': 'High School Library'},
            {'code': '', 'name': 'Office of the Marketing, Alumni Affairs, Public Relations Officer'},
            {'code': '', 'name': 'Carpark Entrance/Exit'},
          ]
        },
        {
          'name': '2nd Floor',
          'rooms': [
            {'code': '', 'name': 'Preparation Room'},
          ]
        },
        {
          'name': '3rd Floor',
          'rooms': [
            {'code': '', 'name': 'Faculty Office Nursing & Midwifery'},
            {'code': '', 'name': 'Anatomy & Physiology Laboratory'},
            {'code': '', 'name': 'Dispensing Room'},
            {'code': '', 'name': 'Microbiology Laboratory'},
            {'code': '', 'name': 'Office of the Dean, College of Nursing'},
            {'code': '', 'name': 'Office of the Dean, College of Midwifery'},
            {'code': '', 'name': 'Faculty Lounge'},
            {'code': '', 'name': 'Storage Room'},
            {'code': '', 'name': 'Nutrition Lecture Room'},
            {'code': '', 'name': 'Nutrition Laboratory'},
            {'code': '', 'name': 'Community Health Nursing'},
          ]
        },
        {
          'name': '4th Floor',
          'rooms': [
            {'code': '', 'name': 'General Ward'},
            {'code': '', 'name': 'Ortho Room'},
            {'code': '', 'name': 'Isolation Room'},
            {'code': '', 'name': 'Central Supply Room'},
            {'code': '', 'name': 'Skills Laboratory'},
          ]
        },
      ]
    },
    {
      'name': 'Science & Tech Building',
      'icon': Icons.biotech,
      'floors': [
        {
          'name': 'Basement',
          'rooms': [
            {'code': '', 'name': 'Electrical Control Room'},
            {'code': '', 'name': 'Basket Ball Court'},
            {'code': '', 'name': 'P.E. Office'},
            {'code': '', 'name': 'Fitness Gym'},
            {'code': '', 'name': 'Entrance/Exit Gate'},
          ]
        },
        {
          'name': '1st Floor',
          'rooms': [
            {'code': '', 'name': 'Entrance/ Exit'},
            {'code': '', 'name': 'CPTOT Rehab. Center'},
            {'code': '', 'name': 'Varsitarian Office'},
          ]
        },
        {
          'name': '2nd Floor',
          'rooms': [
            {'code': '', 'name': 'Office of the Dean, College of Physical Therapy & Occupational Therapy'},
            {'code': '', 'name': 'CPTOT Laboratory'},
          ]
        },
        {
          'name': '3rd Floor',
          'rooms': [
            {'code': '', 'name': 'Office of the Dean, Criminal Justice'},
            {'code': '', 'name': 'Mock Court'},
            {'code': '', 'name': 'FSLA Laboratory A, B'},
            {'code': '', 'name': 'Judo Room'},
            {'code': '', 'name': 'Balistic Laboratory'},
          ]
        },
        {
          'name': '4th Floor',
          'rooms': [
            {'code': '', 'name': 'Office of the Head, Architecture and Fine Arts'},
            {'code': '', 'name': 'Computer Room'},
            {'code': '', 'name': 'Nude Room'},
            {'code': '', 'name': 'Drafting Rooms'},
          ]
        },
      ]
    },
    {
      'name': 'Old High School Building',
      'icon': Icons.history_edu,
      'floors': [
        {
          'name': 'Main Floor',
          'rooms': [
            {'code': '', 'name': 'Vacant classrooms'},
            {'code': '', 'name': 'Temporary Storage Rooms'},
          ]
        },
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 768;
    bool isTablet = screenWidth >= 768 && screenWidth < 1200;

    double sidebarWidth = isMobile ? screenWidth * 0.85 : 350;
    double logoHeight = isMobile ? 60 : 80;

    return Column(
      children: [
        // Top Logo
        Padding(
          padding: EdgeInsets.symmetric(vertical: isMobile ? 10 : 20),
          // child: Image.asset(
          //   'assets/navigation.png',
          //   height: logoHeight,
          //   errorBuilder: (context, error, stackTrace) => SizedBox(height: logoHeight),
          // ),
        ),
        // Map Area with Sidebar Overlay
        Expanded(
          child: Stack(
            children: [
              // Map View
              Positioned.fill(
                child: Container(
                  color: Colors.white,
                  child: InteractiveViewer(
                    maxScale: 5.0,
                    minScale: 0.5,
                    child: _isUsingPlaceholder
                        ? Center(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.map_outlined, size: isMobile ? 60 : 100, color: Colors.grey.shade300),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Floor Plan: ${_selectedBuilding ?? ""}${_selectedFloor != null ? " - $_selectedFloor" : ""}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: isMobile ? 18 : 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    '(Standard Placeholder)',
                                    style: TextStyle(color: Colors.grey.shade300, fontSize: isMobile ? 12 : 14),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Image.asset(
                            _currentMapAsset,
                            fit: BoxFit.contain,
                          ),
                  ),
                ),
              ),
              // Reset Button (if map is not overview)
              if (_currentMapAsset != 'assets/campus_map.jpg' || _isUsingPlaceholder)
                Positioned(
                  right: isMobile ? 10 : 40,
                  top: isMobile ? 10 : 20,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedBuilding = null;
                        _selectedFloor = null;
                        _currentMapAsset = 'assets/campus_map.jpg';
                        _isUsingPlaceholder = false;
                      });
                    },
                    icon: Icon(Icons.layers_clear, size: isMobile ? 16 : 18),
                    label: Text(isMobile ? 'Reset' : 'Back to Campus Overview', style: TextStyle(fontSize: isMobile ? 12 : 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF002147),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 16, vertical: 8),
                    ),
                  ),
                ),
              // Collapsible Sidebar
              AnimatedPositioned(
                duration: const Duration(milliseconds: 150),
                left: _isSidebarCollapsed ? -(sidebarWidth + 10) : (isMobile ? 0 : 20),
                top: isMobile ? 0 : 20,
                bottom: isMobile ? 0 : 20,
                child: _buildSidebar(sidebarWidth, isMobile),
              ),
              // Sidebar Toggle Button (when collapsed)
              if (_isSidebarCollapsed)
                Positioned(
                  left: 0,
                  top: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF002147),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.chevron_right, size: 32, color: Colors.white),
                      onPressed: () => setState(() => _isSidebarCollapsed = false),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSidebar(double width, bool isMobile) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: isMobile ? BorderRadius.zero : BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Sidebar Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF002147),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isMobile ? 0 : 8),
                topRight: Radius.circular(isMobile ? 0 : 8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Campus Buildings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _isSidebarCollapsed = true),
                  child: const Icon(Icons.chevron_left, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
          // Scrollable Building List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _buildings.length,
              itemBuilder: (context, index) {
                final building = _buildings[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildBuildingTile(building),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuildingTile(Map<String, dynamic> building) {
    final isSelected = _selectedBuilding == building['name'] && _selectedFloor == null;
    
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF0F2F5) : Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isSelected ? const Color(0xFF002147).withOpacity(0.3) : Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: _selectedBuilding == building['name'],
          leading: Icon(building['icon'] ?? Icons.business, color: isSelected ? const Color(0xFF002147) : Colors.black54, size: 20),
          onExpansionChanged: (expanded) {
            if (expanded) {
              setState(() {
                _selectedBuilding = building['name'];
                _selectedFloor = null;
                _isUsingPlaceholder = true;
              });
            }
          },
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          title: Text(
            building['name'],
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
              color: isSelected ? const Color(0xFF002147) : Colors.black87,
            ),
          ),
          iconColor: Colors.black87,
          collapsedIconColor: Colors.black87,
          children: (building['floors'] as List).map<Widget>((floor) => _buildFloorTile(building['name'], floor)).toList(),
        ),
      ),
    );
  }

  Widget _buildFloorTile(String buildingName, Map<String, dynamic> floor) {
    final rooms = floor['rooms'] as List;
    final isSelected = _selectedBuilding == buildingName && _selectedFloor == floor['name'];
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF0F2F5) : Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isSelected ? const Color(0xFF002147).withOpacity(0.3) : Colors.black12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          dense: true,
          leading: Icon(Icons.layers, color: isSelected ? const Color(0xFF002147) : Colors.black45, size: 18),
          onExpansionChanged: (expanded) {
            if (expanded) {
              setState(() {
                _selectedBuilding = buildingName;
                _selectedFloor = floor['name'];
                _isUsingPlaceholder = true;
              });
            }
          },
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          title: Text(
            floor['name'],
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 12,
              color: isSelected ? const Color(0xFF002147) : Colors.black87,
            ),
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: const BoxDecoration(
                color: Color(0xFFFAFAFA),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Column(
                children: rooms.map<Widget>((room) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.meeting_room, size: 12, color: Colors.blueGrey),
                        const SizedBox(width: 8),
                        if (room['code'] != null && (room['code'] as String).isNotEmpty) ...[
                          SizedBox(
                            width: 70,
                            child: Text(
                              room['code'],
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            room['name'],
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal, color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

