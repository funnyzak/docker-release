# FFmpeg Media Processing Service

[![Docker Tags](https://img.shields.io/docker/v/funnyzak/ffmpeg-service?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/ffmpeg-service/)
[![Image Size](https://img.shields.io/docker/image-size/funnyzak/ffmpeg-service)](https://hub.docker.com/r/funnyzak/ffmpeg-service/)
[![Docker Stars](https://img.shields.io/docker/stars/funnyzak/ffmpeg-service.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/ffmpeg-service/)
[![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/ffmpeg-service.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/ffmpeg-service/)

A lightweight, containerized FFmpeg media processing microservice built with Flask and Python. This service provides HTTP API endpoints for both video and audio processing, including metadata extraction, format conversion, and screenshot capture (for videos).

Build with the `linux/arm64`, `linux/amd64`, `linux/arm/v7` architectures.

## Features

- **Video Processing**: Extract metadata, capture screenshots, convert formats, and adjust resolution
- **Audio Processing**: Extract metadata and convert between audio formats
- **Format Conversion**: Convert videos between popular formats (MP4, AVI, MOV, MKV, WebM) and audio between formats (MP3, WAV, FLAC, AAC, OGG, M4A, Opus)
- **Resolution Control**: Convert videos to specific resolutions (720p, 1080p, 4K, custom dimensions)
- **Batch Processing**: Combine multiple operations in a single API call
- **URL & File Upload Support**: Process media from URLs or direct file uploads
- **Automatic Cleanup**: Temporary files are automatically deleted after processing
- **Health Monitoring**: Built-in health check endpoint
- **API Key Authentication**: Optional API key authentication for secure access
- **Error Handling**: Comprehensive error handling with appropriate HTTP status codes
- **Flexible Configuration**: All settings configurable via environment variables
- **Multi-Architecture Support**: Supports ARM and x86 architectures

## Pull

```bash
docker pull funnyzak/ffmpeg-service:latest
# GHCR
docker pull ghcr.io/funnyzak/ffmpeg-service:latest
# Aliyun
docker pull registry.cn-beijing.aliyuncs.com/funnyzak/ffmpeg-service:latest
```

## Usage

### Docker Run

```bash
# Run with default settings
docker run -d --name ffmpeg-service --restart on-failure \
  -p 8080:8080 \
  funnyzak/ffmpeg-service

# Run with custom configuration
docker run -d --name ffmpeg-service --restart on-failure \
  -p 8080:8080 \
  -e MAX_FILE_SIZE=1073741824 \
  -e FILE_RETENTION_HOURS=24 \
  -e CLEANUP_INTERVAL_MINUTES=60 \
  -e FLASK_DEBUG=false \
  -v ./temp:/tmp/videos \
  funnyzak/ffmpeg-service

# Run with environment file
docker run -d --name ffmpeg-service --restart on-failure \
  -p 8080:8080 \
  --env-file .env \
  -v ./temp:/tmp/videos \
  funnyzak/ffmpeg-service
```

### Docker Compose

Create a `docker-compose.yml` file:

```yaml
version: "3.8"
services:
  ffmpeg-service:
    image: funnyzak/ffmpeg-service:latest
    container_name: ffmpeg-service
    environment:
      # System settings
      - TZ=Asia/Shanghai
      
      # Application configuration
      - TEMP_DIR=/tmp/videos
      - MAX_FILE_SIZE=524288000      # 500MB in bytes
      - FILE_RETENTION_HOURS=2       # Keep output files for 2 hours
      - CLEANUP_INTERVAL_MINUTES=30  # Run cleanup every 30 minutes
      
      # Supported formats (comma-separated)
      - ALLOWED_VIDEO_EXTENSIONS=mp4,avi,mov,mkv,flv,wmv,webm,m4v
      - SUPPORTED_VIDEO_OUTPUT_FORMATS=mp4,avi,mov,mkv,webm
      - SUPPORTED_AUDIO_OUTPUT_FORMATS=mp3,wav,flac,aac,ogg,m4a,opus
      
      # Flask server settings
      - FLASK_HOST=0.0.0.0
      - FLASK_PORT=8080
      - FLASK_DEBUG=false
      
      # Gunicorn WSGI server settings
      - GUNICORN_WORKERS=4           # Number of worker processes
      - GUNICORN_WORKER_CLASS=sync   # Worker class (sync, gevent, eventlet)
      - GUNICORN_TIMEOUT=120         # Worker timeout in seconds
      - GUNICORN_MAX_REQUESTS=1000   # Restart workers after N requests
      - GUNICORN_MAX_REQUESTS_JITTER=100  # Add randomness to max requests
      
      # API Key authentication (optional)
      - API_KEYS=your_secret_key_here
    ports:
      - "${HOST_PORT:-8080}:${FLASK_PORT:-8080}"
    restart: on-failure
    volumes:
      - ${TEMP_VOLUME:-./temp}:${TEMP_DIR:-/tmp/videos}
```

#### Using Environment File

Create a `.env` file for easier configuration management. You can use the provided `env.example` as a template:

```bash
# Copy the example file
cp env.example .env

# Edit the configuration
nano .env
```

Example `.env` file:

```env
# Application configuration
MAX_FILE_SIZE=1073741824          # 1GB
FILE_RETENTION_HOURS=24           # Keep files for 24 hours
CLEANUP_INTERVAL_MINUTES=60       # Cleanup every hour

# Docker settings
HOST_PORT=8080
TEMP_VOLUME=./temp

# Flask settings
FLASK_DEBUG=false

# Gunicorn WSGI server settings
GUNICORN_WORKERS=4
GUNICORN_WORKER_CLASS=sync
GUNICORN_TIMEOUT=120
GUNICORN_MAX_REQUESTS=1000
GUNICORN_MAX_REQUESTS_JITTER=100

# API Key authentication (optional)
# Leave empty to disable authentication
# Multiple keys can be separated by commas: API_KEYS=key1,key2,key3
API_KEYS=your_secret_key_here
```

Then run:

```bash
docker-compose up -d
```

### Docker Build

```bash
docker build \
  --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
  --build-arg VERSION="1.0.0" \
  -t funnyzak/ffmpeg-service:1.0.0 .
```

### Local Development

For local development without Docker:

```bash
# Install system dependencies (Ubuntu/Debian)
sudo apt-get update && sudo apt-get install -y ffmpeg libmagic1

# Install Python dependencies
pip install -r requirements.txt

# Set environment variables (optional)
export MAX_FILE_SIZE=104857600
export FLASK_DEBUG=true
export FILE_RETENTION_HOURS=1

# Run the service
python app.py
```

### Using the Startup Script

The project includes a startup script that automatically detects the environment:

```bash
# Make the script executable
chmod +x start.sh

# Run the service
./start.sh
```

The script will:
- Use Gunicorn in Docker environments
- Use Flask development server in local environments
- Display configuration information on startup

## Authentication

The service supports optional API key authentication to secure access to video processing endpoints.

### Configuration

Set the `API_KEYS` environment variable to enable authentication:

```bash
# Single API key
API_KEYS=your_secret_key_here

# Multiple API keys (comma-separated)
API_KEYS=key1,key2,key3

# Disable authentication (default)
API_KEYS=
```

### Protected Endpoints

The following endpoints require authentication when `API_KEYS` is configured:
- `POST /process` - Video processing
- `POST /info` - Video information extraction

### Unprotected Endpoints

The following endpoints do not require authentication:
- `GET /health` - Health check
- `GET /download/{filename}` - File download

### Usage

Include the API key in the `X-API-Key` header:

```bash
curl -X POST http://localhost:8080/process \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your_secret_key_here" \
  -d '{"video_url": "https://example.com/video.mp4"}'
```

### Error Responses

- **401 Unauthorized**: Missing API key
- **403 Forbidden**: Invalid API key

## API Endpoints

### Health Check
```http
GET /health
```

**Response:**
```json
{
  "code": 0,
  "msg": "Service is healthy",
  "data": {}
}
```

### Media Processing (Combined Operations)
```http
POST /process
Content-Type: application/json
X-API-Key: your_secret_key_here
```

### Video Processing Example

#### Using URL
```http
POST /process
Content-Type: application/json
X-API-Key: your_secret_key_here
```

**Request Body:**
```json
{
  "video_url": "https://example.com/video.mp4",
  "extract_info": true,
  "take_screenshots": true,
  "screenshot_count": 5,
  "convert_format": "mp4",
  "convert_quality": "medium",
  "convert_resolution": "720p"
}
```

#### Using File Upload
```http
POST /process
Content-Type: multipart/form-data
X-API-Key: your_secret_key_here
```

**Request Body:**
```
file: [video file]
extract_info: true
take_screenshots: true
screenshot_timestamps: [10, 30, 60]
```

**Example with curl:**
```bash
curl -X POST http://localhost:8080/process \
  -H "X-API-Key: your_secret_key_here" \
  -F "file=@video.mp4" \
  -F "extract_info=true" \
  -F "take_screenshots=true" \
  -F "screenshot_count=5" \
  -F "convert_format=mp4" \
  -F "convert_resolution=720p"
```

**Response (Video):**
```json
{
  "code": 0,
  "msg": "Processing completed successfully",
  "data": {
    "media_type": "video",
    "info": {
      "duration": 120.5,
      "size": 15728640,
      "format_name": "mov,mp4,m4a,3gp,3g2,mj2",
      "codec_name": "h264",
      "width": 1920,
      "height": 1080,
      "frame_rate": 30.0,
      "bit_rate": 1048576
    },
    "screenshots": [
      {
        "timestamp": 24.1,
        "filename": "screenshot_abc123_24.jpg",
        "file_size": 102400,
        "url": "/download/screenshot_abc123_24.jpg"
      }
    ],
    "conversion": {
      "filename": "converted_def456.mp4",
      "file_size": 12582912,
      "format": "mp4",
      "resolution": "720p",
      "url": "/download/converted_def456.mp4"
    }
  }
}
```

### Audio Processing Example

#### Using URL
```http
POST /process
Content-Type: application/json
X-API-Key: your_secret_key_here
```

**Request Body:**
```json
{
  "media_url": "https://example.com/audio.wav",
  "extract_info": true,
  "convert_format": "mp3",
  "convert_quality": "high"
}
```

#### Using File Upload
```http
POST /process
Content-Type: multipart/form-data
X-API-Key: your_secret_key_here
```

**Request Body:**
```
file: [audio file]
extract_info: true
convert_format: mp3
convert_quality: high
```

**Example with curl:**
```bash
curl -X POST http://localhost:8080/process \
  -H "X-API-Key: your_secret_key_here" \
  -F "file=@audio.wav" \
  -F "extract_info=true" \
  -F "convert_format=mp3" \
  -F "convert_quality=high"
```

**Response (Audio):**
```json
{
  "code": 0,
  "msg": "Processing completed successfully",
  "data": {
    "media_type": "audio",
    "info": {
      "duration": 180.5,
      "size": 15728640,
      "format_name": "wav",
      "codec_name": "pcm_s16le",
      "sample_rate": 44100,
      "channels": 2,
      "bit_rate": 1411200,
      "channel_layout": "stereo"
    },
    "conversion": {
      "filename": "converted_audio_abc123.mp3",
      "file_size": 5242880,
      "format": "mp3",
      "url": "/download/converted_audio_abc123.mp3"
    }
  }
}
```

### Media Information
```http
POST /info
Content-Type: application/json
X-API-Key: your_secret_key_here
```

**Video Request Body (URL):**
```json
{
  "video_url": "https://example.com/video.mp4"
}
```

**Video Request Body (File Upload):**
```http
POST /info
Content-Type: multipart/form-data
X-API-Key: your_secret_key_here
```

```
file: [video file]
```

**Example with curl:**
```bash
curl -X POST http://localhost:8080/info \
  -H "X-API-Key: your_secret_key_here" \
  -F "file=@video.mp4"
```

**Video Response:**
```json
{
  "code": 0,
  "msg": "Video info extracted successfully",
  "data": {
    "media_type": "video",
    "duration": 120.5,
    "size": 15728640,
    "format_name": "mov,mp4,m4a,3gp,3g2,mj2",
    "codec_name": "h264",
    "width": 1920,
    "height": 1080,
    "frame_rate": 30.0,
    "bit_rate": 1048576
  }
}
```

**Audio Request Body (URL):**
```json
{
  "media_url": "https://example.com/audio.mp3"
}
```

**Audio Request Body (File Upload):**
```http
POST /info
Content-Type: multipart/form-data
X-API-Key: your_secret_key_here
```

```
file: [audio file]
```

**Example with curl:**
```bash
curl -X POST http://localhost:8080/info \
  -H "X-API-Key: your_secret_key_here" \
  -F "file=@audio.mp3"
```

**Audio Response:**
```json
{
  "code": 0,
  "msg": "Audio info extracted successfully",
  "data": {
    "media_type": "audio",
    "duration": 180.5,
    "size": 15728640,
    "format_name": "mp3",
    "codec_name": "mp3",
    "sample_rate": 44100,
    "channels": 2,
    "bit_rate": 320000,
    "channel_layout": "stereo"
  }
}
```

### Download Processed Files
```http
GET /download/{filename}
```

Downloads the processed file (screenshot or converted video).

## Request Parameters

### Processing Options

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `video_url` | string | URL to video file | - |
| `extract_info` | boolean | Extract video metadata | true |
| `take_screenshots` | boolean | Capture screenshots | false |
| `screenshot_timestamps` | array | Specific timestamps for screenshots (seconds) | - |
| `screenshot_count` | integer | Number of evenly spaced screenshots | - |
| `convert_format` | string | Target format (video: mp4, avi, mov, mkv, webm; audio: mp3, wav, flac, aac, ogg, m4a, opus) | - |
| `convert_quality` | string | Conversion quality (low, medium, high) | medium |
| `convert_resolution` | string | Target resolution (720p, 1080p, 1920x1080, etc.) | original |

### File Upload

Alternatively, you can upload files directly using `multipart/form-data`:

#### Video File Upload Example
```bash
curl -X POST http://localhost:8080/process \
  -F "file=@video.mp4" \
  -F "take_screenshots=true" \
  -F "screenshot_count=3" \
  -F "convert_format=mp4" \
  -F "convert_resolution=720p"
```

#### Audio File Upload Example
```bash
curl -X POST http://localhost:8080/process \
  -F "file=@audio.mp3" \
  -F "extract_info=true" \
  -F "convert_format=wav" \
  -F "convert_quality=high"
```

**Supported Audio Formats for Upload:**
- MP3, WAV, FLAC, AAC, OGG, M4A, WMA, Opus
- The service automatically detects audio files and processes them accordingly

## Error Responses

The service returns standardized error responses:

```json
{
  "code": 400,
  "msg": "Error description",
  "data": {}
}
```

**Common Error Codes:**
- `400`: Bad Request (invalid parameters, file too large, unsupported format)
- `404`: Not Found (file or endpoint not found)
- `413`: Payload Too Large (file exceeds 500MB limit)
- `500`: Internal Server Error (processing failed)

## Configuration

All service configurations can be customized via environment variables. This makes it easy to adapt the service for different environments (development, testing, production) without code changes.

### Gunicorn WSGI Server

The service uses Gunicorn as the WSGI server for production deployments, providing better performance and stability compared to Flask's development server.

#### Gunicorn Configuration Options

| Variable | Description | Default | Recommended |
|----------|-------------|---------|-------------|
| `GUNICORN_WORKERS` | Number of worker processes | `4` | `(2 x CPU cores) + 1` |
| `GUNICORN_WORKER_CLASS` | Worker class type | `sync` | `sync` (for CPU-bound tasks) |
| `GUNICORN_TIMEOUT` | Worker timeout in seconds | `120` | `300` (for large files) |
| `GUNICORN_MAX_REQUESTS` | Restart workers after N requests | `1000` | `1000-2000` |
| `GUNICORN_MAX_REQUESTS_JITTER` | Add randomness to max requests | `100` | `100-200` |

#### Worker Configuration Examples

**CPU-Intensive Processing (Default):**
```env
GUNICORN_WORKERS=4
GUNICORN_WORKER_CLASS=sync
GUNICORN_TIMEOUT=120
```

**High-Throughput Processing:**
```env
GUNICORN_WORKERS=8
GUNICORN_WORKER_CLASS=sync
GUNICORN_TIMEOUT=300
GUNICORN_MAX_REQUESTS=2000
```

**Memory-Constrained Environment:**
```env
GUNICORN_WORKERS=2
GUNICORN_WORKER_CLASS=sync
GUNICORN_TIMEOUT=60
GUNICORN_MAX_REQUESTS=500
```

#### Performance Tuning

1. **Worker Count**: Generally `(2 x CPU cores) + 1` for CPU-bound tasks
2. **Worker Class**: Use `sync` for FFmpeg processing (CPU-intensive)
3. **Timeout**: Increase for large file processing (120-300 seconds)
4. **Max Requests**: Restart workers periodically to prevent memory leaks
5. **Jitter**: Add randomness to prevent all workers restarting simultaneously

### Environment Variables

| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `TEMP_DIR` | Temporary files directory | `/tmp/videos` | `/data/temp` |
| `MAX_FILE_SIZE` | Maximum file size in bytes | `524288000` (500MB) | `1073741824` (1GB) |
| `FILE_RETENTION_HOURS` | Hours to keep output files | `2` | `24` |
| `CLEANUP_INTERVAL_MINUTES` | Cleanup task interval | `30` | `60` |
| `ALLOWED_VIDEO_EXTENSIONS` | Comma-separated input formats | `mp4,avi,mov,mkv,flv,wmv,webm,m4v` | `mp4,avi,mov` |
| `SUPPORTED_VIDEO_OUTPUT_FORMATS` | Comma-separated video output formats | `mp4,avi,mov,mkv,webm` | `mp4,webm` |
| `SUPPORTED_AUDIO_OUTPUT_FORMATS` | Comma-separated audio output formats | `mp3,wav,flac,aac,ogg,m4a,opus` | `mp3,wav` |
| `FLASK_HOST` | Flask server host | `0.0.0.0` | `127.0.0.1` |
| `FLASK_PORT` | Flask server port | `8080` | `9000` |
| `FLASK_DEBUG` | Enable debug mode | `false` | `true` |
| `GUNICORN_WORKERS` | Number of Gunicorn worker processes | `4` | `8` |
| `GUNICORN_WORKER_CLASS` | Gunicorn worker class | `sync` | `gevent` |
| `GUNICORN_TIMEOUT` | Worker timeout in seconds | `120` | `300` |
| `GUNICORN_MAX_REQUESTS` | Restart workers after N requests | `1000` | `2000` |
| `GUNICORN_MAX_REQUESTS_JITTER` | Add randomness to max requests | `100` | `200` |
| `API_KEYS` | Comma-separated API keys for authentication | `` (disabled) | `key1,key2,key3` |

### Configuration Examples

#### Development Environment
```env
FLASK_DEBUG=true
MAX_FILE_SIZE=104857600        # 100MB for testing
FILE_RETENTION_HOURS=1         # Quick cleanup
CLEANUP_INTERVAL_MINUTES=10    # Frequent cleanup
```

#### Production Environment
```env
FLASK_DEBUG=false
MAX_FILE_SIZE=2147483648       # 2GB
FILE_RETENTION_HOURS=24        # Keep files longer
CLEANUP_INTERVAL_MINUTES=60    # Less frequent cleanup
ALLOWED_VIDEO_EXTENSIONS=mp4,mov,avi  # Limit formats
```

#### High-Security Environment
```env
MAX_FILE_SIZE=52428800         # 50MB limit
FILE_RETENTION_HOURS=0.5       # 30 minutes retention
CLEANUP_INTERVAL_MINUTES=5     # Very frequent cleanup
SUPPORTED_VIDEO_OUTPUT_FORMATS=mp4   # Only MP4 output
SUPPORTED_AUDIO_OUTPUT_FORMATS=mp3   # Only MP3 output
```

### Supported Formats

**Video Input Formats:**
- MP4, AVI, MOV, MKV, FLV, WMV, WebM, M4V

**Video Output Formats:**
- MP4, AVI, MOV, MKV, WebM

**Audio Input Formats:**
- MP3, WAV, FLAC, AAC, OGG, M4A, WMA, Opus

**Audio Output Formats:**
- MP3, WAV, FLAC, AAC, OGG, M4A, Opus

### Quality Settings

- **Low**: CRF 28 (smaller file size, lower quality)
- **Medium**: CRF 23 (balanced)
- **High**: CRF 18 (larger file size, higher quality)

### Resolution Options

The service supports flexible resolution settings for video conversion:

#### Preset Resolutions
- **240p**: 426x240
- **360p**: 640x360
- **480p**: 854x480
- **720p**: 1280x720 (HD)
- **1080p**: 1920x1080 (Full HD)
- **1440p**: 2560x1440 (2K)
- **2160p** or **4k**: 3840x2160 (4K Ultra HD)

#### Custom Resolutions
- **Width x Height**: `1920x1080`, `1280x720`
- **Width : Height**: `1920:1080`, `1280:720`
- **Single Dimension**: `720` (height, preserves aspect ratio)

#### Examples
```bash
# Preset resolution
"convert_resolution": "720p"

# Custom resolution
"convert_resolution": "1920x1080"

# Preserve aspect ratio with specific height
"convert_resolution": "720"

# Keep original resolution (default)
"convert_resolution": null
```

## Examples

### Extract Video Information
```bash
curl -X POST http://localhost:8080/info \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your_secret_key_here" \
  -d '{"video_url": "https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4"}'
```

### Extract Audio Information
```bash
curl -X POST http://localhost:8080/info \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your_secret_key_here" \
  -d '{"media_url": "https://example.com/audio.mp3"}'
```

### Take 5 Screenshots
```bash
curl -X POST http://localhost:8080/process \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your_secret_key_here" \
  -d '{
    "video_url": "https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4",
    "take_screenshots": true,
    "screenshot_count": 5
  }'
```

### Convert Video to MP4 with Resolution
```bash
curl -X POST http://localhost:8080/process \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your_secret_key_here" \
  -d '{
    "video_url": "https://sample-videos.com/zip/10/avi/SampleVideo_1280x720_1mb.avi",
    "convert_format": "mp4",
    "convert_quality": "high",
    "convert_resolution": "1080p"
  }'
```

### Convert Audio to MP3
```bash
curl -X POST http://localhost:8080/process \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your_secret_key_here" \
  -d '{
    "media_url": "https://example.com/audio.wav",
    "convert_format": "mp3",
    "convert_quality": "high"
  }'
```

### Combined Processing
```bash
curl -X POST http://localhost:8080/process \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your_secret_key_here" \
  -d '{
    "video_url": "https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4",
    "extract_info": true,
    "take_screenshots": true,
    "screenshot_timestamps": [5, 15, 25],
    "convert_format": "webm",
    "convert_quality": "medium",
    "convert_resolution": "720p"
  }'
```

## Performance & Limitations

- **File Size Limit**: Configurable via `MAX_FILE_SIZE` (default: 500MB)
- **Concurrent Processing**: Limited by container resources and available memory
- **Temporary Storage**: Files are automatically cleaned up based on `FILE_RETENTION_HOURS`
- **Timeout**: 30 seconds for URL downloads
- **Memory Usage**: Depends on video size and processing operations
- **Cleanup Frequency**: Configurable via `CLEANUP_INTERVAL_MINUTES`
- **Supported Formats**: Configurable via environment variables


## Troubleshooting

### Common Issues

1. **File Too Large Error**
   - Reduce file size or increase `MAX_FILE_SIZE` environment variable
   - Example: `docker run -e MAX_FILE_SIZE=1073741824 ...` (1GB)

2. **Processing Timeout**
   - Check video file integrity
   - Reduce processing complexity
   - Increase container resources

3. **Download Failed**
   - Verify URL accessibility
   - Check network connectivity
   - Ensure URL points to a video file

4. **Unsupported Format**
   - Add format to `ALLOWED_VIDEO_EXTENSIONS`, `SUPPORTED_VIDEO_OUTPUT_FORMATS`, or `SUPPORTED_AUDIO_OUTPUT_FORMATS`
   - Example: `ALLOWED_VIDEO_EXTENSIONS=mp4,avi,mov,custom_format`
   - Check FFmpeg codec support

5. **Files Not Cleaned Up**
   - Check `FILE_RETENTION_HOURS` and `CLEANUP_INTERVAL_MINUTES` settings
   - Ensure sufficient disk space
   - Verify temp directory permissions

6. **Service Won't Start**
   - Check environment variable syntax (no spaces in comma-separated values)
   - Verify port availability
   - Check container logs for detailed error messages

7. **Configuration Not Applied**
   - Restart container after changing environment variables
   - Verify `.env` file format (no quotes around values)
   - Check environment variable names (case-sensitive)

8. **Invalid Resolution Format**
   - Use supported formats: `720p`, `1080p`, `1920x1080`, `1280:720`
   - Check resolution limits (max: 7680x4320)
   - For aspect ratio preservation, use single dimension: `720`

### Logs

View container logs:
```bash
docker logs ffmpeg-service
```

## Reference

- [FFmpeg Documentation](https://ffmpeg.org/documentation.html)
- [Flask Documentation](https://flask.palletsprojects.com/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)