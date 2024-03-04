package orthomosaic

import rl "vendor:raylib"

main :: proc() {
	screenWidth: i32 = 1600
	screenHeight: i32 = 900

	rl.SetConfigFlags(rl.ConfigFlags{.WINDOW_RESIZABLE, .VSYNC_HINT})
	rl.InitWindow(screenWidth, screenHeight, "Raylib Orthomosaic Viewer")
	defer rl.CloseWindow()

	mapImage := rl.LoadImage("images/RGB.png")
	defer rl.UnloadImage(mapImage)
	
	mapImageCopy := rl.ImageCopy(mapImage)
	defer rl.UnloadImage(mapImageCopy)

	mapTexture := rl.LoadTextureFromImage(mapImage)
	defer rl.UnloadTexture(mapTexture)

	camera := rl.Camera2D{}
	camera.zoom = 1.0

	BPressed := false
	CIRPressed := false
	GPressed := false
	NDVIPressed := false
	NIRPressed := false
	RPressed := false
	REPressed := false
	RGBPressed := false

	slideWidth: i32 = 1280
	slideHeight: i32 = 960
	slideFrontOverlap: f32 = 0.8
	slideSideOverlap: f32 = 0.6
	
	rl.SetTargetFPS(60)

	for !rl.WindowShouldClose() {
		currentWidth := rl.GetScreenWidth()
		currentHeight := rl.GetScreenHeight()

		camera_pan(&camera)

		camera_zoom(&camera)

		if BPressed {
			switch_map_image(&mapImage, &mapTexture, "images/B.png")
			BPressed = false
		} else if CIRPressed {
			switch_map_image(&mapImage, &mapTexture, "images/CIR.png")
			CIRPressed = false
		} else if GPressed {
			switch_map_image(&mapImage, &mapTexture, "images/G.png")
			GPressed = false
		} else if NDVIPressed {
			switch_map_image(&mapImage, &mapTexture, "images/NDVI.png")
			NDVIPressed = false
		} else if NIRPressed {
			switch_map_image(&mapImage, &mapTexture, "images/NIR.png")
			NIRPressed = false
		} else if RPressed {
			switch_map_image(&mapImage, &mapTexture, "images/R.png")
			RPressed = false
		} else if REPressed {
			switch_map_image(&mapImage, &mapTexture, "images/RE.png")
			REPressed = false
		} else if RGBPressed {
			switch_map_image(&mapImage, &mapTexture, "images/RGB.png")
			RGBPressed = false
		}
		
		// Useless should not draw rectangles as texture 
		// if texture_reload {
		//     rl.UnloadImage(mapImageCopy)
		//     mapImageCopy = rl.ImageCopy(mapImage)
	
		//     for x in 0..<mapTexture.width / slideWidth {
		//         rl.ImageDrawRectangleLines(&mapImageCopy, rl.Rectangle{f32(x * slideWidth), 0, f32(slideWidth), f32(slideHeight)}, 5, rl.RED)
		//     }
		//     mapTexture = rl.LoadTextureFromImage(mapImageCopy)

		//     texture_reload = false
		// }

		rl.BeginDrawing()
		defer rl.EndDrawing()
		// Draw here if not dependent on camera
		rl.ClearBackground(rl.BLACK)

		rl.BeginMode2D(camera)
		// Draw here if dependent on camera
		rl.DrawTexture(mapTexture, 0, 0, rl.WHITE)
		rl.EndMode2D()

		// UI here
		BPressed = rl.GuiButton(rl.Rectangle{10, 10, 150, 25}, "Blue")
		CIRPressed = rl.GuiButton(rl.Rectangle{10, 45, 150, 25}, "CIR")
		GPressed = rl.GuiButton(rl.Rectangle{10, 80, 150, 25}, "Green")
		NDVIPressed = rl.GuiButton(rl.Rectangle{10, 115, 150, 25}, "NDVI")
		NIRPressed = rl.GuiButton(rl.Rectangle{10, 150, 150, 25}, "NIR")
		RPressed = rl.GuiButton(rl.Rectangle{10, 185, 150, 25}, "Red")
		REPressed = rl.GuiButton(rl.Rectangle{10, 220, 150, 25}, "RE")
		RGBPressed = rl.GuiButton(rl.Rectangle{10, 255, 150, 25}, "RGB")
		// rl.DrawRectangle(currentWidth - 300, 0, 300, currentHeight, rl.LIGHTGRAY)
		// rl.DrawRectangleLines()
	}
}

// Handles panning the camera
camera_pan :: proc(camera: ^rl.Camera2D) {
	if rl.IsMouseButtonDown(rl.MouseButton.RIGHT) {
		delta := rl.GetMouseDelta()
		delta = delta * (-1.0 / camera.zoom)
		camera.target = camera.target + delta
	}
}

// Handles zooming the camrea
camera_zoom :: proc(camera: ^rl.Camera2D) {
	wheel := rl.GetMouseWheelMove()
	if wheel != 0.0 {
		mouseWorldPos := rl.GetScreenToWorld2D(rl.GetMousePosition(), camera^)
		camera.offset = rl.GetMousePosition()
		camera.target = mouseWorldPos
		zoomIncrement: f32 = 0.125
		camera.zoom += (wheel * zoomIncrement)
		if (camera.zoom < zoomIncrement) {
			camera.zoom = zoomIncrement
		}
	}
}

switch_map_image :: proc(image: ^rl.Image, texture: ^rl.Texture2D, filepath: cstring) {
	rl.UnloadImage(image^)
	image^ = rl.LoadImage(filepath)
	rl.UnloadTexture(texture^)
	texture^ = rl.LoadTextureFromImage(image^)
}