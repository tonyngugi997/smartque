// lib/screens/advanced_departments_screen.dart
import 'package:flutter/material.dart';
import 'package:advanced_login_app/screens/department_data.dart';
import 'package:advanced_login_app/screens/department_model.dart';
// import 'package:advanced_login_app/widgets/department_card.dart';
// import 'package:advanced_login_app/widgets/search_filter_bar.dart';
// import 'package:advanced_login_app/screens/doctor_selection_screen.dart';

class AdvancedDepartmentsScreen extends StatefulWidget {
  const AdvancedDepartmentsScreen({Key? key}) : super(key: key);

  @override
  State<AdvancedDepartmentsScreen> createState() =>
      _AdvancedDepartmentsScreenState();
}

class _AdvancedDepartmentsScreenState extends State<AdvancedDepartmentsScreen>
    with SingleTickerProviderStateMixin {
  late List<HospitalDepartment> _allDepartments;
  late List<HospitalDepartment> _filteredDepartments;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Filter states
  String _searchQuery = '';
  List<String> _selectedSpecializations = [];
  bool _telemedicineOnly = false;
  bool _emergencyOnly = false;
  SortOption _sortBy = SortOption.name;

  // Filter options
  final List<String> _allSpecializations =
      DepartmentData.getAllSpecializations();

  @override
  void initState() {
    super.initState();
    _allDepartments = DepartmentData.getAllDepartments();
    _filteredDepartments = _allDepartments;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {
      _filteredDepartments = _allDepartments.where((dept) {
        // Search filter
        final matchesSearch = _searchQuery.isEmpty ||
            dept.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            dept.description.toLowerCase().contains(_searchQuery.toLowerCase());

        // Specialization filter
        final matchesSpecializations = _selectedSpecializations.isEmpty ||
            dept.specializations
                .any((spec) => _selectedSpecializations.contains(spec));

        // Telemedicine filter
        final matchesTelemedicine = !_telemedicineOnly ||
            (_telemedicineOnly && dept.telemedicineAvailable);

        // Emergency filter
        final matchesEmergency =
            !_emergencyOnly || (_emergencyOnly && dept.emergencyService);

        return matchesSearch &&
            matchesSpecializations &&
            matchesTelemedicine &&
            matchesEmergency;
      }).toList();

      // Apply sorting
      _sortDepartments();
    });
  }

  void _sortDepartments() {
    switch (_sortBy) {
      case SortOption.name:
        _filteredDepartments.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.rating:
        _filteredDepartments.sort((a, b) => b.avgRating.compareTo(a.avgRating));
        break;
      case SortOption.doctorCount:
        _filteredDepartments
            .sort((a, b) => b.doctorCount.compareTo(a.doctorCount));
        break;
      case SortOption.waitTime:
        _filteredDepartments
            .sort((a, b) => a.avgWaitTime.compareTo(b.avgWaitTime));
        break;
    }
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FilterModal(
          selectedSpecializations: _selectedSpecializations,
          telemedicineOnly: _telemedicineOnly,
          emergencyOnly: _emergencyOnly,
          sortBy: _sortBy,
          allSpecializations: _allSpecializations,
          onApply: (specs, telemed, emergency, sort) {
            setState(() {
              _selectedSpecializations = specs;
              _telemedicineOnly = telemed;
              _emergencyOnly = emergency;
              _sortBy = sort;
            });
            _applyFilters();
          },
        );
      },
    );
  }

  void _navigateToDoctors(HospitalDepartment department) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorSelectionScreen(department: department),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: CustomScrollView(
        slivers: [
          // Sticky Header
          SliverAppBar(
            backgroundColor: const Color(0xFF1A1A2E),
            elevation: 10,
            pinned: true,
            floating: true,
            expandedHeight: 180,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              title: const Text(
                'Hospital Departments',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF6C63FF).withOpacity(0.8),
                      const Color(0xFF1A1A2E).withOpacity(0.9),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 100, left: 20, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_allDepartments.length} Specialized Departments',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Find the perfect specialist for your needs',
                        style: TextStyle(
                          color: Color(0xFF00BFA6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Search and Filter Bar
          SliverToBoxAdapter(
            child: SearchFilterBar(
              onSearchChanged: (query) {
                _searchQuery = query;
                _applyFilters();
              },
              onFilterPressed: _showFilterModal,
              activeFilterCount: _selectedSpecializations.length +
                  (_telemedicineOnly ? 1 : 0) +
                  (_emergencyOnly ? 1 : 0),
            ),
          ),

          // Filter 
          if (_selectedSpecializations.isNotEmpty ||
              _telemedicineOnly ||
              _emergencyOnly)
            SliverToBoxAdapter(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (_selectedSpecializations.isNotEmpty)
                      ..._selectedSpecializations.map((spec) {
                        return FilterChip(
                          label: Text(spec),
                          selected: true,
                          onSelected: (selected) {
                            setState(() {
                              _selectedSpecializations.remove(spec);
                            });
                            _applyFilters();
                          },
                          backgroundColor: const Color(0xFF6C63FF),
                          selectedColor: const Color(0xFF4A44C6),
                          labelStyle: const TextStyle(color: Colors.white),
                          checkmarkColor: Colors.white,
                        );
                      }).toList(),
                    if (_telemedicineOnly)
                      FilterChip(
                        label: const Text('Telemedicine'),
                        selected: true,
                        onSelected: (selected) {
                          setState(() {
                            _telemedicineOnly = false;
                          });
                          _applyFilters();
                        },
                        backgroundColor: const Color(0xFF00BFA6),
                        selectedColor: const Color(0xFF009688),
                        labelStyle: const TextStyle(color: Colors.white),
                        checkmarkColor: Colors.white,
                      ),
                    if (_emergencyOnly)
                      FilterChip(
                        label: const Text('Emergency'),
                        selected: true,
                        onSelected: (selected) {
                          setState(() {
                            _emergencyOnly = false;
                          });
                          _applyFilters();
                        },
                        backgroundColor: const Color(0xFFFF6B6B),
                        selectedColor: const Color(0xFFD32F2F),
                        labelStyle: const TextStyle(color: Colors.white),
                        checkmarkColor: Colors.white,
                      ),
                  ],
                ),
              ),
            ),

          // Departments Grid
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final department = _filteredDepartments[index];
                  return SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: DepartmentCard(
                        department: department,
                        onTap: () => _navigateToDoctors(department),
                      ),
                    ),
                  );
                },
                childCount: _filteredDepartments.length,
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showFilterModal,
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        elevation: 10,
        icon: const Icon(Icons.filter_alt_outlined),
        label: const Text('Filters'),
      ),
    );
  }
}

