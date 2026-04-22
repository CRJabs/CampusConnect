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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _buildings = [
    {
      'name': "Founder's Building",
      'icon': Icons.school,
      'floors': [
        {
          'name': 'First Floor',
          'mapAsset': 'assets/maps/founders_1st.png',
          'rooms': [
            {'code': 'CONFERENCE/FACULTY ROOM', 'name': ''},
            {'code': 'OFFICE OF THE DEAN CASE', 'name': ''},
            {'code': 'COMMERCIAL SPACES', 'name': ''},
            {'code': 'STUDENT LOUNGE', 'name': ''},
            {'code': 'Room F101', 'name': ''},
            {'code': 'Room F102', 'name': ''},
            {'code': 'Room F103', 'name': ''},
            {'code': 'MEN\'S CR', 'name': ''},
            {'code': 'WOMEN\'S CR', 'name': ''},
            {'code': 'FOUNDERS HALL GATE', 'name': ''},
          ]
        },
        {
          'name': 'Second Floor',
          'mapAsset': 'assets/maps/founders_2nd.png',
          'rooms': [
            {'code': 'Room F201', 'name': ''},
            {'code': 'Room F202', 'name': ''},
            {'code': 'Room F203', 'name': ''},
            {'code': 'Room F204', 'name': ''},
            {'code': 'Room F205', 'name': ''},
            {'code': 'Room F206', 'name': ''},
            {'code': 'Room F207', 'name': ''},
            {'code': 'Room F208', 'name': ''},
            {'code': 'Room F209', 'name': ''},
            {'code': 'Room F210', 'name': ''},
            {'code': 'TESTING CENTER EXPERIMENTAL PSYCHOLOGY LAB', 'name': ''},
            {'code': 'OFFICE OF THE VICE PRESIDENT FOR ACADEMICS', 'name': ''},
            {'code': 'OFFICE OF THE DEAN, RESEARCH PLANNING DEVELOPMENT', 'name': ''},
            {'code': 'MEN\'S CR', 'name': ''},
            {'code': 'WOMEN\'S CR', 'name': ''},
            {'code': 'FIRE EXIT', 'name': ''},
          ]
        },
        {
          'name': 'Third Floor',
          'mapAsset': 'assets/maps/founders_3rd.png',
          'rooms': [
            {'code': 'Room F301', 'name': ''},
            {'code': 'Room F302', 'name': ''},
            {'code': 'Room F303', 'name': ''},
            {'code': 'Room F304 / Music Room Lec', 'name': ''},
            {'code': 'Room F305', 'name': ''},
            {'code': 'Room F306', 'name': ''},
            {'code': 'Room F307', 'name': ''},
            {'code': 'Room F308', 'name': ''},
            {'code': 'Room F309', 'name': ''},
            {'code': 'Room F310', 'name': ''},
            {'code': 'IE Laboratory', 'name': ''},
            {'code': 'TLE Laboratory', 'name': ''},
            {'code': 'Music Room Rondalla', 'name': ''},
            {'code': 'Piano Room', 'name': ''},
          ]
        },
      ]
    },
    {
      'name': "Achiever's Building",
      'icon': Icons.emoji_events,
      'floors': [
        {
          'name': 'Second Floor',
          'mapAsset': 'assets/maps/achievers_2nd.png',
          'rooms': [
            {'code': 'Room A201', 'name': ''},
            {'code': 'Room A202', 'name': ''},
            {'code': 'Room A203', 'name': ''},
            {'code': 'Room A204', 'name': ''},
            {'code': 'Surveying Instrument Room', 'name': ''},
            {'code': 'Drafting Room', 'name': ''},
            {'code': 'Mechanical Laboratory', 'name': ''},
            {'code': 'Electrical Laboratory', 'name': ''},
            {'code': 'Electronics Laboratory', 'name': ''},
            {'code': 'Storage Room', 'name': ''},
            {'code': 'University Research Center', 'name': ''},
          ]
        },
        {
          'name': 'Third Floor',
          'mapAsset': 'assets/maps/achievers_3rd.png',
          'rooms': [
            {'code': 'Room A301', 'name': ''},
            {'code': 'Room A302', 'name': ''},
            {'code': 'Room A303', 'name': ''},
            {'code': 'Room A304', 'name': ''},
            {'code': 'Room A305', 'name': ''},
            {'code': 'Room A306', 'name': ''},
            {'code': 'Room A307', 'name': ''},
            {'code': 'Room A308', 'name': ''},
            {'code': 'Room A309', 'name': ''},
            {'code': 'CETAFA Conference Room', 'name': ''},
            {'code': 'CETAFA Faculty Office', 'name': ''},
            {'code': 'Office of the Dean, CETAFA', 'name': ''},
            {'code': 'CETAFA SSG Office', 'name': ''},
            {'code': 'MEN\'S CR', 'name': ''},
          ]
        },
      ]
    },
    {
      'name': 'Diamond Building',
      'icon': Icons.diamond,
      'floors': [
        {
          'name': 'First Floor',
          'mapAsset': 'assets/maps/diamond_1st.png',
          'rooms': [
            {'code': 'Room D101', 'name': ''},
            {'code': 'Room D102', 'name': ''},
            {'code': 'Room D103', 'name': ''},
            {'code': 'Room D104', 'name': ''},
            {'code': 'Room D105', 'name': ''},
            {'code': 'Room D106', 'name': ''},
            {'code': 'Room D107', 'name': ''},
            {'code': 'Room D108', 'name': ''},
            {'code': 'Room D109', 'name': ''},
            {'code': 'STUDENT LOUNGE', 'name': ''},
            {'code': 'MEN\'S CR', 'name': ''},
            {'code': 'WOMEN\'S CR', 'name': ''},
          ]
        },
        {
          'name': 'Second Floor',
          'mapAsset': 'assets/maps/diamond_2nd.png',
          'rooms': [
            {'code': 'Room D201', 'name': ''},
            {'code': 'Room D202', 'name': ''},
            {'code': 'Room D203', 'name': ''},
            {'code': 'Room D204', 'name': ''},
            {'code': 'Room D205', 'name': ''},
            {'code': 'Room D206', 'name': ''},
            {'code': 'Room D207', 'name': ''},
            {'code': 'Room D208', 'name': ''},
            {'code': 'Room D209', 'name': ''},
            {'code': 'STUDENT LOUNGE', 'name': ''},
            {'code': 'OPEN AREA', 'name': ''},
            {'code': 'MEN\'S CR', 'name': ''},
            {'code': 'WOMEN\'S CR', 'name': ''},
          ]
        },
        {
          'name': 'Third Floor',
          'mapAsset': 'assets/maps/diamond_3rd.png',
          'rooms': [
            {'code': 'CHN ROOM', 'name': ''},
            {'code': 'CHEMICAL ROOM', 'name': ''},
            {'code': 'NUTRITION LABORATORY', 'name': ''},
            {'code': 'MICRO BIO LABORATORY', 'name': ''},
            {'code': 'DISPENSING', 'name': ''},
            {'code': 'ANATOMY LABORATORY', 'name': ''},
            {'code': 'CAHS OFFICE OF THE DEAN / FACULTY OFFICE', 'name': ''},
            {'code': 'CONFERENCE ROOM', 'name': ''},
            {'code': 'STUDENT LOUNGE', 'name': ''},
            {'code': 'OPEN AREA', 'name': ''},
            {'code': 'MEN\'S CR', 'name': ''},
            {'code': 'WOMEN\'S CR', 'name': ''},
          ]
        },
      ]
    },
    {
      'name': 'Administration Building',
      'icon': Icons.account_balance,
      'floors': [
        {
          'name': 'First Floor',
          'mapAsset': 'assets/maps/admin_1st.png',
          'rooms': [
            {'code': 'President\'s Office', 'name': ''},
            {'code': 'Illuminada\'s Home', 'name': ''},
            {'code': 'Office of the VP Administration & HR Manager', 'name': ''},
            {'code': 'Registrar\'s Office', 'name': ''},
            {'code': 'Conference Room 1', 'name': ''},
          ]
        },
        {
          'name': 'Second Floor',
          'mapAsset': 'assets/maps/admin_2nd.png',
          'rooms': [
            {'code': 'Office of the Dean, CHMTN/COP ', 'name': ''},
            {'code': 'Classroom 1', 'name': ''},
            {'code': 'Classroom 2', 'name': ''},
            {'code': 'Classroom 3', 'name': ''},
            {'code': 'Classroom 4', 'name': ''},
            {'code': 'Instrumentation Room', 'name': ''},
            {'code': 'Chem Lecture Room', 'name': ''},
            {'code': 'Speech Clinic', 'name': ''},
            {'code': 'Comp Lab D', 'name': ''},
            {'code': 'MIS', 'name': ''},
            {'code': 'CMen\'s CR', 'name': ''},
          ]
        },
        {
          'name': 'Third Floor',
          'mapAsset': 'assets/maps/admin_3rd.png',
          'rooms': [
            {'code': 'Zoology Laboratory', 'name': ''},
            {'code': 'Apparatus', 'name': ''},
            {'code': 'Botany Laboratory', 'name': ''},
            {'code': 'Bio Chem Laboratory', 'name': ''},
            {'code': 'Dispensing', 'name': ''},
            {'code': 'Research Center', 'name': ''},
            {'code': 'Comp Lab A', 'name': ''},
            {'code': 'Comp Lab B', 'name': ''},
            {'code': 'Comp Lab C', 'name': ''},
            {'code': 'Control & Server Room', 'name': ''},
            {'code': 'Women\'s CR', 'name': ''},
          ]
        },
        {
          'name': 'Fourth Floor',
          'mapAsset': 'assets/maps/admin_4th.png',
          'rooms': [
            {'code': 'CHEMICAL STORAGE', 'name': ''},
            {'code': 'COLLEGE PHYSICS LABORATORY 1', 'name': ''},
            {'code': 'COLLEGE PHYSICS LABORATORY 2', 'name': ''},
            {'code': 'CHEMISTRY LABORATORY 1', 'name': ''},
            {'code': 'CHEMISTRY LABORATORY 2', 'name': ''},
            {'code': 'DISPENSING ROOM', 'name': ''},
            {'code': 'DANCE HALL', 'name': ''},
            {'code': 'MEN\'S CR', 'name': ''},
            {'code': 'WOMEN\'S CR', 'name': ''},
            {'code': 'STORAGE', 'name': ''},
          ]
        }
      ]
    }
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
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search for a room...',
                hintStyle: const TextStyle(fontSize: 14),
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: const Color(0xFF002147).withOpacity(0.3), width: 1),
                ),
              ),
            ),
          ),
          // Scrollable Building List or Search Results
          Expanded(
            child: _searchQuery.isEmpty 
              ? ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _buildings.length,
                  itemBuilder: (context, index) {
                    final building = _buildings[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildBuildingTile(building),
                    );
                  },
                )
              : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    List<Map<String, dynamic>> results = [];

    for (var building in _buildings) {
      for (var floor in building['floors']) {
        for (var room in floor['rooms']) {
          final roomCode = (room['code'] as String).toLowerCase();
          final roomName = (room['name'] as String).toLowerCase();
          
          if (roomCode.contains(_searchQuery) || roomName.contains(_searchQuery)) {
            results.add({
              'buildingName': building['name'],
              'floor': floor,
              'room': room,
            });
          }
        }
      }
    }

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No rooms found for "$_searchQuery"',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        final buildingName = result['buildingName'];
        final floor = result['floor'];
        final room = result['room'];

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            dense: true,
            leading: const Icon(Icons.meeting_room, size: 20, color: Color(0xFF002147)),
            title: Text(
              room['code'].isEmpty ? room['name'] : room['code'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            subtitle: Text(
              '$buildingName - ${floor['name']}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
            onTap: () {
              setState(() {
                _selectedBuilding = buildingName;
                _selectedFloor = floor['name'];
                if (floor['mapAsset'] != null) {
                  _currentMapAsset = floor['mapAsset'];
                  _isUsingPlaceholder = false;
                } else {
                  _isUsingPlaceholder = true;
                }
                _searchQuery = '';
                _searchController.clear();
              });
            },
          ),
        );
      },
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
                _currentMapAsset = 'assets/campus_map.jpg';
                _isUsingPlaceholder = false;
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
                if (floor['mapAsset'] != null) {
                  _currentMapAsset = floor['mapAsset'];
                  _isUsingPlaceholder = false;
                } else {
                  _isUsingPlaceholder = true;
                }
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
                          width: 180,
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

