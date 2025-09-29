class ApiUrl {
  // LOCAL

  static const baseUrl = "http://resco-billing.omcpower.co.in/";
  // static const baseUrl = "http://103.255.64.69:81/";
  // static const buildApiUrl = '${baseUrl}swooosh_admin/api/';
  // static const imageUrl = '${baseUrl}swooosh_admin/public/storage/';

  //LIVE
  static const buildApiUrl = '${baseUrl}api/';
  static const imageUrl = '${baseUrl}public/storage';

  //AUTH
  static const login = 'login';

  //dashboard
  static const graphicaldashboard = 'graphical-dashboard';
  static const getbillingMonth = 'get-billing-month-year';

  //add meter
  static const getcustomerbyIdwwithoutpagination =
      'billing-customer-meter?user_id=';
  static const getmeterbyId = 'get-meters-by-customers';
  static const getmeterdetail = 'get-meter-details';

  //fillter
  static const getfillter = 'get';

  //customer list
  static const getcustomerbyIdwwithpagination = 'get-customers-by-user?user_id';

  //add meter
  static const meterreadingsubmit = 'meter-reading';
}
