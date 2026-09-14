// Property onboarding (PRD P0-9). Shapes deliberately mirror what an OTA
// listing carries, so an OTA/PMS feed can populate them later (P2-2) without
// reshaping the model.

class RoomTypeDraft {
  RoomTypeDraft({
    required this.name,
    this.count = 0,
    this.maxOccupancy = 2,
    this.sizeSqFt = 0,
    this.baseRate = 0,
  });

  String name;
  int count;
  int maxOccupancy;
  int sizeSqFt;
  int baseRate;

  bool get isComplete => name.isNotEmpty && count > 0 && baseRate > 0;
}

enum MealPlanCode {
  ep('EP', 'European Plan', 'Room only'),
  cp('CP', 'Continental Plan', 'Room + breakfast'),
  map('MAP', 'Modified American Plan', 'Room + breakfast + one meal'),
  ap('AP', 'American Plan', 'Room + all meals');

  const MealPlanCode(this.code, this.label, this.includes);
  final String code;
  final String label;
  final String includes;
}

class MealPlanDraft {
  MealPlanDraft({required this.plan, this.enabled = false, this.supplement = 0});

  final MealPlanCode plan;
  bool enabled;

  /// Added per person per night on top of the room rate.
  int supplement;
}

enum FacilityGroup { property, room, dining, wellness, business }

class FacilityDraft {
  FacilityDraft({
    required this.name,
    required this.group,
    this.available = false,
  });

  final String name;
  final FacilityGroup group;
  bool available;
}

enum LandmarkKind {
  airport('Airport'),
  railway('Railway station'),
  busStand('Bus stand'),
  attraction('Attraction'),
  corporateHub('Corporate hub');

  const LandmarkKind(this.label);
  final String label;
}

class LandmarkDraft {
  LandmarkDraft({
    required this.kind,
    required this.name,
    this.distanceKm = 0,
    this.minutes = 0,
  });

  final LandmarkKind kind;
  String name;
  double distanceKm;
  int minutes;

  bool get isComplete => name.isNotEmpty && distanceKm > 0;
}

enum SetupStep {
  basics('Property', 'Name, city and address'),
  rooms('Rooms', 'Types, counts and base rates'),
  rates('Rates', 'Seasonal and weekend pricing'),
  mealPlans('Meal plans', 'What each rate includes'),
  facilities('Facilities', 'What the property offers'),
  nearby('Nearby', 'Distances guests judge you on'),
  review('Review', 'Publish and go bookable');

  const SetupStep(this.label, this.detail);
  final String label;
  final String detail;
}

/// The working draft. A property becomes bookable only when every required
/// step is complete.
class PropertyDraft {
  PropertyDraft();

  String name = '';
  String city = '';
  String address = '';
  String starRating = '4';
  int totalRooms = 0;

  final rooms = <RoomTypeDraft>[
    RoomTypeDraft(name: 'Deluxe King', count: 24, maxOccupancy: 2, sizeSqFt: 320, baseRate: 5400),
    RoomTypeDraft(name: 'Deluxe Twin', count: 18, maxOccupancy: 2, sizeSqFt: 320, baseRate: 5400),
  ];

  int weekendUpliftPercent = 15;
  int peakSeasonUpliftPercent = 30;
  bool taxInclusive = false;

  final mealPlans = <MealPlanDraft>[
    MealPlanDraft(plan: MealPlanCode.ep, enabled: true),
    MealPlanDraft(plan: MealPlanCode.cp, enabled: true, supplement: 650),
    MealPlanDraft(plan: MealPlanCode.map, supplement: 1200),
    MealPlanDraft(plan: MealPlanCode.ap, supplement: 1750),
  ];

  final facilities = <FacilityDraft>[
    FacilityDraft(name: 'Swimming pool', group: FacilityGroup.property, available: true),
    FacilityDraft(name: 'Free parking', group: FacilityGroup.property, available: true),
    FacilityDraft(name: 'Power backup', group: FacilityGroup.property, available: true),
    FacilityDraft(name: 'Lift', group: FacilityGroup.property, available: true),
    FacilityDraft(name: 'Air conditioning', group: FacilityGroup.room, available: true),
    FacilityDraft(name: 'In-room safe', group: FacilityGroup.room),
    FacilityDraft(name: 'Mini bar', group: FacilityGroup.room, available: true),
    FacilityDraft(name: 'Tea / coffee maker', group: FacilityGroup.room, available: true),
    FacilityDraft(name: 'Multi-cuisine restaurant', group: FacilityGroup.dining, available: true),
    FacilityDraft(name: 'Room service 24h', group: FacilityGroup.dining, available: true),
    FacilityDraft(name: 'Bar', group: FacilityGroup.dining),
    FacilityDraft(name: 'Spa', group: FacilityGroup.wellness),
    FacilityDraft(name: 'Gym', group: FacilityGroup.wellness, available: true),
    FacilityDraft(name: 'Banquet hall', group: FacilityGroup.business, available: true),
    FacilityDraft(name: 'Conference room', group: FacilityGroup.business),
  ];

  final landmarks = <LandmarkDraft>[
    LandmarkDraft(kind: LandmarkKind.airport, name: 'Jaipur International', distanceKm: 12.4, minutes: 28),
    LandmarkDraft(kind: LandmarkKind.railway, name: 'Jaipur Junction', distanceKm: 6.1, minutes: 18),
    LandmarkDraft(kind: LandmarkKind.busStand, name: 'Sindhi Camp', distanceKm: 5.2, minutes: 16),
    LandmarkDraft(kind: LandmarkKind.attraction, name: 'Hawa Mahal', distanceKm: 4.8, minutes: 15),
    LandmarkDraft(kind: LandmarkKind.corporateHub, name: 'Mahindra World City', distanceKm: 21.0, minutes: 40),
  ];

  bool published = false;

  int get roomCount => rooms.fold(0, (s, r) => s + r.count);
  int get facilityCount => facilities.where((f) => f.available).length;
  int get mealPlanCount => mealPlans.where((m) => m.enabled).length;

  bool isStepComplete(SetupStep step) => switch (step) {
        SetupStep.basics => name.isNotEmpty && city.isNotEmpty && address.isNotEmpty,
        SetupStep.rooms => rooms.isNotEmpty && rooms.every((r) => r.isComplete),
        SetupStep.rates => rooms.every((r) => r.baseRate > 0),
        SetupStep.mealPlans => mealPlans.any((m) => m.enabled),
        SetupStep.facilities => facilities.any((f) => f.available),
        SetupStep.nearby => landmarks.where((l) => l.isComplete).length >= 3,
        SetupStep.review => false,
      };

  List<SetupStep> get incompleteSteps => SetupStep.values
      .where((s) => s != SetupStep.review && !isStepComplete(s))
      .toList();

  bool get canPublish => incompleteSteps.isEmpty;

  double get progress {
    final total = SetupStep.values.length - 1;
    final done = total - incompleteSteps.length;
    return done / total;
  }
}
