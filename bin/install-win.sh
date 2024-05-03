#!/bin/bash
# To be used with GitBash

cd "$(dirname "${0}")"

if [ ! -f ./yt-dlp.exe ]; then
	curl -OL https://github.com/yt-dlp/yt-dlp/releases/download/2024.04.09/yt-dlp.exe
fi
if [ ! -f ./ffmpeg ] || [ ! -f ./ffplay.exe ] || [ ! -f ./ffprobe.exe ]; then
	curl -OL https://github.com/GyanD/codexffmpeg/releases/download/7.0/ffmpeg-7.0-essentials_build.zip
	unzip ffmpeg-7.0-essentials_build.zip
	mv ffmpeg-7.0-essentials_build/bin/* ./
	rm -rf ffmpeg-7.0-essentials_build
	rm -rf ffmpeg-7.0-essentials_build.zip
fi

echo "yt-dlp and ffmpeg are installed"