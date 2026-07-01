# Accessibility
## Sewlio Studio

**Version:** 1.0.0  
**Status:** Draft  
**Owner:** UX Engineering

---

# Purpose

This document defines the accessibility standards for Sewlio Studio.

Accessibility is not an optional feature or a compliance exercise. It is a core product requirement that ensures users with different abilities, hardware, and working environments can successfully create embroidery designs.

Sewlio Studio aims to be accessible while maintaining the precision required for professional design work.

---

# Goals

The application should be usable by:

- Keyboard-only users
- Users with low vision
- Users with color vision deficiencies
- Users using screen readers (where technically practical)
- Users using touch devices
- Users using stylus devices
- Users using assistive pointing devices
- Left-handed and right-handed users

---

# Accessibility Principles

## Perceivable

Information should always be visible, understandable, and distinguishable.

Never rely solely on:

- Color
- Animation
- Icons
- Shape

Every important state should have at least two visual indicators.

---

## Operable

Every action should be possible using multiple input methods.

Supported input methods:

- Mouse
- Keyboard
- Touch
- Apple Pencil
- Android Stylus
- Trackpad
- Pen Tablet

---

## Understandable

The application should behave consistently.

Identical actions should produce identical results.

No hidden workflows.

No unpredictable state changes.

---

## Robust

Accessibility should work consistently across:

- Windows
- macOS
- Linux
- Web
- iPadOS
- Android Tablet

---

# Compliance Target

The long-term goal is alignment with **WCAG 2.2 AA** where applicable to a desktop-grade creative application.

Some professional creative interactions (for example, freehand drawing) cannot always be fully represented to assistive technologies, but all surrounding application functionality should remain accessible.

---

# Supported Input Devices

## Desktop

- Mouse
- Keyboard
- Trackpad
- Drawing Tablet
- Pen Display

---

## Tablet

- Finger
- Apple Pencil
- Android Stylus

---

# Keyboard Navigation

Every primary function must be keyboard accessible.

Examples:

Open Project

Save

Undo

Redo

Zoom

Pan

Rotate View

Switch Tool

Duplicate

Delete

Export

Layer Selection

Panel Navigation

Property Editing

---

## Focus Order

Focus order must follow a predictable pattern.

```
Toolbar

↓

Toolbox

↓

Canvas

↓

Inspector

↓

Layers

↓

History

↓

Status Bar
```

Never trap focus.

---

## Focus Indicators

Focused elements must have:

- Visible outline
- High contrast
- Minimum 2px border equivalent
- Consistent appearance

---

# Keyboard Shortcuts

All major actions require shortcuts.

Examples

| Action | Shortcut |
|----------|----------|
| New | Ctrl/Cmd + N |
| Open | Ctrl/Cmd + O |
| Save | Ctrl/Cmd + S |
| Undo | Ctrl/Cmd + Z |
| Redo | Ctrl/Cmd + Shift + Z |
| Duplicate | Ctrl/Cmd + D |
| Delete | Delete |
| Zoom In | Ctrl/Cmd + + |
| Zoom Out | Ctrl/Cmd + - |
| Fit Canvas | Ctrl/Cmd + 0 |
| Hand Tool | Space |
| Pen Tool | P |
| Selection | V |

Shortcuts should be customizable in future versions.

---

# Screen Reader Support

The following areas should expose semantic information:

Project

Layers

Toolbar

Menus

Buttons

Properties

Dialogs

Settings

History

File Browser

---

The canvas itself cannot realistically expose every stitch or vector node through a screen reader.

Instead:

Selected objects should provide summaries.

Example:

```
Selected Object

Rectangle

Width: 120 mm

Height: 80 mm

Fill Stitch

Estimated Stitches: 4,582

Thread Color: Madeira 1147
```

---

# Color Accessibility

Never rely only on color.

Bad:

Red = Error

Good:

Red icon

+

Error icon

+

Error label

+

Error message

---

# Color Blind Support

Support:

- Protanopia
- Deuteranopia
- Tritanopia

Thread colors should always include:

- Color Name
- Manufacturer Code
- Preview
- Search

Example:

```
Madeira

1147

Deep Red
```

instead of only showing a red circle.

---

# High Contrast Mode

Provide optional high contrast themes.

Increase:

