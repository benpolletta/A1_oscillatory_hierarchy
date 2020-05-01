//<!--
// A script to highlight a table row and present it as a clickable link
// Based on http://www.alistapart.com/articles/tableruler/

function showLink(element, bgColor, meetingNumber) {
  element.style.cursor= 'pointer';
  element.style.background = bgColor;
  window.status = "Show details for meeting " + meetingNumber;
  // Also show border for IE...
  element.style.borderStyle = 'solid';
  element.style.borderWidth = '1px';
  element.style.borderColor = bgColor;
}

function hideLink(element, bgColor) {
  element.style.background = bgColor;
  element.style.borderStyle = 'none';
}

// -->
