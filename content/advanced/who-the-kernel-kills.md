+++
title = "Who the kernel kills: my login died, the 20GB model survived"
date = 2026-11-04
weight = 9
authorship = "human-ai"
+++

My machine ran out of memory three times in one day. Each time, the model that caused it carried on serving, and my login session died. Nothing was misconfigured. That is simply what the defaults do.

If you take one thing from this post: **running out of memory is survivable. The kernel picking the wrong thing to kill is what actually costs you.**

## It did not look like a memory problem

What I saw, in order, was this. Mid-morning, asking my own document search a question returned an error. The log behind it said connection refused on a port. The service listening on that port had died at 07:21, and I found out at 09:02.

No memory warning reached me. Nothing said "out of memory". The visible failure was a refused connection, nearly two hours after the thing that caused it.

> Connection refused, on a service you did not stop, is a memory question. Check whether the thing that manages it is still alive before you start debugging the service itself.

## The scoreboard nobody shows you

The kernel scores every process for how attractive it is to kill. Higher score, killed sooner. I went and read the actual numbers on my box:

| Process | score |
|---|---|
| desktop session processes | 200 |
| `systemd --user` | 100 |
| `llama-server` holding the model | 0 |

Read that from the top. The desktop helpers go first, then the thing that manages all my user services, and only after both of those, if the machine is still short, does it consider the process holding twenty gigabytes.

The model is the most expensive thing on the machine and the kernel prices it as the most precious.

And there is a second-order effect that cost me more than the first. Several of my services run under the user manager, which makes them its children. When `systemd --user` dies, **all of them die with it.** One of mine was using almost no memory at all and got killed anyway, because its parent was cheap.

> A user service has no independent survival. It is exactly as safe as the manager above it, which the kernel prices at 100.

## The setting that made it worse by working correctly

A while back I had stopped the model server from using swap. That was a good decision for a good reason: a model paged out to disk is not slow, it is useless, because every token has to be read back. Denying it swap means an overrun hits a wall straight away rather than crawling for an hour.

It does exactly that. What I had not thought through is the consequence. Those pages are now unevictable. When memory gets tight the kernel's usual move is to push something out to swap, and it cannot. So it kills instead, and it kills by score, which takes us straight back to the table above.

The setting is still right. It just needed the score fixed next to it.

## The guard that was running and could not act

I had a tool installed for exactly this, `earlyoom`, which is supposed to kill something before the kernel has to. It was running throughout all three crashes and did nothing at all. Its configuration:

```
EARLYOOM_ARGS="-m 4 -s 6 -r 3600"
```

Memory below 4 percent **and** swap below 6 percent. Both. Its own help text says so plainly, and I had never read that line.

My box has 47GB of swap that the model server is forbidden from touching, so free swap sat near 100 percent permanently. The second condition could never be true. The tool logged hourly, cheerfully, through three crashes.

Fixing it took two goes, and the second reason is also in the help text. Setting `-s 100` ungated the polite kill but not the forceful one, because the kill threshold defaults to **half** whatever you set. So I had a guard that would warn at 100 percent and act at 50, against 79 percent free. Half of it was still dead and the service reported itself perfectly healthy.

It is `-s 100,100`.

> When a tool takes a setting as `A[,B]` and you only set `A`, go and find out what `B` defaults to. Half a guard that reports success is worse than no guard at all.

## The fix

Make the model the cheapest thing on the box, not the most precious:

```ini
# /etc/systemd/system/ollama.service.d/oom-victim.conf
[Service]
OOMScoreAdjust=500
```

Five hundred beats the session's two hundred, so the model becomes the kernel's first choice instead of its last. The service already restarts automatically, so it is back in seconds. A model dying and reloading is an annoyance. Losing the manager that runs all your services is an outage you discover two hours later.

Child processes inherit the score, which is the part that matters here, because the parent holds almost nothing and the child holds the weights.

{{< fig src="/image/posts/oom-kill-order.svg" class="diagram" alt="Kill order before and after: the 20GB model moves from last to first, above the desktop session and the user service manager." caption="Before, the machine protected the model and threw away everything else. After, the model goes first and comes straight back." >}}

## It worked

That night, for the first time, the guard actually fired:

```
earlyoom: low memory! at or below SIGTERM limits: mem 4.00%, swap 100.00%
earlyoom: sending SIGTERM to "llama-server": badness 1004
earlyoom: process exited after 0.3 seconds
```

It picked the model. Gone in three tenths of a second, restarted automatically. Later the same evening a request ran with free memory down to 4.8GB, the exact condition that had killed my session twice, and nothing died.

One night is not proof. It is the first evidence pointing the right way.

## How this hid from me

**A broken config file looked correct and the service reported healthy.** I wrote the drop-in with `echo -e` inside `sh`, which on Ubuntu is dash, whose `echo` does not understand `-e`. The file began with a literal `-e [Service]`. systemd logged "Assignment outside of section. Ignoring." and started up fine with the setting at zero. Two rounds lost to a file that existed and contained text that looked right. Use `printf`, and verify with `systemctl show` rather than by reading the file back.

**A tool that cannot act looks exactly like a tool with nothing to do.** `earlyoom` logged its memory readings every hour, all of them accurate, none of them revealing that its second condition made it inert.

**From the outside, a dead service and an empty answer are the same error.** The message I saw for "that service was killed" and the message for "it found nothing" were both just a failure in a chat window.

---

You do not need a big machine for this to bite. Any Linux box running something memory-hungry has the same defaults:

- **Find out who the kernel would kill first.** Read `/proc/<pid>/oom_score_adj` for the big process and for `systemd --user`.
- **Make the expensive, restartable thing the first victim.** It is the one that can come back.
- **Remember that user services die with their manager**, however little memory they use.
- **Check your guard can actually fire**, rather than trusting that it is installed.
- **Treat "connection refused" as a possible memory story**, especially hours later.

The crashes were never the problem. Memory ran out, which happens. What cost me the morning was that the machine protected the thing that was eating it and threw away the thing I was using it through.
