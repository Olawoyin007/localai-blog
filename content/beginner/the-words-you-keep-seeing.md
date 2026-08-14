+++
title = "The words you keep seeing, in plain English"
date = 2026-05-24
weight = 9
authorship = "human-ai"
+++

You have seen them. AWQ4. Tokens. Quantization. Words thrown around in forums and on model pages as if everyone already knows what they mean. They can be confusing, and honestly, a little intimidating.

So let's calmly look at them, with the lens of simplicity. That is what this space is for.

None of these are as hard as they look. Here are the ones you will bump into most, grouped so they build on each other. You do not need to memorise anything - read once, come back when a word jumps out, and they slowly stop being scary.

## The model itself

**Model / LLM.** The AI itself. LLM is short for *large language model* - the kind behind a chatbot. You give it words, it gives you words back.

**Weights.** A model's learned knowledge, saved as a huge pile of numbers. When people say "download the weights," they just mean the model file.

**Parameters (the "B").** Those numbers, counted. "7B" means seven billion of them. More usually means smarter, and bigger to store. Think of it like engine size.

**MoE (mixture of experts).** A model split into many small "experts," where only a few do the work on each word. So a big model can think with a light touch. You will see it written like **35B-A3B**: 35 billion in total, but only about 3 billion *active* per word. Big brain, small effort.

## Talking to it

**Token.** A chunk of text, roughly a short word or a piece of one. Models read and write in tokens, not letters. As a rough guide, 100 tokens is about 75 words. When something is measured or limited "per token," this is why.

**Context (or context window).** How much text the model can keep in mind at once, counted in tokens. A bigger context lets it read a longer document or remember more of your chat. It also costs more memory - see the scratchpad below.

**Inference.** A fancy word for "the model answering." When you read that a model is "running inference," it is just thinking up a reply.

**KV cache.** The model's scratchpad for the conversation you are having right now. It grows with the context. This is the quiet reason a *small* model can still use a lot of memory: give it a big context, and the scratchpad gets big.

## Making it smaller

Almost every model you run at home has been shrunk to fit. These words are all about how.

**Quantization.** Shrinking a model by storing its numbers with less fine detail, so it takes less memory and runs faster. You trade a little quality for a lot of space - usually a great deal.

**Bits (4-bit, 8-bit).** How much detail each number keeps. 8-bit keeps more (bigger, a touch better). 4-bit keeps less (smaller, faster, and still very good). 4-bit is the common sweet spot.

**AWQ, NVFP4, GGUF.** Just different recipes for that shrinking. AWQ and NVFP4 are 4-bit methods - NVFP4 is a newer one built for recent NVIDIA chips. GGUF is the file format the easy tools (like Ollama) use. The name mostly tells you which tool and which chip it suits.

**Q4, Q6, Q8.** The shrink levels you see inside GGUF files. The number is the bits: Q4 is 4-bit (small), Q8 is 8-bit (larger, closest to the original). Q4 is the usual place to start.

**"AWQ4"** - now you can read it yourself. It just means AWQ, at 4-bit. The wall was never that tall.

## Where it runs

**CPU / GPU.** The CPU is your computer's general brain. The GPU (the graphics card) is a specialist that is much faster at the maths models need. Models run on either - a GPU is faster, a CPU is perfectly fine to start.

**RAM / VRAM.** Both are memory. RAM is your computer's main memory; VRAM is the graphics card's own, faster memory. A model has to fit in whichever one it runs on.

**Local vs cloud.** Local means the model runs on *your* machine. Cloud means it runs on someone else's servers, far away. This whole site is about local.

## That is most of the wall gone

You do not need all of these at once. Each one clicks into place the first time you actually run a model and see it for yourself. Keep this page handy, come back when a new word jumps out at you, and remember the rule this whole site runs on: calm beats clever, every time.
