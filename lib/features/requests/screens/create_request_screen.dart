import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../auth/providers/auth_provider.dart';
import '../../services/providers/services_provider.dart';
import '../providers/requests_provider.dart';

class CreateRequestScreen extends ConsumerStatefulWidget {
  final String? initialServiceId;
  final String? initialServiceName;

  const CreateRequestScreen({
    super.key,
    this.initialServiceId,
    this.initialServiceName,
  });

  @override
  ConsumerState<CreateRequestScreen> createState() =>
      _CreateRequestScreenState();
}

class _CreateRequestScreenState extends ConsumerState<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedServiceId;
  final _descriptionController = TextEditingController();
  final _addressController =
      TextEditingController(text: '742 Evergreen Terrace, Springfield');
  DateTime _preferredDate = DateTime.now().add(const Duration(days: 1));
  String _preferredTime = '10:00 AM - 12:00 PM';
  String _priority = 'MEDIUM';

  final List<String> _timeSlots = [
    '08:00 AM - 10:00 AM',
    '10:00 AM - 12:00 PM',
    '12:00 PM - 02:00 PM',
    '02:00 PM - 04:00 PM',
    '04:00 PM - 06:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _selectedServiceId = widget.initialServiceId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final servicesState = ref.read(servicesProvider);
      if (_selectedServiceId == null && servicesState.services.isNotEmpty) {
        if (widget.initialServiceName != null) {
          final match = servicesState.services.firstWhere(
            (s) => s.name
                .toLowerCase()
                .contains(widget.initialServiceName!.toLowerCase()),
            orElse: () => servicesState.services.first,
          );
          setState(() => _selectedServiceId = match.id);
        } else {
          setState(() => _selectedServiceId = servicesState.services.first.id);
        }
      }
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _preferredDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _preferredDate = picked);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedServiceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a service category')),
      );
      return;
    }

    final authState = ref.read(authProvider);
    final serviceItem =
        ref.read(servicesProvider.notifier).getServiceById(_selectedServiceId!);
    final customerId = authState.profile?.id ?? 'demo-customer';

    final created = await ref.read(requestsProvider.notifier).createRequest(
          customerId: customerId,
          serviceId: _selectedServiceId!,
          description: _descriptionController.text,
          preferredDate: _preferredDate,
          preferredTime: _preferredTime,
          address: _addressController.text,
          priority: _priority,
          serviceItem: serviceItem,
        );

    if (created != null && mounted) {
      context.replace('/request-success', extra: created.requestId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicesState = ref.watch(servicesProvider);
    final requestsState = ref.watch(requestsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Book Service Request',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service Type Dropdown
                const Text(
                  'Select Service Category',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _selectedServiceId,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.handyman_outlined,
                        color: AppColors.textSecondary, size: 20),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: servicesState.services.map((service) {
                    return DropdownMenuItem<String>(
                      value: service.id,
                      child: Text(service.name),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedServiceId = val),
                  validator: (val) =>
                      val == null ? 'Please select a service' : null,
                ),
                const SizedBox(height: 18),

                // Description
                CustomTextField(
                  controller: _descriptionController,
                  label: 'Problem or Service Description',
                  hint: 'Describe the issue or required repair in detail...',
                  prefixIcon: Icons.description_outlined,
                  maxLines: 4,
                  validator: (v) =>
                      Validators.validateRequired(v, 'Description'),
                ),
                const SizedBox(height: 18),

                // Preferred Date & Time
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Preferred Date',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: _selectDate,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined,
                                      size: 18, color: AppColors.textSecondary),
                                  const SizedBox(width: 8),
                                  Text(
                                    DateFormat('MMM dd, yyyy')
                                        .format(_preferredDate),
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textPrimary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Time Window',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _preferredTime,
                            isExpanded: true,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 14),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            items: _timeSlots.map((slot) {
                              return DropdownMenuItem<String>(
                                value: slot,
                                child: Text(slot,
                                    style: const TextStyle(fontSize: 12)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _preferredTime = val);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Address
                CustomTextField(
                  controller: _addressController,
                  label: 'Service Address',
                  hint: 'Street, Apartment, City, Postal Code',
                  prefixIcon: Icons.location_on_outlined,
                  maxLines: 2,
                  validator: (v) => Validators.validateRequired(v, 'Address'),
                ),
                const SizedBox(height: 18),

                // Priority Selection
                const Text(
                  'Job Priority',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: ['LOW', 'MEDIUM', 'HIGH'].map((p) {
                    final isSelected = _priority == p;
                    Color pColor = p == 'HIGH'
                        ? AppColors.priorityHigh
                        : (p == 'MEDIUM'
                            ? AppColors.priorityMedium
                            : AppColors.priorityLow);

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _priority = p),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? pColor.withValues(alpha: 0.12)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? pColor : AppColors.cardBorder,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              p,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? pColor
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                // Submit Button
                CustomButton(
                  text: 'Submit Request to Admin Dispatch',
                  isLoading: requestsState.isSubmitting,
                  onPressed: _handleSubmit,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
