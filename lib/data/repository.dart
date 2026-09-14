import 'package:flutter/foundation.dart';

import '../access/role.dart';
import '../domain/models.dart';
import '../domain/setup_models.dart';

/// In-memory store. v1 intelligence data is keyed in by hand rather than fed
/// from a PMS, so the repository is the system of record for now; the shapes
/// here are what an OTA/PMS feed would later populate (PRD P2-2).
class FoxRepository extends ChangeNotifier {
  FoxRepository() {
    _seed();
  }

  static final _today = DateTime.now();
  static DateTime _d(int offset) =>
      DateTime(_today.year, _today.month, _today.day + offset);

  final properties = const [
    Property(id: 'jai', name: 'FoxOtale Jaipur', city: 'Jaipur', totalRooms: 78),
    Property(id: 'udr', name: 'FoxOtale Udaipur', city: 'Udaipur', totalRooms: 54),
    Property(id: 'goa', name: 'FoxOtale Candolim', city: 'Goa', totalRooms: 96),
  ];

  late Property _property;
  Property get property => _property;
  set property(Property p) {
    _property = p;
    notifyListeners();
  }

  FoxRole _role = FoxRole.gmHm;
  FoxRole get role => _role;
  set role(FoxRole r) {
    _role = r;
    notifyListeners();
  }

  /// The property being onboarded. Unpublished until every required step of
  /// PRD P0-9 is complete.
  final draft = PropertyDraft();

  void touchDraft() => notifyListeners();

  void publishDraft() {
    draft.published = true;
    notifyListeners();
  }

  late List<Room> _rooms;
  late List<Booking> _bookings;
  late List<StaffTask> _tasks;
  late List<GuestRequest> _requests;

  List<Room> get rooms => List.unmodifiable(_rooms);
  List<Booking> get bookings => List.unmodifiable(_bookings);
  List<StaffTask> get tasks => List.unmodifiable(_tasks);
  List<GuestRequest> get requests => List.unmodifiable(_requests);

  // ------------------------------------------------------------ reservations
  List<Booking> get arrivals =>
      _bookings.where((b) => _isSameDay(b.checkIn, _today)).toList();
  List<Booking> get departures =>
      _bookings.where((b) => _isSameDay(b.checkOut, _today)).toList();
  List<Booking> get inHouse => _bookings
      .where((b) => b.checkIn.isBefore(_today) && b.checkOut.isAfter(_today))
      .toList();

  int get revenueToday =>
      arrivals.fold(0, (s, b) => s + b.totalAmount) +
      inHouse.fold(0, (s, b) => s + b.totalAmount ~/ b.nights);
  int get paymentReceived => _bookings.fold(0, (s, b) => s + b.amountPaid);
  int get paymentPending => _bookings.fold(0, (s, b) => s + b.balance);
  int get pendingFolios => _bookings.where((b) => b.balance > 0).length;

  int get occupancyPercent {
    final occupied =
        _rooms.where((r) => r.state == RoomState.occupied).length;
    return _rooms.isEmpty ? 0 : (occupied * 100 / _rooms.length).round();
  }

  int get arr {
    final nights = _bookings.fold(0, (s, b) => s + b.nights);
    if (nights == 0) return 0;
    return _bookings.fold(0, (s, b) => s + b.totalAmount) ~/ nights;
  }

  // ------------------------------------------------------------------ counts
  int roomsInState(RoomState s) => _rooms.where((r) => r.state == s).length;
  int get openTasks =>
      _tasks.where((t) => t.state != TaskState.done).length;
  int get overdueTasks => _tasks.where((t) => t.isOverdue).length;
  int get openRequests =>
      _requests.where((r) => r.state != TaskState.done).length;

  List<StaffTask> tasksFor(String assignee) =>
      _tasks.where((t) => t.assignee == assignee).toList();

  // ----------------------------------------------------------------- mutation
  void setRoomState(String number, RoomState state) {
    final i = _rooms.indexWhere((r) => r.number == number);
    if (i == -1) return;
    _rooms[i] = _rooms[i].copyWith(state: state);
    notifyListeners();
  }

  void setTaskState(String id, TaskState state) {
    final i = _tasks.indexWhere((t) => t.id == id);
    if (i == -1) return;
    _tasks[i] = _tasks[i].copyWith(state: state);
    notifyListeners();
  }

  void assignTask(String id, String assignee) {
    final i = _tasks.indexWhere((t) => t.id == id);
    if (i == -1) return;
    _tasks[i] = _tasks[i]
        .copyWith(assignee: assignee, state: TaskState.assigned);
    notifyListeners();
  }

  void setRequestState(String id, TaskState state) {
    final i = _requests.indexWhere((r) => r.id == id);
    if (i == -1) return;
    _requests[i] = _requests[i].copyWith(state: state);
    notifyListeners();
  }

  // ------------------------------------------------------------ intelligence
  final segments = const [
    SegmentRevenue(
        segment: BookingSegment.corporate,
        revenue: 4820000,
        roomNights: 1284,
        budget: 4500000),
    SegmentRevenue(
        segment: BookingSegment.ota,
        revenue: 3140000,
        roomNights: 902,
        budget: 3400000),
    SegmentRevenue(
        segment: BookingSegment.direct,
        revenue: 2260000,
        roomNights: 640,
        budget: 1900000),
    SegmentRevenue(
        segment: BookingSegment.travelAgent,
        revenue: 1180000,
        roomNights: 331,
        budget: 1250000),
    SegmentRevenue(
        segment: BookingSegment.walkIn,
        revenue: 640000,
        roomNights: 188,
        budget: 500000),
    SegmentRevenue(
        segment: BookingSegment.banquet,
        revenue: 410000,
        roomNights: 0,
        budget: 600000),
  ];

