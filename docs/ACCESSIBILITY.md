# Ishara — Accessibility Statement

## Commitment

Ishara is designed from the ground up for **deaf and hard-of-hearing (D/HH)** users. Accessibility is not an afterthought — it is the core product mission.

## WCAG 2.1 Conformance

Ishara targets **WCAG 2.1 Level AA** conformance for all interactive elements.

### Perceivable (Principle 1)

| Guideline | Status | Implementation |
|-----------|--------|----------------|
| 1.1 Text Alternatives | ✅ Met | All interactive icons have semantic labels or tooltips |
| 1.2 Time-based Media | ✅ Met | Camera/mic are live input, not pre-recorded media |
| 1.3 Adaptable | ✅ Met | App layout uses standard Material 3 components with semantic structure |
| 1.4 Distinguishable | ✅ Met | Light/dark themes with high-contrast color tokens; text sizes follow Material type scale |

### Operable (Principle 2)

| Guideline | Status | Implementation |
|-----------|--------|----------------|
| 2.1 Keyboard Accessible | ✅ Met | All controls are focusable; Flutter handles focus traversal automatically |
| 2.2 Enough Time | ✅ Met | No timed actions; all alerts persist until dismissed |
| 2.3 Seizures | ✅ Met | Visual flash alerts use a single brief highlight, not strobing patterns |
| 2.4 Navigable | ✅ Met | Bottom navigation, AppBars with back buttons, clear page titles |

### Understandable (Principle 3)

| Guideline | Status | Implementation |
|-----------|--------|----------------|
| 3.1 Readable | ✅ Met | Simple, clear language throughout UI and AI responses |
| 3.2 Predictable | ✅ Met | Consistent navigation pattern (bottom nav), no unexpected redirects |
| 3.3 Input Assistance | ✅ Met | Form fields have hints, validation errors shown inline |

### Robust (Principle 4)

| Guideline | Status | Implementation |
|-----------|--------|----------------|
| 4.1 Compatible | ✅ Met | Uses Flutter's Semantics framework for TalkBack/VoiceOver compatibility |

## Assistive Technology Support

### Screen Readers (TalkBack / VoiceOver)
- All buttons, icons, and controls expose semantic labels
- Live regions announce sign interpretations and sound alerts dynamically via `SemanticsService.announce()`
- Navigation landmarks are defined by standard Material AppBar/BottomNavigationBar widgets

### Multi-Sensory Alerts
Sound awareness alerts use **three simultaneous channels** to ensure no alert is missed:
1. **Visual**: Screen flash + on-screen card with sound classification
2. **Haptic**: Distinct vibration patterns for warning vs. critical levels
3. **Audio/TTS**: Screen reader announcement and notification

### Dark Mode
Full dark theme support reduces eye strain and improves readability in low-light environments. Persisted across sessions.

## Design Decisions for D/HH Users

| Decision | Rationale |
|----------|-----------|
| Text-based emergency SOS | Eliminates the need for voice calls; emergency messages include note that sender is deaf |
| On-device pose detection | Works offline; no need for network to detect signing |
| Sign dictionary with emojis | Visual association aids recognition and learning |
| AI chat (text-only) | Primary interaction channel for D/HH users who communicate via text |
| Operator chat in emergency | Text relay for communicating with emergency responders |
| Configurable sound thresholds | Users can adjust what sound levels trigger alerts based on their environment |

## Known Limitations

- **Text scaling**: App respects system font size but has not been tested at extreme scale factors (> 2x)
- **Right-to-left (RTL)**: Not yet tested with RTL languages
- **Switch access**: Not explicitly tested with switch control devices
- **Color blindness**: Theme colors have not been validated against all color vision deficiency types

## Feedback

If you encounter accessibility barriers, please open a GitHub issue at:
https://github.com/Medialordofficial/Ishara/issues
