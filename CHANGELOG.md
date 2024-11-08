## 0.0.1

### Initial Release
- Introduced `NavManagerConfig` for configuring module registration.
- Added `Module` interface for registering dependencies and routes.
- Implemented `NavManager` for flexible dependency injection.
- Provided `GetItNavManager` as an optional dependency injection mechanism with support for `singleton`, `lazySingleton`, and `factory` scopes.
- Support for both local and remote modules with automatic configuration.
- Added customizable dependency injection options to use `GetIt` or other DI packages.
- Introduced `NavRouter` abstraction for managing navigation logic in a modular way.