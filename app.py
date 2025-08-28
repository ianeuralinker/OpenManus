# app.py
import os, shlex, subprocess
from typing import List, Union, Optional

from fastapi import FastAPI, HTTPException, Header
from pydantic import BaseModel

APP = FastAPI(title="OpenManus API", version="0.1.0")

OPENMANUS_DIR = os.getenv("OPENMANUS_DIR", "/app/OpenManus")
API_KEY = os.getenv("API_KEY", "")  # opcional, defina no Coolify p/ proteger

def _run_cli(args: List[str], timeout: int = 600) -> dict:
    try:
        proc = subprocess.run(
            ["python", "main.py", *args],
            cwd=OPENMANUS_DIR,
            capture_output=True,
            text=True,
            timeout=timeout,
        )
        return {
            "returncode": proc.returncode,
            "stdout": proc.stdout,
            "stderr": proc.stderr,
        }
    except subprocess.TimeoutExpired:
        raise HTTPException(status_code=504, detail="Timeout executando o OpenManus.")

def _check_key(x_api_key: Optional[str]):
    if API_KEY and x_api_key != API_KEY:
        raise HTTPException(status_code=401, detail="API key inválida.")

class RunRequest(BaseModel):
    # você pode enviar string ("run --foo bar") ou lista (["run", "--foo", "bar"])
    args: Union[str, List[str]] = "run"

@APP.get("/healthz")
def healthz():
    return {"status": "ok"}

@APP.get("/help")
def help(x_api_key: Optional[str] = Header(None)):
    _check_key(x_api_key)
    return _run_cli(["--help"])

@APP.post("/run")
def run(req: RunRequest, x_api_key: Optional[str] = Header(None)):
    _check_key(x_api_key)
    if isinstance(req.args, str):
        args = shlex.split(req.args)
    else:
        args = req.args
    return _run_cli(args)
