#!/bin/bash
# Tested on: GitBash

cd "$(dirname "${0}")"
./bin/install-win.sh  # idempotent, does nothing if binaries are present

# Each line should contain a playlist URI
while read PL_URI; do
	[ -z "${PL_URI}" ] && continue;
	echo "Playlist: ${PL_URI}"
	PL_VAR_FILE="./plname.txt"

	# Update download directory file name variable stored in file
	rm -f "${PL_VAR_FILE}"
	./bin/yt-dlp \
		--update \
		--simulate \
		--no-playlist \
		--playlist-items 1:1 \
		--print-to-file  "%(playlist_title)s" "${PL_VAR_FILE}" \
		"${PL_URI}";

	# Store into variable, trim return carriage '\r' per read operation
	read -r PL_NAME < "${PL_VAR_FILE}"
	PL_NAME="$(tr -d '\r' <<< "${PL_NAME}")"
	rm -f "${PL_VAR_FILE}"
	DL_DIR="./dl/${PL_NAME}"

	# Write link of playlist to info file
	mkdir -p "${DL_DIR}"
	echo "${PL_URI}" > "${DL_DIR}/uri.txt"

	# Download into directory with archive file
	# Options listed at: https://github.com/yt-dlp/yt-dlp?tab=readme-ov-file
	./bin/yt-dlp \
		--no-update \
		--no-playlist \
		--no-lazy-playlist \
		--no-abort-on-error \
		--no-flat-playlist \
		--no-overwrites \
		--no-restrict-filenames \
		--no-audio-multistreams \
		--no-prefer-free-formats \
		--no-cache-dir \
		--write-thumbnail \
		--convert-thumbnails png \
		--progress \
		--console-title \
		--impersonate chrome:windows \
		--retries 2 \
		--windows-filenames \
		--part \
		--ffmpeg-location ./bin/ \
		--extract-audio \
		--audio-format mp3 \
		--audio-quality best \
		--output "${DL_DIR}/%(playlist_index)04d-%(title)s.%(ext)s" \
		--concurrent-fragments 10 \
		--download-archive "${DL_DIR}/archive.txt" \
		"${PL_URI}";

		# Alternatively this also works, rather than relying on previous fetch
		#--output "./dl/%(playlist_title)s/%(playlist_index)04d-%(title)s.%(ext)s" \

# Inserts an empty line at the end if not present
done < <(tr -d '\r' < ./playlistlist.txt)
