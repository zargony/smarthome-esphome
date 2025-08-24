esphome_image := "ghcr.io/esphome/esphome:2025.8.0"

docker := require("docker")
docker_run_opts := "-it --rm -v .:/config -v ./cache:/cache"

# List available recipes
default:
    @{{just_executable()}} --list --justfile {{justfile()}}

# Display ESPHome CLI help
help:
    {{docker}} run {{docker_run_opts}} {{esphome_image}} --help

# Pull ESPHome image
pull:
    {{docker}} pull {{esphome_image}}

# Run ESPHome dashboard server
dashboard:
    {{docker}} run {{docker_run_opts}} -p 6052:6052 {{esphome_image}} dashboard /config

# Clean all intermediate files and cache data
[confirm]
clean:
    rm -rf .esphome cache

# Create and check configuration for the given device
config DEVICE:
    {{docker}} run {{docker_run_opts}} {{esphome_image}} config /config/{{DEVICE}}.yaml

# Compile firmware image for the given device
compile DEVICE:
    {{docker}} run {{docker_run_opts}} {{esphome_image}} compile /config/{{DEVICE}}.yaml

# Upload firmware to the given device
upload DEVICE:
    {{docker}} run {{docker_run_opts}} {{esphome_image}} upload /config/{{DEVICE}}.yaml

# Display logs of the given device
logs DEVICE:
    {{docker}} run {{docker_run_opts}} {{esphome_image}} logs /config/{{DEVICE}}.yaml

# Upload firmware and display logs of the given device
run DEVICE:
    {{docker}} run {{docker_run_opts}} {{esphome_image}} run /config/{{DEVICE}}.yaml

# Flash firmware of the given device to a locally connected device
flash DEVICE:
    esptool write-flash 0x0 .esphome/build/{{DEVICE}}/.pioenvs/{{DEVICE}}/firmware.factory.bin
