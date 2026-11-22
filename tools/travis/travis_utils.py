import asyncio

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
async def run_with_timeout_guards(args):
    target_process = await asyncio.create_subprocess_exec(*args, stderr=asyncio.subprocess.STDOUT)
    task = ensure_future(print_timeout_guards())

    ret = await target_process.wait()
    task.cancel()
    return ret

async def print_timeout_guards():
    while True:
        await asyncio.sleep(8*60)
        print("Keeping Travis alive. Ignore this!")

# Runs the given command to completion and returns its exit code.
# asyncio.run picks an event loop that can manage subprocesses on every platform.
def run_command(args):
    return asyncio.run(run_with_timeout_guards(args))
