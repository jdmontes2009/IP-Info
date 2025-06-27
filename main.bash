#!/bin/bash

# Define the directories you need
directories=(
  "android/app/src/main/res/mipmap-mdpi"
  "android/app/src/main/res/mipmap-hdpi"
  "android/app/src/main/res/mipmap-xhdpi"
  "android/app/src/main/res/mipmap-xxhdpi"
  "android/app/src/main/res/mipmap-xxxhdpi"
  "android/app/src/main/res/mipmap-anydpi-v26"
)

# Create the directories
for dir in "${directories[@]}"; do
  mkdir -p "$dir"
done

echo "Directories created successfully!"

