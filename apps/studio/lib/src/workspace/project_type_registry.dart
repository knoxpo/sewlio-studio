import 'domain_module.dart';
import 'embroidery_module.dart';
import 'project_type.dart';

/// Project Type Registry (ARCH-034): resolves the active domain's UI
/// contributions. Built-ins register inline, same pattern as
/// [panelRegistry] — future domains append here at startup.
final domainModules = <DomainUiModule>[embroideryModule];

/// The registered module for [type]. Throws when the domain was never
/// registered — that is a wiring bug, not a runtime condition.
DomainUiModule moduleFor(ProjectType type) =>
    domainModules.firstWhere((m) => m.type == type);
