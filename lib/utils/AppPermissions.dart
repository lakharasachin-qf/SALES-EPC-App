import 'package:sales_app/models/login_model.dart';
import 'package:sales_app/preference/UserPreference.dart';

class AppPermissions {
  static final AppPermissions _instance = AppPermissions._internal();
  factory AppPermissions() => _instance;
  AppPermissions._internal();

  // Internal map to store rights dynamically
  final Map<String, bool> _rights = {};

  // --- Boolean getters for each right ---
  bool get isLeadManagement => _rights['lead_management'] ?? false;
  bool get canAddLead => _rights['add_lead'] ?? false;
  bool get canUpdateLead => _rights['update_lead'] ?? false;
  bool get canDeleteLead => _rights['delete_lead'] ?? false;

  bool get canUploadProposals => _rights['upload_proposals'] ?? false;
  bool get canManageProposals => _rights['manage_proposals'] ?? false;

  bool get canUploadFinanceDocuments =>
      _rights['upload_finance_documents'] ?? false;
  bool get canManageFinanceDocuments =>
      _rights['manage_finance_documents'] ?? false;

  bool get isAdministration => _rights['administration'] ?? false;
  bool get isUserManagement => _rights['user_management'] ?? false;
  bool get canAddUser => _rights['add_user'] ?? false;
  bool get canUpdateUser => _rights['update_user'] ?? false;
  bool get canDeleteUser => _rights['delete_user'] ?? false;

  bool get isRoleManagement => _rights['role_management'] ?? false;
  bool get canAddRole => _rights['add_role'] ?? false;
  bool get canUpdateRole => _rights['update_role'] ?? false;
  bool get canDeleteRole => _rights['delete_role'] ?? false;

  bool get isClusterManagement => _rights['clusters'] ?? false;
  bool get canAddCluster => _rights['add_cluster'] ?? false;
  bool get canUpdateCluster => _rights['update_cluster'] ?? false;
  bool get canDeleteCluster => _rights['delete_cluster'] ?? false;

  bool get isDistrictManagement => _rights['district_management'] ?? false;
  bool get canAddDistrict => _rights['add_district'] ?? false;
  bool get canUpdateDistrict => _rights['update_district'] ?? false;
  bool get canDeleteDistrict => _rights['delete_district'] ?? false;

  bool get isCustomerManagement => _rights['customer_management'] ?? false;
  bool get canUpdateCustomer => _rights['update_customer'] ?? false;
  bool get canViewCustomer => _rights['view_customer'] ?? false;

  bool get isTargetManagement => _rights['target_management'] ?? false;
  bool get canAddTarget => _rights['add_target'] ?? false;
  bool get canUpdateTarget => _rights['update_target'] ?? false;
  bool get canDeleteTarget => _rights['delete_target'] ?? false;

  bool get canAccessDashboard => _rights['dashboard'] ?? false;
  bool get canUploadFiles => _rights['upload_files'] ?? false;
  bool get canManageFiles => _rights['manage_files'] ?? false;
  bool get canAccessMeetingCalendar => _rights['meeting_calendar'] ?? false;
  bool get canViewReport => _rights['report'] ?? false;

  /// Initialize all boolean flags from rights list
  void setRights(List<String> rights) {
    _rights.clear();
    for (var right in rights) {
      _rights[right] = true;
    }
  }

  /// Load rights from SharedPreferences
  Future<void> loadRights() async {
    User? user = await UserPreferences().getSignInInfo();
    if (user != null && user.rights.isNotEmpty) {
      setRights(user.rights);
    }
  }

  /// --- Check if a user has a specific right ---
  bool hasRight(String right) {
    return _rights[right] ?? false;
  }

  /// --- Check if user has any of the rights ---
  bool hasAny(List<String> rights) {
    for (var right in rights) {
      if (_rights[right] == true) return true;
    }
    return false;
  }

  /// --- Check if user has all of the rights ---
  bool hasAll(List<String> rights) {
    for (var right in rights) {
      if (_rights[right] != true) return false;
    }
    return true;
  }
}
