# playlist-dl

This is to easen downloading a music playlist via yt-dlp.
Assumes a [Git BASH](https://git-scm.com/download/win) terminal on Windows as the environment.

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

Per each playlist, there are `dl/*/uri.txt` files containing the respective URI of that playlist,
and `dl/*/archive.txt` file contaning video identifiers of already downloaded videos. Whether or not
downloaded files and present, as long as videos are listed within the archive file, yt-dlp will skip
them. This way you can move or modify previously downloaded files.

> Note that no metadata parameters are used here. For more see: https://github.com/yt-dlp/yt-dlp?tab=readme-ov-file
