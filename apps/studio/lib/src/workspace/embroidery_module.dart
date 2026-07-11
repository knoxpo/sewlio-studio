import 'domain_module.dart';
import 'project_type.dart';

/// Embroidery domain UI contributions (ARCH-036: embroidery registers
/// as the active MVP domain). Toolbox, panels, and overlays are filled
/// in as the stitch workspace lands.
final embroideryModule = DomainUiModule(
  type: ProjectType.embroidery,
  domainLabel: 'Stitch',
);
