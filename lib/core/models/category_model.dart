import 'package:equatable/equatable.dart';

class SubcategoryModel extends Equatable {
  final String id;
  final String name;

  const SubcategoryModel({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}

class CategoryModel extends Equatable {
  final String id;
  final String name;
  final String icon;
  final String color;
  final List<SubcategoryModel> subcategories;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.subcategories = const [],
  });

  @override
  List<Object?> get props => [id, name, icon, color, subcategories];
}
