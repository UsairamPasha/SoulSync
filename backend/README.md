# SoulSync Django Backend API Platform

Enterprise-grade Django REST API backend built for SoulSync.

## Setup Instructions

1. Navigate to `backend/` directory.
2. Create and activate a virtual environment:
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   ```
3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
4. Run migrations:
   ```bash
   python manage.py makemigrations
   python manage.py migrate
   ```
5. Start development server:
   ```bash
   python manage.py runserver
   ```
6. Access Swagger API documentation:
   - `http://127.0.0.1:8000/api/docs/`
