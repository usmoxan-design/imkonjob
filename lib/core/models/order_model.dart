import 'package:equatable/equatable.dart';
import 'provider_model.dart';

enum OrderStatus {
  searching,
  proposalsReceived,
  providerSelected,
  onTheWay,
  arrived,
  inProgress,
  completed,
  cancelled,
}

enum OrderType { quick, scheduled, tender }

class OrderProposalModel extends Equatable {
  final String id;
  final ProviderModel provider;
  final double price;
  final String estimatedArrival;
  final String note;

  const OrderProposalModel({
    required this.id,
    required this.provider,
    required this.price,
    required this.estimatedArrival,
    required this.note,
  });

  @override
  List<Object?> get props => [id, provider, price, estimatedArrival, note];
}

class OrderModel extends Equatable {
  final String id;
  final String serviceType;
  final String description;
  final String address;
  final OrderStatus status;
  final OrderType type;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final ProviderModel? provider;
  final double? estimatedPrice;
  final String? estimatedArrival;
  final List<OrderProposalModel> proposals;

  const OrderModel({
    required this.id,
    required this.serviceType,
    required this.description,
    required this.address,
    required this.status,
    required this.type,
    required this.createdAt,
    this.scheduledAt,
    this.provider,
    this.estimatedPrice,
    this.estimatedArrival,
    this.proposals = const [],
  });

  OrderModel copyWith({
    String? id,
    String? serviceType,
    String? description,
    String? address,
    OrderStatus? status,
    OrderType? type,
    DateTime? createdAt,
    DateTime? scheduledAt,
    ProviderModel? provider,
    double? estimatedPrice,
    String? estimatedArrival,
    List<OrderProposalModel>? proposals,
  }) {
    return OrderModel(
      id: id ?? this.id,
      serviceType: serviceType ?? this.serviceType,
      description: description ?? this.description,
      address: address ?? this.address,
      status: status ?? this.status,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      provider: provider ?? this.provider,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      estimatedArrival: estimatedArrival ?? this.estimatedArrival,
      proposals: proposals ?? this.proposals,
    );
  }

  String get statusLabel {
    switch (status) {
      case OrderStatus.searching:
        return 'Qidirilmoqda';
      case OrderStatus.proposalsReceived:
        return 'Takliflar keldi';
      case OrderStatus.providerSelected:
        return 'Usta tanlandi';
      case OrderStatus.onTheWay:
        return 'Yo\'lda';
      case OrderStatus.arrived:
        return 'Yetib keldi';
      case OrderStatus.inProgress:
        return 'Bajarilyapti';
      case OrderStatus.completed:
        return 'Tugallandi';
      case OrderStatus.cancelled:
        return 'Bekor qilindi';
    }
  }

  @override
  List<Object?> get props => [
        id,
        serviceType,
        description,
        address,
        status,
        type,
        createdAt,
        scheduledAt,
        provider,
        estimatedPrice,
        estimatedArrival,
        proposals,
      ];
}
