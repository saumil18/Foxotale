import '../access/role.dart';

enum RoomState {
  vacantClean('Vacant clean'),
  vacantDirty('Vacant dirty'),
  occupied('Occupied'),
  inspected('Inspected'),
  outOfOrder('Out of order'),
  outOfService('Out of service');

  const RoomState(this.label);
  final String label;
}

enum PaymentState {
  paid('Paid'),
  partPaid('Part paid'),
  pending('Pending'),
  overdue('Overdue');

  const PaymentState(this.label);
  final String label;
}

enum TaskState {
  unassigned('Unassigned'),
  assigned('Assigned'),
  inProgress('In progress'),
  blocked('Blocked'),
  done('Done');

  const TaskState(this.label);
  final String label;
}

enum TaskKind {
  housekeeping('Housekeeping'),
  maintenance('Maintenance'),
  frontDesk('Front desk'),
  fnb('F&B'),
  guestRequest('Guest request');

  const TaskKind(this.label);
  final String label;
}

enum BookingSegment {
  corporate('Corporate'),
  ota('OTA'),
  direct('Direct'),
  travelAgent('Travel agent'),
  walkIn('Walk-in'),
  banquet('Banquet');

  const BookingSegment(this.label);
  final String label;
}

class Property {
  const Property({
    required this.id,
    required this.name,
    required this.city,
    required this.totalRooms,
  });

  final String id;
  final String name;
  final String city;
  final int totalRooms;
}

class Room {
  const Room({
    required this.number,
    required this.type,
    required this.floor,
    required this.state,
    this.guestName,
  });

  final String number;
  final String type;
  final int floor;
  final RoomState state;
  final String? guestName;

  Room copyWith({RoomState? state}) => Room(
        number: number,
        type: type,
        floor: floor,
        state: state ?? this.state,
        guestName: guestName,
      );
}

class Booking {
  const Booking({
    required this.id,
    required this.guestName,
    required this.roomNumber,
    required this.roomType,
    required this.checkIn,
    required this.checkOut,
    required this.nights,
    required this.totalAmount,
    required this.amountPaid,
    required this.segment,
    required this.source,
    this.corporate,
  });

  final String id;
  final String guestName;
  final String roomNumber;
  final String roomType;
  final DateTime checkIn;
  final DateTime checkOut;
  final int nights;
  final int totalAmount;
  final int amountPaid;
  final BookingSegment segment;
  final String source;
  final String? corporate;

  int get balance => totalAmount - amountPaid;

  PaymentState get paymentState {
    if (balance <= 0) return PaymentState.paid;
    if (amountPaid > 0) return PaymentState.partPaid;
    return checkOut.isBefore(DateTime.now())
        ? PaymentState.overdue
        : PaymentState.pending;
  }
}

class StaffTask {
  const StaffTask({
    required this.id,
    required this.title,
    required this.kind,
    required this.state,
    required this.assignee,
    required this.roomNumber,
    required this.due,
    this.note,
  });

  final String id;
  final String title;
  final TaskKind kind;
  final TaskState state;

  /// Every task has an owner and a status; nothing is lost (PRD goal 6).
  final String assignee;
  final String? roomNumber;
  final DateTime due;
  final String? note;

  bool get isOverdue => state != TaskState.done && due.isBefore(DateTime.now());

  StaffTask copyWith({TaskState? state, String? assignee}) => StaffTask(
        id: id,
        title: title,
        kind: kind,
        state: state ?? this.state,
        assignee: assignee ?? this.assignee,
        roomNumber: roomNumber,
        due: due,
        note: note,
      );
}

class GuestRequest {
  const GuestRequest({
    required this.id,
    required this.guestName,
    required this.roomNumber,
    required this.request,
    required this.raisedAt,
    required this.state,
    required this.assignee,
  });

  final String id;
  final String guestName;
  final String roomNumber;
  final String request;
  final DateTime raisedAt;
  final TaskState state;
  final String? assignee;

  Duration get waiting => DateTime.now().difference(raisedAt);

  GuestRequest copyWith({TaskState? state, String? assignee}) => GuestRequest(
        id: id,
        guestName: guestName,
        roomNumber: roomNumber,
        request: request,
        raisedAt: raisedAt,
        state: state ?? this.state,
        assignee: assignee ?? this.assignee,
      );
}

class SegmentRevenue {
  const SegmentRevenue({
    required this.segment,
    required this.revenue,
    required this.roomNights,
    required this.budget,
  });

  final BookingSegment segment;
  final int revenue;
  final int roomNights;
  final int budget;

  int get variance => revenue - budget;
  int get arr => roomNights == 0 ? 0 : revenue ~/ roomNights;
}

class CorporateAccount {
  const CorporateAccount({
    required this.name,
    required this.kind,
    required this.roomNights,
    required this.revenue,
  });

  final String name;
  final String kind;
  final int roomNights;
  final int revenue;

  int get arr => roomNights == 0 ? 0 : revenue ~/ roomNights;
}

class StaffMember {
  const StaffMember({
    required this.name,
    required this.role,
    required this.department,
    required this.onShift,
  });

  final String name;
  final FoxRole role;
  final String department;
  final bool onShift;
}
