#!/bin/bash
# Tested on: GitBash

cd "$(dirname "${0}")"

# Environment and Executables
YT_DLP=( '/usr/bin/env' 'yt-dlp' )
OPT_IMPERSONATE_TARGET=()
OPT_WINDOWS_FILENAMES=()
OPT_FFMPEG=()
if [[ "${OSTYPE}" =~ ^msys ]]; then
	# idempotent, does nothing if binaries are present
	./bin/install-win.sh && {
		YT_DLP=( './bin/yt-dlp' )
		OPT_IMPERSONATE_TARGET=( '--impersonate' 'chrome:windows' )
		OPT_WINDOWS_FILENAMES=( '--windows-filenames' )
		OPT_FFMPEG=('--ffmpeg-location' './bin/')
	} || {
		echo "Please run and inspect: 'bash ./bin/install-win.sh'"
		exit 1
	}
elif [[ "${OSTYPE}" =~ ^darwin ]]; then
	{
		brew install yt-dlp ffmpeg curl cffi && which yt-dlp && which ffmpeg && which curl
	} 1>/dev/null 2>&1 || {
		echo "Please run and inspect 'brew install yt-dlp fmmpeg curl cffi'"
		exit 2
	}
else
	{
		which yt-dlp && which ffmpeg
	} || {
		echo "Please first ensure yt-dlp and ffmpeg are installed."
		exit 3
	}
fi

# Each line should contain a playlist URI
while read PL_URI; do
	# Ignore empty lines and comments (# must be first char)
	{ [ -z "${PL_URI}" ] || [[ "${PL_URI}" =~ ^# ]]	} && continue;
	echo "Playlist: ${PL_URI}"
	PL_VAR_FILE="./dl/plname.txt"

	# List impersonate targets for debugging
	${YT_DLP[@]} --list-impersonate-targets

	# Update download directory file name variable stored in file
	rm -f "${PL_VAR_FILE}"
	${YT_DLP[@]} \
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
	${YT_DLP[@]} \
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
		${OPT_IMPERSONATE_TARGET[@]} \
		--retries 2 \
		${OPT_WINDOWS_FILENAMES[@]} \
		--part \
		${OPT_FFMPEG[@]} \
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