# Viam Provisioning App Example

This project is a Flutter-based template that serves as a starting point for building a mobile application to provision Viam-powered devices. It provides a solid foundation with essential features already implemented, allowing you to focus on your specific needs and branding.

The application uses the official Viam Flutter SDK, which includes a provisioning widget that leverages Bluetooth for a seamless setup experience.

## Getting Started

Before you begin, ensure you have the Flutter development environment set up on your machine. For detailed instructions, please refer to the [official Flutter documentation](https://docs.flutter.dev/get-started/install).

### Customization

As a template, this project requires some customization to make it your own. Below is a checklist of items you'll need to update:

**1. Application Identifiers:**

- **Android:** In `android/app/build.gradle.kts`, change the `applicationId` to your unique package name.
- **iOS:** In XCode, update the `Bundle Identifier` under `Runner > Targets > General`.

**2. Logos and Branding:**

- **App Icons:** Replace the launch icon, see the flutter_launcher_icons section in pubspec.yaml
- **In-App Logos:** The logos used on the login screen and main menu can be found in the `images/` directory. Replace these with your own assets and update the references in the following files:
  - `lib/screens/login/login_screen.dart`
  - `lib/screens/home/widgets/menu.dart`

**3. Authentication Keys:**

The application uses `flutter_appauth` for OAuth 2.0. You will need to configure it with your own authentication credentials. Look for the `TODO` comments in the following files:

- `lib/consts.dart`: Replace the placeholder URLs with your own.
- `lib/auth/auth_service.dart`: Update the client IDs and other authentication parameters.

**4. Machine Naming Schema:**

The app provides a default naming convention for newly created machines. You can customize this to fit your needs:

- `lib/screens/create_machine/create_machine_view_model.dart`: Look for the `_machineName` getter and implement your own naming logic. The `TODO` comment will guide you to the right place.


## Features

This template comes with a rich set of features to get you started:

-   **Authentication:** A complete login flow using Viam's OAuth 2.0 integration, with secure credential storage via `flutter_secure_storage`.
-   **Organization Switching:** A simple interface for users to switch between their Viam organizations.
-   **Machine Fleet Overview:** A flattened list of all machines across all locations within a selected organization, making it easy to see every machine at a glance.
-   **Real-time Machine Status:** See the live status of each machine (e.g., `online`, `offline`).
-   **Provisioning Flow:** A seamless, integrated provisioning process powered by Viam's Bluetooth LE widget.
-   **Machine Creation:** A simple workflow to create a new location and provision a new machine within it.

## Project Structure

The project is organized by feature, with each screen having its own directory containing the view, view model, and any related widgets. This structure is designed to be scalable and easy to maintain.

-   `lib/auth/`: Contains the authentication service and related logic.
-   `lib/data/`: Houses the repositories and services that interact with the Viam API and local storage.
-   `lib/screens/`: Contains all the application's screens, organized by feature.
-   `lib/routing/`: Manages the application's navigation using `go_router`.
-   `lib/theme/`: Defines the application's color scheme and overall theme.

## Architecture

This template is designed to provide a clear and scalable starting point for developers, whether they are seasoned with Flutter or just getting started. The architecture follows the official recommendations from the Flutter team, emphasizing a clean separation of concerns between the UI, business logic, and data layers. You can read more about these recommendations [here](https://docs.flutter.dev/app-architecture).

For state management, this project uses a combination of `ChangeNotifier` (via View Models) and the `provider` package. This approach was chosen for its simplicity and low boilerplate, making it easy to understand and extend. However, the architecture is decoupled enough that you can readily swap `provider` for another state management solution like BLoC or Riverpod if it better suits your team's preferences or project complexity.
