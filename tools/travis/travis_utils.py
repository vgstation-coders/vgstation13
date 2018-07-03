import asyncio
import sys

ensure_future = None

# ensure_future is new in 3.4.4, previously it was asyncio.async.
try:
    ensure_future = asyncio.ensure_future
except AttributeError:
    # Can't directly do asyncio.async because async is a keyword now,
    # and that'd parse error on newer versions.
    ensure_future = getattr(asyncio, "async")

# DM SOMEHOW manages to go 10 minutes without logging anything nowadays.
# So... Travis kills it.
# Thanks DM.
# This repeats messages like travis_wait (which I couldn't get working) does to prevent that.
@asyncio.coroutine
def run_with_timeout_guards(args):
    target_process = yield from asyncio.create_subprocess_exec(*args, stderr=asyncio.subprocess.STDOUT)
    task = ensure_future(print_timeout_guards())

    ret = yield from target_process.wait()
    task.cancel()
    return ret

@asyncio.coroutine
def print_timeout_guards():
    while True:
        yield from asyncio.sleep(8*60)
        print("Keeping Travis alive. Ignore this!")

# Windows needs a different event loop to manage subprocesses
def get_platform_event_loop():
    if sys.platform == "win32" or sys.platform == "cygwin":
        loop = asyncio.ProactorEventLoop()
        asyncio.set_event_loop(loop)
        return loop
    else:
        return asyncio.get_event_loop()
