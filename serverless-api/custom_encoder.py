import json
from decimal import Decimal

# https://docs.python.org/3/library/json.html
# Encoder needs to be extended to support Decimal type
class DecimalEncoder(json.JSONEncoder):
  def default(self, obj):
    if isinstance(obj, Decimal):
      return str(obj)
    return json.JSONEncoder.default(self, obj)