class FilterModal extends StatefulWidget {
  final List<String> selectedSpecializations;
  final bool telemedicineOnly;
  final bool emergencyOnly;
  final SortOption sortBy;
  final List<String> allSpecializations;
  final Function(List<String>, bool, bool, SortOption) onApply;

  const FilterModal({
    super.key,
    required this.selectedSpecializations,
    required this.telemedicineOnly,
    required this.emergencyOnly,
    required this.sortBy,
    required this.allSpecializations,
    required this.onApply,
  });

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  late List<String> _selectedSpecs;
  late bool _telemedicine;
  late bool _emergency;
  late SortOption _sort;

  @override
  void initState() {
    super.initState();
    _selectedSpecs = List.from(widget.selectedSpecializations);
    _telemedicine = widget.telemedicineOnly;
    _emergency = widget.emergencyOnly;
    _sort = widget.sortBy;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A3E),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.filter_alt_outlined, color: Color(0xFF6C63FF)),
                const SizedBox(width: 10),
                const Text(
                  'Filter & Sort',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Sort Options
                const Text(
                  'Sort By',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: [
                    FilterChip(
                      label: const Text('Name A-Z'),
                      selected: _sort == SortOption.name,
                      onSelected: (selected) {
                        setState(() {
                          _sort = SortOption.name;
                        });
                      },
                      backgroundColor: Colors.white.withOpacity(0.1),
                      selectedColor: const Color(0xFF6C63FF),
                      labelStyle: TextStyle(
                        color: _sort == SortOption.name
                            ? Colors.white
                            : Colors.white70,
                      ),
                    ),
                    FilterChip(
                      label: const Text('Highest Rating'),
                      selected: _sort == SortOption.rating,
                      onSelected: (selected) {
                        setState(() {
                          _sort = SortOption.rating;
                        });
                      },
                      backgroundColor: Colors.white.withOpacity(0.1),
                      selectedColor: const Color(0xFF6C63FF),
                      labelStyle: TextStyle(
                        color: _sort == SortOption.rating
                            ? Colors.white
                            : Colors.white70,
                      ),
                    ),
                    FilterChip(
                      label: const Text('Most Doctors'),
                      selected: _sort == SortOption.doctorCount,
                      onSelected: (selected) {
                        setState(() {
                          _sort = SortOption.doctorCount;
                        });
                      },
                      backgroundColor: Colors.white.withOpacity(0.1),
                      selectedColor: const Color(0xFF6C63FF),
                      labelStyle: TextStyle(
                        color: _sort == SortOption.doctorCount
                            ? Colors.white
                            : Colors.white70,
                      ),
                    ),
                    FilterChip(
                      label: const Text('Lowest Wait Time'),
                      selected: _sort == SortOption.waitTime,
                      onSelected: (selected) {
                        setState(() {
                          _sort = SortOption.waitTime;
                        });
                      },
                      backgroundColor: Colors.white.withOpacity(0.1),
                      selectedColor: const Color(0xFF6C63FF),
                      labelStyle: TextStyle(
                        color: _sort == SortOption.waitTime
                            ? Colors.white
                            : Colors.white70,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Services
                const Text(
                  'Services',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Checkbox(
                      value: _telemedicine,
                      onChanged: (value) {
                        setState(() {
                          _telemedicine = value!;
                        });
                      },
                      activeColor: const Color(0xFF00BFA6),
                      checkColor: Colors.white,
                    ),
                    const Text(
                      'Telemedicine Available',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _emergency,
                      onChanged: (value) {
                        setState(() {
                          _emergency = value!;
                        });
                      },
                      activeColor: const Color(0xFFFF6B6B),
                      checkColor: Colors.white,
                    ),
                    const Text(
                      'Emergency Services',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Specializations
                const Text(
                  'Specializations',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.allSpecializations.map((spec) {
                    return FilterChip(
                      label: Text(spec),
                      selected: _selectedSpecs.contains(spec),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedSpecs.add(spec);
                          } else {
                            _selectedSpecs.remove(spec);
                          }
                        });
                      },
                      backgroundColor: Colors.white.withOpacity(0.1),
                      selectedColor: const Color(0xFF6C63FF),
                      labelStyle: TextStyle(
                        color: _selectedSpecs.contains(spec)
                            ? Colors.white
                            : Colors.white70,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Apply Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A3E),
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedSpecs.clear();
                        _telemedicine = false;
                        _emergency = false;
                        _sort = SortOption.name;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: BorderSide(
                          color: const Color(0xFF6C63FF).withOpacity(0.5)),
                    ),
                    child: const Text(
                      'Clear All',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(
                          _selectedSpecs, _telemedicine, _emergency, _sort);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Enums
enum SortOption { name, rating, doctorCount, waitTime }
