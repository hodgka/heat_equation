package heat_equation

import "core:math"
import "core:fmt"
import "core:strings"
import "core:os"
import "core:bufio"
import rl "vendor:raylib"
import "core:time"

WIDTH :: 1280
HEIGHT :: 720
DIFFUSION_CONSTANT :: 1.0
grid := init_grid(initial_condition, boundary_condition)
temp_grid := init_grid(initial_condition, boundary_condition)
max_value : f32 = 1e-6
min_value : f32 = math.MAX_F32_PRECISION
frame_number := 0
TIME_BETWEEN_UPDATES :: 1
last_update := time.time_to_unix_nano(time.now())

initial_condition :: proc(row, col: i32) -> f32 {
    row_scaled := f32(row) / f32(WIDTH)
    col_scaled := f32(col) / f32(HEIGHT)
    return math.sin(math.TAU*row_scaled)*math.sin(math.TAU*col_scaled)
}

boundary_condition :: proc(x, y: i32, t: f32) -> f32 {
    return 0
}

update :: proc(dt: f32){
    t := time.time_to_unix_nano(time.now())
    if (t - last_update) <= TIME_BETWEEN_UPDATES{
        return
    }
    last_update = t
    current_cell: f32
    for i in 1..<HEIGHT-1 {
        for j in 1..<WIDTH -1 {
            current_cell = grid[i*WIDTH + j]
            temp_grid[i*WIDTH + j] = current_cell + 1
            fmt.println(grid[(i+1)*WIDTH + j], grid[(i-1)*WIDTH + j])
            temp_grid[i*WIDTH + j] = current_cell + DIFFUSION_CONSTANT * dt * (
                grid[(i+1)*WIDTH + j] + \  
                grid[(i-1)*WIDTH + j]  + \
                grid[i*WIDTH + (j+1)] + \
                grid[i*WIDTH + (j-1)] + \
                -4 * current_cell   \
            )
            // fmt.println(temp_grid[i*WIDTH + j])
            max_value = max(max_value, temp_grid[i*WIDTH + j])
            min_value = min(min_value, temp_grid[i*WIDTH + j])
        }
    }
    grid = temp_grid
    frame_number += 1
}

color_to_value :: proc(color: rl.Color) -> u32 {
    x := (u32(color[0]) << 24) | (u32(color[1]) << 16) | (u32(color[2]) << 8) | u32(color[3]);
    return x
}

draw :: proc(){
    
    rl.BeginDrawing()
    // rl.DrawText(fmt.ctprintf("Frame number: {0}", frame_number), 10, 10, 14, rl.WHITE)
    rl.ClearBackground(rl.BLACK)
    // pixels := make([]rl.Color, HEIGHT*WIDTH)
    
    // img := rl.GenImageColor(WIDTH, HEIGHT, rl.BLACK)
    // rl.ImageFormat(&img, .UNCOMPRESSED_R8G8B8A8)
    // tex := rl.LoadTextureFromImage(img);

    rgba_pixels := make([]u8, WIDTH*HEIGHT*4)
    current_value: f32
    for i in 0..<i32(HEIGHT) {
        for j in 0..<i32(WIDTH) {
            current_value = grid[i*WIDTH + j]
            color := colormap_lookup(&viridis_data, normalize_range(current_value, min_value, max_value))
            rl.DrawPixel(j, i, color)
        }
    }
    rl.EndDrawing()

}

main :: proc() {
    rl.InitWindow(WIDTH, HEIGHT, "Heat equation")
    rl.SetTargetFPS(1)

    // print_grid(grid)
    for (!rl.WindowShouldClose()){
        fmt.printfln("MIN: {0}, MAX: {1}", min_value, max_value)
        update(rl.GetFrameTime())
        draw()

    }
    rl.CloseWindow()
}

init_grid :: proc(
    initial_condition: proc(row, col:i32) -> f32,
    boundary_condition: proc(row, col:i32, t:f32) -> f32
) -> []f32 
{
    grid := make([]f32, HEIGHT*WIDTH)
    i_temp, j_temp: i32
    for i in 0..<i32(HEIGHT) {
        for j in 0..<i32(WIDTH) {
            grid[i*WIDTH + j] = initial_condition(i, j)
            if i == 0 || j == 0 || i == HEIGHT-1 || j == WIDTH-1 {
                grid[i*WIDTH + j] = boundary_condition(i, j, 0)
            }
        }
    }

    return grid
}

print_grid :: proc(grid: []f32){
    for i in 0..<HEIGHT {
        line: [WIDTH]string
        for j in 0..<WIDTH {
            line[j] =  fmt.aprintf("{0:.0f}", grid[i*WIDTH + j])
        }
        joined_line := strings.join(line[:], " ")
        fmt.println(joined_line)
    }
}

normalize_range :: proc(value, min, max: f32) -> f32 {
    return (value - min) / (max - min)
}