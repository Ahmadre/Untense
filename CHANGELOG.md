# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-17

### Added

- **Core Tracking**: Tension level slider (0–100) with three therapeutic zones: Mindfulness (0–30), Emotion Regulation (30–70), Stress Tolerance (70–100)
- **Custom Zone-Colored Slider**: Single-bar slider with permanently painted zone colors and precise label positioning
- **Situation & Feeling Input**: Free-text fields per entry to capture context
- **Emotion Tagging**: 18 predefined emotions (anger, fear, sadness, joy, disgust, surprise, shame, guilt, loneliness, frustration, anxiety, contentment, love, hope, gratitude, overwhelm, numbness, restlessness)
- **Notes**: Optional free-text notes per entry
- **Entry Modal Sheet**: WoltModalSheet-based add/edit flow (bottom sheet on mobile, dialog on desktop)
- **History Page**: Chronological list of all entries with search, filtering, and period-based views (Week, Month, Year)
- **Charts & Analytics**: Interactive tension charts via fl_chart with responsive height and stats row (average, max, min, entry count)
- **PDF Therapeutic Report**: Comprehensive export for therapists with summary statistics, zone distribution, emotion profile, daily overview, detailed entries, and disclaimer — supports anonymous or named reports with configurable date ranges
- **Data Export/Import**: JSON-based backup and restore via file picker and share dialog
- **Notifications**: Configurable daily reminders
- **Internationalization**: Full German (de-DE) and English (en-GB) support via i18next
- **Responsive Layout**: Liquid glass bottom navigation on mobile/tablet, NavigationRail on desktop (≥840dp)
- **Dark Mode**: Full dark theme support with custom splash screen (logo + animated loading bar)
- **App Branding**: Custom launcher icons for Android, iOS, and Web; native splash screen
- **PWA Support**: Progressive Web App with manifest, service worker, and Docker deployment (multi-stage Flutter → nginx)
- **CI/CD Pipeline**: GitHub Actions workflow with path-filtered triggers, Docker build, private registry push, and Watchtower auto-update
- **Clean Architecture**: Layered architecture (Presentation → Domain → Data) with BLoC state management, Hive local storage, and GetIt dependency injection
- **Offline-First**: All data stored locally via Hive — no cloud dependency, full privacy
- **Settings Page**: Theme selection, language switch, notification configuration, data management (export, import, PDF report, delete all)
