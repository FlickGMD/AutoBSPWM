#!/bin/bash
readonly wall_dir="$HOME/Imágenes/wallpapers/"
readonly cacheDir="/tmp/cache/"

# Create cache dir if not exists
[ -d "$cacheDir" ] || mkdir -p "$cacheDir"

# Get focused monitor name
focused_monitor=$(bspc query -M -m focused --names)

# Get monitor width and DPI
monitor_width=$(xrandr | grep -w -- "$focused_monitor" | grep -o '[0-9]\+x[0-9]\+' | cut -d 'x' -f 1)
screen_dpi=$(xdpyinfo | awk '/resolution/{print $2; exit}' | cut -d 'x' -f1)

# Calculate icon size
icon_size=$(( (monitor_width * 14) / (${screen_dpi:-96} ) ))
rofi_override="element-icon{size:${icon_size}px;}"
rofi_command="rofi -dmenu -theme ~/.config/rofi/Selector/SelectWall.rasi -theme-str $rofi_override"

# Detect number of cores and set a sensible number of jobs
get_optimal_jobs() {
    cores=$(nproc)
    if [ "$cores" -le 2 ]; then
        echo 2
    elif [ "$cores" -gt 4 ]; then
        echo 4
    else
        echo $((cores - 1))
    fi
}

PARALLEL_JOBS=$(get_optimal_jobs)

process_func_def='process_image() {
    imagen="$1"
    nombre_archivo=$(basename "$imagen")
    cache_file="${cacheDir}/${nombre_archivo}"
    md5_file="${cacheDir}/.${nombre_archivo}.md5"
    lock_file="${cacheDir}/.lock_${nombre_archivo}"
    current_md5=$(xxh64sum "$imagen" | cut -d " " -f1) 
    (
        flock -x 9
        if [ ! -f "$cache_file" ] || [ ! -f "$md5_file" ] || [ "$current_md5" != "$(cat "$md5_file" 2>/dev/null)" ]; then
            magick "$imagen" -resize 500x500^ -gravity center -extent 500x500 "$cache_file"
            echo "$current_md5" > "$md5_file"
        fi
        rm -f "$lock_file"
    ) 9>"$lock_file"
}'

export process_func_def cacheDir wall_dir

# Clean old locks before starting
rm -f "${cacheDir}"/.lock_* 2>/dev/null || true

# Process files in parallel
find "$wall_dir" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -print0 | \
    xargs -0 -P "$PARALLEL_JOBS" -I {} sh -c "$process_func_def; process_image \"{}\""

# Clean orphaned cache files and their locks
for cached in "$cacheDir"/*; do
    [ -f "$cached" ] || continue
    original="${wall_dir}/$(basename "$cached")"
    if [ ! -f "$original" ]; then
        nombre_archivo=$(basename "$cached")
        rm -f "$cached" \
            "${cacheDir}/.${nombre_archivo}.md5" \
            "${cacheDir}/.lock_${nombre_archivo}"
    fi
done

# Clean any remaining lock files
rm -f "${cacheDir}"/.lock_* 2>/dev/null || true

# Launch rofi
wall_selection=$(find "${wall_dir}" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -print0 |
    xargs -0 basename -a |
    LC_ALL=C sort |
    while IFS= read -r A; do
        printf '%s\000icon\037%s/%s\n' "$A" "$cacheDir" "$A"
    done | $rofi_command)

# Set wallpaper
AnimatedWall --stop
if [[ ! -z "${wall_selection}" ]]; then 
  feh --no-fehbg --bg-fill ${wall_dir}/${wall_selection}
fi

[[ -d "${cacheDir}" ]] && rm -rf "${cacheDir}"
