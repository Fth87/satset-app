import 'dart:io';

import 'package:flutter/material.dart' hide FilterChip;

import '../core/app_controller.dart';
import '../models/package.dart';
import 'app_widgets.dart';


// UI Components

class PreviewPanel extends StatelessWidget {
  const PreviewPanel({super.key, 
    required this.imagePath,
    required this.onRetake,
    required this.onSend,
  });

  final String imagePath;
  final VoidCallback onRetake;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF111111),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(File(imagePath), fit: BoxFit.contain),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.75),
                    Colors.transparent,
                  ],
                ),
              ),
              child: const Text(
                'Preview gambar resi',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BottomNav extends StatelessWidget {
  const BottomNav({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final isDispatcher = controller.profile?.role == UserRole.dispatcher;
    final navItems = isDispatcher
        ? const [
            (AppScreen.dispatcherDashboard, Icons.inventory_2_outlined, 'Home'),
            (AppScreen.dispatcherLiveMap, Icons.map_outlined, 'Map'),
            (AppScreen.dispatcherAssignments, Icons.list_alt, 'Assign'),
            (AppScreen.dispatcherCenter, Icons.shield_outlined, 'Center'),
            (AppScreen.profile, Icons.person_outline, 'Profile'),
          ]
        : const [
            (AppScreen.dashboard, Icons.inventory_2_outlined, 'Home'),
            (AppScreen.manifest, Icons.inventory_outlined, 'Manifest'),
            (AppScreen.scanner, Icons.document_scanner_outlined, 'Scan'),
            (AppScreen.mapNav, Icons.map_outlined, 'Map'),
            (AppScreen.profile, Icons.person_outline, 'Profile'),
          ];

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 94,
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: line),
              borderRadius: BorderRadius.circular(36),
            ),
            child: Row(
              children: [
                for (final item in navItems)
                  Expanded(
                    child: NavItem(
                      active: controller.screen == item.$1,
                      icon: item.$2,
                      label: item.$3,
                      compact: isDispatcher,
                      isAction: !isDispatcher && item.$1 == AppScreen.scanner,
                      onTap: () => controller.go(item.$1),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  const NavItem({super.key, 
    required this.active,
    required this.icon,
    required this.label,
    required this.onTap,
    this.compact = false,
    this.isAction = false,
  });

  final bool active;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool compact;
  final bool isAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: Material(
        color: active ? surface : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: isAction ? 50 : 32,
                height: isAction ? 50 : 32,
                decoration: BoxDecoration(
                  color: isAction ? ink : Colors.transparent,
                  borderRadius: BorderRadius.circular(isAction ? 18 : 99),
                ),
                child: Icon(
                  icon,
                  color: isAction
                      ? Colors.white
                      : active
                          ? ink
                          : muted,
                  size: isAction
                      ? 32
                      : compact
                          ? 20
                          : 22,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: active ? ink : muted,
                  fontSize: isAction
                      ? 10.5
                      : compact
                          ? 9
                          : 10,
                  fontWeight: active || isAction
                      ? FontWeight.w900
                      : FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScrollPage extends StatelessWidget {
  const ScrollPage({super.key, 
    required this.child,
    this.header,
    this.topPadding = 20,
    this.bottomPadding = 24,
    this.onRefresh,
    this.controller,
  });

  final Widget child;
  final Widget? header;
  final double topPadding;
  final double bottomPadding;
  final Future<void> Function()? onRefresh;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    Widget list = ListView(
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20, topPadding, 20, bottomPadding),
      children: [child],
    );

    if (onRefresh != null) {
      list = RefreshIndicator(
        onRefresh: onRefresh!,
        color: ink,
        child: list,
      );
    }

    return Column(
      children: [
        header ?? const SizedBox.shrink(),
        Expanded(child: list),
      ],
    );
  }
}

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, 
    required this.title,
    required this.subtitle,
    required this.roleLabel,
    required this.statusLabel,
    required this.onBell,
  });

  final String title;
  final String subtitle;
  final String roleLabel;
  final String statusLabel;
  final VoidCallback onBell;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: const Border(bottom: BorderSide(color: line)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 28,
                          height: 1,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: muted,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: onBell,
                  icon: const Icon(Icons.notifications_none),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                HeaderChip(label: roleLabel),
                const HeaderChip(label: 'Surabaya Selatan'),
                HeaderChip(label: statusLabel),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CourierHomeTop extends StatelessWidget {
  const CourierHomeTop({super.key, required this.controller, required this.onBell});

  final AppController controller;
  final VoidCallback onBell;

  @override
  Widget build(BuildContext context) {
    final allPackages = controller.packages;
    final total = allPackages.length;
    final done = allPackages.where((p) => p.status == PackageStatus.delivered).length;
    final pending = allPackages.where((p) => p.status == PackageStatus.pending).length;
    final fail = allPackages.where((p) => p.status == PackageStatus.clarification).length;

    return SafeArea(
      bottom: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(bottom: BorderSide(color: line)),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.currentCity,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Overview - Today, ${DateTime.now().toString().substring(5, 10)}',
                        style: const TextStyle(
                          color: muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: onBell,
                  icon: const Icon(Icons.notifications_none),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: MiniStat(value: total.toString(), label: 'Total'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MiniStat(
                    value: done.toString(),
                    label: 'Done',
                    icon: Icons.check,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MiniStat(
                    value: pending.toString(),
                    label: 'Pend',
                    icon: Icons.schedule,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MiniStat(
                    value: fail.toString(),
                    label: 'Fail',
                    icon: Icons.close,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MiniStat extends StatelessWidget {
  const MiniStat({super.key, required this.value, required this.label, this.icon});

  final String value;
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: surface,
        border: Border.all(color: line),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 12, color: muted),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  label.toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HeaderChip extends StatelessWidget {
  const HeaderChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: line),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: ink,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class PackageCard extends StatelessWidget {
  const PackageCard({super.key, required this.package, required this.controller});

  final DeliveryPackage package;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => controller.go(AppScreen.deliveryDetail, package: package),
      borderRadius: BorderRadius.circular(24),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package.id,
                        style: const TextStyle(
                          color: muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        package.recipient,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusChip(package: package),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              package.address,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: muted),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.package});

  final DeliveryPackage package;

  @override
  Widget build(BuildContext context) {
    final text = switch (package.status) {
      PackageStatus.pending => package.eta,
      PackageStatus.clarification => 'Comm AI',
      PackageStatus.delivered => 'Done',
    };
    return Chip(label: Text(text));
  }
}

const mockChat = [];

class ChatLog extends StatelessWidget {
  const ChatLog({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'COMMUNICATION LOG',
            style: TextStyle(
              color: muted,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          for (final msg in mockChat)
            Align(
              alignment: msg.sender == 'ai'
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                constraints: const BoxConstraints(maxWidth: 300),
                decoration: BoxDecoration(
                  color: msg.sender == 'ai' ? surface : ink,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      msg.text,
                      style: TextStyle(
                        color: msg.sender == 'ai' ? ink : Colors.white,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      msg.time,
                      style: const TextStyle(color: muted, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MetricsPage extends StatelessWidget {
  const MetricsPage({super.key, 
    required this.controller,
    required this.title,
    required this.mainLabel,
    required this.mainValue,
    required this.progress,
  });

  final AppController controller;
  final String title;
  final String mainLabel;
  final String mainValue;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return ScrollPage(
      bottomPadding: 96,
      header: AppHeader(title: title, controller: controller),
      child: Column(
        children: [
          AppCard(
            child: Column(
              children: [
                Text(
                  mainLabel.toUpperCase(),
                  style: const TextStyle(
                    color: muted,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  mainValue,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  color: ink,
                  backgroundColor: line,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(
                child: InsightCard(
                  label: 'Avg Time',
                  value: '4.5 min',
                  body: 'Per drop',
                  icon: Icons.schedule,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: InsightCard(
                  label: 'AI Resolve',
                  value: '88%',
                  body: 'Autonomous',
                  icon: Icons.auto_awesome,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MapMock extends StatelessWidget {
  const MapMock({super.key, this.fleet = false});

  final bool fleet;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: MapPainter(fleet: fleet),
      child: const SizedBox.expand(),
    );
  }
}

class MapPainter extends CustomPainter {
  const MapPainter({required this.fleet});

  final bool fleet;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(const Color(0xFFEFF1F3), BlendMode.src);
    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final route = Paint()
      ..color = ink
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < 7; i++) {
      final y = size.height * (i + 1) / 8;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y + (i.isEven ? 28 : -28)),
        road,
      );
    }
    for (var i = 0; i < 5; i++) {
      final x = size.width * (i + 1) / 6;
      canvas.drawLine(Offset(x, 0), Offset(x + 30, size.height), road);
    }

    final path = Path()
      ..moveTo(size.width * .22, size.height * .78)
      ..quadraticBezierTo(
        size.width * .38,
        size.height * .54,
        size.width * .52,
        size.height * .48,
      )
      ..quadraticBezierTo(
        size.width * .70,
        size.height * .40,
        size.width * .78,
        size.height * .25,
      );
    canvas.drawPath(path, route);

    final points = fleet
        ? [
            Offset(size.width * .35, size.height * .58),
            Offset(size.width * .68, size.height * .34),
          ]
        : [
            Offset(size.width * .22, size.height * .78),
            Offset(size.width * .52, size.height * .48),
            Offset(size.width * .78, size.height * .25),
          ];
    for (final p in points) {
      canvas.drawCircle(p, 10, Paint()..color = Colors.white);
      canvas.drawCircle(p, 7, Paint()..color = ink);
    }
  }

  @override
  bool shouldRepaint(covariant MapPainter oldDelegate) {
    return oldDelegate.fleet != fleet;
  }
}

class MetricList extends StatelessWidget {
  const MetricList({super.key, required this.rows});

  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++)
            ListTile(
              title: Text(rows[i].$1, style: const TextStyle(color: muted)),
              trailing: Text(
                rows[i].$2,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              shape: i == rows.length - 1
                  ? null
                  : const Border(bottom: BorderSide(color: line)),
            ),
        ],
      ),
    );
  }
}

class ProfileInfo extends StatelessWidget {
  const ProfileInfo({super.key, required this.profile});

  final OperatorProfile profile;

  @override
  Widget build(BuildContext context) {
    return MetricList(
      rows: [
        if (profile.role == UserRole.courier) ('Vehicle', profile.vehicle),
        ('Zone', profile.zone),
        ('Phone', '+62 812 3456 7890'),
      ],
    );
  }
}

const mockUserVehicle = 'Van - L 1234 XY';
const mockUserZone = 'Surabaya Selatan';

class MenuButton extends StatelessWidget {
  const MenuButton({super.key, 
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: EdgeInsets.zero,
        child: ListTile(
          leading: Icon(icon),
          title: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }
}

class InsightCard extends StatelessWidget {
  const InsightCard({super.key, 
    required this.label,
    required this.value,
    required this.body,
    required this.icon,
  });

  final String label;
  final String value;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    color: muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Icon(icon, size: 18, color: muted),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(color: muted, height: 1.25)),
        ],
      ),
    );
  }
}

class AgentTile extends StatelessWidget {
  const AgentTile({super.key, 
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 14),
          Text(
            title.toUpperCase(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
          ),
          Text(subtitle, style: const TextStyle(color: muted, fontSize: 11)),
        ],
      ),
    );
  }
}

class FilterChip extends StatelessWidget {
  const FilterChip({super.key, required this.label, this.active = false});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        backgroundColor: active ? ink : Colors.white,
        labelStyle: TextStyle(color: active ? Colors.white : muted),
        side: const BorderSide(color: line),
      ),
    );
  }
}

class LogCard extends StatelessWidget {
  const LogCard({super.key, 
    required this.icon,
    required this.title,
    required this.time,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String time;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                Text(time, style: const TextStyle(color: muted, fontSize: 11)),
              ],
            ),
            const Divider(height: 20),
            Text(body, style: const TextStyle(color: muted, height: 1.4)),
          ],
        ),
      ),
    );
  }
}

class IncidentCard extends StatelessWidget {
  const IncidentCard({super.key, required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              const Text(
                '10 min ago',
                style: TextStyle(color: muted, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(body, style: const TextStyle(color: muted, height: 1.35)),
          const SizedBox(height: 10),
          const Text(
            'Reported by C-88291',
            style: TextStyle(
              color: muted,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class EvidenceBox extends StatelessWidget {
  const EvidenceBox({super.key, 
    required this.label,
    required this.icon,
    required this.height,
  });

  final String label;
  final IconData icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: line),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36),
          const SizedBox(height: 10),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: muted,
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    );
  }
}

class MiniAction extends StatelessWidget {
  const MiniAction({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 22, color: ink),
        const SizedBox(height: 6),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: muted,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
