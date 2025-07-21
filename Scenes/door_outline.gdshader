shader_type spatial;
render_mode unshaded, depth_test_disabled, cull_disabled;

uniform vec3 color : source_color = vec3(1,1,0);
uniform float thickness : hint_range(0.0, 0.2, 0.01) = 0.05;
uniform float edge_width : hint_range(0.0, 1.0, 0.01) = 0.1;

varying vec3 world_normal;
varying vec3 world_position;

void vertex() {
	VERTEX += thickness * NORMAL;
	world_normal = NORMAL;
	world_position = VERTEX;
}

void fragment() {
	// Calculate how much this fragment faces the camera
	vec3 view_dir = normalize(CAMERA_POSITION_WORLD - world_position);
	float facing = abs(dot(world_normal, view_dir));
	
	// Only show edges (where surface is perpendicular to view)
	if (facing > edge_width) {
		discard;
	}
	
	ALBEDO = color;
	ALPHA = 1.0 - (facing / edge_width);
}