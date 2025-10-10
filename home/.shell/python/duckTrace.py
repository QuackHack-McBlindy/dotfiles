import subprocess
import shlex

def _dt(level: str, message: str):
    cmd = f'dt_{level} {shlex.quote(message)}'
    subprocess.call(cmd, shell=True)

def dt_debug(msg):    _dt("debug", msg)
def dt_info(msg):     _dt("info", msg)
def dt_warning(msg):  _dt("warning", msg)
def dt_error(msg):    _dt("error", msg)
def dt_critical(msg): _dt("critical", msg)

dt_debug("duckTrace loggiong loaded. quack quack")
