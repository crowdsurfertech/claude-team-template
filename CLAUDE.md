
## Session Timeout & Keep-Alive

**Default session timeout is 60 minutes.** A background heartbeat daemon extends this
automatically while the Claude process is alive, but you should still call `keep-alive`
explicitly when spawning background processes that outlive Claude turns.

```bash
keep-alive <seconds>   # extend the deadline by N more seconds from now
```

Call `keep-alive` BEFORE starting any background process that may take more than 10 minutes,
and again at each checkpoint. Example: `keep-alive 21600` before a multi-hour training sweep.

## Critical: Never Write Blocking Shell Loops

**The most common failure mode** is a single Bash call that contains a `while` loop running
for many minutes. This completely blocks your context — you cannot call any other tools,
cannot send Slack updates, and the orchestrator sees no output and eventually times out.

**WRONG — do not do this:**
```bash
while kill -0 $PID 2>/dev/null; do
    sleep 60
    tail -5 "$LOG"
done
```

**RIGHT — check once per Claude turn:**
```bash
sleep 60
if kill -0 $PID 2>/dev/null; then
    tail -5 "$LOG"
    echo "STILL_RUNNING: check again in next turn"
else
    echo "DONE"
fi
```
Then read the output and issue another Bash call for the next check. Multiple short Bash
calls are far better than one long loop.

**Maximum recommended blocking time per Bash call: 5 minutes (sleep 300).**

## Python Output Buffering

When running Python in a pipe (`python | tee log`), output is buffered by default and
may not appear in the log for a long time. Always use:

```bash
PYTHONUNBUFFERED=1 python -m mymodule ... 2>&1 | tee log
```
or add `-u` flag: `python -u -m mymodule ...`

Without this, your log will appear empty even while training runs fine.

## Slack Communication

You have a direct Slack posting tool available in this environment:

```bash
slack-post "your message here"
```

Environment variables already set: `SLACK_BOT_TOKEN`, `SLACK_CHANNEL`, `SLACK_THREAD_TS`.

**Use this for:**
- Progress updates from long-running tasks
- Results from background processes spawned with `&`
- Any message you want to send mid-task without waiting for your turn to end

Background processes you spawn can also call `slack-post` directly — the env vars are inherited.

## Saving Artifacts

To save output files (reports, generated code, data files, etc.) so they persist after the task:

```bash
save-artifact <path/to/file>
save-artifact <path/to/file> "custom-name.ext"   # optional custom name
```

This uploads the file to S3 and prints the S3 URI. **Include any returned URIs in your final
response** so they appear in the Slack thread for easy retrieval.

Environment variables already set: `ARTIFACTS_BUCKET`, `ARTIFACTS_PREFIX`.
