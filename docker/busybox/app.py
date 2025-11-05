import logging

from fastapi import FastAPI, Request
from fastapi.encoders import jsonable_encoder

# Initialize the FastAPI app
app = FastAPI(title="api")

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(levelname)s [logger="%(name)s"] - %(message)s')
logger = logging.getLogger("request_logger")

logger.info("Starting FastAPI app")
@app.middleware("http")
async def middleware(request: Request, call_next):
    try:
        json_body = await request.json()
    except Exception:
        json_body = None
        body = await request.body()
    
    res = await call_next(request)
    logger.info(' | '.join([
        f'Method="{request.method}"',
        f'URL="{request.url}"',
        f'Headers="{jsonable_encoder(request.headers)}"',
        f'JSON_body="{json_body}"' if json_body else f'Body="{body.decode()}"',
    ]))
    return res

@app.api_route("/{full_path:path}", methods=["GET", "POST"])
async def log_json(request: Request, full_path: str):
    return {"status": "OK"}
