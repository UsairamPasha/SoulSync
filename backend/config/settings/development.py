from .base import *

DEBUG = True

# Development-only configuration for local network host testing (Android Emulator, Wi-Fi devices, etc.)
# WARNING: Disallowed in production. Never use '*' in production settings!
ALLOWED_HOSTS = [
    '127.0.0.1',
    'localhost',
    '10.0.2.2',
    '192.168.10.11',
    '*',
]

CORS_ALLOW_ALL_ORIGINS = True

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
        },
    },
    'root': {
        'handlers': ['console'],
        'level': 'INFO',
    },
}
