from rest_framework.renderers import JSONRenderer

class StandardJSONRenderer(JSONRenderer):
    """
    Standardizes DRF JSON responses to match Flutter's expected ApiResponse<T> format:
    {
      "success": true,
      "message": "...",
      "data": { ... },
      "meta": null
    }
    """
    def render(self, data, accepted_media_type=None, renderer_context=None):
        response = renderer_context.get('response') if renderer_context else None
        status_code = response.status_code if response else 200

        # If data is already formatted by custom exception handler or contains success flag
        if isinstance(data, dict) and 'success' in data:
            return super().render(data, accepted_media_type, renderer_context)

        is_success = status_code < 400
        message = 'Request completed successfully' if is_success else 'An error occurred'

        custom_data = {
            'success': is_success,
            'message': message,
            'data': data if is_success else None,
            'errors': data if not is_success else None,
        }

        return super().render(custom_data, accepted_media_type, renderer_context)