- Border visibility
- Focus indicators
- Panel separation
- Selected object visibility

---

# Themes

Support:

Light

Dark

High Contrast Dark

High Contrast Light

Future:

Custom themes

---

# Typography

Minimum body text:

14 px

Recommended:

16 px

Inspector labels:

14–16 px

Dialogs:

16 px

Never use tiny fixed-size fonts.

Respect system scaling where possible.

---

# Zoom

Entire UI should support scaling.

100%

125%

150%

175%

200%

250%

300%

Canvas zoom is independent from UI zoom.

---

# Canvas Accessibility

Canvas should support:

Smooth Zoom

Pan

Rotate

Fit Selection

Fit Hoop

Fit Artwork

Reset View

---

Selection should remain visible regardless of zoom level.

---

# Touch Targets

Minimum touch target:

44 × 44 pt (Apple Human Interface Guidelines)

Recommended:

48 × 48 dp

Small icons should receive invisible hit-area padding.

---

# Apple Pencil

Support:

Pressure

Tilt (future)

Hover (supported devices)

Double Tap (where supported)

Palm Rejection

---

# Android Stylus

Support:

Pressure

Hover (supported hardware)

Palm rejection where platform provides it

---

# Gesture Accessibility

Provide alternatives for gestures.

Example:

Pinch to Zoom

↓

Also support

Zoom buttons

Keyboard

Mouse Wheel

Trackpad

---

Example:

Long Press

↓

Context Menu button

---

# Motion Accessibility

Provide:

Reduced Motion Mode

Disable:

Needle animation

Panel animations

Zoom animations

Parallax

Fade effects

---

# Sound Accessibility

The application should never rely on sound.

Every audio cue must have a visual equivalent.

---

# Error Messages

Errors should be:

Clear

Actionable

Non-technical

Example:

Bad

```
Export Failed
```

Good

```
DST export could not be completed because the design exceeds the stitch limit for the selected machine profile.

Current:

145,000 stitches

Machine Limit:

120,000 stitches
```

---

# Confirmation Dialogs

Critical actions require confirmation.

Examples

Delete Project

Delete Layer

Overwrite Export

Reset Preferences

---

Dialogs should support:

Keyboard

Touch

Screen readers

Escape key

---

# File Dialogs

Should remember:

Recent folders

Recent projects

Recent exports

---

# Forms

Every input requires:

Label

Placeholder (optional)

Validation

Error message

Help text where necessary

---

# Loading States

Every long operation should provide:

Progress

Cancelable state where practical

Estimated completion if possible

---

Examples

Import SVG

Generate stitches

Export

Project migration

---

# Performance Accessibility

The interface should remain responsive while:

Generating stitches

Loading projects

Exporting machine files

Large redraws

Long-running operations should never freeze the UI thread.

---

# Localization

Future support:

Unicode

RTL layouts (future evaluation)

Localized thread names

Localized machine names

Metric/Imperial units

---

# Left-Handed Mode

Optional future feature.

Allows:

Inspector placement

Toolbox placement

Floating panel repositioning

Stylus-friendly layouts

---

# Recovery

If the application crashes:

Restore session

Recover autosave

Restore panel layout

Restore viewport

Restore undo history where feasible

---

# Accessibility Testing

Manual testing

Keyboard-only navigation

High contrast themes

Screen readers

Touch-only workflow

Stylus workflow

---

Automated testing

Widget semantics

Keyboard focus order

Contrast checks

Label validation

---

# Definition of Done

A feature is not complete unless:

✓ Keyboard accessible

✓ Touch accessible

✓ Mouse accessible

✓ Supports screen-reader semantics where practical

✓ Works in high contrast mode

✓ Meets minimum touch target sizes

✓ Supports UI scaling

✓ Error states are understandable

✓ Loading states are communicated

✓ Focus order is correct

✓ Accessibility tests pass

---

# Future Improvements

Voice commands

Macro recording

Gesture customization

Custom keyboard shortcuts

Accessibility profiles

AI-assisted accessibility recommendations

Alternative color palettes for embroidery thread previews

Enhanced stylus accessibility settings

---

# References

- WCAG 2.2
- Apple Human Interface Guidelines
- Material Design Accessibility Guidelines
- Flutter Accessibility Best Practices
- Microsoft Inclusive Design Principles
