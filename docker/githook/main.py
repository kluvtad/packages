import logging
from typing import Annotated
import time

from fastapi import FastAPI, Request, Depends, Header, status, HTTPException
from fastapi.responses import JSONResponse
from fastapi.routing import APIRouter
from uvicorn.protocols.utils import get_client_addr, get_path_with_query_string

from lib.schemas import *
from lib.components import *

app = FastAPI()
git_client = GIT_CLIENT()

log_level= logging.getLevelName(os.getenv("LOG_LEVEL", logging.INFO))
logging.getLogger('uvicorn.access').setLevel(log_level)

custom_logger = logging.getLogger('uvicorn.custom')
custom_logger.setLevel(logging.WARN)

GITHOOK_TOKEN=os.getenv("GITHOOK_TOKEN")

@app.exception_handler(HTTPException)
async def http_exception_handler(req: Request, exc: HTTPException):
  req_body = await req.json()
  custom_logger.warning(f'%s - "%s %s HTTP/%s" %d - %s - %s - %s', 
                get_client_addr(req.scope), 
                req.method,
                get_path_with_query_string(req.scope),
                req.scope["http_version"],
                exc.status_code,
                exc.headers, 
                exc.detail, 
                req_body)
  return JSONResponse({"detail": exc.detail}, exc.status_code)

@app.get("/health")
def health():
  try:
    body = git_client.status()
  except subprocess.CalledProcessError as e: 
    raise HTTPException(
      status_code= status.HTTP_503_SERVICE_UNAVAILABLE,
      detail= e.stderr
    )
  msg = "OK!"
  status_code = status.HTTP_200_OK

  for f in body["dirty_files"]: 
    file_status, _ = f.split(" ")
    if file_status == "AA":
      msg = "Repo is conflicted!"
      status_code= status.HTTP_409_CONFLICT
  
  return JSONResponse({
    "status": body,
    "message": msg
  }, status_code)

def verify_token(token: Annotated[str, Header(alias="githook-token")]):
  if token != GITHOOK_TOKEN:
    raise HTTPException(
      status_code=status.HTTP_401_UNAUTHORIZED, 
      detail='Token is invalid',
      headers={
        "githook-token": token
      }
    )
  
def update_repo():
  try:
    git_client.pull()
    git_client.merge('origin/main')
  except subprocess.CalledProcessError as e: 
    raise HTTPException(
      status_code= status.HTTP_503_SERVICE_UNAVAILABLE,
      detail= e.stderr.decode() if type(e.stderr) is bytes else e.stderr
    )
  
@app.post("/yaml", dependencies=[Depends(verify_token), Depends(update_repo)])
def yaml(req: Item):
  with git_client.thread_lock:
    try:
      for key, val in req.data.items():
        git_client.edit_yaml(
          file= req.file,
          key= key,
          value= val
        )
      git_client.commit(
        f"CI[{git_client.branch}]: {req.file}", 
        descriptions= [f"+ '{key}'='{val}'" for key, val in req.data.items()], 
        locked= True
      )
      git_client.push()
    except subprocess.CalledProcessError as e: 
      git_client.reset_hard(f"origin/{git_client.branch}", locked= True)
      raise HTTPException(
        status_code= status.HTTP_500_INTERNAL_SERVER_ERROR,
        detail= e.stderr.decode() if type(e.stderr) is bytes else e.stderr
      )
