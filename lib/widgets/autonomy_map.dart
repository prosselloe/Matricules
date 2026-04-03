import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:matricules/providers/model_provider.dart';

class AutonomyMap extends StatefulWidget {
  const AutonomyMap({super.key});

  @override
  State<AutonomyMap> createState() => _AutonomyMapState();
}

class _AutonomyMapState extends State<AutonomyMap> with TickerProviderStateMixin {
  final MapController _mapController = MapController();

  void _animatedMove(LatLng dest, double zoom) {
    final latTween = Tween<double>(
        begin: _mapController.camera.center.latitude, end: dest.latitude);
    final lngTween = Tween<double>(
        begin: _mapController.camera.center.longitude, end: dest.longitude);
    final zoomTween =
        Tween<double>(begin: _mapController.camera.zoom, end: zoom);

    final controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    final animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      if (mounted) {
        _mapController.move(
          LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
          zoomTween.evaluate(animation),
        );
      }
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final modelProvider = Provider.of<ModelProvider>(context);
    final autonomies = modelProvider.autonomies;

    if (modelProvider.selectedAutonomy != null) {
      final selectedAutonomyData = autonomies.firstWhere(
        (p) => p.name == modelProvider.selectedAutonomy,
        orElse: () => autonomies.first,
      );

      final coords = LatLng(
        selectedAutonomyData.latitude,
        selectedAutonomyData.longitude,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _animatedMove(coords, 10.0);
        }
      });
    }

    return FlutterMap(
      mapController: _mapController,
      options: const MapOptions(
        initialCenter: LatLng(40.0, -4.0),
        initialZoom: 5.5,
        maxZoom: 15.0,
        minZoom: 3.0,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'dev.prosselloe.volkswagen',
        ),
        MarkerLayer(
          markers: autonomies.map((autonomy) {
            final isSelected = modelProvider.selectedAutonomy == autonomy.name;
            return Marker(
              width: 50,
              height: 50,
              point: LatLng(autonomy.latitude, autonomy.longitude),
              child: GestureDetector(
                onTap: () {
                  modelProvider.filterByAutonomy(autonomy.name);
                },
                child: Tooltip(
                  message: autonomy.name,
                  child: Icon(
                    Icons.location_pin,
                    size: isSelected ? 40 : 30,
                    color: isSelected ? Colors.cyan : Colors.red,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
