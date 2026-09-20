+++
title = "The harness: the program that actually runs the model"
date = 2026-09-20
weight = 12
authorship = "human-ai"
+++

People say "the model did it." But a model, on its own, can't do much of anything. It takes in some text and gives back the text most likely to follow - once - and then it forgets you were ever there. Whatever actually did the thing (kept the conversation, ran the command, tried again after a mistake) was a program wrapped around the model. That program is the harness, and it does far more of the work than most people give it credit for.

## What a model does on its own - less than you'd think

A model is a text predictor. Text in, likely next text out, and that's the whole trick. It has no memory of the last message. It can't open a file, run a command, or check today's date. It can't even decide to answer a second time. One input, one output, finished. Everything past that point is somebody else's job.

## The harness is that somebody

The harness is the program sitting around the model, doing all the parts the model can't. It has three jobs, really:

- It **holds the conversation**, and picks what slice of it to show the model each turn. The model only ever sees what the harness hands it.
- It **reads the reply**, and when the model writes "run this command," the harness is the thing that actually runs it, then pastes the result back in for the model to read.
- It **runs the loop**: model speaks, harness acts, harness feeds the result back, model speaks again, round and round until the work is done.

Picture a brilliant person with no hands and no short-term memory. They can think and talk, and nothing else. The harness is the assistant sitting next to them - keeping the notes, doing what they ask, handing them what they need, then asking the next question. Take the assistant away and the genius says one clever thing and forgets you exist.

## Same model, different harness, different tool

This is the part that catches people out. Drop the very same model into two different harnesses and it behaves like two different tools.

A bare chat box gives you a model that can only talk back. Put that identical model inside Claude Code or [Goose]({{< relref "goose-an-honest-local-agent" >}}) and it suddenly reads your files, runs your tests, fixes a bug, and checks its own work. The model didn't get smarter between the two. The harness gave it hands and a loop. So when an "agent" impresses you, or does something daft, a large share of the credit - or the blame - belongs to the harness, not the brain inside it.

When you run a local model, something is always playing this role. Ollama's chat is a light harness: a conversation and not much more. Goose is a heavy one: real tools, a real loop, the works. The model file on your disk is exactly the same in both. What it can *do* is set by the harness you run it in.

## Where it sits with the rest

I wrote before about [three jobs people keep mixing up]({{< relref "gateway-mcp-evals-three-jobs" >}}): the gateway picks which model answers, MCP gives the model tools, and evals tell you whether the answer was any good. The harness is the thing standing in the middle of all three. It calls the gateway to get a model, plugs the MCP tools in, runs the loop, and produces the answers your evals then grade. Those three are the parts. The harness is what holds them and turns the handle.

So here's the honest reframing. The model is the engine; the harness is the whole car around it. An engine on a workbench revs beautifully and goes nowhere. Next time something clever happens and you're about to say "the model did that," remember there was a plain program holding the wheel the whole time.
