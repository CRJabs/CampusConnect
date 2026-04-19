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
      'name': "Founder's Building",
      'icon': Icons.school,
      'floors': [
        {
          'name': 'First Floor',
          'rooms': [
            {'code': 'Room F101', 'name': 'General Classroom'},
            {'code': 'Room F102', 'name': 'Faculty Office'},
            {'code': 'Room F103', 'name': 'Student Lounge'},
          ]
        },
        {
          'name': 'Second Floor',
          'rooms': [
            {'code': 'Room F201', 'name': 'IT Laboratory'},
            {'code': 'Room F202', 'name': 'Server Room'},
            {'code': 'Room F203', 'name': 'Multimedia Room'},
          ]
        },
        {
          'name': 'Third Floor',
          'rooms': [
            {'code': 'Room F301', 'name': 'CETAFA Industrial Engineering Lab'},
            {'code': 'Room F302', 'name': 'Drafting Room'},
            {'code': 'Room F303', 'name': 'Robotics Lab'},
          ]
        },
      ]
    },
    {
      'name': "Achiever's Building",
      'icon': Icons.emoji_events,
      'floors': [
        {'name': 'First Floor', 'rooms': [{'code': 'Room A101', 'name': 'Placeholder Room'}]},
        {'name': 'Second Floor', 'rooms': [{'code': 'Room A201', 'name': 'Placeholder Room'}]},
        {'name': 'Third Floor', 'rooms': [{'code': 'Room A301', 'name': 'Placeholder Room'}]},
      ]
    },
    {
      'name': 'Diamond Building',
      'icon': Icons.diamond,
      'floors': [
        {'name': 'First Floor', 'rooms': [{'code': 'Room D101', 'name': 'Placeholder Room'}]},
        {'name': 'Second Floor', 'rooms': [{'code': 'Room D201', 'name': 'Placeholder Room'}]},
        {'name': 'Third Floor', 'rooms': [{'code': 'Room D301', 'name': 'Placeholder Room'}]},
      ]
    },
    {
      'name': 'IRC Building',
      'icon': Icons.menu_book,
      'floors': [
        {'name': 'First Floor', 'rooms': [{'code': 'Room I101', 'name': 'Placeholder Room'}]},
        {'name': 'Second Floor', 'rooms': [{'code': 'Room I201', 'name': 'Placeholder Room'}]},
        {'name': 'Third Floor', 'rooms': [{'code': 'Room I301', 'name': 'Placeholder Room'}]},
      ]
    },
    {
      'name': 'High School Building',
      'icon': Icons.auto_stories,
      'floors': [
        {'name': 'First Floor', 'rooms': [{'code': 'Room H101', 'name': 'Placeholder Room'}]},
        {'name': 'Second Floor', 'rooms': [{'code': 'Room H201', 'name': 'Placeholder Room'}]},
        {'name': 'Third Floor', 'rooms': [{'code': 'Room H301', 'name': 'Placeholder Room'}]},
      ]
    },
    {
      'name': 'Old High School Building',
      'icon': Icons.history_edu,
      'floors': [
        {'name': 'First Floor', 'rooms': [{'code': 'Room O101', 'name': 'Placeholder Room'}]},
        {'name': 'Second Floor', 'rooms': [{'code': 'Room O201', 'name': 'Placeholder Room'}]},
        {'name': 'Third Floor', 'rooms': [{'code': 'Room O301', 'name': 'Placeholder Room'}]},
      ]
    },
    {
      'name': 'Science & Tech Building',
      'icon': Icons.biotech,
      'floors': [
        {'name': 'First Floor', 'rooms': [{'code': 'Room S101', 'name': 'Placeholder Room'}]},
        {'name': 'Second Floor', 'rooms': [{'code': 'Room S201', 'name': 'Placeholder Room'}]},
        {'name': 'Third Floor', 'rooms': [{'code': 'Room S301', 'name': 'Placeholder Room'}]},
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
                        SizedBox(
                          width: 70,
                          child: Text(
                            room['code'],
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(width: 8),
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

