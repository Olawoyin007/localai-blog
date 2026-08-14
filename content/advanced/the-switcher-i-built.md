+++
title = "The switcher I built: a seatbelt for one shared box"
date = 2026-06-28
weight = 10
authorship = "human-ai"
+++

In [a recent post]({{< relref "one-machine-two-engines" >}}) I shared how my whole machine hard-rebooted because two model engines reached into the same memory at once. I ended it by mentioning a small script I wrote the day after - a seatbelt. This is me taking that script apart.

First, what it even is. **vLLM** - the heavier of my two model engines - only runs one model at a time. So when I want a different model, I run a small script that stops the one that is loaded and starts the next. That script is the switcher. Swapping models sounds harmless, but on a machine where everything shares one pool of memory, it is the most dangerous thing I do routinely - which is exactly why the script grew the shape it did.

It has one job: **never let loading a model crash the box.** It is not clever. It is a checklist I no longer trust myself to run by hand. You do not need my script or my machine - the *shape* works on any computer where memory is tight. Steal the shape.

## 1. Only ever one model at a time

vLLM grabs its entire memory budget the moment it starts. So the rule is simple: before starting a new model, get rid of the old one.

```bash
# Only ever one model. Remove the old container, then start the new one.
docker rm -f vllm 2>/dev/null || true
sleep 3   # let the old model's memory actually free before we measure

docker run -d --name vllm --gpus all -p 8000:8000 \
    "$IMAGE" "${REPO[$KEY]}" \
    --served-model-name "${NAME[$KEY]}" \
    --gpu-memory-utilization "${UTIL[$KEY]}" \
    --max-model-len "${CTX[$KEY]}"
```

That `sleep 3` looks silly, but it earned its place: memory does not free the instant the old container dies, and if I measured too soon I would read a number that was about to change.

## 2. Give each model its own budget

`--gpu-memory-utilization` is the fraction of the machine's memory a model is allowed to claim. I set it per model, by hand, so each one gets just what it needs - its weights plus room to think, nothing more.

```bash
# Fraction of the box's 119GB each model may claim (weights + room to think).
declare -A UTIL=(
    [glm-flash]="0.30"     # ~36GB - a small daily driver
    [qwen3.5-35b]="0.35"   # ~42GB
    [qwen3.5-122b]="0.75"  # ~89GB - the flagship
)
```

The flagship gets a big slice, the small models get small ones. This one table is most of the memory planning for the whole box.

## 3. The seatbelt: check before you load

This is the heart of it, and the part that came straight out of the crash. Before launching anything, work out how much the model will need, look at how much is actually free, and **refuse to load if it will not fit with room to spare.**

```bash
# Short on memory = kernel OOM = the whole box hard-reboots. So: check first.
NEED_GB=$(awk "BEGIN{printf \"%d\", ${UTIL[$KEY]} * 119}")
AVAIL_GB=$(awk '/MemAvailable/{printf "%d", $2/1048576}' /proc/meminfo)

if (( AVAIL_GB < NEED_GB + 5 )); then
    echo "FATAL: need ~${NEED_GB}G + 5G headroom; only ${AVAIL_GB}G free."
    echo "vLLM grabs its whole budget up front - launching would OOM the kernel."
    exit 1   # refuse, on purpose
fi
```

That `+ 5` is the headroom - the little cushion that keeps a tight fit from becoming a crash. And the `exit 1` is the whole point: it is a script that says *no*. A failed model is an annoyance. A rebooted box is a disaster. This turns the second into the first.

## 4. Mind the roommate

My other engine, Ollama, lives in the same memory. It can be holding a model I forgot about - exactly what bit me. So before loading, the script simply asks it, out loud:

```bash
# Ollama models live in the same memory pool. Surface them before we load.
RESIDENT=$(ollama ps 2>/dev/null | tail -n +2)
if [[ -n "$RESIDENT" ]]; then
    echo "WARNING: ollama is still holding a model (same memory pool):"
    echo "$RESIDENT"
fi
```

There is one more subtlety I learned the hard way: even "free" memory has a twist. A big file copy - like downloading a model - fills a hidden cache that vLLM counts against you, so a load can fail even when the free number looked fine. The script checks that stricter number too and tells me how to clear the cache if it bites.

## 5. Tell the truth when it fails

The old version just launched and left me staring at a blinking cursor, wondering. Now it waits for the load and reports the real outcome - and if it failed, it digs the actual error out of the logs instead of making me go find it.

```bash
# Wait, then tell the truth: READY, or FAILED with the real reason.
if [[ "$(docker inspect -f '{{.State.Running}}' vllm)" != "true" ]]; then
    echo "FAILED. Root cause:"
    docker logs vllm 2>&1 | grep -oE '(ValueError|KeyError|RuntimeError): .*' | tail -3
    exit 1
fi
```

A small kindness to future-me, who is always tired and always in a hurry.

One last quiet choice: after a reboot, the script loads **nothing** automatically. If a bad model could restart the box, and the box then reloaded that same bad model, I would have a machine stuck in a reboot loop. Starting empty means a crash can never repeat itself on its own.

## What this means for you

You do not need Docker, or vLLM, or a big box. The shape is what travels:

- **One heavy thing at a time.** Clear the old before you start the new.
- **Give it a budget** and write that budget down, per model.
- **Check before you load, and refuse if it will not fit.** A script that says no is worth more than one that tries its best.
- **Leave headroom.** The last little cushion is what keeps a mistake from becoming a disaster.
- **Make failures legible.** Print the real error. Your tired future self will thank you.

The whole thing is about a hundred lines of plain shell. It is not impressive. But it was the difference between a machine I was afraid to touch and one I trust. Write the seatbelt before you need it, not the day after - though the day after works too. I would know.
