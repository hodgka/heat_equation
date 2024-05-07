package heat_equation

import "core:math"
import "core:fmt"
import "core:strings"
import "core:os"
import "core:bufio"
import rl "vendor:raylib"
import "core:time"

L :: 100
T :: 500
alpha :: 10.0
dx :: 1.0
dt : f32 = (dx * dx) / (4*alpha)
gamma : f32 = (alpha * dt) / (dx*dx)
rw :: 10
rh :: 10


grid := init_grid(initial_condition, boundary_condition)
temp_grid := init_grid(initial_condition, boundary_condition)
max_value : f32 = 1e-6
min_value : f32 = math.MAX_F32_PRECISION
frame_number := 0
// TIME_BETWEEN_UPDATES :: 500
// last_update := time.time_to_unix_nano(time.now())

initial_condition :: proc(row, col: i32) -> f32 {
    row_scaled := f32(row) / f32(L)
    col_scaled := f32(col) / f32(L)
    return 100*math.sin(math.TAU*row_scaled)*math.sin(math.TAU*col_scaled)
}

boundary_condition :: proc(x, y: i32, t: f32) -> f32 {
    if x == 0 {
        return -10
    }
    if x == L {
        return -10
    }
    if y == 0{
        return -10
    }
    if y == L {
        return -10
    }
    return 0
}

init_grid :: proc(
    initial_condition: proc(row, col:i32) -> f32,
    boundary_condition: proc(row, col:i32, t:f32) -> f32
) -> []f32 
{
    grid := make([]f32, L*L)
    i_temp, j_temp: i32
    for i in 0..<i32(L) {
        for j in 0..<i32(L) {
            grid[i*L + j] = initial_condition(i, j)
            if i == 0 || j == 0 || i == L-1 || j == L-1 {
                grid[i*L + j] = boundary_condition(i, j, 0)
            }
        }
    }

    return grid
}

print_grid :: proc(grid: []f32){
    for i in 0..<L {
        line: [L]string
        for j in 0..<L {
            line[j] =  fmt.aprintf("{0:.0f}", grid[i*L + j])
        }
        joined_line := strings.join(line[:], " ")
        fmt.println(joined_line)
    }
}

normalize_range :: proc(value, min, max: f32) -> f32 {
    return (value - min) / (max - min)
}

update :: proc(dt: f32){
    // t := time.time_to_unix_nano(time.now())
    // if (t - last_update) <= TIME_BETWEEN_UPDATES{
    //     return
    // }
    // last_update = t
    for i in 1..<L-1 {
        for j in 1..<L -1 {
            temp_grid[i*L + j] = grid[i*L + j] + gamma * (
                grid[(i+1)*L + j] + \  
                grid[(i-1)*L + j]  + \
                grid[i*L + (j+1)] + \
                grid[i*L + (j-1)] + \
                -4 * grid[i*L + j]   \
            )
            max_value = max(max_value, temp_grid[i*L + j])
            min_value = min(min_value, temp_grid[i*L + j])
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
    rl.ClearBackground(rl.BLACK)
    rgba_pixels := make([]u8, L*L*4)
    current_value: f32
    for i in 0..<i32(L) {
        for j in 0..<i32(L) {
            current_value = grid[i*L + j]
            color := colormap_lookup(&viridis_data, normalize_range(current_value, min_value, max_value))
            rl.DrawRectangle(i*rw, j*rh, rw, rh, color)
        }
    }
    rl.EndDrawing()
}

main :: proc() {
    rl.InitWindow(L*rw, L*rh, "Heat equation")
    rl.SetTargetFPS(60)

    for (!rl.WindowShouldClose()){
        fmt.printfln("MIN: {0}, MAX: {1}", min_value, max_value)
        update(rl.GetFrameTime())
        draw()

    }
    rl.CloseWindow()
}

