import 'package:hero/core/enums/app_role.dart';
import 'package:hero/core/models/app_menu_item.dart';

abstract class MenuRepository {
  Future<List<AppMenuItem>> fetchMenus(AppRole role);
}
