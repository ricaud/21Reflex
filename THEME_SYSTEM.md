# 21Reflex Theme System Documentation

## Overview

The 21Reflex theme system is a **protocol-based architecture** that allows for complete visual transformation of the app. Unlike traditional theme systems that only change colors, this system enables themes to:

- Render completely different button styles (glass vs hand-drawn vs pixel art)
- Use custom shapes with wobbly edges or perfect pixels
- Define unique typography (serif, handwritten, pixel fonts)
- Specify animation personalities (smooth, bouncy, glitch, wobbly)
- Provide custom audio and music

## Architecture

### Core Protocol: `AppTheme`

All themes conform to `AppTheme`, which defines factory methods for every UI component:

```swift
protocol AppTheme: ObservableObject {
    // Identity
    var id: String { get }
    var name: String { get }
    var cost: Int { get }
    var description: String { get }

    // Component Factories
    func makeBackground() -> AnyView
    func makeButton(style: ThemeButtonStyle, title: String, icon: String?, action: @escaping () -> Void) -> AnyView
    func makeCardView(card: Card) -> AnyView
    func makeTimerBar(progress: Double) -> AnyView
    // ... and more

    // Typography
    func font(for style: FontStyle) -> Font
    func fontColor(for style: FontStyle) -> Color

    // Animation & Audio
    var animationStyle: AnimationStyle { get }
    var soundEffectStyle: SoundEffectStyle { get }
    var themeSongFilename: String? { get }
}
```

### Theme Categories

Themes are organized into categories with shared base classes:

| Category | Base Class | Visual Style | Example Themes |
|----------|------------|--------------|----------------|
| Glass | `GlassTheme` | Refined, translucent, iOS-native | Slate, Ocean, Midnight |
| Playful | `PlayfulTheme` | Thick borders, solid fills, fun | Classic Retro, Candy, Arcade |
| Hand Drawn | `HandDrawnTheme` | Sketchy, wobbly, artistic | Sketchbook, Crayon |
| Retro | `RetroTheme` | Pixel art, CRT effects | Pixel, CRT Monitor, Vaporwave |
| Luxury | `LuxuryTheme` | Premium, shimmering | Gold, Diamond |

## Creating a New Theme

### Step 1: Choose a Base Class

Select the base class that best matches your desired aesthetic:

```swift
// For refined glass themes
final class MyGlassTheme: GlassTheme { }

// For thick-bordered fun themes
final class MyPlayfulTheme: PlayfulTheme { }

// For hand-drawn artistic themes
final class MySketchTheme: HandDrawnTheme { }

// For pixel/retro themes
final class MyRetroTheme: RetroTheme { }
```

### Step 2: Override Identity Properties

```swift
final class NeonNightTheme: GlassTheme {
    override var id: String { "neon_night" }
    override var name: String { "Neon Night" }
    override var cost: Int { 300 }
    override var description: String { "Cyberpunk neon with electric accents" }
    override var previewImageName: String? { "preview_neon_night" }
}
```

### Step 3: Override Colors

Each base class has color properties to customize:

```swift
final class NeonNightTheme: GlassTheme {
    override var backgroundColor: Color { Color(hex: "#0A0A1A") }
    override var accentColor: Color { Color(hex: "#FF00FF") }  // Magenta
    override var secondaryColor: Color { Color(hex: "#00FFFF") }  // Cyan
    override var textColor: Color { .white }
}
```

### Step 4: Override Component Methods (Optional)

For complete control, override any factory method:

```swift
override func makeButton(style: ThemeButtonStyle, title: String, icon: String?, action: @escaping () -> Void) -> AnyView {
    AnyView(
        Button(action: action) {
            HStack {
                if let icon { Image(systemName: icon) }
                Text(title)
            }
            .font(font(for: .button))
            .foregroundStyle(textColor)
            .frame(maxWidth: .infinity, minHeight: 54)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(accentColor.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(accentColor, lineWidth: 2)
                    )
            )
            .shadow(color: accentColor.opacity(0.5), radius: 8, x: 0, y: 0)
        }
    )
}
```

### Step 5: Register the Theme

Add your theme to `ThemeRegistry.swift`:

