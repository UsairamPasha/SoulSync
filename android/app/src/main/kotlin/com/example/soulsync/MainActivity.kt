package com.example.soulsync

import android.provider.MediaStore
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: AudioServiceActivity() {
    private val CHANNEL = "soulsync/media_scanner"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "querySongs" -> {
                    try {
                        val songs = queryAudioSongs()
                        result.success(songs)
                    } catch (e: Exception) {
                        result.error("QUERY_ERROR", e.message, null)
                    }
                }
                "queryArtists" -> {
                    try {
                        val artists = queryAudioArtists()
                        result.success(artists)
                    } catch (e: Exception) {
                        result.error("QUERY_ERROR", e.message, null)
                    }
                }
                "queryAlbums" -> {
                    try {
                        val albums = queryAudioAlbums()
                        result.success(albums)
                    } catch (e: Exception) {
                        result.error("QUERY_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun queryAudioSongs(): List<Map<String, Any?>> {
        val songList = mutableListOf<Map<String, Any?>>()
        val projection = arrayOf(
            MediaStore.Audio.Media._ID,
            MediaStore.Audio.Media.TITLE,
            MediaStore.Audio.Media.ARTIST,
            MediaStore.Audio.Media.ALBUM,
            MediaStore.Audio.Media.ALBUM_ID,
            MediaStore.Audio.Media.ARTIST_ID,
            MediaStore.Audio.Media.DURATION,
            MediaStore.Audio.Media.DATA,
            MediaStore.Audio.Media.SIZE,
            MediaStore.Audio.Media.DATE_ADDED
        )

        val selection = "${MediaStore.Audio.Media.IS_MUSIC} != 0"

        contentResolver.query(
            MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
            projection,
            selection,
            null,
            "${MediaStore.Audio.Media.DATE_ADDED} DESC"
        )?.use { cursor ->
            val idCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media._ID)
            val titleCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.TITLE)
            val artistCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ARTIST)
            val albumCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM)
            val albumIdCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM_ID)
            val artistIdCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ARTIST_ID)
            val durationCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DURATION)
            val dataCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DATA)
            val sizeCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.SIZE)
            val dateAddedCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DATE_ADDED)

            while (cursor.moveToNext()) {
                val song = mapOf(
                    "id" to cursor.getLong(idCol),
                    "title" to (cursor.getString(titleCol) ?: "Unknown Track"),
                    "artist" to (cursor.getString(artistCol) ?: "Unknown Artist"),
                    "album" to (cursor.getString(albumCol) ?: "Unknown Album"),
                    "albumId" to cursor.getLong(albumIdCol),
                    "artistId" to cursor.getLong(artistIdCol),
                    "duration" to cursor.getLong(durationCol),
                    "data" to (cursor.getString(dataCol) ?: ""),
                    "size" to cursor.getLong(sizeCol),
                    "dateAdded" to cursor.getLong(dateAddedCol)
                )
                songList.add(song)
            }
        }
        return songList
    }

    private fun queryAudioArtists(): List<Map<String, Any?>> {
        val artistList = mutableListOf<Map<String, Any?>>()
        val projection = arrayOf(
            MediaStore.Audio.Artists._ID,
            MediaStore.Audio.Artists.ARTIST,
            MediaStore.Audio.Artists.NUMBER_OF_ALBUMS,
            MediaStore.Audio.Artists.NUMBER_OF_TRACKS
        )

        contentResolver.query(
            MediaStore.Audio.Artists.EXTERNAL_CONTENT_URI,
            projection,
            null,
            null,
            "${MediaStore.Audio.Artists.ARTIST} ASC"
        )?.use { cursor ->
            val idCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Artists._ID)
            val artistCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Artists.ARTIST)
            val albumsCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Artists.NUMBER_OF_ALBUMS)
            val tracksCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Artists.NUMBER_OF_TRACKS)

            while (cursor.moveToNext()) {
                val artist = mapOf(
                    "id" to cursor.getLong(idCol),
                    "artist" to (cursor.getString(artistCol) ?: "Unknown Artist"),
                    "numberOfAlbums" to cursor.getInt(albumsCol),
                    "numberOfTracks" to cursor.getInt(tracksCol)
                )
                artistList.add(artist)
            }
        }
        return artistList
    }

    private fun queryAudioAlbums(): List<Map<String, Any?>> {
        val albumList = mutableListOf<Map<String, Any?>>()
        val projection = arrayOf(
            MediaStore.Audio.Albums._ID,
            MediaStore.Audio.Albums.ALBUM,
            MediaStore.Audio.Albums.ARTIST,
            MediaStore.Audio.Albums.NUMBER_OF_SONGS
        )

        contentResolver.query(
            MediaStore.Audio.Albums.EXTERNAL_CONTENT_URI,
            projection,
            null,
            null,
            "${MediaStore.Audio.Albums.ALBUM} ASC"
        )?.use { cursor ->
            val idCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Albums._ID)
            val albumCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Albums.ALBUM)
            val artistCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Albums.ARTIST)
            val songsCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Albums.NUMBER_OF_SONGS)

            while (cursor.moveToNext()) {
                val album = mapOf(
                    "id" to cursor.getLong(idCol),
                    "album" to (cursor.getString(albumCol) ?: "Unknown Album"),
                    "artist" to (cursor.getString(artistCol) ?: "Unknown Artist"),
                    "numberOfSongs" to cursor.getInt(songsCol)
                )
                albumList.add(album)
            }
        }
        return albumList
    }
}
