enum FoxRole {
  owner('Owner', 'All owned properties', true),
  areaGm('Area GM', 'A cluster / city of properties', true),
  areaHm('Area HM', 'A cluster / city of properties', true),
  gmHm('GM / HM', 'One property', false),
  opsManager('Ops Manager', 'One property', false),
  supervisor('Supervisor', 'Department / floor', false),
  executive('Executive', 'Own tasks', false);

  const FoxRole(this.label, this.scope, this.chainOnly);

  final String label;
  final String scope;

  /// Area roles exist only in a chain. A standalone hotel uses Owner plus
  /// the property roles.
  final bool chainOnly;
}
