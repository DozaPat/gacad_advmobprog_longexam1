# GACAD Advanced Mobile Programming - Long Exam 1

A complete Flutter implementation of the Long Exam 1 brief. The app is a
Facebook-inspired campus feed backed by [DummyJSON](https://dummyjson.com/).

## Requirements covered

- Uses the exam's model/service/widget/screen organization.
- Implements the supplied `Post` JSON compatibility fields and post service
  pattern, extended for the current DummyJSON post response.
- Includes responsive Facebook-inspired sign-in, feed, post, comments,
  notifications, profile, and settings interfaces.
- Handles loading, empty, error, retry, and disabled states.
- Uses one author-list request for the feed instead of a request per post.
- Includes model and widget tests and passes static analysis.

## Phase-by-phase implementation

### Phase 0 - Project foundation

The empty repository was initialized as a cross-platform Flutter project. The
PDF's directory structure was created under `assets/` and `lib/`, the requested
packages were added, and Android internet access was enabled.

### Phase 1 - Authentication and persisted session

- `UserService` signs in through `POST /auth/login` and validates a saved token
  through `GET /auth/me`.
- `SessionProvider` stores the complete user/session JSON in
  `SharedPreferences`.
- `SplashScreen` restores the session and routes to either `HomeScreen` or
  `SignInScreen`.
- Invalid or expired API tokens are removed. A valid cached profile can still
  open during a temporary network outage.

### Phase 2 - Feed, profile, preferences, and sign-out

- `PostService.getPosts()` renders the main feed.
- `PostService.getPostsByUser(userId)` renders only the signed-in user's posts
  on the profile screen.
- `ThemeProvider` persists dark mode and notification preferences.
- `SettingsScreen` exposes both preferences and a confirmed sign-out action.

### Phase 3 - Post interactions and comments

- Every post has a clickable like button with immediate visual/count feedback.
- Selecting Comment opens `DetailScreen` and loads
  `GET /comments/post/{postId}`.
- Signed-in users can submit through `POST /comments/add`; the returned comment
  is inserted into the conversation immediately.

DummyJSON simulates create/update/delete operations, so a newly added comment
is returned to the app but is not permanently stored by the service.

## Project structure

```text
assets/
|-- fonts/
|-- icons/
`-- images/
    |-- NUCCITLogo_Black.png
    |-- NUCCITLogo_White.png
    `-- owl.jpg
lib/
|-- models/
|   |-- comment.dart
|   |-- post.dart
|   `-- user.dart
|-- providers/
|   |-- session_provider.dart
|   `-- theme_provider.dart
|-- screens/
|   |-- detail_screen.dart
|   |-- home_screen.dart
|   |-- newsfeed_screen.dart
|   |-- notification_screen.dart
|   |-- profile_screen.dart
|   |-- settings_screen.dart
|   |-- signin_screen.dart
|   `-- splash_screen.dart
|-- services/
|   |-- comment_service.dart
|   |-- post_service.dart
|   `-- user_service.dart
|-- widgets/
|   |-- custom_button.dart
|   |-- custom_dialogs.dart
|   |-- custom_font.dart
|   |-- custom_info.dart
|   |-- custom_inkwell_button.dart
|   |-- custom_textformfield.dart
|   `-- post_card.dart
|-- constants.dart
`-- main.dart
```

The source PDF named two commercial fonts and campus-specific artwork but did
not include their original asset files. The required folders and image
filenames are present as replaceable placeholders; the working UI uses Material
icons and DummyJSON profile images so it does not redistribute unlicensed font
or brand files.

## Run

```sh
flutter pub get
flutter run
```

The DummyJSON documentation's demo account is prefilled:

- Username: `emilys`
- Password: `emilyspass`

## Verify

```sh
flutter analyze
flutter test
```

On Windows installations where the Flutter SDK path contains a space, a native
asset hook may require running Flutter through the SDK's short path. This is a
local toolchain quoting issue, not an application error.

