// lib/widgets/wallet/vehicle_selector_tab.dart
import 'package:flutter/material.dart';
import '../../config/app_constants.dart';
import '../../models/wallet_model.dart';

class VehicleSelectorTab extends StatelessWidget {
  final List<VehicleModel> vehicles;
  final int selectedIndex;
  final void Function(int) onVehicleSelected;

  const VehicleSelectorTab({
    super.key,
    required this.vehicles,
    required this.selectedIndex,
    required this.onVehicleSelected,
  });

  bool _hasIssue(VehicleDocumentsModel docs) {
    final e = docs.emission;
    final i = docs.insurance;
    final r = docs.revenueLicense;
    return (e?.isExpired ?? false) ||
        (e?.overallStatus == 'FAIL') ||
        (i?.isExpired ?? false) ||
        (r?.isExpired ?? false);
  }

  bool _hasEmissionFail(EmissionCertModel? e) =>
      e != null && e.overallStatus == 'FAIL' && !e.isExpired;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('My Vehicles (${vehicles.length})',
            style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final v = vehicles[index];
              final isSelected = index == selectedIndex;
              final hasIssue   = _hasIssue(v.documents);
              final hasEmFail  = _hasEmissionFail(v.documents.emission);

              return GestureDetector(
                onTap: () => onVehicleSelected(index),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 120,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryGreen
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? null
                            : Border.all(color: AppColors.divider),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color:
                                      AppColors.primaryGreen.withAlpha(80),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withAlpha(12),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _vehicleIcon(v.vehicleClass),
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                            size: 26,
                          ),
                          const SizedBox(height: 5),
                          Text(v.registrationNo,
                              style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                              overflow: TextOverflow.ellipsis),
                          Text(v.make,
                              style: TextStyle(
                                  color: isSelected
                                      ? Colors.white.withAlpha(180)
                                      : AppColors.textSecondary,
                                  fontSize: 10),
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),

                    // Issue dot badge
                    if (hasIssue || hasEmFail)
                      Positioned(
                        top: -3,
                        right: 8,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: hasEmFail
                                ? AppColors.warningOrange
                                : AppColors.errorRed,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white, width: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _vehicleIcon(String vehicleClass) {
    final cls = vehicleClass.toUpperCase();
    if (cls.contains('MOTOR CYCLE') || cls.contains('CYCLE')) {
      return Icons.two_wheeler;
    }
    if (cls.contains('THREE WHEELER')) return Icons.electric_rickshaw;
    if (cls.contains('BUS'))           return Icons.directions_bus;
    if (cls.contains('LORRY'))         return Icons.local_shipping;
    if (cls.contains('GOODS'))         return Icons.local_shipping;
    return Icons.directions_car;
  }
}