```swift
private func registerDefaultThemes() {
    allThemes = [
        // Existing themes...
        NeonNightTheme(),  // Add your theme here
    ]
}
```

## Component Reference

### Background

```swift
func makeBackground() -> AnyView
```

Returns the background view for all screens.

**Examples:**
- Glass: Gradient with `.ultraThinMaterial` overlay
- Sketchbook: Paper texture with notebook lines
- CRT: Black with scanline overlay

### Buttons

```swift
func makeButton(
    style: ThemeButtonStyle,
    title: String,
    icon: String?,
    action: @escaping () -> Void
) -> AnyView
```

**ThemeButtonStyle values:**
- `.primary` - Main action buttons
- `.secondary` - Alternative actions
- `.destructive` - Delete/reset actions
- `.answerCorrect` - Correct answer state
- `.answerWrong` - Wrong answer state
- `.answerNeutral` - Default answer button
- `.specialAction` - Bust/Blackjack buttons

### Cards

```swift
func makeCardView(card: Card) -> AnyView
func makeCardBack() -> AnyView
```

Render playing cards. Consider your theme's visual style:
- Glass: Clean, rounded rectangles with subtle shadows
- Sketch: Wobbly edges using `RoughRectangle`
- Pixel: Sharp edges using `PixelRectangle`

### Timer Bar

```swift
func makeTimerBar(progress: Double) -> AnyView
```

Progress value is 0.0 to 1.0.

**Examples:**
- Glass: Smooth rounded rectangle with gradient fill
- Sketch: Pencil-drawn container with segmented fill
- Pixel: Discrete pixel blocks

### Typography

```swift
func font(for style: FontStyle) -> Font
func fontColor(for style: FontStyle) -> Color
```

**FontStyle values:**
- `.titleLarge` - "Paused", "Game Over"
- `.titleMedium` - Section headers
- `.body` - Regular text
- `.button` - Button labels
- `.numericLarge` - Scores, card values
- `.cardRank`, `.cardSuit` - Card text

## Custom Shapes

### RoughRectangle

Hand-drawn rectangle with wobbly edges:

```swift
RoughRectangle(cornerRadius: 8, roughness: 2.0)
    .fill(Color.white)
    .stroke(Color.black, lineWidth: 2)
```

**Parameters:**
- `cornerRadius`: Corner roundness
- `roughness`: Amount of wobble (0 = perfect, higher = more rough)

### PixelRectangle

Sharp pixel-aligned rectangle:

```swift
PixelRectangle(pixelSize: 4)
    .fill(Color.green)
```

### ScanlineOverlay

CRT monitor effect:

```swift
ScanlineOverlay(
    lineSpacing: 4,
    lineOpacity: 0.4,
    glowIntensity: 0.1
)
```

## Animation Styles

Set `animationStyle` to control the feel:

| Style | Description | Best For |
|-------|-------------|----------|
| `.smooth` | iOS default, elegant | Glass themes |
| `.bouncy` | Springy, energetic | Playful themes |
| `.instant` | No animation | Pixel/retro themes |
| `.wobbly` | Hand-drawn feel | Sketch themes |
| `.glitch` | Quick, jerky | Cyberpunk themes |
| `.elastic` | Exaggerated spring | Cartoon themes |

## Audio Integration

Themes can provide custom music by conforming to `ThemeAudio`:

```swift
final class ArcadeTheme: PlayfulTheme, ThemeAudio {
    var menuMusic: String? { "arcade_menu" }
    var gameMusic: String? { "arcade_game" }
    var gameOverMusic: String? { "arcade_over" }

    func soundEffect(for event: SoundEvent) -> String? {
        switch event {
        case .correctAnswer: return "arcade_correct"
        case .wrongAnswer: return "arcade_wrong"
        default: return nil
        }
    }
}
```

**Sound Events:**
- `.correctAnswer`
- `.wrongAnswer`
- `.buttonTap`
- `.cardDeal`
- `.cardFlip`
- `.gameOver`
- `.coinEarned`

Add audio files to `Resources/ThemeAudio/{theme_id}/`.

## Best Practices

### 1. Contrast is Key

Ensure text is readable on your background:

```swift
func contrastingTextColor(for background: Color) -> Color {
    isColorDark(background) ? .white : .black
}
```

