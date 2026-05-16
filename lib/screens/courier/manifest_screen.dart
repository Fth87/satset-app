import 'dart:async';
import 'package:flutter/material.dart' hide FilterChip;

import '../../core/app_controller.dart';
import '../../core/location_service.dart';
import '../../models/package.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/app_shell_widgets.dart';

class ManifestScreen extends StatefulWidget {
  const ManifestScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<ManifestScreen> createState() => _ManifestScreenState();
}

class _ManifestScreenState extends State<ManifestScreen> {
  String _selectedFilter = 'Akan Dikirim';
  String _searchQuery = '';
  String _sortBy = 'ID'; // 'ID', 'Recipient'
  bool _isSearching = false;
  bool _hasLocationPermission = false;
  bool _isCheckingPermission = true;
  Timer? _searchDebounce;

  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _checkPermission();
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      setState(() => _searchQuery = val);
    });
  }

  Future<void> _checkPermission() async {
    setState(() => _isCheckingPermission = true);
    // Request permission early
    final granted = await LocationService.requestPermissions();
    if (mounted) {
      setState(() {
        _hasLocationPermission = granted;
        _isCheckingPermission = false;
      });
      if (granted) {
        // Already called in initState or controller
        // widget.controller.fetchPackages();
      }
    }
  }

  void _showAddPackageDialog(BuildContext context) {
    final recipientController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    String priority = 'Standard';
    PackageStatus status = PackageStatus.pending;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add New Package'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: recipientController,
                  decoration: const InputDecoration(labelText: 'Recipient Name'),
                ),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                ),
                DropdownButtonFormField<String>(
                  initialValue: priority,
                  items: ['Standard', 'Express', 'Priority']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => setDialogState(() => priority = val!),
                  decoration: const InputDecoration(labelText: 'Priority'),
                ),
                DropdownButtonFormField<PackageStatus>(
                  initialValue: status,
                  items: const [
                    DropdownMenuItem(value: PackageStatus.pending, child: Text('Akan Dikirim')),
                    DropdownMenuItem(value: PackageStatus.clarification, child: Text('Anomaly')),
                    DropdownMenuItem(value: PackageStatus.delivered, child: Text('Finished')),
                  ],
                  onChanged: (val) => setDialogState(() => status = val!),
                  decoration: const InputDecoration(labelText: 'Initial Status'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                if (recipientController.text.isEmpty || addressController.text.isEmpty) return;
                final id = 'PKG-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
                widget.controller.addPackage({
                  'id': id,
                  'recipient': recipientController.text,
                  'address': addressController.text,
                  'phone': phoneController.text,
                  'priority': priority,
                  'status': status.name,
                  'eta': '2h',
                  'confidence': 95,
                  'cluster': 'A',
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Package added successfully')));
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      widget.controller.fetchMorePackages();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingPermission) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_hasLocationPermission) {
      return Scaffold(
        backgroundColor: surface,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_off_outlined, size: 64, color: muted),
                const SizedBox(height: 16),
                const Text(
                  'Akses Lokasi Diperlukan',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Aplikasi membutuhkan akses lokasi untuk mengoptimalkan rute manifest Anda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: muted),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Berikan Akses',
                  onPressed: _checkPermission,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final allPackages = widget.controller.packages;
    
    // Filtering
    List<DeliveryPackage> filteredPackages = allPackages;
    if (_selectedFilter == 'Akan Dikirim') {
      filteredPackages = allPackages.where((p) => p.status == PackageStatus.pending).toList();
    } else if (_selectedFilter == 'Anomaly') {
      filteredPackages = allPackages.where((p) => p.status == PackageStatus.clarification).toList();
    } else if (_selectedFilter == 'Finished') {
      filteredPackages = allPackages.where((p) => p.status == PackageStatus.delivered).toList();
    }

    // Search
    if (_searchQuery.isNotEmpty) {
      filteredPackages = filteredPackages.where((p) => 
        p.recipient.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p.address.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p.id.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Sort
    if (_sortBy == 'ID') {
      filteredPackages.sort((a, b) => a.id.compareTo(b.id));
    } else if (_sortBy == 'Recipient') {
      filteredPackages.sort((a, b) => a.recipient.compareTo(b.recipient));
    }

    final toDeliverCount = allPackages.where((p) => p.status == PackageStatus.pending).length;
    final finishedCount = allPackages.where((p) => p.status == PackageStatus.delivered).length;
    final anomalyCount = allPackages.where((p) => p.status == PackageStatus.clarification).length;

    return ScrollPage(
      bottomPadding: 96,
      controller: _scrollController,
      onRefresh: () => widget.controller.fetchPackages(),
      header: AppHeader(
        title: '',
        backTo: _isSearching ? null : AppScreen.dashboard,
        trailing: Row(
          mainAxisSize: _isSearching ? MainAxisSize.max : MainAxisSize.min,
          children: [
            if (_isSearching)
              Expanded(
                child: TextField(
                  autofocus: true,
                  onChanged: _onSearchChanged,
                  decoration: const InputDecoration(
                    hintText: 'Search...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            IconButton(
              onPressed: () => setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) _searchQuery = '';
              }),
              icon: Icon(_isSearching ? Icons.close : Icons.search),
            ),
            IconButton(
              onPressed: () => _showAddPackageDialog(context),
              icon: const Icon(Icons.add_circle_outline),
            ),
            PopupMenuButton<String>(
              onSelected: (val) => setState(() => _sortBy = val),
              icon: const Icon(Icons.filter_list),
              itemBuilder: (ctx) => [
                const PopupMenuItem(value: 'ID', child: Text('Sort by ID')),
                const PopupMenuItem(value: 'Recipient', child: Text('Sort by Name')),
              ],
            ),
          ],
        ),
        controller: widget.controller,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Navigate Action
          PrimaryButton(
            label: 'Navigate All (Optimized)',
            icon: Icons.navigation,
            onPressed: () {
              final pendingPackages = allPackages.where((p) => p.status == PackageStatus.pending).toList();
              if (pendingPackages.isEmpty) {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tidak ada paket untuk dikirim')));
                 return;
              }
              widget.controller.go(AppScreen.mapNav, package: pendingPackages.first);
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _selectedFilter = 'Akan Dikirim'),
                  child: FilterChip(
                    label: 'Akan Dikirim ($toDeliverCount)', 
                    active: _selectedFilter == 'Akan Dikirim'
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _selectedFilter = 'Anomaly'),
                  child: FilterChip(
                    label: 'Anomaly ($anomalyCount)', 
                    active: _selectedFilter == 'Anomaly'
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _selectedFilter = 'Finished'),
                  child: FilterChip(
                    label: 'Finished ($finishedCount)', 
                    active: _selectedFilter == 'Finished'
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (widget.controller.isLoadingPackages)
            ...List.generate(
              5,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Container(height: 40, color: muted.withValues(alpha: 0.1)),
                ),
              ),
            )
          else if (filteredPackages.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('Tidak ada paket ditemukan.', style: TextStyle(color: muted)),
              ),
            )
          else
            ...filteredPackages.map(
              (pkg) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: PackageCard(package: pkg, controller: widget.controller),
              ),
            ),
          if (widget.controller.isFetchingMore)
             const Padding(
               padding: EdgeInsets.symmetric(vertical: 20),
               child: Center(child: CircularProgressIndicator()),
             ),
        ],
      ),
    );
  }
}