  final corporates = const [
    CorporateAccount(
        name: 'Infosys Ltd', kind: 'Corporate', roomNights: 412, revenue: 1840000),
    CorporateAccount(
        name: 'Make My Trip', kind: 'Travel agent', roomNights: 388, revenue: 1310000),
    CorporateAccount(
        name: 'Tata Consultancy', kind: 'Corporate', roomNights: 296, revenue: 1240000),
    CorporateAccount(
        name: 'Weddings by Riya', kind: 'Event company', roomNights: 204, revenue: 980000),
    CorporateAccount(
        name: 'Yatra Online', kind: 'Travel agent', roomNights: 176, revenue: 620000),
    CorporateAccount(
        name: 'Mahindra Group', kind: 'Corporate', roomNights: 142, revenue: 590000),
  ];

  final team = const [
    StaffMember(
        name: 'Rohit Sharma', role: FoxRole.gmHm, department: 'Management', onShift: true),
    StaffMember(
        name: 'Meera Iyer', role: FoxRole.opsManager, department: 'Operations', onShift: true),
    StaffMember(
        name: 'Anil Khan', role: FoxRole.supervisor, department: 'Housekeeping', onShift: true),
    StaffMember(
        name: 'Vaishali Deshpande', role: FoxRole.supervisor, department: 'Front desk', onShift: false),
    StaffMember(
        name: 'Suresh Pillai', role: FoxRole.executive, department: 'Housekeeping', onShift: true),
    StaffMember(
        name: 'Neha Gupta', role: FoxRole.executive, department: 'Front desk', onShift: true),
  ];

  int get revenueMtd => segments.fold(0, (s, x) => s + x.revenue);
  int get budgetMtd => segments.fold(0, (s, x) => s + x.budget);
  int get varianceMtd => revenueMtd - budgetMtd;

  // ------------------------------------------------------------------- seed
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _seed() {
    _property = properties.first;

    const types = ['Deluxe King', 'Deluxe Twin', 'Premier Suite', 'Heritage Room'];
    const states = [
      RoomState.occupied,
      RoomState.occupied,
      RoomState.vacantClean,
      RoomState.vacantDirty,
      RoomState.occupied,
      RoomState.inspected,
      RoomState.occupied,
      RoomState.outOfOrder,
    ];
    _rooms = [
      for (var floor = 1; floor <= 4; floor++)
        for (var n = 1; n <= 8; n++)
          Room(
            number: '${floor}0$n',
            type: types[(floor + n) % types.length],
            floor: floor,
            state: states[(floor * 3 + n) % states.length],
          ),
    ];

    const guests = [
      'Sharma, Rohit', 'Iyer, Meera', 'Khan, Anil', 'Deshpande, Vaishali',
      'Pillai, Suresh', 'Gupta, Neha', 'Menon, Kavya', 'Bose, Arindam',
      'Reddy, Sanjana', 'Chauhan, Vikram', 'Nair, Divya', 'Joshi, Prateek',
    ];
    const segs = BookingSegment.values;
    const sources = ['Booking.com', 'Direct', 'MakeMyTrip', 'Corporate desk',
                     'Walk-in', 'Agoda'];
    _bookings = [
      for (var i = 0; i < guests.length; i++)
        Booking(
          id: 'BK${2400 + i}',
          guestName: guests[i],
          roomNumber: _rooms[i * 2].number,
          roomType: _rooms[i * 2].type,
          checkIn: _d(i % 3 == 0 ? 0 : -(i % 4) - 1),
          checkOut: _d((i % 5) + 1),
          nights: (i % 5) + 1,
          totalAmount: 6200 + (i * 1850),
          amountPaid: i % 4 == 0 ? 0 : (6200 + (i * 1850)) ~/ (i % 3 + 1),
          segment: segs[i % segs.length],
          source: sources[i % sources.length],
          corporate: i % 3 == 0 ? 'Infosys Ltd' : null,
        ),
    ];

    const titles = [
      'Turn down service', 'Deep clean bathroom', 'AC not cooling',
      'Restock minibar', 'Late check-out setup', 'Replace bath linen',
      'Fix door lock', 'Set up banquet hall', 'Airport pickup arrangement',
    ];
    const kinds = TaskKind.values;
    const assignees = ['Suresh Pillai', 'Neha Gupta', 'Anil Khan', 'Unassigned'];
    const taskStates = [
      TaskState.assigned, TaskState.inProgress, TaskState.done,
      TaskState.unassigned, TaskState.blocked,
    ];
    _tasks = [
      for (var i = 0; i < titles.length; i++)
        StaffTask(
          id: 'TK${100 + i}',
          title: titles[i],
          kind: kinds[i % kinds.length],
          state: taskStates[i % taskStates.length],
          assignee: assignees[i % assignees.length],
          roomNumber: i % 3 == 0 ? null : _rooms[i].number,
          due: _today.add(Duration(hours: (i % 5) - 1)),
        ),
    ];

    const reqs = [
      'Extra towels and a bathrobe',
      'Airport drop at 04:30 tomorrow',
      'Room service — South Indian breakfast',
      'Iron and ironing board',
      'Late check-out until 2pm',
    ];
    _requests = [
      for (var i = 0; i < reqs.length; i++)
        GuestRequest(
          id: 'GR${50 + i}',
          guestName: guests[i],
          roomNumber: _rooms[i * 3].number,
          request: reqs[i],
          raisedAt: _today.subtract(Duration(minutes: 7 + i * 23)),
          state: i < 2 ? TaskState.unassigned : TaskState.inProgress,
          assignee: i < 2 ? null : assignees[i % 3],
        ),
    ];
  }
}