### 2. Consistent Spacing

Use standard frame sizes for buttons:
- Height: 50-54 points
- Max width: `.infinity`

### 3. Accessibility

Maintain WCAG contrast ratios:
- Normal text: 4.5:1 minimum
- Large text: 3:1 minimum

### 4. Test Animations

Ensure your theme's animation style works well:
- Button presses should feel responsive
- Card dealing should be visible but not slow
- Feedback should be immediate

### 5. Preview Your Theme

Use the preview canvas to test:

```swift
#Preview("My Theme") {
    ZStack {
        MyTheme().makeBackground()

        VStack {
            MyTheme().makeButton(style: .primary, title: "Test", icon: nil, action: {})
            MyTheme().makeCardView(card: Card(rank: .ace, suit: .spades))
        }
    }
}
```

## Example: Complete Theme Implementation

Here's a complete "Neon Night" theme:

```swift
import SwiftUI

final class NeonNightTheme: GlassTheme {
    // Identity
    override var id: String { "neon_night" }
    override var name: String { "Neon Night" }
    override var cost: Int { 400 }
    override var description: String { "Cyberpunk neon with glitch effects" }

    // Colors
    override var backgroundColor: Color { Color(hex: "#0A0A1A") }
    override var accentColor: Color { Color(hex: "#FF00FF") }
    override var secondaryColor: Color { Color(hex: "#00FFFF") }
    override var textColor: Color { .white }

    // Animation
    override var animationStyle: AnimationStyle { .glitch }
    override var soundEffectStyle: SoundEffectStyle { .futuristic }

    // Custom background with grid
    override func makeBackground() -> AnyView {
        AnyView(
            ZStack {
                backgroundColor

                // Neon grid
                GeometryReader { geo in
                    VStack(spacing: 40) {
                        ForEach(0..<Int(geo.size.height/40)) { _ in
                            Rectangle()
                                .fill(accentColor.opacity(0.2))
                                .frame(height: 1)
                        }
                    }
                }

                // Glow overlay
                RadialGradient(
                    colors: [accentColor.opacity(0.1), .clear],
                    center: .center,
                    startRadius: 100,
                    endRadius: 400
                )
            }
            .ignoresSafeArea()
        )
    }
}
```

## Troubleshooting

### Theme not appearing in store

- Ensure theme is registered in `ThemeRegistry.registerDefaultThemes()`
- Check that `id` is unique
- Verify `cost` is >= 0

### Build errors about missing types

The SourceKit errors about missing types are normal during development - the files reference each other and will resolve when compiled as a module.

### Colors not appearing correctly

- Use `Color(hex: "#RRGGBB")` from `BaseTheme`
- Ensure hex strings include the `#` prefix
- Check alpha values if using opacity

### Custom fonts not working

- Add font files to the app bundle
- Register fonts in Info.plist
- Use exact PostScript name: `.custom("FontName", size: 16)`

## File Organization

```
Themes/
├── Protocols/
│   ├── AppTheme.swift          # Main protocol
│   ├── ThemeAudio.swift        # Audio protocol
│   └── ThemeAnimations.swift   # Animation helpers
├── Base/
│   └── BaseTheme.swift         # Shared helpers
├── Components/
│   ├── RoughRectangle.swift    # Hand-drawn shape
│   ├── PixelShape.swift        # Pixel art shapes
│   ├── ScanlineOverlay.swift   # CRT effect
│   └── ThemeComponents.swift   # Reusable builders
├── Glass/
│   ├── GlassTheme.swift
│   ├── SlateTheme.swift
│   └── ...
├── Playful/
│   ├── PlayfulTheme.swift
│   ├── ClassicRetroTheme.swift
│   └── ...
├── HandDrawn/
│   ├── HandDrawnTheme.swift
│   ├── SketchbookTheme.swift
│   └── ...
├── Retro/
│   ├── RetroTheme.swift
│   ├── PixelTheme.swift
│   └── ...
├── Luxury/
│   ├── LuxuryTheme.swift
│   ├── GoldTheme.swift
│   └── ...
└── Registry/
    └── ThemeRegistry.swift     # Theme registration
```

---

For questions or to add new theme categories, refer to the existing implementations as examples.
