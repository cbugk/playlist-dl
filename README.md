# playlist-dl

This is to easen downloading a music playlist via yt-dlp.
Assumes a [Git BASH](https://git-scm.com/download/win) terminal onWindows as the environemnt.

Following is enought to get you started:

```bash
git clone https://github.com/cbugk/playlist-dl.git
cd playlist-dl
```

```bash
cp ./playlistlist-example.txt ./playlistlist.txt

# Edit file such that each line has a playlist URI
```

```bash
chmod +x ./download-playlists.sh
./download-playlists.sh
```

You can find directories with playlists' names under `dl` directory.

Per each directory there is a `dl/*/uri.txt` file containing the respective URI of that playlist,
and an `archive.txt` file contaning video identifiers of already downloaded videos. If you happen
to modify downloaded files and rerun, yt-dlp will skip those videos listed within the `--download-archive`
file.

> Note that no metadata parameters are used here. For more see: https://github.com/yt-dlp/yt-dlp?tab=readme-ov-file
