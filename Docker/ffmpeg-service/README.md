# FFmpeg Video Processing Service

[![Docker Tags](https://img.shields.io/docker/v/funnyzak/ffmpeg-service?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/ffmpeg-service/)
[![Image Size](https://img.shields.io/docker/image-size/funnyzak/ffmpeg-service)](https://hub.docker.com/r/funnyzak/ffmpeg-service/)
[![Docker Stars](https://img.shields.io/docker/stars/funnyzak/ffmpeg-service.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/ffmpeg-service/)
[![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/ffmpeg-service.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/ffmpeg-service/)

A lightweight, containerized FFmpeg video processing microservice built with Flask and Python. This service provides HTTP API endpoints for video metadata extraction, screenshot capture, and format conversion.

Build with the `linux/arm64`, `linux/386`, `linux/amd64`, `linux/arm/v6`, `linux/arm/v7`, `linux/arm64/v8` architectures.

## Features

- **Video Information Extraction**: Get detailed metadata including duration, codec, resolution, bitrate, etc.
- **Screenshot Capture**: Extract frames at specific timestamps or evenly spaced intervals
- **Format Conversion**: Convert videos between popular formats (MP4, AVI, MOV, MKV, WebM)
- **Batch Processing**: Combine multiple operations in a single API call
- **URL & File Upload Support**: Process videos from URLs or direct file uploads
- **Automatic Cleanup**: Temporary files are automatically deleted after processing
- **Health Monitoring**: Built-in health check endpoint
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
      - SUPPORTED_OUTPUT_FORMATS=mp4,avi,mov,mkv,webm
      
      # Flask server settings
      - FLASK_HOST=0.0.0.0
      - FLASK_PORT=8080
      - FLASK_DEBUG=false
    ports:
      - "${HOST_PORT:-8080}:${FLASK_PORT:-8080}"
    restart: on-failure
    volumes:
      - ${TEMP_VOLUME:-./temp}:${TEMP_DIR:-/tmp/videos}
```

#### Using Environment File

Create a `.env` file for easier configuration management:

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

### Video Processing (Combined Operations)
```http
POST /process
Content-Type: application/json
```

**Request Body:**
```json
{
  "video_url": "https://example.com/video.mp4",
  "extract_info": true,
  "take_screenshots": true,
  "screenshot_count": 5,
  "convert_format": "mp4",
  "convert_quality": "medium"
}
```

Or upload a file:
```http
POST /process
Content-Type: multipart/form-data

file: [video file]
extract_info: true
take_screenshots: true
screenshot_timestamps: [10, 30, 60]
```

**Response:**
```json
{
  "code": 0,
  "msg": "Processing completed successfully",
  "data": {
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
      "url": "/download/converted_def456.mp4"
    }
  }
}
```

### Video Information Only
```http
POST /info
Content-Type: application/json
```

**Request Body:**
```json
{
  "video_url": "https://example.com/video.mp4"
}
```

**Response:**
```json
{
  "code": 0,
  "msg": "Video info extracted successfully",
  "data": {
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
| `convert_format` | string | Target format (mp4, avi, mov, mkv, webm) | - |
| `convert_quality` | string | Conversion quality (low, medium, high) | medium |

### File Upload

Alternatively, you can upload files directly using `multipart/form-data`:

```bash
curl -X POST http://localhost:8080/process \
  -F "file=@video.mp4" \
  -F "take_screenshots=true" \
  -F "screenshot_count=3"
```

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

### Environment Variables

| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `TEMP_DIR` | Temporary files directory | `/tmp/videos` | `/data/temp` |
| `MAX_FILE_SIZE` | Maximum file size in bytes | `524288000` (500MB) | `1073741824` (1GB) |
| `FILE_RETENTION_HOURS` | Hours to keep output files | `2` | `24` |
| `CLEANUP_INTERVAL_MINUTES` | Cleanup task interval | `30` | `60` |
| `ALLOWED_VIDEO_EXTENSIONS` | Comma-separated input formats | `mp4,avi,mov,mkv,flv,wmv,webm,m4v` | `mp4,avi,mov` |
| `SUPPORTED_OUTPUT_FORMATS` | Comma-separated output formats | `mp4,avi,mov,mkv,webm` | `mp4,webm` |
| `FLASK_HOST` | Flask server host | `0.0.0.0` | `127.0.0.1` |
| `FLASK_PORT` | Flask server port | `8080` | `9000` |
| `FLASK_DEBUG` | Enable debug mode | `false` | `true` |

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
SUPPORTED_OUTPUT_FORMATS=mp4   # Only MP4 output
```

### Supported Formats

**Input Formats:**
- MP4, AVI, MOV, MKV, FLV, WMV, WebM, M4V

**Output Formats:**
- MP4, AVI, MOV, MKV, WebM

### Quality Settings

- **Low**: CRF 28 (smaller file size, lower quality)
- **Medium**: CRF 23 (balanced)
- **High**: CRF 18 (larger file size, higher quality)

## Examples

### Extract Video Information
```bash
curl -X POST http://localhost:8080/info \
  -H "Content-Type: application/json" \
  -d '{"video_url": "https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4"}'
```

### Take 5 Screenshots
```bash
curl -X POST http://localhost:8080/process \
  -H "Content-Type: application/json" \
  -d '{
    "video_url": "https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4",
    "take_screenshots": true,
    "screenshot_count": 5
  }'
```

### Convert to MP4
```bash
curl -X POST http://localhost:8080/process \
  -H "Content-Type: application/json" \
  -d '{
    "video_url": "https://sample-videos.com/zip/10/avi/SampleVideo_1280x720_1mb.avi",
    "convert_format": "mp4",
    "convert_quality": "high"
  }'
```

### Combined Processing
```bash
curl -X POST http://localhost:8080/process \
  -H "Content-Type: application/json" \
  -d '{
    "video_url": "https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4",
    "extract_info": true,
    "take_screenshots": true,
    "screenshot_timestamps": [5, 15, 25],
    "convert_format": "webm",
    "convert_quality": "medium"
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

## Security Considerations

- Files are processed in isolated temporary directories
- Automatic cleanup prevents disk space issues
- Input validation for file types and sizes
- No persistent storage of user files
- Resource limits prevent abuse

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
   - Add format to `ALLOWED_VIDEO_EXTENSIONS` or `SUPPORTED_OUTPUT_FORMATS`
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

### Environment Variable Best Practices

1. **Format Lists Correctly**
   ```env
   # ✅ Correct: No spaces around commas
   ALLOWED_VIDEO_EXTENSIONS=mp4,avi,mov,mkv
   
   # ❌ Wrong: Spaces around commas
   ALLOWED_VIDEO_EXTENSIONS=mp4, avi, mov, mkv
   ```

2. **Use Appropriate Values**
   ```env
   # File sizes in bytes
   MAX_FILE_SIZE=1073741824  # 1GB
   
   # Boolean values
   FLASK_DEBUG=true  # or false, 1, 0, yes, no
   
   # Time values
   FILE_RETENTION_HOURS=24    # Integer or decimal
   ```

3. **Environment-Specific Configuration**
   ```bash
   # Development
   cp .env.development .env
   
   # Production  
   cp .env.production .env
   ```

### Complete .env File Example

Create a `.env` file with the following template:

```env
# FFmpeg Service Environment Configuration
# Copy and modify as needed for your environment

# System settings
TZ=Asia/Shanghai

# Application configuration
TEMP_DIR=/tmp/videos
MAX_FILE_SIZE=524288000              # 500MB in bytes (customize as needed)
FILE_RETENTION_HOURS=2               # Keep output files for 2 hours  
CLEANUP_INTERVAL_MINUTES=30          # Run cleanup every 30 minutes

# Supported formats (comma-separated, no spaces around commas)
ALLOWED_VIDEO_EXTENSIONS=mp4,avi,mov,mkv,flv,wmv,webm,m4v
SUPPORTED_OUTPUT_FORMATS=mp4,avi,mov,mkv,webm

# Flask server settings
FLASK_HOST=0.0.0.0
FLASK_PORT=8080
FLASK_DEBUG=false

# Docker Compose specific variables
HOST_PORT=8080                       # Host port to expose the service
TEMP_VOLUME=./temp                   # Host directory for temp files

# Example configurations for different environments:

# Production (high capacity)
# MAX_FILE_SIZE=2147483648           # 2GB
# FILE_RETENTION_HOURS=24            # Keep files for 24 hours
# CLEANUP_INTERVAL_MINUTES=60        # Cleanup every hour

# Development
# FLASK_DEBUG=true
# FILE_RETENTION_HOURS=1             # Keep files for 1 hour for quick testing
# CLEANUP_INTERVAL_MINUTES=10        # More frequent cleanup

# Testing
# MAX_FILE_SIZE=104857600            # 100MB for testing
# FILE_RETENTION_HOURS=0.5           # Keep files for 30 minutes only
```

### Logs

View container logs:
```bash
docker logs ffmpeg-service
```

## Reference

- [FFmpeg Documentation](https://ffmpeg.org/documentation.html)
- [Flask Documentation](https://flask.palletsprojects.com/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)