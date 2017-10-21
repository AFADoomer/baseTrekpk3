// Modified from boris's original code here: https://forum.zdoom.org/viewtopic.php?f=3&t=48834

uniform float timer;

vec4 Process(vec4 color)
{
	vec2 foreground = gl_TexCoord[0].st;
	vec2 highlight = gl_TexCoord[0].st;
	
	// Highlight starts at 128 units and scrolls
	highlight.x += 0.5;
	highlight.y += timer * 0.25;

	// Make sure y is between 0 and 1
	highlight.y = mod(highlight.y, 1.0);

	vec4 foregroundTexel = getTexel(foreground);
	vec4 highlightTexel = getTexel(highlight);

	// Draw the overlay over the foreground image, colored by the highlight portion
	return (foregroundTexel + 2 * highlightTexel) * color;
}