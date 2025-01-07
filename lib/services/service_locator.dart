import 'api_service.dart';
import 'user_service.dart';
import 'project_service.dart';
import 'event_service.dart';
import 'api_constants.dart';

class ServiceLocator {
    static final String baseUrl = 'http://10.0.2.2:3000';
  static final ApiService apiService = ApiService(ApiConstants.baseUrl);
  static final UserService userService = UserService(apiService);
  static final ProjectService projectService = ProjectService(apiService);
  static final EventService eventService = EventService(baseUrl);
}
