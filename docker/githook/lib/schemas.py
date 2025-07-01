from pydantic import BaseModel 
from typing import Dict
class Item(BaseModel):
    file: str
    data: Dict[str, str]