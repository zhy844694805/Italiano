#!/usr/bin/env python3
"""
Convert voices-v1.0.bin to voices.json for kokoro_tts_flutter
"""
import numpy as np
import json
import os

# Get the voices bin file path
script_dir = os.path.dirname(os.path.abspath(__file__))
bin_path = os.path.expanduser("~/.pub-cache/hosted/pub.dev/kokoro_tts_flutter-0.2.0+1/assets/")

# Try to find the bin file - might be downloaded to app data
home = os.path.expanduser("~")

# Check multiple possible locations
possible_paths = [
    # From the model download
    os.path.join(script_dir, "build/app/outputs/flutter-apk/"),
    # Cached version
    os.path.expanduser("~/Downloads/voices-v1.0.bin"),
    # Direct download
    "/tmp/voices-v1.0.bin"
]

# Download if needed
import urllib.request
voices_url = "https://github.com/thewh1teagle/kokoro-onnx/releases/download/model-files-v1.0/voices-v1.0.bin"
bin_file = "/tmp/voices-v1.0.bin"

if not os.path.exists(bin_file):
    print(f"Downloading voices-v1.0.bin...")
    urllib.request.urlretrieve(voices_url, bin_file)
    print(f"Downloaded to {bin_file}")

# Load the voices
print(f"Loading voices from {bin_file}...")
data = np.load(bin_file)

print(f"Available voices: {list(data.keys())}")

# Extract only Italian voices (and a fallback)
italian_voices = ['if_sara', 'im_nicola']
fallback_voices = ['af_heart']  # Include a default voice as fallback

voices_to_export = italian_voices + fallback_voices

voices_dict = {}
for voice_name in voices_to_export:
    if voice_name in data:
        # Convert numpy array to nested list
        voice_data = data[voice_name]
        print(f"  {voice_name}: shape {voice_data.shape}")
        voices_dict[voice_name] = voice_data.tolist()
    else:
        print(f"  {voice_name}: NOT FOUND")

# Save to JSON
output_path = os.path.join(script_dir, "assets/voices.json")
print(f"Saving to {output_path}...")

with open(output_path, 'w') as f:
    json.dump(voices_dict, f)

file_size = os.path.getsize(output_path)
print(f"Done! File size: {file_size / 1024 / 1024:.2f} MB")
print(f"Exported voices: {list(voices_dict.keys())}")
