# Free Trial Limit Feature

This feature implements trial period limitations for the Pockeat app. It restricts access to premium features once the free trial period has ended and directs users to the beta tester registration page.

## Components

### Services

- `FreeLimitService`: Core service that handles checking trial validity and redirecting users when their trial has expired.

### Screens

- `FreeTrialStatusScreen`: Shows detailed information about the current trial status, including progress, days remaining, and benefits.
- `TrialEndedScreen`: Displays when a user attempts to access a premium feature after their trial has ended, encouraging them to become a beta tester.

## How It Works

1. When a user attempts to access a premium feature (like food or exercise tracking), the `FreeLimitService.checkAndRedirect()` method is called.
2. If the trial is valid, the user can access the feature.
3. If the trial has expired, the user is redirected to the `TrialEndedScreen`.
4. From there, users can apply to become beta testers for continued access or return to the home screen.

## Integration Points

- `ExerciseInputPage` and `FoodInputPage` both check trial validity on page load.
- The service is registered in the dependency injection system (`service_locator.dart`).
- Trial validation logic relies on the `UserModel.isInFreeTrial` property.

## Usage

To add trial restriction to a new screen:

```dart
class MyPremiumFeaturePage extends StatefulWidget {
  @override
  State<MyPremiumFeaturePage> createState() => _MyPremiumFeaturePageState();
}

class _MyPremiumFeaturePageState extends State<MyPremiumFeaturePage> {
  final FreeLimitService _freeLimitService = GetIt.instance<FreeLimitService>();

  @override
  void initState() {
    super.initState();
    // Check if trial is valid when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTrialValidity();
    });
  }
  
  // Check if user can access this feature
  Future<void> _checkTrialValidity() async {
    await _freeLimitService.checkAndRedirect(context);
  }
  
  // Rest of the implementation...
}
```
