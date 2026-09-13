# Spin the Wheel Game - README

## Overview
This project is a simple "Spin the Wheel" game implemented using HTML, CSS, and JavaScript. The user interacts with a wheel divided into colored segments representing different prizes. The user clicks a button to spin the wheel, which rotates a random number of degrees before stopping at a segment to reveal a prize.

---

## Structure and Explanation

### HTML
The core structure of the webpage is defined in the HTML:

- `<!DOCTYPE html>` and `<html>` define the document type and start of the HTML document.
- `<head>` contains meta information, including character set and viewport settings for mobile responsiveness.
- `<title>` sets the page title to "Spin the Wheel."
- `<body>` includes:
  - A main heading (`<h1>`) prompting the user with "Would You Spin the Wheel?"
  - A `div` with class `wheel-container` holding the wheel and a pointer element.
  - A button (`<button>`) for spinning the wheel.
  - A paragraph (`<p id="result">`) to display the spin result.

### CSS (Styles)
Styling is defined within a `<style>` block:

- General body styling:
  - `font-family: Arial, sans-serif` for a clean, modern font.
  - `text-align: center` centers all content.
  - `background-color: #f4f4f4` sets a light gray background.

- **Wheel Styling**:
  - `.wheel-container` centers the wheel on the page.
  - `.wheel` represents the circular wheel using `border-radius: 50%`.
  - `.segment` defines each prize segment using `clip-path` to form a triangle shape. Different colors and text are applied to individual segments.

- **Pointer Styling**:
  - `.pointer` is a triangular shape positioned above the wheel using `border` properties.

- **Button Styling**:
  - The button uses padding, rounded corners, and hover effects to enhance user interaction.

### JavaScript (Interaction)
The interactive behavior is controlled with a script inside a `<script>` block:

- **Variables and Elements**:
  - `wheel` references the wheel element.
  - `resultDisplay` is the paragraph to display the result.
  - `prizes` is an array holding the prize names.
  - `spinButton` references the spin button.

- **Spin Logic**:
  - `currentRotation` keeps track of the cumulative wheel rotation.
  - Clicking the button triggers a spin. A random degree between 0 and 360 is calculated.
  - The total rotation includes five full spins plus the random degree.
  - `wheel.style.transition` animates the spin over 3 seconds.
  - `wheel.style.transform` rotates the wheel.

- **Determine Prize**:
  - The final degree is found by taking the modulus of `currentRotation` with 360.
  - The `index` is calculated to identify the prize segment.
  - `resultDisplay.textContent` updates with the prize name after a 3-second timeout.

---

## How to Run
1. Open the provided HTML file in a web browser.
2. Click the "Spin!" button.
3. Wait for the wheel to stop and view the result displayed below.

---

## Customization
- **Prizes**: Update the `prizes` array in JavaScript to change the prize names.
- **Colors**: Modify the background-color property in each `.segment` class for different segment colors.
- **Spin Speed**: Adjust the duration of the transition in `wheel.style.transition`.

---

## Compatibility
This project is compatible with modern browsers that support CSS3 and JavaScript. Ensure JavaScript is enabled for functionality.

---

## Known Issues
- On rare occasions, rounding errors may slightly affect the prize selection.
- Adjustments to segment positioning may require recalculating rotation angles.

---

## Future Improvements
- Add sound effects for a more engaging experience.
- Display a more detailed animation with easing for smoother transitions.
- Include a restart button to reset without refreshing the page.

---

Enjoy spinning the wheel!

