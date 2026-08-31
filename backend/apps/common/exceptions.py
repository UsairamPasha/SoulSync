from rest_framework.views import exception_handler
from rest_framework.response import Response
from rest_framework import status

def custom_exception_handler(exc, context):
    response = exception_handler(exc, context)

    if response is not None:
        message = 'Validation or processing error occurred.'
        if isinstance(response.data, dict):
            if 'detail' in response.data:
                message = str(response.data['detail'])
            elif response.data:
                # Use first error message if available
                first_key = next(iter(response.data))
                first_val = response.data[first_key]
                if isinstance(first_val, list) and first_val:
                    message = f"{first_key}: {first_val[0]}"
                else:
                    message = f"{first_key}: {first_val}"

        response.data = {
            'success': False,
            'message': message,
            'errors': response.data,
        }

    return response
